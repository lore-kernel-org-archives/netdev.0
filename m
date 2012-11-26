From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH net-next] dsa: Hide core config options; make drivers
 select what they need
Date: Mon, 26 Nov 2012 11:53:20 -0800
Message-ID: <50B3C8B0.5000308@infradead.org>
References: <1353957370.2717.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34422 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab2KZTxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 14:53:31 -0500
In-Reply-To: <1353957370.2717.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2012 11:16 AM, Ben Hutchings wrote:

> Commit 82167cb8c6b2f8166d5c7532e5ef4b5e0cc46a72 ('net: dsa/slave: Fix
> compilation warnings') fixed one possible invalid configuration
> (NET_DSA enabled with no trailer formats) but added others: drivers
> can select NET_DSA without its dependencies being met.
> 
> It's not very useful to make either the DSA core or the tagging
> formats manually selectable without a driver to use them, so:
> 
> 1. Define a hidden HAVE_NET_DSA option and move the dependencies of
>    NET_DSA to that.  While we're at it, drop the deprecated
>    EXPERIMENTAL dependency.
> 2. Make NET_DSA and the drivers dependent on HAVE_NET_DSA.
> 3. Hide the tagging format options again.
> 4. Make drivers select both NET_DSA and the appropriate tagging format
>    option.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>


Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  drivers/net/dsa/Kconfig |    4 ++++
>  net/dsa/Kconfig         |   30 +++++++++++++-----------------
>  2 files changed, 17 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index 96eae22..b8fe808 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -1,4 +1,5 @@
>  menu "Distributed Switch Architecture drivers"
> +	depends on HAVE_NET_DSA
>  
>  config NET_DSA_MV88E6XXX
>  	tristate
> @@ -6,6 +7,7 @@ config NET_DSA_MV88E6XXX
>  
>  config NET_DSA_MV88E6060
>  	tristate "Marvell 88E6060 ethernet switch chip support"
> +	select NET_DSA
>  	select NET_DSA_TAG_TRAILER
>  	---help---
>  	  This enables support for the Marvell 88E6060 ethernet switch
> @@ -17,6 +19,7 @@ config NET_DSA_MV88E6XXX_NEED_PPU
>  
>  config NET_DSA_MV88E6131
>  	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
> +	select NET_DSA
>  	select NET_DSA_MV88E6XXX
>  	select NET_DSA_MV88E6XXX_NEED_PPU
>  	select NET_DSA_TAG_DSA
> @@ -26,6 +29,7 @@ config NET_DSA_MV88E6131
>  
>  config NET_DSA_MV88E6123_61_65
>  	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
> +	select NET_DSA
>  	select NET_DSA_MV88E6XXX
>  	select NET_DSA_TAG_EDSA
>  	---help---
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 0f5dc34..f5eede1 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -1,28 +1,24 @@
> +config HAVE_NET_DSA
> +	def_bool y
> +	depends on NETDEVICES && !S390
> +
> +# Drivers must select NET_DSA and the appropriate tagging format
> +
>  config NET_DSA
>  	tristate
> -	default n
> -	depends on EXPERIMENTAL && NETDEVICES && !S390
> +	depends on HAVE_NET_DSA
>  	select PHYLIB
> -	---help---
> -	  This allows you to use hardware switch chips that use
> -	  the Distributed Switch Architecture.
>  
> -
> -menu "Distributed Switch Architecture support"
> +if NET_DSA
>  
>  # tagging formats
>  config NET_DSA_TAG_DSA
> -	bool "Original DSA packet tagging format"
> -	select NET_DSA
> -	default n
> +	bool
>  
>  config NET_DSA_TAG_EDSA
> -	bool "Ethertype DSA packet tagging format"
> -	select NET_DSA
> -	default n
> +	bool
>  
>  config NET_DSA_TAG_TRAILER
> -	bool "Trailer DSA packet tagging format"
> -	select NET_DSA
> -	default n
> -endmenu
> +	bool
> +
> +endif



-- 
~Randy
