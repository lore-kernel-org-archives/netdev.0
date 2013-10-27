From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 1/2] net/benet: Identify interface type in advance
Date: Sun, 27 Oct 2013 14:22:07 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C26A3562B@CMEXMB1.ad.emulex.com>
References: <1382688165-20957-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Gavin Shan <shangw@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17633 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab3J0OWJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 10:22:09 -0400
In-Reply-To: <1382688165-20957-1-git-send-email-shangw@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> 
> Function be_map_pci_bars() is being called in be_ctrl_init(). Since
> be_ctrl_init() has fetched the value of PCI config register 0x58,
> we needn't access the same register in be_map_pci_bars() again to
> incur unnecessary PCI config access.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |    9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..1a799d2 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3960,11 +3960,6 @@ static int be_roce_map_pci_bars(struct be_adapter *adapter)
>  static int be_map_pci_bars(struct be_adapter *adapter)
>  {
>  	u8 __iomem *addr;
> -	u32 sli_intf;
> -
> -	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
> -	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
> -				SLI_INTF_IF_TYPE_SHIFT;
> 
>  	if (BEx_chip(adapter) && be_physfn(adapter)) {
>  		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
> @@ -4011,7 +4006,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
> 
>  	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
>  	adapter->sli_family = (sli_intf & SLI_INTF_FAMILY_MASK) >>
> -				 SLI_INTF_FAMILY_SHIFT;
> +				SLI_INTF_FAMILY_SHIFT;
> +	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
> +				SLI_INTF_IF_TYPE_SHIFT;

Gavin, adapter->if_type is not being used anywhere in the driver.
We could just get rid of it.

>  	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
> 
>  	status = be_map_pci_bars(adapter);
> --
> 1.7.9.5
