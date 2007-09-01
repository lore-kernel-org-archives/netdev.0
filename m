From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 4/5]S2io: Check for CARD_DOWN before handling traffic
Date: Fri, 31 Aug 2007 21:43:37 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702243AEB@nekter>
References: <46D811BB.5060007@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:19065 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbXIABnl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 21:43:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46D811BB.5060007@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,
> > - Added check to return from the traffic handling function, if the
card
> status
> >   is DOWN.
> >
> > Signed-off-by: Sivakumar Subramani
<sivakumar.subramani@neterion.com>
> > Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> > ---
> > diff -Nurp patch3/drivers/net/s2io.c patch4/drivers/net/s2io.c
> > --- patch3/drivers/net/s2io.c	2007-08-15 08:57:32.000000000
-0700
> > +++ patch4/drivers/net/s2io.c	2007-08-15 08:42:14.000000000
-0700
> > @@ -2927,6 +2927,11 @@ static int s2io_poll(struct net_device *
> >  	int i;
> >
> >  	atomic_inc(&nic->isr_cnt);
> > +	if (unlikely(atomic_read(&nic->card_state) == CARD_DOWN)) {
> > +		atomic_dec(&nic->isr_cnt);
> > +		return IRQ_NONE;
> > +	}
> > +
> >  	mac_control = &nic->mac_control;
> >  	config = &nic->config;
> >
> 
> invalid return value, for this function
> 
> Overall, this looks quite racy -- why does the card state differ from
> net_device state in the first place?
[Ram] Agreed, it is racy. Will use test_and_set_bit(), set_bit() and
clear_bit().
The card reset could be initiated due to an internal error detected in
one of the blocks in the chip, while interrupts are still occurring.
There is a  net_device state (LINK_STATE_START) set at open and reset at
close but none for temporary disabled/enabled states. Did you want us to
use this enum along with the CARRIER states?

Ram

