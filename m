From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] ems_pci: fix size of CAN controllers BAR mapping for
	CPC-PCI	v2
Date: Thu, 24 Sep 2009 10:37:19 +0200
Message-ID: <4ABB2FBF.8080906@grandegger.com>
References: <20090923153747.30154.99860.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20090923153747.30154.99860.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

Sebastian Haas wrote:
> The driver mapped only 128 bytes of the CAN controller address space when a
> CPC-PCI v2 was detected (incl. CPC-104P). This patch will fix it by always
> mapping the whole address space (4096 bytes on all boards) of the
> corresponding PCI BAR.
> 
> Signed-off-by: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
> ---
> 
>  drivers/net/can/sja1000/ems_pci.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
> index 7d84b8a..ba98063 100644
> --- a/drivers/net/can/sja1000/ems_pci.c
> +++ b/drivers/net/can/sja1000/ems_pci.c
> @@ -94,12 +94,14 @@ struct ems_pci_card {
>  #define EMS_PCI_CDR             (CDR_CBP | CDR_CLKOUT_MASK)
>  
>  #define EMS_PCI_V1_BASE_BAR     1
> -#define EMS_PCI_V1_MEM_SIZE     4096
> +#define EMS_PCI_V1_MEM_SIZE     4096 /* size of PITA control area */
>  #define EMS_PCI_V2_BASE_BAR     2
> -#define EMS_PCI_V2_MEM_SIZE     128
> +#define EMS_PCI_V2_MEM_SIZE     128 /* size of PLX control area */
>  #define EMS_PCI_CAN_BASE_OFFSET 0x400 /* offset where the controllers starts */
>  #define EMS_PCI_CAN_CTRL_SIZE   0x200 /* memory size for each controller */
>  
> +#define EMS_PCI_CONTR_MEM_SIZE  4096 /* size of controller area */
> +
>  static struct pci_device_id ems_pci_tbl[] = {
>  	/* CPC-PCI v1 */
>  	{PCI_VENDOR_ID_SIEMENS, 0x2104, PCI_ANY_ID, PCI_ANY_ID,},
> @@ -266,7 +268,7 @@ static int __devinit ems_pci_add_card(struct pci_dev *pdev,
>  		goto failure_cleanup;
>  	}
>  
> -	card->base_addr = pci_iomap(pdev, base_bar, mem_size);
> +	card->base_addr = pci_iomap(pdev, base_bar, EMS_PCI_CONTR_MEM_SIZE);
>  	if (card->base_addr == NULL) {
>  		err = -ENOMEM;
>  		goto failure_cleanup;

I see. To avoid confusion I suggest renaming some variables and defines:

s/EMS_PCI_V1_MEM_SIZE/EMS_PCI_V1_CONF_SIZE/
s/EMS_PCI_V2_MEM_SIZE/EMS_PCI_V2_CONF_SIZE/
s/mem_size/conf_size/
s/EMS_PCI_CONTR_MEM_SIZE/EMS_PCI_BASE_SIZE/

Would that not be more appropriate?

Wolfgang.
