From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/3] r8169: fix WOL setting for 8105 and 8111EVL
Date: Wed, 31 Aug 2011 21:13:44 +0200
Message-ID: <20110831191344.GA24634@electric-eye.fr.zoreil.com>
References: <1314807479-1552-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41913 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375Ab1HaTcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 15:32:15 -0400
Content-Disposition: inline
In-Reply-To: <1314807479-1552-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> 8105, 8111E, and 8111EVL need enable RxConfig bit 1 ~ 3 for supporting
> wake on lan.
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 1cf8c3c..96e003a 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -3416,8 +3416,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
>  		rtl_writephy(tp, 0x1f, 0x0000);
>  		rtl_writephy(tp, MII_BMCR, 0x0000);
>  
> -		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
> -		    tp->mac_version == RTL_GIGA_MAC_VER_33)
> +		if (tp->mac_version == RTL_GIGA_MAC_VER_29 ||
> +		    tp->mac_version == RTL_GIGA_MAC_VER_30 ||
> +		    tp->mac_version == RTL_GIGA_MAC_VER_32 ||
> +		    tp->mac_version == RTL_GIGA_MAC_VER_33 ||
> +		    tp->mac_version == RTL_GIGA_MAC_VER_34)
>  			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
>  				AcceptMulticast | AcceptMyPhys);

Fine for RTL_GIGA_MAC_VER_34 but RTL_GIGA_MAC_VER_29 and RTL_GIGA_MAC_VER_29
use r810x_pll_power_{up/down}, not their r8168_pll_xyz siblings.

-- 
Ueimor
