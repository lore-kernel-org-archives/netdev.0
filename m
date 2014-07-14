From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 5/6] ethernet: amd: fix pci device ids
Date: Mon, 14 Jul 2014 21:36:17 +0400
Message-ID: <53C41511.5090204@cogentembedded.com>
References: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com> <1405319147-5212-6-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: varkabhadram@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:44359 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230AbaGNRgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 13:36:17 -0400
Received: by mail-lb0-f180.google.com with SMTP id w7so3007518lbi.25
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 10:36:15 -0700 (PDT)
In-Reply-To: <1405319147-5212-6-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/14/2014 10:25 AM, varkabhadram@gmail.com wrote:

> From: Varka Bhadram <varkab@cdac.in>

> Normally any device ids will be above the corresponding device driver
> structure. This patch moves the pci device ids and MODULE_DEVICE_TABLE()
> above the pci driver structure.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/amd/amd8111e.c |   20 +++++++++++---------
>   1 file changed, 11 insertions(+), 9 deletions(-)

> diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
> index e2fb9e2..3e41568 100644
> --- a/drivers/net/ethernet/amd/amd8111e.c
> +++ b/drivers/net/ethernet/amd/amd8111e.c
[...]
> @@ -109,14 +108,6 @@ MODULE_PARM_DESC(coalesce, "Enable or Disable interrupt coalescing, 1: Enable, 0
>   module_param_array(dynamic_ipg, bool, NULL, 0);
>   MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disable");
>
> -static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
> -
> -	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
> -	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
> -	{ 0, }
> -
> -};
> -
>   /* This function will read the PHY registers. */
>   static int amd8111e_read_phy(struct amd8111e_priv* lp, int phy_id, int reg, u32* val)
>   {
> @@ -1953,6 +1944,17 @@ static void amd8111e_remove_one(struct pci_dev *pdev)
>   	}
>   }
>
> +static const struct pci_device_id amd8111e_pci_tbl[] = {
> +	{
> +	 .vendor = PCI_VENDOR_ID_AMD,
> +	 .device = PCI_DEVICE_ID_AMD8111E_7462,

    I don't that's equivalent to what was there before: PCI_ANY_ID is defined 
as (~0), not 0.

> +	},
> +	{
> +	 .vendor = 0,

    You can completely skip the explicit initializers, the entry will be 
init'ed with 0s anyway.

> +	}
> +};
> +MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
> +

WBR, Sergei
