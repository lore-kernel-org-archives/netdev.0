From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 net 1/6] net: mvneta: add configuration for MBUS
 windows access protection
Date: Thu, 26 Nov 2015 19:25:22 +0100
Message-ID: <20151126192522.25b297ec@free-electrons.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
	<1448561293-16431-2-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com, <stable@vger.kernel.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46315 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752826AbbKZSZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 13:25:30 -0500
In-Reply-To: <1448561293-16431-2-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcin,

On Thu, 26 Nov 2015 19:08:08 +0100, Marcin Wojtas wrote:
> This commit adds missing configuration of MBUS windows access protection
> in mvneta_conf_mbus_windows function - a dedicated variable for that
> purpose remained there unused since v3.8 initial mvneta support. Because
> of that the register contents were inherited from the bootloader.
> 
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Cc: <stable@vger.kernel.org> # v3.8+
> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
> unit")

Is this actually fixing a user visible problem? If not, then I am not
sure it qualifies for stable.

> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index e84c7f2..c4327b9 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -62,6 +62,7 @@
>  #define MVNETA_WIN_SIZE(w)                      (0x2204 + ((w) << 3))
>  #define MVNETA_WIN_REMAP(w)                     (0x2280 + ((w) << 2))
>  #define MVNETA_BASE_ADDR_ENABLE                 0x2290
> +#define MVNETA_ACCESS_PROTECT_ENABLE		0x2294

Spaces are used for indentation in the definitions of all other
constants in this driver, so I think you should stick with this
convention, at least to remain consistent.

>  #define MVNETA_PORT_CONFIG                      0x2400
>  #define      MVNETA_UNI_PROMISC_MODE            BIT(0)
>  #define      MVNETA_DEF_RXQ(q)                  ((q) << 1)
> @@ -3188,9 +3189,11 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
>  
>  		win_enable &= ~(1 << i);
>  		win_protect |= 3 << (2 * i);
> +

Unneeded change.

>  	}
>  
>  	mvreg_write(pp, MVNETA_BASE_ADDR_ENABLE, win_enable);
> +	mvreg_write(pp, MVNETA_ACCESS_PROTECT_ENABLE, win_protect);
>  }

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
