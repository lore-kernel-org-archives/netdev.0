From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path init
Date: Fri, 16 Jul 2010 09:30:19 +0200
Message-ID: <20100716093019.2a15b0f9@dhcp-lab-109.englab.brq.redhat.com>
References: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
	<5AD9FE05-1F9B-44DE-8CC4-4D63F43E79C8@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935639Ab0GPHa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 03:30:29 -0400
In-Reply-To: <5AD9FE05-1F9B-44DE-8CC4-4D63F43E79C8@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jul 2010 11:57:59 -0700
Mitchell Erblich <erblichs@earthlink.net> wrote:

> > @@ -3039,7 +3039,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
> > 			rx_pg->page = NULL;
> > 
> > 			err = bnx2_alloc_rx_page(bp, rxr,
> > -						 RX_PG_RING_IDX(pg_prod));
> > +						 RX_PG_RING_IDX(pg_prod),
> > +	
> 
> > 					 GFP_ATOMIC);
> 
> Why not GFP_NOWAIT here?
> This would then not use the last reserved pages of memory.
> This still would remove the possibe sleep asociated with GFP_KERNEL.

There is no GFP_NOWAIT usage in any network driver. I'm not sure if
this flag is intended to driver usage. Anyway I can not judge if
GFP_ATOMIC -> GFP_NOWAIT conversion is good or bad idea, I think you
should ask mm guys about that.

Stanislaw
