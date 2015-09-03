From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 1/1] net: fec: clear receive interrupts before
	processing a packet
Date: Thu, 3 Sep 2015 14:40:16 +0000
Message-ID: <BN3PR0301MB121953FBD872A851B4865475F5680@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1441185854-16107-1-git-send-email-b38611@freescale.com>
 <20150902094015.GA27372@frolo.macqel> <20150903080013.GA17053@frolo.macqel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
To: Philippe De Muyter <phdm@macq.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0113.outbound.protection.outlook.com ([65.55.169.113]:50560
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753832AbbICOkT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 10:40:19 -0400
In-Reply-To: <20150903080013.GA17053@frolo.macqel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe De Muyter <phdm@macq.eu> Sent: Thursday, September 03, 2015 4:00 PM
> To: Duan Fugang-B38611
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux@arm.linux.org.uk
> Subject: Re: [PATCH net-next 1/1] net: fec: clear receive interrupts
> before processing a packet
> 
> Hi Andy,
> 
> can you resubmit it, adding also my
> 
> Reported-by: Philippe De Muyter <phdm@macqel.be>
> 
> and explaining that it also prevents a complete rx blockage failure ?
> 
> Philippe
> 
Sorry, consider the patch was submitted/reviewed/applied, so I just re-submited it with keeping the original author/commit log/sign-in information.

> On Wed, Sep 02, 2015 at 11:40:15AM +0200, Philippe De Muyter wrote:
> > On Wed, Sep 02, 2015 at 05:24:14PM +0800, Fugang Duan wrote:
> > > From: Russell King <rmk+kernel@arm.linux.org.uk>
> > >
> > > The patch just to re-submit the patch "db3421c114cfa6326" because
> > > the patch "4d494cdc92b3b9a0" remove the change.
> >
> > I think you should mention also the titles of the commits.
> >
> > And maybe send it also to stable.
> > >
> > > Clear any pending receive interrupt before we process a pending
> packet.
> > > This helps to avoid any spurious interrupts being raised after we
> > > have fully cleaned the receive ring, while still allowing an
> > > interrupt to be raised if we receive another packet.
> > >
> > > The position of this is critical: we must do this prior to reading
> > > the next packet status to avoid potentially dropping an interrupt
> > > when a packet is still pending.
> > >
> > > Acked-by: Fugang Duan <B38611@freescale.com>
> > > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > > ---
> > >  drivers/net/ethernet/freescale/fec_main.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > > b/drivers/net/ethernet/freescale/fec_main.c
> > > index 1f89c59..6bed0ff 100644
> > > --- a/drivers/net/ethernet/freescale/fec_main.c
> > > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > > @@ -1400,6 +1400,7 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)
> > >  		if ((status & BD_ENET_RX_LAST) == 0)
> > >  			netdev_err(ndev, "rcv is not +last\n");
> > >
> > Could a comment be added here to avoid another future removal ?
> >
> > > +		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
> > >
> > >  		/* Check for errors. */
> > >  		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
> > > --
> > > 1.9.1
> >
> > Philippe
> 
> --
> Philippe De Muyter +32 2 6101532 Macq SA rue de l'Aeronef 2 B-1140
> Bruxelles
