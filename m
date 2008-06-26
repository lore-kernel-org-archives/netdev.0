From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Wed, 25 Jun 2008 22:48:29 -0700
Message-ID: <20080625224829.3c6f4789@extreme>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jie Yang <Jie.Yang@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50413 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbYFZFsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 01:48:32 -0400
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jun 2008 13:37:23 +0800
Jie Yang <Jie.Yang@Atheros.com> wrote:

> From: Jie Yang <jie.yang@atheros.com>
> 
> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114
> 
> Signed-off-by: Jie Yang <jie.yang @atheros.com>
> ---
> diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/atl1e/Makefile linux-2.6.25.3.atheros/drivers/net/atl1e/Makefile
> --- linux-2.6.25.3.orig/drivers/net/atl1e/Makefile      1970-01-01 08:00:00.000000000 +0800
> +++ linux-2.6.25.3.atheros/drivers/net/atl1e/Makefile   2008-06-20 11:22:34.000000000 +0800
> @@ -0,0 +1,2 @@
> +obj-$(CONFIG_ATL1E)    += atl1e.o
> +atl1e-y                        += atl1e_main.o atl1e_hw.o atl1e_ethtool.o atl1e_param.o
> diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/Kconfig linux-2.6.25.3.atheros/drivers/net/Kconfig
> --- linux-2.6.25.3.orig/drivers/net/Kconfig     2008-05-10 12:48:50.000000000 +0800
> +++ linux-2.6.25.3.atheros/drivers/net/Kconfig  2008-06-19 18:17:42.000000000 +0800
> @@ -2445,6 +2445,32 @@ config ATL1
>           To compile this driver as a module, choose M here.  The module
>           will be called atl1.
> 
> +config ATL1E
> +       tristate "Atheros L1e Gigabit Ethernet support (EXPERIMENTAL)"
> +       depends on PCI && EXPERIMENTAL
> +       select CRC32
> +       select MII
> +       help
> +         This driver supports the Atheros L1E gigabit ethernet adapter.
> +
> +         To compile this driver as a module, choose M here.  The module
> +         will be called atl1e.
> +
> +config ATL1E_NAPI
> +       bool "Use Rx Polling (NAPI)"
> +       depends on ATL1E
> +       help
> +         NAPI is a new driver API designed to reduce CPU and interrupt load
> +         when the driver is receiving lots of packets from the card. It is
> +         still somewhat experimental and thus not yet enabled by default.
> +
> +         If your estimated Rx load is 10kpps or more, or if the card will be
> +         deployed on potentially unfriendly networks (e.g. in a firewall),
> +         then say Y here.
> +
> +         If in doubt, say N.
> +
> +
>  endif # NETDEV_1000

Congratulations on the best new vendor driver submission to date.

I would prefer that the driver be NAPI only, because configuration choices
are hard for users and distribution to make correct choice. Plus it means two
choices for your QA to test.
