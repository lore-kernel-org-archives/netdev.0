From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 11/26] can: constify local structures
Date: Mon, 12 Sep 2016 14:33:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121432210.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <1473599168-30561-12-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1473599168-30561-12-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-can-owner@vger.kernel.org
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
kernel_ulong_t as a type, so it interpreted eg

(kernel_ulong_t)&plx_pci_card_info_adlink

as a bit and operation.

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
>  drivers/net/can/c_can/c_can_pci.c |    4 ++--
>  drivers/net/can/sja1000/plx_pci.c |   20 ++++++++++----------
>  2 files changed, 12 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
> index 7be393c..4bc345d 100644
> --- a/drivers/net/can/c_can/c_can_pci.c
> +++ b/drivers/net/can/c_can/c_can_pci.c
> @@ -251,14 +251,14 @@ static void c_can_pci_remove(struct pci_dev *pdev)
>  	pci_disable_device(pdev);
>  }
>
> -static struct c_can_pci_data c_can_sta2x11= {
> +static const struct c_can_pci_data c_can_sta2x11 = {
>  	.type = BOSCH_C_CAN,
>  	.reg_align = C_CAN_REG_ALIGN_32,
>  	.freq = 52000000, /* 52 Mhz */
>  	.bar = 0,
>  };
>
> -static struct c_can_pci_data c_can_pch = {
> +static const struct c_can_pci_data c_can_pch = {
>  	.type = BOSCH_C_CAN,
>  	.reg_align = C_CAN_REG_32,
>  	.freq = 50000000, /* 50 MHz */
> diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
> index 3eb7430..59bc378 100644
> --- a/drivers/net/can/sja1000/plx_pci.c
> +++ b/drivers/net/can/sja1000/plx_pci.c
> @@ -170,7 +170,7 @@ struct plx_pci_card_info {
>  	void (*reset_func)(struct pci_dev *pdev);
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_adlink = {
> +static const struct plx_pci_card_info plx_pci_card_info_adlink = {
>  	"Adlink PCI-7841/cPCI-7841", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{1, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
> @@ -178,7 +178,7 @@ static struct plx_pci_card_info plx_pci_card_info_adlink = {
>  	/* based on PLX9052 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_adlink_se = {
> +static const struct plx_pci_card_info plx_pci_card_info_adlink_se = {
>  	"Adlink PCI-7841/cPCI-7841 SE", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
> @@ -186,7 +186,7 @@ static struct plx_pci_card_info plx_pci_card_info_adlink_se = {
>  	/* based on PLX9052 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_esd200 = {
> +static const struct plx_pci_card_info plx_pci_card_info_esd200 = {
>  	"esd CAN-PCI/CPCI/PCI104/200", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> @@ -194,7 +194,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd200 = {
>  	/* based on PLX9030/9050 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_esd266 = {
> +static const struct plx_pci_card_info plx_pci_card_info_esd266 = {
>  	"esd CAN-PCI/PMC/266", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> @@ -202,7 +202,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd266 = {
>  	/* based on PLX9056 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_esd2000 = {
> +static const struct plx_pci_card_info plx_pci_card_info_esd2000 = {
>  	"esd CAN-PCIe/2000", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
> @@ -210,7 +210,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd2000 = {
>  	/* based on PEX8311 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_ixxat = {
> +static const struct plx_pci_card_info plx_pci_card_info_ixxat = {
>  	"IXXAT PC-I 04/PCI", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x200, 0x80} },
> @@ -218,7 +218,7 @@ static struct plx_pci_card_info plx_pci_card_info_ixxat = {
>  	/* based on PLX9050 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_marathon_pci = {
> +static const struct plx_pci_card_info plx_pci_card_info_marathon_pci = {
>  	"Marathon CAN-bus-PCI", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x00, 0x00}, {4, 0x00, 0x00} },
> @@ -234,7 +234,7 @@ static struct plx_pci_card_info plx_pci_card_info_marathon_pcie = {
>  	/* based on PEX8311 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_tews = {
> +static const struct plx_pci_card_info plx_pci_card_info_tews = {
>  	"TEWS TECHNOLOGIES TPMC810", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x000, 0x80}, {2, 0x100, 0x80} },
> @@ -242,7 +242,7 @@ static struct plx_pci_card_info plx_pci_card_info_tews = {
>  	/* based on PLX9030 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_cti = {
> +static const struct plx_pci_card_info plx_pci_card_info_cti = {
>  	"Connect Tech Inc. CANpro/104-Plus Opto (CRG001)", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{0, 0x00, 0x00}, { {2, 0x000, 0x80}, {2, 0x100, 0x80} },
> @@ -250,7 +250,7 @@ static struct plx_pci_card_info plx_pci_card_info_cti = {
>  	/* based on PLX9030 */
>  };
>
> -static struct plx_pci_card_info plx_pci_card_info_elcus = {
> +static const struct plx_pci_card_info plx_pci_card_info_elcus = {
>  	"Eclus CAN-200-PCI", 2,
>  	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
>  	{1, 0x00, 0x00}, { {2, 0x00, 0x80}, {3, 0x00, 0x80} },
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
