From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 01/10] ethtool: prevent null pointer
 dereference with NTUPLE set but no set_rx_ntuple
Date: Sat, 26 Feb 2011 00:21:15 +0000
Message-ID: <1298679675.3555.4.camel@localhost>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
	 <20110225233244.7920.26742.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28917 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932977Ab1BZAVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 19:21:21 -0500
In-Reply-To: <20110225233244.7920.26742.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-25 at 15:32 -0800, Alexander Duyck wrote:
> This change is meant to prevent a possible null pointer dereference if
> NETIF_F_NTUPLE is defined but the set_rx_ntuple function pointer is not.

I think it would be a bug for NETIF_F_NTUPLE to be enabled on a device
that doesn't have this operation.  Are there any drivers for which this
is possible?

> This issue appears to affect all kernels since 2.6.34.

If this can actually happen, the fix should go to net-2.6 and
stable@kernel.org.  However, I think that the null deference is
impossible and this really just fixes the error code.

Ben.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  net/core/ethtool.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..4843674 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -893,6 +893,9 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
>  	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
>  	int ret;
>  
> +	if (!ops->set_rx_ntuple)
> +		return -EOPNOTSUPP;
> +
>  	if (!(dev->features & NETIF_F_NTUPLE))
>  		return -EINVAL;
>  
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

