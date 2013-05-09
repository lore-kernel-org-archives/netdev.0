From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2] net: smsc911x: don't artificially limit build
Date: Thu, 9 May 2013 11:26:50 +0100
Message-ID: <20130509102650.GC8258@e106331-lin.cambridge.arm.com>
References: <1368095027-8448-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:48609 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753547Ab3EIK1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 06:27:17 -0400
Content-Disposition: inline
In-Reply-To: <1368095027-8448-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should of course be PATCH, not PATCHv2.

I blame my shell's command history completion.

Mark.

On Thu, May 09, 2013 at 11:23:47AM +0100, Mark Rutland wrote:
> Currently the SMSC911X driver may only be built for a specific set of
> architectures, being limited to do so by a Kconfig depends line. This
> means that if a platform wishes to use the driver, its architecture must
> be added to the list explicitly, introducing pointless churn.
> 
> This may have been due to the driver's use of the {read,write}s{b,w,l}
> functions, which have since been replaced with the more standard
> io{read,write}{8,16,32}_rep. We can instead depend on HAS_IOMEM, which
> should prevent build issues while allowing the driver to be built for
> currently unlisted architectures, including x86 and arm64.
> 
> This patch removes the explicit list of architectures from the driver's
> depend line, and replaces it with a dependency on HAS_IOMEM.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/smsc/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
> index bb4c167..ff9e994 100644
> --- a/drivers/net/ethernet/smsc/Kconfig
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -97,7 +97,7 @@ config SMC911X
>  
>  config SMSC911X
>  	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
> -	depends on (ARM || SUPERH || BLACKFIN || MIPS || MN10300)
> +	depends on HAS_IOMEM
>  	select CRC32
>  	select NET_CORE
>  	select MII
> -- 
> 1.8.1.1
> 
