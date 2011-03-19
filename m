From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 13:38:38 -0700 (PDT)
Message-ID: <20110319.133838.71107089.davem@davemloft.net>
References: <201103191631.07952.oliver@neukum.org>
	<1300548821.2831.28.camel@edumazet-laptop>
	<1300549151.2831.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, anca.emanuel@gmail.com, piotr@hosowicz.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, torvalds@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300549151.2831.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Mar 2011 16:39:11 +0100

> [PATCH] r8169: fix a bug in rtl8169_init_phy()
> 
> commit 54405cde7624 (r8169: support control of advertising.)
> introduced a bug in rtl8169_init_phy()
> 
> Reported-by: Piotr Hosowicz <piotr@hosowicz.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6, thanks Eric.

Linus, this is definitely the bug you were seeing too.

> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 5e40351..493b0de 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2685,9 +2685,9 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
>  	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
>  		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
>  		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
> -		tp->mii.supports_gmii ?
> +		(tp->mii.supports_gmii ?
>  			ADVERTISED_1000baseT_Half |
> -			ADVERTISED_1000baseT_Full : 0);
> +			ADVERTISED_1000baseT_Full : 0));
>  
>  	if (RTL_R8(PHYstatus) & TBI_Enable)
>  		netif_info(tp, link, dev, "TBI auto-negotiating\n");
> 
> 
