From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix auto speed down issue
Date: Sat, 30 Mar 2013 13:43:19 +0100
Message-ID: <20130330124319.GB19236@electric-eye.fr.zoreil.com>
References: <1364541062-9024-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bowgotsai@google.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364541062-9024-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 28fb50a..a9eedf7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -3818,6 +3818,21 @@ static void rtl_init_mdio_ops(struct rtl8169_private *tp)
>  	}
>  }
>  
> +static void rtl_speed_down(struct rtl8169_private *tp)
> +{
> +	u32	adv;
> +	int	lpa;
> +
> +	rtl_writephy(tp, 0x1f, 0x0000);
> +	lpa = rtl_readphy(tp, MII_LPA);
> +
> +	adv = ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full;
> +	if (!(lpa & (ADVERTISE_10HALF | ADVERTISE_10FULL)))

You may use the LPA_* #defines here.

-- 
Ueimor
