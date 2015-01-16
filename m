From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] ip_tunnel: Create percpu gro_cell
Date: Fri, 16 Jan 2015 11:38:33 -0800
Message-ID: <1421437113.11734.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421431860-1960597-1-git-send-email-kafai@fb.com>
	 <1421431860-1960597-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:48639 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbAPTif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:38:35 -0500
Received: by mail-ie0-f178.google.com with SMTP id vy18so22475181iec.9
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 11:38:34 -0800 (PST)
In-Reply-To: <1421431860-1960597-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 10:11 -0800, Martin KaFai Lau wrote:
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
>  include/net/gro_cells.h | 29 ++++++++++++-----------------
>  1 file changed, 12 insertions(+), 17 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
