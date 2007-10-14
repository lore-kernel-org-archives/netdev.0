From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH v3 3/4] FEC mpc52xx: the driver
Date: Sun, 14 Oct 2007 15:43:25 -0600
Message-ID: <fa686aa40710141443u4defd1f4m8076a730a185135b@mail.gmail.com>
References: <20071014075511.GC3000@nd47.coderock.org>
	 <20071014075921.GF3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org, tnt@246tnt.com, netdev@vger.kernel.org
To: "Domen Puncer" <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:46759 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759532AbXJNVn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 17:43:27 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1727712wah
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 14:43:25 -0700 (PDT)
In-Reply-To: <20071014075921.GF3000@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/07, Domen Puncer <domen.puncer@telargo.com> wrote:
> Driver for ethernet on mpc5200/mpc5200b SoCs (FEC).
>
>
> Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

Looks quite good to me.  Comments below...

>
> ---
>  drivers/net/Kconfig              |    1
>  drivers/net/Makefile             |    1
>  drivers/net/fec_mpc52xx/Kconfig  |   15
>  drivers/net/fec_mpc52xx/Makefile |    2
>  drivers/net/fec_mpc52xx/fec.c    | 1098 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/fec_mpc52xx/fec.h    |  313 +++++++++++
>  6 files changed, 1430 insertions(+)
>
> Index: linux.git/drivers/net/Kconfig
> ===================================================================
> --- linux.git.orig/drivers/net/Kconfig
> +++ linux.git/drivers/net/Kconfig
> @@ -1894,6 +1894,7 @@ config NE_H8300
>           controller on the Renesas H8/300 processor.
>
>  source "drivers/net/fec_8xx/Kconfig"
> +source "drivers/net/fec_mpc52xx/Kconfig"

Personally, I'd just add the mpc52xx items to drivers/net/Kconfig; but
I won't make a fuss either way.

===================================================================
> --- linux.git.orig/drivers/net/Makefile
> +++ linux.git/drivers/net/Makefile
> @@ -210,6 +210,7 @@ obj-$(CONFIG_SMC911X) += smc911x.o
>  obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
>  obj-$(CONFIG_DM9000) += dm9000.o
>  obj-$(CONFIG_FEC_8XX) += fec_8xx/
> +obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx/

Ditto here;  Heck, we're only talking about 3 files here.  I'd
probably put all three into drivers/net...  or even merge the 2 .c and
one .h files into a single file.  But, again, it's not a big deal.

>  obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
>  obj-$(CONFIG_MLX4_CORE) += mlx4/
>
> Index: linux.git/drivers/net/fec_mpc52xx/Kconfig
> ===================================================================
> --- /dev/null
> +++ linux.git/drivers/net/fec_mpc52xx/Kconfig
> @@ -0,0 +1,15 @@
> +menu "MPC5200 Networking Options"
> +       depends PPC_MPC52xx && NET_ETHERNET

Drop the menu

> +
> +config FEC_MPC52xx
> +       tristate "FEC driver"
> +       depends on NET_ETHERNET

Drop "NET_ETHERNET"; if you're here, then NET_ETHERNET *is* selected.
Add "PPC_MPC52xx"

> +       select PPC_BESTCOMM
> +       select PPC_BESTCOMM_FEC
> +       select CRC32
> +       select PHYLIB
> +       ---help---
> +         This option enables support for the MPC5200's on-chip
> +         Fast Ethernet Controller
> +
> +endmenu
> Index: linux.git/drivers/net/fec_mpc52xx/Makefile
>

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
grant.likely@secretlab.ca
(403) 399-0195
