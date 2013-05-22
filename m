From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: [PATCH v4 11/12] ARM: kirkwood: remove redundant DT board files
Date: Wed, 22 May 2013 22:36:33 +0200
Message-ID: <20130522203633.GA28394@schnuecks.de>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-12-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369154510-4927-12-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

On Tue, May 21, 2013 at 06:41:49PM +0200, Sebastian Hesselbarth wrote:
> With DT support for mv643xx_eth, board specific init for some boards now
> is unneccessary. Remove those board files, Kconfig entries, and
> corresponding entries in kirkwood_defconfig.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Note: board-km_kirkwood.c is also removed, as Valentin Longchamp confirmed
> the lock-up is not caused by accessing clock gating registers but rather
> non-existent device registers. This will be addressed by dtsi separation
> for kirkwood and bobcat SoC variants.
> 
> Changelog:
> v3->v4:
> - remove more boards that don't require board specific setup
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  arch/arm/configs/kirkwood_defconfig           |   16 ----
>  arch/arm/mach-kirkwood/Kconfig                |  117 -------------------------
>  arch/arm/mach-kirkwood/Makefile               |   16 ----
>  arch/arm/mach-kirkwood/board-dnskw.c          |    7 --
>  arch/arm/mach-kirkwood/board-dockstar.c       |   32 -------
>  arch/arm/mach-kirkwood/board-dreamplug.c      |   35 --------
>  arch/arm/mach-kirkwood/board-dt.c             |   38 --------
>  arch/arm/mach-kirkwood/board-goflexnet.c      |   34 -------
>  arch/arm/mach-kirkwood/board-guruplug.c       |   33 -------
>  arch/arm/mach-kirkwood/board-ib62x0.c         |   29 ------
>  arch/arm/mach-kirkwood/board-iconnect.c       |   10 ---
>  arch/arm/mach-kirkwood/board-iomega_ix2_200.c |   34 -------
>  arch/arm/mach-kirkwood/board-km_kirkwood.c    |   44 ----------
>  arch/arm/mach-kirkwood/board-lsxl.c           |   16 ----
>  arch/arm/mach-kirkwood/board-mplcec4.c        |   14 ---
>  arch/arm/mach-kirkwood/board-ns2.c            |   35 --------
>  arch/arm/mach-kirkwood/board-openblocks_a6.c  |   26 ------
>  arch/arm/mach-kirkwood/board-readynas.c       |    6 --
>  arch/arm/mach-kirkwood/board-ts219.c          |   13 ---
>  arch/arm/mach-kirkwood/board-usi_topkick.c    |   29 ------
>  20 files changed, 584 deletions(-)
>  delete mode 100644 arch/arm/mach-kirkwood/board-dockstar.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-dreamplug.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-goflexnet.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-guruplug.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-ib62x0.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-iomega_ix2_200.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-km_kirkwood.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-ns2.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-openblocks_a6.c
>  delete mode 100644 arch/arm/mach-kirkwood/board-usi_topkick.c
> 
...
> diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
> index 8db388a..a86b41c 100644
> --- a/arch/arm/mach-kirkwood/board-dt.c
> +++ b/arch/arm/mach-kirkwood/board-dt.c
> @@ -104,59 +104,21 @@ static void __init kirkwood_dt_init(void)
>  	kexec_reinit = kirkwood_enable_pcie;
>  #endif
>  
> -	if (of_machine_is_compatible("globalscale,dreamplug"))
> -		dreamplug_init();
> -
> -	if (of_machine_is_compatible("globalscale,guruplug"))
> -		guruplug_dt_init();
> -
>  	if (of_machine_is_compatible("dlink,dns-kirkwood"))
>  		dnskw_init();
>  
> -	if (of_machine_is_compatible("iom,iconnect"))
> -		iconnect_init();
> -
> -	if (of_machine_is_compatible("raidsonic,ib-nas62x0"))
> -		ib62x0_init();
> -
>  	if (of_machine_is_compatible("qnap,ts219"))
>  		qnap_dt_ts219_init();
>  
> -	if (of_machine_is_compatible("seagate,dockstar"))
> -		dockstar_dt_init();
> -
> -	if (of_machine_is_compatible("seagate,goflexnet"))
> -		goflexnet_init();
> -
>  	if (of_machine_is_compatible("buffalo,lsxl"))
>  		lsxl_init();
>  
> -	if (of_machine_is_compatible("iom,ix2-200"))
> -		iomega_ix2_200_init();
> -
> -	if (of_machine_is_compatible("keymile,km_kirkwood"))
> -		km_kirkwood_init();
> -
> -	if (of_machine_is_compatible("lacie,cloudbox") ||
> -	    of_machine_is_compatible("lacie,inetspace_v2") ||
> -	    of_machine_is_compatible("lacie,netspace_lite_v2") ||
> -	    of_machine_is_compatible("lacie,netspace_max_v2") ||
> -	    of_machine_is_compatible("lacie,netspace_mini_v2") ||
> -	    of_machine_is_compatible("lacie,netspace_v2"))
> -		ns2_init();
> -
>  	if (of_machine_is_compatible("mpl,cec4"))
>  		mplcec4_init();
>  
>  	if (of_machine_is_compatible("netgear,readynas-duo-v2"))
>  		netgear_readynas_init();
>  
> -	if (of_machine_is_compatible("plathome,openblocks-a6"))
> -		openblocks_a6_init();
> -
> -	if (of_machine_is_compatible("usi,topkick"))
> -		usi_topkick_init();
> -
>  	of_platform_populate(NULL, kirkwood_dt_match_table, NULL, NULL);
>  }

We still have:

static const char * const kirkwood_dt_board_compat[] = {
	"globalscale,dreamplug",
	"globalscale,guruplug",
	"dlink,dns-320",
	"dlink,dns-325",
	"iom,iconnect",
	"raidsonic,ib-nas62x0",
	"qnap,ts219",
	"seagate,dockstar",
	"seagate,goflexnet",
	"buffalo,lsxl",
	"iom,ix2-200",
	"keymile,km_kirkwood",
	"lacie,cloudbox",
	"lacie,inetspace_v2",
	"lacie,netspace_lite_v2",
	"lacie,netspace_max_v2",
	"lacie,netspace_mini_v2",
	"lacie,netspace_v2",
	"mpl,cec4",
	"netgear,readynas-duo-v2",
	"plathome,openblocks-a6",
	"usi,topkick",
	"zyxel,nsa310",
	NULL
};

in that file. I think it does not make sense that we need to list
boards here that can be described fully by DT. When adding such a
board in the future, you will still need to adapt board-dt.c.

Should we remove the boards that you removed above here as well and
add

	"marvell,kirkwood-88f6192",
	"marvell,kirkwood-88f6281",
	"marvell,kirkwood-88f6282",
	"marvell,kirkwood-88f6283",
	"marvell,kirkwood-88f6702",
	"marvell,kirkwood-98DX4122",

or even just state "marvell,kirkwood"?

- Simon
