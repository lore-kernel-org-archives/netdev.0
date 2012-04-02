From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 net-next 08/28] ethtool: Add a common
 function for drivers with transmit time stamping.
Date: Mon, 2 Apr 2012 18:34:45 +0100
Message-ID: <1333388085.2623.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
	<7eca521e2f9db67dab89a9c2bfd62b8fdff587f3.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>, Martin,
	Jacob Keller <jacob.e.keller@intel.com>, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7eca521e2f9db67dab89a9c2bfd62b8fdff587f3.1333289292.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-01 at 17:19 +0200, Richard Cochran wrote:
> Currently, most drivers do not support transmit SO_TIMESTAMPING. For those
> that do support it, there is one appropriate response to the get_ts_info
> query. This patch adds a common function providing this response.

This looks fine but obviously depends on the other ethtool change.

Ben.

> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  include/linux/ethtool.h |    1 +
>  net/core/ethtool.c      |   11 +++++++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 776b3d0..0245d1d 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -806,6 +806,7 @@ struct net_device;
>  
>  /* Some generic methods drivers may use in their ethtool_ops */
>  u32 ethtool_op_get_link(struct net_device *dev);
> +int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti);
>  
>  /**
>   * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index d6eff4b..14bb8b1 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -38,6 +38,17 @@ u32 ethtool_op_get_link(struct net_device *dev)
>  }
>  EXPORT_SYMBOL(ethtool_op_get_link);
>  
> +int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
> +{
> +	info->so_timestamping =
> +		SOF_TIMESTAMPING_TX_SOFTWARE |
> +		SOF_TIMESTAMPING_RX_SOFTWARE |
> +		SOF_TIMESTAMPING_SOFTWARE;
> +	info->phc_index = -1;
> +	return 0;
> +}
> +EXPORT_SYMBOL(ethtool_op_get_ts_info);
> +
>  /* Handlers for each ethtool command */
>  
>  #define ETHTOOL_DEV_FEATURE_WORDS	((NETDEV_FEATURE_COUNT + 31) / 32)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
