From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] myri10ge: more Intel chipsets providing aligned PCIe
 completions
Date: Wed, 11 Apr 2007 11:54:20 -0400
Message-ID: <461D04AC.4020306@garzik.org>
References: <461BE372.2000600@myri.com> <461BE3C3.3020800@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46863 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141AbXDKPyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 11:54:23 -0400
In-Reply-To: <461BE3C3.3020800@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Add the Intel 5000 southbridge (aka Intel 6310/6311/6321ESB) PCIe ports
> and the Intel E30x0 chipsets to the whitelist of aligned PCIe completion.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> Index: linux-rc/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-04-10 21:03:59.000000000 +0200
> +++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-04-10 21:04:35.000000000 +0200
> @@ -2487,6 +2487,10 @@
>  
>  #define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
>  #define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
> +#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1 0x3510
> +#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4 0x351b
> +#define PCI_DEVICE_ID_INTEL_E3000_PCIE	0x2779
> +#define PCI_DEVICE_ID_INTEL_E3010_PCIE	0x277a
>  #define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
>  #define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
>  
> @@ -2526,6 +2530,18 @@
>  				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
>  				&& bridge->device <=
>  				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
> +			    /* All Intel E3000/E3010 PCIE ports */
> +			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
> +				&& (bridge->device ==
> +				    PCI_DEVICE_ID_INTEL_E3000_PCIE
> +				    || bridge->device ==
> +				    PCI_DEVICE_ID_INTEL_E3010_PCIE))
> +			    /* All Intel 6310/6311/6321ESB PCIE ports */
> +			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
> +				&& bridge->device >=
> +				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1
> +				&& bridge->device <=
> +				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4)
>  			    /* All Intel E5000 PCIE ports */
>  			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
>  				&& bridge->device >=

though I'm applying this, long term this should probably move out of 
myri driver


