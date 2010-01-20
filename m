From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 16:12:04 -0800
Message-ID: <14385191E87B904DBD836449AA30269D580AF2@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com><20100116145014.172ad340@lxorguk.ukuu.org.uk><14385191E87B904DBD836449AA30269D580A93@MORGANITE.micrel.com> <20100119213214.024b7794@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dave Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756200Ab0ATANf@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100119213214.024b7794@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
>>> If you make a private copy of pdev in your struct you should
>>> refcount
>> it and use
>>> pci_dev_get/pci_dev_put when you take and release the reference.
> 
>> I do not understand how pci_dev_get/pci_dev_put work.  Does the pdev
>> pointer actually change during the lifetime of the PCI driver?
> 
> No but it can go away if the device is removed. The pci_dev_get
ensures it won't go away while
> you have a pointer to it. and the pci_dev_put gives up your reference.

> 

If the PCI device is removed, like physically removing the card,
shouldn't the kernel also close the network device assocated with the
PCI device?  The driver does actually cleanup the network devices and
free all memory when the pci remove function is called.

>From the PCI network drivers included in the kernel I found most drivers
use pci_dev_put only on devices that are outside their own PCI devices,
retrieved from the pci_get_device call.  (They never call pci_dev_get.)
That makes sense as those PCI devices are outside PCI driver control.
