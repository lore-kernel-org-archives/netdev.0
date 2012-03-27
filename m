From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/5] r8169: add csi_opt
Date: Wed, 28 Mar 2012 00:54:37 +0200
Message-ID: <20120327225437.GC22177@electric-eye.fr.zoreil.com>
References: <1332834834-5185-1-git-send-email-hayeswang@realtek.com> <1332834834-5185-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332834834-5185-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Modify the CSI relative functions by using csi_opt method.

I'll queue the series until Davem opens net-next.

We are supposed to be in a "merge previously queued patches and fix problems"
phase yet.

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3edb996..35b1fea 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> -static void rtl_csi_access_enable_2(void __iomem *ioaddr)
> +static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
>  {
> -	rtl_csi_access_enable(ioaddr, 0x27000000);
> +	struct csi_ops *ops = &tp->csi_ops;
> +
> +	switch (tp->mac_version) {
> +	default:
> +		ops->write	= r8169_csi_write;
> +		ops->read	= r8169_csi_read;
> +		break;
> +	}
>  }
>  
>  struct ephy_info {
[...]
> @@ -6199,6 +6267,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	rtl_init_mdio_ops(tp);
>  	rtl_init_pll_power_ops(tp);
>  	rtl_init_jumbo_ops(tp);
> +	rtl_init_csi_ops(tp);
>  
>  	rtl8169_print_mac_version(tp);

It will enable the CSI read/write functions where they previously weren't.

Is it really supposed to behave this way ?

Thanks.

-- 
Ueimor
