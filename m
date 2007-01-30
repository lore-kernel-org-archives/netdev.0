From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Mon, 29 Jan 2007 19:41:08 -0600
Message-ID: <20070130014107.GA18935@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070129102233.27f236ee@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49963 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbXA3Bef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 20:34:35 -0500
Content-Disposition: inline
In-Reply-To: <20070129102233.27f236ee@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 10:22:33AM -0800, Stephen Hemminger wrote:
> Basic initalization, setup comments.

Thanks, fixes have been incorporated and will be reposted. Most of them
was obviously just my lack of diligence. See however the two below.

> > +static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
> > +{
> > +	struct net_device *dev = data;
> > +	struct pasemi_mac *mac = netdev_priv(dev);
> > +	unsigned int reg;
> > +
> > +	pasemi_mac_clean_tx(mac);
> > +
> > +	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
> > +	if (*mac->tx_status & PAS_STATUS_TIMER)
> > +		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
> > +
> > +	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
> > +			       reg);
> > +
> > +	return IRQ_HANDLED;
> > +}
> 
> To do shared IRQ's properly you need to check to see if
> this is your device IRQ or not. Maybe reading config value?

Right now it's guaranteed that the interrupts will not be shared. They're
fixed for the on-chip devices, and no other driver should be binding to
the same channels (and thus irqs).

If it changes in the future, the driver would need other rework as well.

> > +
> > +static struct pci_driver pasemi_mac_driver = {
> > +   .name = "pasemi_mac",
> > +   .id_table = pasemi_mac_pci_tbl,
> > +   .probe = pasemi_mac_probe,
> 
> Don't you need a remove routine?

No hotplug support at this time, so I didn't see any use in providing one.


-Olof
