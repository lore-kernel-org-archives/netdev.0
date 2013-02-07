From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/5] r8169: Modify the method for setting firmware
Date: Thu, 7 Feb 2013 01:02:52 +0100
Message-ID: <20130207000252.GB2784@electric-eye.fr.zoreil.com>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com> <1360161987-3268-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360161987-3268-3-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Remove useless action PHY_READ_EFUSE, and define the new action
> PHY_MDIO_CHG.
> 
> PHY_MDIO_CHG is used to modify the mdio operation. By the way, the
> firmware could support setting mac ocp.
> 
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index d1bee4c..55a7fb5 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -2321,8 +2339,15 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
>  		case PHY_BJMPN:
>  			index -= regno;
>  			break;
> -		case PHY_READ_EFUSE:
> -			predata = rtl8168d_efuse_read(tp, regno);
> +		case PHY_MDIO_CHG:
> +			if (data == 0) {
> +				ops->write = org.write;
> +				ops->read = org.read;
> +			} else if (data == 1) {
> +				ops->write = mac_mcu_write;
> +				ops->read = mac_mcu_read;
> +			}

Did you check that none of rtl_nic/rtl8168d-{1, 2}.fw uses PHY_READ_EFUSE ?

-- 
Ueimor
