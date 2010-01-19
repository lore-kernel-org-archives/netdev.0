From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 21:32:14 +0000
Message-ID: <20100119213214.024b7794@lxorguk.ukuu.org.uk>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
	<20100116145014.172ad340@lxorguk.ukuu.org.uk>
	<14385191E87B904DBD836449AA30269D580A93@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dave Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755936Ab0ASV3p@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D580A93@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> +#define PCI_VENDOR_ID_KS884X		0x16C6
> >> +#define PCI_DEVICE_ID_KS8841		0x8841
> >> +#define PCI_DEVICE_ID_KS8842		0x8842
> > 
> > Those belong in the pci device id header.
> > 
> > 
> 
> I do not quite understand your suggestion.  Do I need to put those IDs
> in one of the kernel headers?

Into include/linux/pci_ids.h

> >> +	hw->pdev = pdev;
> > 
> > 
> > If you make a private copy of pdev in your struct you should refcount
> it and use
> > pci_dev_get/pci_dev_put when you take and release the reference. 

> I do not understand how pci_dev_get/pci_dev_put work.  Does the pdev
> pointer actually change during the lifetime of the PCI driver?

No but it can go away if the device is removed. The pci_dev_get ensures
it won't go away while you have a pointer to it. and the pci_dev_put
gives up your reference.

> I also like the attribute to associate with the network device rather
> than the PCI device, as the KSZ8842 driver can create another virtual
> network device.  I tried to pass the device pointer of the network
> device to device_create_file function and the driver crashed.  I will
> investigate this matter further.

Ok
