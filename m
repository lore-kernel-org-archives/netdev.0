From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 8/8] benet: Kconfig, Makefile, MAINTAINERS
Date: Sat, 5 Jul 2008 01:39:33 -0400
Message-ID: <20080705013933.91175119.billfink@mindspring.com>
References: <20080704165755.1c3a284c@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: "Subbu Seetharaman" <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:50631 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbYGEFjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 01:39:41 -0400
In-Reply-To: <20080704165755.1c3a284c@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Jul 2008, Subbu Seetharaman wrote:

> Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
> ---
>  MAINTAINERS          |    7 +++++++
>  drivers/net/Kconfig  |    8 ++++++++
>  drivers/net/Makefile |    1 +
>  3 files changed, 16 insertions(+), 0 deletions(-)

...

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f4182cf..78b4d6e 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2581,6 +2581,14 @@ config BNX2X
>  
>  source "drivers/net/sfc/Kconfig"
>  
> +config BENET
> +	tristate "ServerEngines 10Gb NIC - BladeEngine"
> +	depends on PCI
> +	select INET_LRO
> +	help
> +	  This driver implements the NIC functionality for ServerEngines
> +	  10Gb network adapter BladeEngine (EC 3210).
> +
>  endif # NETDEV_10000
>  
>  source "drivers/net/tokenring/Kconfig"

I'm no Kconfig expert, but based on previous driver discussions,
I believe the above depends needs to be changed to:

	depends on PCI && INET

to prevent certain build problems that can arise from having just
the "select INET_LRO" clause.

						-Bill
