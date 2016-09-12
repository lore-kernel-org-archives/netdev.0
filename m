From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 20/26] stmmac: pci: constify local structures
Date: Mon, 12 Sep 2016 14:08:38 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121407370.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <1473599168-30561-21-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-21-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 11 Sep 2016, Julia Lawall wrote:

> For structure types defined in the same file or local header files, find
> top-level static structure declarations that have the following
> properties:
> 1. Never reassigned.
> 2. Address never taken
> 3. Not passed to a top-level macro call
> 4. No pointer or array-typed field passed to a function or stored in a
> variable.
> Declare structures having all of these properties as const.

Please ignore this patch.  Coccinelle incorrectly interpreted

{PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info}

as a bit and operation, since it did not recognize kernel_ulong_t as a
type.

julia

> Done using Coccinelle.
> Based on a suggestion by Joe Perches <joe@perches.com>.
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
> The semantic patch seems too long for a commit log, but is in the cover
> letter.
>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 56c8a23..5c612c3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -141,7 +141,7 @@ static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
>  	{}
>  };
>
> -static struct stmmac_pci_info quark_pci_info = {
> +static const struct stmmac_pci_info quark_pci_info = {
>  	.setup = quark_default_data,
>  	.dmi = quark_pci_dmi_data,
>  };
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
