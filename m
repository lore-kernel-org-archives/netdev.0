From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 net-next 1/2] ip_tunnel: Create percpu gro_cell
Date: Wed, 14 Jan 2015 16:14:10 -0800
Message-ID: <1421280850.11734.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
	 <1421192564-437455-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:60808 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbbAOAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 19:14:13 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so12085556iec.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 16:14:12 -0800 (PST)
In-Reply-To: <1421192564-437455-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-13 at 15:42 -0800, Martin KaFai Lau wrote:
> In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
> All skb will be queued to the same cell->napi_skbs.  The
> gro_cell_poll is pinned to one core under load.  In production traffic,
> we also see severe rx_dropped in the tunl iface and it is probably due to
> this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog.
> 
> This patch is trying to alloc_percpu(struct gro_cell) and schedule
> gro_cell_poll to process the skb in the same core.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
