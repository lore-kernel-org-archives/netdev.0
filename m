From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 06/10] r8169:change function name and behavior
 of function "rtl_w1w0_phy"
Date: Wed, 1 Oct 2014 00:33:37 +0200
Message-ID: <20140930223337.GA27610@electric-eye.fr.zoreil.com>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
 <1412089230-10208-6-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chun-Hao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412089230-10208-6-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chun-Hao Lin <hau@realtek.com> :
> Change function name from "rtl_w1w0_phy" to "rtl_w0w1_phy".
> And its behavior from "or first then mask" to "mask first then or".

- I don't mind if its changed for a reason but the commit message doesn't
  tell why. Is it related to the overlap of the masks below ?

- rtl_w1w0_phy was supposed to abbreviate "write ones then write zeros"
  where parameters are taken in this order. You won't hit the 80 cols
  limit if you replace it with something like "rtl_set_clear_phy" (if you
  use something longer it won't fit for rtl_w1w0_eri).

[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 1bf6696..e68fe5e 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -3575,33 +3575,33 @@ static void rtl8168h_1_hw_phy_config(struct rtl8169_private *tp)
>  	/* CHN EST parameters adjust - giga master */
>  	rtl_writephy(tp, 0x1f, 0x0a43);
>  	rtl_writephy(tp, 0x13, 0x809b);
> -	rtl_w1w0_phy(tp, 0x14, 0x8000, 0xf800);
> +	rtl_w0w1_phy(tp, 0x14, 0x8000, 0xf800);
>  	rtl_writephy(tp, 0x13, 0x80a2);
> -	rtl_w1w0_phy(tp, 0x14, 0x8000, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x8000, 0xff00);
>  	rtl_writephy(tp, 0x13, 0x80a4);
> -	rtl_w1w0_phy(tp, 0x14, 0x8500, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x8500, 0xff00);
>  	rtl_writephy(tp, 0x13, 0x809c);
> -	rtl_w1w0_phy(tp, 0x14, 0xbd00, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0xbd00, 0xff00);
>  	rtl_writephy(tp, 0x1f, 0x0000);
>  
>  	/* CHN EST parameters adjust - giga slave */
>  	rtl_writephy(tp, 0x1f, 0x0a43);
>  	rtl_writephy(tp, 0x13, 0x80ad);
> -	rtl_w1w0_phy(tp, 0x14, 0x7000, 0xf800);
> +	rtl_w0w1_phy(tp, 0x14, 0x7000, 0xf800);
>  	rtl_writephy(tp, 0x13, 0x80b4);
> -	rtl_w1w0_phy(tp, 0x14, 0x5000, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x5000, 0xff00);
>  	rtl_writephy(tp, 0x13, 0x80ac);
> -	rtl_w1w0_phy(tp, 0x14, 0x4000, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x4000, 0xff00);
>  	rtl_writephy(tp, 0x1f, 0x0000);
>  
>  	/* CHN EST parameters adjust - fnet */
>  	rtl_writephy(tp, 0x1f, 0x0a43);
>  	rtl_writephy(tp, 0x13, 0x808e);
> -	rtl_w1w0_phy(tp, 0x14, 0x1200, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x1200, 0xff00);
>  	rtl_writephy(tp, 0x13, 0x8090);
> -	rtl_w1w0_phy(tp, 0x14, 0xe500, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0xe500, 0xff00);
>  	rtl_writephy(tp, 0x13, 0x8092);
> -	rtl_w1w0_phy(tp, 0x14, 0x9f00, 0xff00);
> +	rtl_w0w1_phy(tp, 0x14, 0x9f00, 0xff00);
>  	rtl_writephy(tp, 0x1f, 0x0000);
>  
>  	/* enable R-tune & PGA-retune function */
> @@ -3620,57 +3620,57 @@ static void rtl8168h_1_hw_phy_config(struct rtl8169_private *tp)
>  	dout_tapbin &= 0xf000;
>  	rtl_writephy(tp, 0x1f, 0x0a43);
>  	rtl_writephy(tp, 0x13, 0x827a);
> -	rtl_w1w0_phy(tp, 0x14, dout_tapbin, 0xf000);
> +	rtl_w0w1_phy(tp, 0x14, dout_tapbin, 0xf000);
>  	rtl_writephy(tp, 0x13, 0x827b);
> -	rtl_w1w0_phy(tp, 0x14, dout_tapbin, 0xf000);
> +	rtl_w0w1_phy(tp, 0x14, dout_tapbin, 0xf000);
>  	rtl_writephy(tp, 0x13, 0x827c);
> -	rtl_w1w0_phy(tp, 0x14, dout_tapbin, 0xf000);
> +	rtl_w0w1_phy(tp, 0x14, dout_tapbin, 0xf000);
>  	rtl_writephy(tp, 0x13, 0x827d);
> -	rtl_w1w0_phy(tp, 0x14, dout_tapbin, 0xf000);
> +	rtl_w0w1_phy(tp, 0x14, dout_tapbin, 0xf000);
[...]

-- 
Ueimor
