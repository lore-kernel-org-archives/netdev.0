From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 3/3] ethernet: arc: Add support for specific SoC glue layer device tree bindings
Date: Tue, 26 Aug 2014 11:44:17 +0200
Message-ID: <6043486.sQSNjC9EMf@wuerfel>
References: <1409045032-29604-1-git-send-email-romain.perier@gmail.com> <1409045032-29604-3-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, heiko@sntech.de, tklauser@distanz.ch,
	b.galvani@gmail.com, eric.dumazet@gmail.com,
	yongjun_wei@trendmicro.com.cn, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:52427 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458AbaHZJoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 05:44:30 -0400
In-Reply-To: <1409045032-29604-3-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code changes all look good in this version, but the Kconfig and changelog
are not yet perfect:

On Tuesday 26 August 2014 09:23:52 Romain Perier wrote:
> Some platforms have special bank registers which might be used to select
> the correct clock or the right mode for Media Indepent Interface controllers.
> Sometimes, it is also required to activate vcc regulators in the right order to supply
> the ethernet controller at the right time. This patch is an architecture refactoring
> of the arc-emac device driver. it adds a new software design which allows to add specific
> platform glue layer. Each platform has now its own module which performs custom initialization
> and remove for the target and then calls to the core driver.

Please restrict the changelog line width to something like 70 characters

> diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
> index 514c57f..e193826 100644
> --- a/drivers/net/ethernet/arc/Kconfig
> +++ b/drivers/net/ethernet/arc/Kconfig
> @@ -17,12 +17,16 @@ config NET_VENDOR_ARC
>  
>  if NET_VENDOR_ARC
>  
> -config ARC_EMAC
> -	tristate "ARC EMAC support"
> +config ARC_EMAC_CORE
> +	bool

This should be 'tristate', so you can build it as a loadable module
when ARC_EMAC is also a module. Kconfig will ensure it is set to 'y'
if any other built-in driver selects it, or to 'm' if it is selected
only by drivers that are also modules.

>  	select MII
>  	select PHYLIB
>  	depends on OF_IRQ
>  	depends on OF_NET
> +
> +config ARC_EMAC
> +	tristate "ARC EMAC support"
> +	select ARC_EMAC_CORE

The 'depends on' lines need to be moved below, otherwise you can still
enable ARC_EMAC if OF_IRQ and OF_NET are disabled.

	Arnd
