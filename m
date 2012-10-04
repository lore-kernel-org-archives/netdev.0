From: hayeswang <hayeswang@realtek.com>
Subject: RE: Possible bug with r8169 driver
Date: Thu, 4 Oct 2012 10:09:22 +0800
Message-ID: <2B85B2AE7F334F8CBC4C4A084CA849FB@realtek.com.tw>
References: <2197741.c8FeV4Xbis@bureau> <20120927222147.GA29047@electric-eye.fr.zoreil.com> <1478421.GOy9qdQlkG@bureau> <20120929072028.GA3730@electric-eye.fr.zoreil.com> <262549102A0343EDA34AA0A41217180C@realtek.com.tw> <20121001185629.GA4922@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Nolwenn' <donolwenn@gmail.com>, <netdev@vger.kernel.org>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50150 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab2JDCJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 22:09:34 -0400
In-Reply-To: <20121001185629.GA4922@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c 
> b/drivers/net/ethernet/realtek/r8169.c
> index eb81da4..e0f1b8d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4271,8 +4271,8 @@ static void rtl_set_rx_mode(struct 
> net_device *dev)
>  		mc_filter[1] = swab32(data);
>  	}
>  
> -	RTL_W32(MAR0 + 4, mc_filter[1]);
> -	RTL_W32(MAR0 + 0, mc_filter[0]);
> +	RTL_W32(MAR0 + 4, 0xffffffff);
> +	RTL_W32(MAR0 + 0, 0xffffffff);
>  
>  	RTL_W32(RxConfig, tmp);
>  }

The RTL_GIGA_MAC_VER_35 is designed without multicast hardware filter, so you
should set IO 0x08 ~ 0x0f to 0xff for receiving all multicast packets without
filtering them.

Best Regards,
Hayes
