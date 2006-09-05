From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2: hw checksum failures
Date: Mon, 4 Sep 2006 20:56:45 -0700
Message-ID: <20060904205645.6c80f30c@localhost.localdomain>
References: <1157416603.22705.62.camel@localhost.localdomain>
	<20060904203442.1c9ed2eb@localhost.localdomain>
	<1157427758.22705.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55207 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965130AbWIED4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 23:56:55 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157427758.22705.65.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Sep 2006 13:42:38 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Mon, 2006-09-04 at 20:34 -0700, Stephen Hemminger wrote:
> > Unneeded byte swap was occurring.
> > 
> > --- linux-2.6.orig/drivers/net/sky2.c
> > +++ linux-2.6/drivers/net/sky2.c
> > @@ -2001,7 +2001,7 @@ static int sky2_status_intr(struct sky2_
> >  		case OP_RXCHKS:
> >  			skb = sky2->rx_ring[sky2->rx_next].skb;
> >  			skb->ip_summed = CHECKSUM_HW;
> > -			skb->csum = le16_to_cpu(status);
> > +			skb->csum = status;
> >  			break;
> >  
> >  		case OP_TXINDEXLE:
> 
> I've removed it in my paches (have you seen the other patches I sent for
> this driver ?), though I'm pre-swapping status and lenght now before the
> switch/case so there might still be an issue there. I'll have a look.

The other tack would be to leave the "reverse in hw" flag on and take out all the existing
swap calls but then you have to add an ifdef to re-order all the structures for tx_le, rx_le, status_le.
That is what the vendor (GPL) version of sk98lin does.

