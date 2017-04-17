From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH] net: thunderx: Fix set_max_bgx_per_node for 81xx rgx
Date: Mon, 17 Apr 2017 16:52:22 +0530
Message-ID: <CA+sq2CeGUWFpLWVbBLdJ9856=J256MY1R5H6rXNavvxSf4wrGg@mail.gmail.com>
References: <1492068301-1141-1-git-send-email-george.cherian@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LAKML <linux-arm-kernel@lists.infradead.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>
To: George Cherian <george.cherian@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34990 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdDQLWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 07:22:24 -0400
In-Reply-To: <1492068301-1141-1-git-send-email-george.cherian@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 12:55 PM, George Cherian
<george.cherian@cavium.com> wrote:
> Add the PCI_SUBSYS_DEVID_81XX_RGX and use the same to set
> the max bgx per node count.
>
> This fixes the issue intoduced by following commit
> 78aacb6f6 net: thunderx: Fix invalid mac addresses for node1 interfaces
> With this commit the max_bgx_per_node for 81xx is set as 2 instead of 3
> because of which num_vfs is always calculated as zero.
>
> Signed-off-by: George Cherian <george.cherian@cavium.com>
> ---
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 1 +
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.h | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index 64a1095..a0ca68c 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -134,6 +134,7 @@ static void set_max_bgx_per_node(struct pci_dev *pdev)
>         pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &sdevid);
>         switch (sdevid) {
>         case PCI_SUBSYS_DEVID_81XX_BGX:
> +       case PCI_SUBSYS_DEVID_81XX_RGX:
>                 max_bgx_per_node = MAX_BGX_PER_CN81XX;
>                 break;
>         case PCI_SUBSYS_DEVID_83XX_BGX:
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
> index c5080f2c..6b7fe6fd 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
> @@ -16,6 +16,7 @@
>  /* Subsystem device IDs */
>  #define PCI_SUBSYS_DEVID_88XX_BGX              0xA126
>  #define PCI_SUBSYS_DEVID_81XX_BGX              0xA226
> +#define PCI_SUBSYS_DEVID_81XX_RGX              0xA254
>  #define PCI_SUBSYS_DEVID_83XX_BGX              0xA326
>
>  #define    MAX_BGX_THUNDER                     8 /* Max 2 nodes, 4 per node */
> --
> 2.1.4
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

Looks good, thanks.

Sunil.
