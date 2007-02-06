From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 13:25:58 -0800 (PST)
Message-ID: <20070206.132558.88342464.davem@davemloft.net>
References: <20070206.114659.107250775.davem@davemloft.net>
	<45C8EAC4.9020803@cosmosbay.com>
	<1170799541.3535.25.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752288AbXBFV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 16:26:23 -0500
In-Reply-To: <1170799541.3535.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 06 Feb 2007 14:05:41 -0800

> On Tue, 2007-02-06 at 21:53 +0100, Eric Dumazet wrote:
> 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > plain text document attachment (tg3_avoid_divide.patch)
> > --- linux-2.6.20/drivers/net/tg3.c.orig	2007-02-06 22:30:39.000000000 +0100
> > +++ linux-2.6.20-ed/drivers/net/tg3.c	2007-02-06 22:32:42.000000000 +0100
> > @@ -3384,7 +3384,7 @@
> >  		}
> >  next_pkt_nopost:
> >  		sw_idx++;
> > -		sw_idx %= TG3_RX_RCB_RING_SIZE(tp);
> > +		sw_idx &= (TG3_RX_RCB_RING_SIZE(tp) - 1);
> >  
> >  		/* Refresh hw_idx to see if there is new work */
> >  		if (sw_idx == hw_idx) {
> 
> There are other places doing similar divide (e.g. tg3_recycle_rx(),
> tg3_alloc_rx_skb()).  I think we should change them all.

Ok, I'll take care of this.
