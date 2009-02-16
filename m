From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] TG3: &&/|| confusion
Date: Mon, 16 Feb 2009 09:27:19 -0800
Message-ID: <C27F8246C663564A84BB7AB343977242163420407C@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <49989494.6010804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "'Roel Kluin'" <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1275 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbZBPR1c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 12:27:32 -0500
In-Reply-To: <49989494.6010804@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:

> phyid Can't be both TG3_PHY_OUI_1 and TG3_PHY_OUI_2 and TG3_PHY_OUI_3.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> // vi drivers/net/tg3.h +2698
> #define TG3_PHY_OUI_1                   0x00206000
> #define TG3_PHY_OUI_2                   0x0143bc00
> #define TG3_PHY_OUI_3                   0x03625c00
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 4595962..b080f94 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -2237,8 +2237,8 @@ static int tg3_set_power_state(struct
> tg3 *tp, pci_power_t state)
>                       phyid = phydev->drv->phy_id &
> phydev->drv->phy_id_mask;
>                       if (phyid != TG3_PHY_ID_BCMAC131) {
>                               phyid &= TG3_PHY_OUI_MASK;
> -                             if (phyid == TG3_PHY_OUI_1 &&
> -                                 phyid == TG3_PHY_OUI_2 &&
> +                             if (phyid == TG3_PHY_OUI_1 ||
> +                                 phyid == TG3_PHY_OUI_2 ||
>                                   phyid == TG3_PHY_OUI_3)
>                                       do_low_power = true;
>                       }
>
>

Thanks, this looks good to me, but I need Matt to ACK this patch.

