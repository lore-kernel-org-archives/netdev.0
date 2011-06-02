From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] Add Fujitsu 1000base-SX PCI ID to tg3
Date: Thu, 2 Jun 2011 15:35:12 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1106021453330.21002@math.ut.ee>
References: <alpine.SOC.1.00.1105251836550.16961@math.ut.ee> <20110601211401.GB1482@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bounces.ut.ee ([193.40.5.137]:54000 "EHLO bounces.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab1FBNAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 09:00:30 -0400
In-Reply-To: <20110601211401.GB1482@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This patch adds the PCI ID of Fujitsu 1000base-SX NIC to tg3 driver. 
> > Tested to detect the card, MAC and serdes, not tested with link at the 
> > moment since I have no fiber switch here. I did not add new constants to 
> > the pci_ids.h header file since these constants are used only here.
> > 
> > Signed-off-by: Meelis Roos <mroos@linux.ee>
> > 
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index 7a5daef..7b1901e 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -273,6 +273,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
> >  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1003)},
> >  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC9100)},
> >  	{PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_TIGON3)},
> > +	{PCI_DEVICE(0x10cf, 0x11a2)}, /* Fujitsu 1000base-SX with BCM5703SKHB */
> >  	{}
> >  };
> 
> I don't have any problems with the patch, but before we integrate it,
> can we make sure it passes traffic?  I'd hate to add support for a
> device and later find out it doesn't work.

Checked with direct link to another NIC, link came up.

[   99.067432] tg3 0000:01:0b.0: eth1: Link is up at 1000 Mbps, full duplex
[   99.067662] tg3 0000:01:0b.0: eth1: Flow control is on for TX and on for RX 

I can also see DHCP requests from one interface on the other with 
tcpdump, so data gets also through. Seems to work.

-- 
Meelis Roos (mroos@linux.ee)
