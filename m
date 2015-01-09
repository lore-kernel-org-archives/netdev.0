From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] ip_tunnel: create percpu gro_cell
Date: Fri, 9 Jan 2015 15:17:03 -0800
Message-ID: <20150109231703.GF3842288@devbig242.prn2.facebook.com>
References: <1420828933-844290-1-git-send-email-kafai@fb.com>
 <1420844264.5947.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58640 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758211AbbAIXRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 18:17:09 -0500
Content-Disposition: inline
In-Reply-To: <1420844264.5947.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 02:57:44PM -0800, Eric Dumazet wrote:
> On Fri, 2015-01-09 at 10:42 -0800, Martin KaFai Lau wrote:
> > In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
> > All skb will be queued to the same cell->napi_skbs.  The
> > gro_cell_poll is pinned to one core under load. In production traffic,
> > we also see severe rx_dropped in the tunl iface and it is probably due to
> > this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog
> > 
> > This patch is trying to alloc_percpu(struct gro_cell) and schedule
> > gro_cell_poll to process it in the same core.
> 
> 
> I wrote a similar patch here at Google,  but I removed the
> ____cacheline_aligned_in_smp attribute on struct gro_cell
> 
> It was needed because of kcalloc(), but with alloc_percpu(), no gain
> adding a padding.
Is the spin_lock() still needed?

Thanks,
--Martin
