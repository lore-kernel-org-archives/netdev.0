From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 1/2] r8169: enable ALDPS for power saving
Date: Tue, 23 Oct 2012 21:33:04 +0200
Message-ID: <20121023193304.GB10463@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <1350974831-1438-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1350974831-1438-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Enable ALDPS function to save power when link down. Note that the
> feature should be set after the other PHY settings. And the firmware
> is necessary. Don't enable it without loading the firmware.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
[...]

Please see my just sent answer in yesterday's thread.

> +static void r810x_aldps_disable(struct rtl8169_private *tp)
> +{
> +	rtl_writephy(tp, 0x1f, 0x0000);
> +	rtl_writephy(tp, 0x18, 0x0310);
> +	msleep(100);
> +}

rtl8402_hw_phy_config used a msleep(20). Meguesses it won't hurt, right ?

[...]
> +
> +	/* ALDPS enable */
> +	r8168_aldps_enable_1(tp);

The functions are literate enough: you can remove the comment.

[...]
> @@ -6391,6 +6431,8 @@ static void rtl8169_net_suspend(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> +	tp->features &= ~RTL_FEATURE_EXTENDED;
> +
>  	if (!netif_running(dev))
>  		return;

No (as previously stated).

-- 
Ueimor
