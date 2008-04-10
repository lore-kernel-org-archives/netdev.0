From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2 2.6.25-rc8] ixgbe: save and restore pcie/msi state
 to	support EEH recovery
Date: Thu, 10 Apr 2008 13:48:58 -0700
Message-ID: <47FE7D3A.2090703@intel.com>
References: <1207856434.24768.27.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: wendy xiong <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40248 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757382AbYDJUx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 16:53:58 -0400
In-Reply-To: <1207856434.24768.27.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wendy xiong wrote:
> Hi,
> 
> To enable EEH support for pci-express network adapters, pcie/msi state
> needs to be saved and restored for that adapter.
> 
> We have tested this EEH patch with Intel 10G pci-express ixgbe adapter.
> 
> Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>


Thanks Wendy,

I'll pull (both) these in my tree and make sure they get merged. thanks!

Auke

> 
> 
> diff -Nuarp linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c
> --- linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c        2008-04-07 19:18:08.000000000 -0500
> +++ linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c     2008-04-10 12:54:17.000000000 -0500
> @@ -2654,6 +2654,7 @@ static int __devinit ixgbe_probe(struct
>         }
> 
>         pci_set_master(pdev);
> +       pci_save_state(pdev);
> 
>         netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
>         if (!netdev) {
> @@ -2910,6 +2911,7 @@ static pci_ers_result_t ixgbe_io_slot_re
>                 return PCI_ERS_RESULT_DISCONNECT;
>         }
>         pci_set_master(pdev);
> +       pci_restore_state(pdev);
> 
>         pci_enable_wake(pdev, PCI_D3hot, 0);
>         pci_enable_wake(pdev, PCI_D3cold, 0);
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

