From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/5] e1000: remove PCI Express device IDs
Date: Wed, 30 Apr 2008 11:08:59 -0700
Message-ID: <4818B5BB.1020209@intel.com>
References: <20080402204802.29122.81707.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6319 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbYD3SJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 14:09:19 -0400
In-Reply-To: <20080402204802.29122.81707.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> We do not want to prolong the situation much longer that e1000
> and e1000e support these devices at the same time. As a result,
> take out the bandage that was added for the interim period
> and remove all the PCI Express device IDs from e1000.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Jeff Garzik <jeff@garzik.org>

Jeff,

I would like to see something like this merged in this merge window if that is
still possible - I think we both agree that postponing this change for another
kernel release will just make it much more confusing for users who need to switch.


Auke



> ---
> 
>  drivers/net/Kconfig            |    3 ---
>  drivers/net/e1000/e1000_main.c |   33 ---------------------------------
>  2 files changed, 0 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 95d1b61..ec764a9 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2028,9 +2028,6 @@ config E1000E
>  	  To compile this driver as a module, choose M here. The module
>  	  will be called e1000e.
>  
> -config E1000E_ENABLED
> -	def_bool E1000E != n
> -
>  config IP1000
>  	tristate "IP1000 Gigabit Ethernet support"
>  	depends on PCI && EXPERIMENTAL
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 757d02f..f12de3c 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -47,12 +47,6 @@ static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation
>   * Macro expands to...
>   *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>   */
> -#ifdef CONFIG_E1000E_ENABLED
> -  #define PCIE(x) 
> -#else
> -  #define PCIE(x) x,
> -#endif
> -
>  static struct pci_device_id e1000_pci_tbl[] = {
>  	INTEL_E1000_ETHERNET_DEVICE(0x1000),
>  	INTEL_E1000_ETHERNET_DEVICE(0x1001),
> @@ -79,14 +73,6 @@ static struct pci_device_id e1000_pci_tbl[] = {
>  	INTEL_E1000_ETHERNET_DEVICE(0x1026),
>  	INTEL_E1000_ETHERNET_DEVICE(0x1027),
>  	INTEL_E1000_ETHERNET_DEVICE(0x1028),
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1049))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104A))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104B))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104C))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104D))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105E))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105F))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
>  	INTEL_E1000_ETHERNET_DEVICE(0x1075),
>  	INTEL_E1000_ETHERNET_DEVICE(0x1076),
>  	INTEL_E1000_ETHERNET_DEVICE(0x1077),
> @@ -95,28 +81,9 @@ PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
>  	INTEL_E1000_ETHERNET_DEVICE(0x107A),
>  	INTEL_E1000_ETHERNET_DEVICE(0x107B),
>  	INTEL_E1000_ETHERNET_DEVICE(0x107C),
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107D))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107E))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107F))
>  	INTEL_E1000_ETHERNET_DEVICE(0x108A),
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108B))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108C))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1096))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1098))
>  	INTEL_E1000_ETHERNET_DEVICE(0x1099),
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x109A))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A4))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A5))
>  	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10B9))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BA))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BB))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BC))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C4))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C5))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D5))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D9))
> -PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10DA))
>  	/* required last entry */
>  	{0,}
>  };
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

