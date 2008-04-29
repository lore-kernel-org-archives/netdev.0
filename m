From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth: Ack IRQ events as late as possible.
Date: Tue, 29 Apr 2008 20:14:14 +0800
Message-ID: <989B956029373F45A0B8AF029708189002007ED6@zch01exm26.fsl.freescale.net>
References: <1209138209-8073-1-git-send-email-Joakim.Tjernlund@transmode.se> <989B956029373F45A0B8AF029708189002007ECF@zch01exm26.fsl.freescale.net> <1209467644.6904.46.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>
To: <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:59349 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbYD2MOZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 08:14:25 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3TCEGnl011460
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 05:14:16 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3TCEEuX005515
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 07:14:15 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1209467644.6904.46.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > diff --git a/drivers/net/ucc_geth.h 
> b/drivers/net/ucc_geth.h index 
> > > cc24e87..7451f17 100644
> > > --- a/drivers/net/ucc_geth.h
> > > +++ b/drivers/net/ucc_geth.h
> > > @@ -207,8 +207,8 @@ struct ucc_geth {
> > >  			UCCE_RXB3 | UCCE_RXB2 | UCCE_RXB1 | UCCE_RXB0)
> > >  #define UCCE_RXF         (UCCE_RXF7 | UCCE_RXF6 | UCCE_RXF5 
> > > | UCCE_RXF4 |\
> > >  			UCCE_RXF3 | UCCE_RXF2 | UCCE_RXF1 | UCCE_RXF0)
> > > -#define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA  | UCCE_CBPR 
> > > | UCCE_BSY  |\
> > > -			UCCE_RXC  | UCCE_TXC  | UCCE_TXE)
> > > +#define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA | UCCE_CBPR |\
> > > +			UCCE_RXC  | UCCE_TXC)
> > 
> > This will remove UCCE_BSY and UCCE_TXE from the uccm_mask, hence 
> > disabled them from generating interrupts.
> 
> Yeah, got mislead by the UCCE_RX_EVENTS and UCC_TX_EVENTS just below.
> So the UCCE_OTHER change should go, but the rest stay.
> 
> > 
> > How is the improvement after your change to put off interrupt ack?
> > Isn't it caused by disabling the busy interrupts?
> 
> Not sure, got no time to measure ATM. Besides that, I do 

I agree that by putting off ack to TX/RX interrupts, there could be some
performance benefit in some cases.  But the last clear to ucce will make
it possible to miss a packet.

> think this change is needed anyway. There is no sane way to 
> handle the stats counters in the main irq loop. The next step 
> would be to actually start counting errors. Agreed?

I don't agree here.  The BSY event doesn't mean RXB will be set too.
The same applies for TX.  Acking the error events ealier will make the
error counter more accurate.

- Leo
