From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 01/13] net: mvneta: add configuration for MBUS windows access protection
Date: Wed, 25 Nov 2015 19:19:08 +0100
Message-ID: <87si3u7xib.fsf@free-electrons.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<1448178839-3541-2-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com, <stable@vger.kernel.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-2-git-send-email-mw@semihalf.com> (Marcin
	Wojtas's message of "Sun, 22 Nov 2015 08:53:47 +0100")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On dim., nov. 22 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> This commit adds missing configuration of MBUS windows access protection
> in mvneta_conf_mbus_windows function - a dedicated variable for that
> purpose remained there unused since v3.8 initial mvneta support. Because
> of that the register contents were inherited from the bootloader.

It looks OK for me and at least after applying the driver continues
working :)

I guess you find it when you tested suspend to ram.

Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Thanks,

Gregory


>
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Cc: <stable@vger.kernel.org> # v3.8+
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index e84c7f2..0f30aaa 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -62,6 +62,7 @@
>  #define MVNETA_WIN_SIZE(w)                      (0x2204 + ((w) << 3))
>  #define MVNETA_WIN_REMAP(w)                     (0x2280 + ((w) << 2))
>  #define MVNETA_BASE_ADDR_ENABLE                 0x2290
> +#define MVNETA_ACCESS_PROTECT_ENABLE		0x2294
>  #define MVNETA_PORT_CONFIG                      0x2400
>  #define      MVNETA_UNI_PROMISC_MODE            BIT(0)
>  #define      MVNETA_DEF_RXQ(q)                  ((q) << 1)
> @@ -3188,6 +3189,8 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
>  
>  		win_enable &= ~(1 << i);
>  		win_protect |= 3 << (2 * i);
> +
> +		mvreg_write(pp, MVNETA_ACCESS_PROTECT_ENABLE, win_protect);
>  	}
>  
>  	mvreg_write(pp, MVNETA_BASE_ADDR_ENABLE, win_enable);
> -- 
> 1.8.3.1
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
