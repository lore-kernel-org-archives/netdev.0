From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] pch_gbe: fix unmet direct dependency on PTP_1588_CLOCK_PCH
Date: Mon, 09 Sep 2013 13:00:37 -0700
Message-ID: <522E28E5.5010106@infradead.org>
References: <1378754910-2254-1-git-send-email-murzin.v@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ben@decadent.org.uk,
	jeffrey.t.kirsher@intel.com, rdunlap@xenotime.net,
	haicheng.lee@gmail.com
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59642 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3IIUBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 16:01:17 -0400
In-Reply-To: <1378754910-2254-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/13 12:28, Vladimir Murzin wrote:
> While cross-building for PPC.
> 
> warning: (PCH_GBE) selects PTP_1588_CLOCK_PCH which has unmet direct
> dependencies (X86 || COMPILE_TEST)
> 
> Both PCH_GBE and PPT_1588_CLOCK_PCH is only compatible with Intel
> architecture. Add dependency on x86 for PCH_GBE. Keep COMPILE_TEST to allow
> building on different arches.
> 
> Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> index cb22341..4a935ec 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
> @@ -4,7 +4,7 @@
>  
>  config PCH_GBE
>  	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
> -	depends on PCI
> +	depends on PCI && (x86 || COMPILE_TEST)

Has this been tested?
That should be             X86

>  	select MII
>  	select PTP_1588_CLOCK_PCH
>  	---help---
> 


-- 
~Randy
