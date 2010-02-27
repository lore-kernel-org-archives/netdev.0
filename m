From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH v2] ethtool: Add direct access to
 ops->get_sset_count
Date: Sat, 27 Feb 2010 04:37:14 +0000
Message-ID: <1267245434.16186.81.camel@localhost>
References: <20100227034927.1123.8292.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Garzik <jgarzik@redhat.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55387 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967794Ab0B0EhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 23:37:22 -0500
In-Reply-To: <20100227034927.1123.8292.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 19:49 -0800, Jeff Kirsher wrote:
> From: Jeff Garzik <jgarzik@redhat.com>
> 
> This patch is an alternative approach for accessing string
> counts, vs. the drvinfo indirect approach.  This way the drvinfo
> space doesn't run out, and we don't break ABI later.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Slander!

> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  include/linux/ethtool.h |   25 ++++++++++++-----
>  net/core/ethtool.c      |   71 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 89 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index cca1c3d..ff2a49c 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -239,10 +239,10 @@ struct ethtool_pauseparam {
>  
>  #define ETH_GSTRING_LEN		32
>  enum ethtool_stringset {
> -	ETH_SS_TEST		= 0,
> -	ETH_SS_STATS,
> -	ETH_SS_PRIV_FLAGS,
> -	ETH_SS_NTUPLE_FILTERS,
> +	ETH_SS_TEST		= (1 << 0),
> +	ETH_SS_STATS		= (1 << 1),
> +	ETH_SS_PRIV_FLAGS	= (1 << 2),
> +	ETH_SS_NTUPLE_FILTERS	= (1 << 3),
>  };
[...]

This breaks the established ABI for ETHTOOL_GSTRINGS.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

