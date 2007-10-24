From: Glen Gray <glen.gray@lincor.com>
Subject: Re: [PATCH 13/13] r8169: more phy init for the 8168
Date: Wed, 24 Oct 2007 10:29:11 +0100
Message-ID: <471F1067.50403@lincor.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com> <20071018210224.GN31724@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:4138 "EHLO
	smtp2.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750998AbXJXJko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 05:40:44 -0400
In-Reply-To: <20071018210224.GN31724@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are any of these likely to fix the Ethernet multicast issues a few of us 
have seen with 8110sc cards ?

Francois Romieu wrote:
> Realtek's r8168 driver version 8.003.00 adds new init sequences
> (they do not appear in version 8.002.00).
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |   34 ++++++++++++++++++++++++++++++++++
>  1 files changed, 34 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 8ffd573..e8960f2 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1243,6 +1243,16 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
>  
>  	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
>  }
> +static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
> +{
> +	struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0000 },
> +		{ 0x10, 0xf41b },
> +		{ 0x1f, 0x0000 }
> +	};
> +
> +	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}
>  
>  static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
>  {
> @@ -1279,6 +1289,22 @@ static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
>  	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
>  }
>  
> +static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
> +{
> +	struct phy_reg phy_reg_init[] = {
> +		{ 0x1f, 0x0000 },
> +		{ 0x12, 0x2300 },
> +		{ 0x1f, 0x0003 },
> +		{ 0x16, 0x0f0a },
> +		{ 0x1f, 0x0000 },
> +		{ 0x1f, 0x0002 },
> +		{ 0x0c, 0x7eb8 },
> +		{ 0x1f, 0x0000 }
> +	};
> +
> +	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
> +}
> +
>  static void rtl_hw_phy_config(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
> @@ -1296,12 +1322,20 @@ static void rtl_hw_phy_config(struct net_device *dev)
>  	case RTL_GIGA_MAC_VER_04:
>  		rtl8169sb_hw_phy_config(ioaddr);
>  		break;
> +	case RTL_GIGA_MAC_VER_11:
> +	case RTL_GIGA_MAC_VER_12:
> +	case RTL_GIGA_MAC_VER_17:
> +		rtl8168b_hw_phy_config(ioaddr);
> +		break;
>  	case RTL_GIGA_MAC_VER_18:
>  		rtl8168cp_hw_phy_config(ioaddr);
>  		break;
>  	case RTL_GIGA_MAC_VER_19:
>  		rtl8168c_hw_phy_config(ioaddr);
>  		break;
> +	case RTL_GIGA_MAC_VER_20:
> +		rtl8168cx_hw_phy_config(ioaddr);
> +		break;
>  	default:
>  		break;
>  	}
>   


-- 
Glen Gray <glen@lincor.com>              Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

