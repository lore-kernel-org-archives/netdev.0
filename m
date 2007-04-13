From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/7] NetXen: Fixes for Power PC architecture
Date: Fri, 13 Apr 2007 16:54:12 +0100
Message-ID: <20070413155412.GA25348@infradead.org>
References: <200704131542.l3DFgvsv002650@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43057 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686AbXDMPyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 11:54:36 -0400
Content-Disposition: inline
In-Reply-To: <200704131542.l3DFgvsv002650@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 13, 2007 at 08:42:57AM -0700, Linsys Contractor Mithlesh Thukral wrote:
> NetXen: Configurable interrupts on PPC architecture
> This patch will add support to add command line argument to specify
> the interrupt type on a PPC machine. Fixes some issues seen on Big endian
> machines.
> 
> Signed-off by: Milan Bag <mbag@netxen.com> 
> Acked-by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic.h      |    6 +++---
>  drivers/net/netxen/netxen_nic_hw.c   |    2 +-
>  drivers/net/netxen/netxen_nic_init.c |    4 ++--
>  drivers/net/netxen/netxen_nic_main.c |    6 ++++++
>  4 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index 3549c7c..7ba2383 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -64,9 +64,9 @@ #include <asm/pgtable.h>
>  #include "netxen_nic_hw.h"
>  
>  #define _NETXEN_NIC_LINUX_MAJOR 3
> -#define _NETXEN_NIC_LINUX_MINOR 3
> -#define _NETXEN_NIC_LINUX_SUBVERSION 3
> -#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3"
> +#define _NETXEN_NIC_LINUX_MINOR 4
> +#define _NETXEN_NIC_LINUX_SUBVERSION 2
> +#define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
>  
>  #define NUM_FLASH_SECTORS (64)
>  #define FLASH_SECTOR_SIZE (64 * 1024)
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index 3195fa5..4206125 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -1141,7 +1141,7 @@ void netxen_nic_flash_print(struct netxe
>  				       netxen_nic_driver_name);
>  				return;
>  			}
> -			*ptr32 = le32_to_cpu(*ptr32);
> +			*ptr32 = cpu_to_le32(*ptr32);

Please add proper __le32 and avoid in-place swapping.  Please use sparse
to verify that your endianess handling is correct.

> +#ifdef CONFIG_PPC
> +static int nx_ppc_msi_enable = 0;      /* by default donot enable msi */
> +module_param(nx_ppc_msi_enable, int, 0644);
> +MODULE_PARM_DESC(nx_ppc_msi_enable, "NetXen PPC MSI enable value");
> +#endif /* CONFIG_PPC */

NACK.  If msi is broken on your card for certain setup disable it
completely, if ppc msi support is broken fix it there.

