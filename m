From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 05/26] ARCNET: constify local structures
Date: Mon, 12 Sep 2016 14:31:14 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121429040.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <1473599168-30561-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-6-git-send-email-Julia.Lawall@lip6.fr>
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

Actually, this patch should be dropped.  Coccinelle did not recognize
kernel_ulong_t as a type, so it interpreted things like

(kernel_ulong_t)&card_info_10mbit

as a bit and operation.

julia


>
> Done using Coccinelle.
> Based on a suggestion by Joe Perches <joe@perches.com>.
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
> The semantic patch seems too long for a commit log, but is in the cover
> letter.
>
>  drivers/net/arcnet/com20020-pci.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
> index 239de38..32b8406 100644
> --- a/drivers/net/arcnet/com20020-pci.c
> +++ b/drivers/net/arcnet/com20020-pci.c
> @@ -264,7 +264,7 @@ static void com20020pci_remove(struct pci_dev *pdev)
>  	}
>  }
>
> -static struct com20020_pci_card_info card_info_10mbit = {
> +static const struct com20020_pci_card_info card_info_10mbit = {
>  	.name = "ARC-PCI",
>  	.devcount = 1,
>  	.chan_map_tbl = {
> @@ -277,7 +277,7 @@ static struct com20020_pci_card_info card_info_10mbit = {
>  	.flags = ARC_CAN_10MBIT,
>  };
>
> -static struct com20020_pci_card_info card_info_5mbit = {
> +static const struct com20020_pci_card_info card_info_5mbit = {
>  	.name = "ARC-PCI",
>  	.devcount = 1,
>  	.chan_map_tbl = {
> @@ -290,7 +290,7 @@ static struct com20020_pci_card_info card_info_5mbit = {
>  	.flags = ARC_IS_5MBIT,
>  };
>
> -static struct com20020_pci_card_info card_info_sohard = {
> +static const struct com20020_pci_card_info card_info_sohard = {
>  	.name = "PLX-PCI",
>  	.devcount = 1,
>  	/* SOHARD needs PCI base addr 4 */
> @@ -304,7 +304,7 @@ static struct com20020_pci_card_info card_info_sohard = {
>  	.flags = ARC_CAN_10MBIT,
>  };
>
> -static struct com20020_pci_card_info card_info_eae_arc1 = {
> +static const struct com20020_pci_card_info card_info_eae_arc1 = {
>  	.name = "EAE PLX-PCI ARC1",
>  	.devcount = 1,
>  	.chan_map_tbl = {
> @@ -329,7 +329,7 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
>  	.flags = ARC_CAN_10MBIT,
>  };
>
> -static struct com20020_pci_card_info card_info_eae_ma1 = {
> +static const struct com20020_pci_card_info card_info_eae_ma1 = {
>  	.name = "EAE PLX-PCI MA1",
>  	.devcount = 2,
>  	.chan_map_tbl = {
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
