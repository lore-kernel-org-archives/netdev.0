From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 2/2 2.6.25-rc8] ixgbe: save and restore pcie/msi state
	to	support EEH recovery
Date: Thu, 24 Apr 2008 10:50:06 -0500
Message-ID: <1209052206.7339.40.camel@wendyx.austin.ibm.com>
References: <1207856434.24768.27.camel@wendyx.austin.ibm.com>
	 <47FE7D3A.2090703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43645 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbYDXPuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:50:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3OFo8P7001292
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:50:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OFo8uK388120
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:50:08 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OFo8b7009504
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:50:08 -0400
In-Reply-To: <47FE7D3A.2090703@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches got ack by Intel developer. Can you put them in your
tree for 2.6.26 kernel?

Thanks,
Wendy
On Thu, 2008-04-10 at 13:48 -0700, Kok, Auke wrote:
> wendy xiong wrote:
> > Hi,
> > 
> > To enable EEH support for pci-express network adapters, pcie/msi state
> > needs to be saved and restored for that adapter.
> > 
> > We have tested this EEH patch with Intel 10G pci-express ixgbe adapter.
> > 
> > Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
> 
> 
> Thanks Wendy,
> 
> I'll pull (both) these in my tree and make sure they get merged. thanks!
> 
> Auke
> 
> > 
> > 
> > diff -Nuarp linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c
> > --- linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c        2008-04-07 19:18:08.000000000 -0500
> > +++ linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c     2008-04-10 12:54:17.000000000 -0500
> > @@ -2654,6 +2654,7 @@ static int __devinit ixgbe_probe(struct
> >         }
> > 
> >         pci_set_master(pdev);
> > +       pci_save_state(pdev);
> > 
> >         netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
> >         if (!netdev) {
> > @@ -2910,6 +2911,7 @@ static pci_ers_result_t ixgbe_io_slot_re
> >                 return PCI_ERS_RESULT_DISCONNECT;
> >         }
> >         pci_set_master(pdev);
> > +       pci_restore_state(pdev);
> > 
> >         pci_enable_wake(pdev, PCI_D3hot, 0);
> >         pci_enable_wake(pdev, PCI_D3cold, 0);
> > 
> > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

