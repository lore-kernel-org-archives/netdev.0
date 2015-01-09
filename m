From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] ip_tunnel: create percpu gro_cell
Date: Fri, 09 Jan 2015 14:57:44 -0800
Message-ID: <1420844264.5947.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420828933-844290-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:54146 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbbAIW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 17:57:47 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so4191473igi.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 14:57:46 -0800 (PST)
In-Reply-To: <1420828933-844290-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-09 at 10:42 -0800, Martin KaFai Lau wrote:
> In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
> All skb will be queued to the same cell->napi_skbs.  The
> gro_cell_poll is pinned to one core under load. In production traffic,
> we also see severe rx_dropped in the tunl iface and it is probably due to
> this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog
> 
> This patch is trying to alloc_percpu(struct gro_cell) and schedule
> gro_cell_poll to process it in the same core.


I wrote a similar patch here at Google, but I removed the
____cacheline_aligned_in_smp attribute on struct gro_cell

It was needed because of kcalloc(), but with alloc_percpu(), no gain
adding a padding.
