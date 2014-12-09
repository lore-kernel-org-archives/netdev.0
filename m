From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 7/9] r8169:update rtl8168dp ephy parameter
Date: Wed, 10 Dec 2014 00:50:16 +0100
Message-ID: <20141209235016.GC22285@electric-eye.fr.zoreil.com>
References: <1418143563-7652-1-git-send-email-hau@realtek.com>
 <1418143563-7652-8-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418143563-7652-8-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index a979519..42eda35 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
>  static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
>  {
>  	void __iomem *ioaddr = tp->mmio_addr;
>  	struct pci_dev *pdev = tp->pci_dev;
>  	static const struct ephy_info e_info_8168d_4[] = {
> -		{ 0x0b, ~0,	0x48 },
> -		{ 0x19, 0x20,	0x50 },
> -		{ 0x0c, ~0,	0x20 }
> +		{ 0x0b, 0x0000,	0x0048 },
> +		{ 0x19, 0x0020,	0x0050 },
> +		{ 0x0c, 0x0100,	0x0020 },
> +		{ 0x10, 0x0004,	0x0000 }
>  	};
> -	int i;
>  
>  	rtl_csi_access_enable_1(tp);
>  
> -	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
> +	if (tp->dev->mtu <= ETH_DATA_LEN)
> +		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
[...]
> @@ -6328,11 +6308,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  		break;
>  
>  	case RTL_GIGA_MAC_VER_28:
> -		rtl_hw_start_8168d_4(tp);
> -		break;
> -
>  	case RTL_GIGA_MAC_VER_31:
> -		rtl_hw_start_8168dp(tp);
> +		rtl_hw_start_8168d_4(tp);

RTL_GIGA_MAC_VER_28 would thus use a mtu dependant rtl_tx_performance_tweak
in its hw_start handler but would not include one in its jumbo_ops helpers.

It does not seem completely right.

-- 
Ueimor
