From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: net: phy: realtek: add rtl8201f driver
Date: Wed, 8 May 2013 12:41:20 +0200
Message-ID: <20130508104119.GA24905@electric-eye.fr.zoreil.com>
References: <201305081910.27203.neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jongsung Kim <neidhard.kim@lge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201305081910.27203.neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jongsung Kim <neidhard.kim@lge.com> :
> This patch adds the minimal driver to manage the
> Realtek RTL8201F 10/100Mbps Transceivers.

Your patch contains both "remove unused #define" and "support new hardware"
parts. I am not sure that the former is adequate for submission until
net-next opens.

> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
[...]
> +static int rtl8201f_config_intr(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	phy_write(phydev, RTL8201F_PSR, 0x0007);	/* select page 7 */

static void rtl8201f_page_select(struct phy_device *phydev, int page) ?

[...]
> @@ -96,16 +141,16 @@ static struct phy_driver rtl8211e_driver = {
>  
>  static int __init realtek_init(void)
>  {
> -	int ret;
> -
> -	ret = phy_driver_register(&rtl8211b_driver);
> -	if (ret < 0)
> +	if(phy_driver_register(&rtl8201f_driver) < 0)
         ^^ -> missing space.

> +		return -ENODEV;

Please propagate phy_driver_register error code.

> +	if(phy_driver_register(&rtl8211b_driver) < 0)
>  		return -ENODEV;
>  	return phy_driver_register(&rtl8211e_driver);

Unbalanced error paths.

>  }
>  
>  static void __exit realtek_exit(void)
>  {
> +	phy_driver_unregister(&rtl8201f_driver);
>  	phy_driver_unregister(&rtl8211b_driver);
>  	phy_driver_unregister(&rtl8211e_driver);

Code duplication.

You may use an array of phy_driver for realtek_{init/exit}

-- 
Ueimor
