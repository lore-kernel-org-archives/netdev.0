From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] sfc: Fix dependency for SFC_MTD
Date: Wed, 19 Nov 2008 13:37:50 -0800
Message-ID: <4924872E.5070102@oracle.com>
References: <20081119204850.GF8240@solarflare.com> <20081119205353.GG8240@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	David Woodhouse <dwmw2@infradead.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50178 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbYKSViJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 16:38:09 -0500
In-Reply-To: <20081119205353.GG8240@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Randy Dunlap found that SFC_MTD was selected when sfc was built-in and
> the MTD core was a module.  Don't allow that combination.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

I realized that this problem came up because SFC_MTD is a boolean
that depends on tristates, so the boolean is set (=y) when
SFC=y or SFC=m.  Thus extra handling for it is needed,
like Ben did here.

> ---
>  drivers/net/sfc/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> Now with S-o-b; sorry for the spam.
> 
> Ben.
> 
> diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
> index 3e25fb3..c535408 100644
> --- a/drivers/net/sfc/Kconfig
> +++ b/drivers/net/sfc/Kconfig
> @@ -14,7 +14,7 @@ config SFC
>  	  will be called sfc.
>  config SFC_MTD
>  	bool "Solarflare Solarstorm SFC4000 flash MTD support"
> -	depends on SFC && MTD
> +	depends on SFC && MTD && !(SFC=y && MTD=m)
>  	default y
>  	help
>  	  This exposes the on-board flash memory as an MTD device (e.g.

