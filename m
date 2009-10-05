From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] dcb: data center bridging ops should be
	r/o
Date: Mon, 05 Oct 2009 13:08:18 -0700
Message-ID: <1254773298.2667.27.camel@localhost.localdomain>
References: <20091005090103.0340ef29@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	David Miller <davem@davemloft.net>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091005090103.0340ef29@s6510>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2009-10-05 at 09:01 -0700, Stephen Hemminger wrote:
> The data center bridging ops structure can be const
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

Thanks Stephen, that was an oversight.

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

> --- a/drivers/net/ixgbe/ixgbe.h	2009-10-03 21:40:25.712809970 -0700
> +++ b/drivers/net/ixgbe/ixgbe.h	2009-10-03 21:40:33.490342038 -0700
> @@ -397,7 +397,7 @@ enum ixgbe_boards {
>  extern struct ixgbe_info ixgbe_82598_info;
>  extern struct ixgbe_info ixgbe_82599_info;
>  #ifdef CONFIG_IXGBE_DCB
> -extern struct dcbnl_rtnl_ops dcbnl_ops;
> +extern const struct dcbnl_rtnl_ops dcbnl_ops;
>  extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
>                                struct ixgbe_dcb_config *dst_dcb_cfg,
>                                int tc_max);
> --- a/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-10-03 21:39:54.710299317 -0700
> +++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-10-03 21:40:05.990317034 -0700
> @@ -563,7 +563,7 @@ static u8 ixgbe_dcbnl_setapp(struct net_
>  	return rval;
>  }
>  
> -struct dcbnl_rtnl_ops dcbnl_ops = {
> +const struct dcbnl_rtnl_ops dcbnl_ops = {
>  	.getstate	= ixgbe_dcbnl_get_state,
>  	.setstate	= ixgbe_dcbnl_set_state,
>  	.getpermhwaddr	= ixgbe_dcbnl_get_perm_hw_addr,
> --- a/include/linux/netdevice.h	2009-10-03 21:40:52.730300256 -0700
> +++ b/include/linux/netdevice.h	2009-10-03 21:41:10.362812001 -0700
> @@ -909,7 +909,7 @@ struct net_device
>  
>  #ifdef CONFIG_DCB
>  	/* Data Center Bridging netlink ops */
> -	struct dcbnl_rtnl_ops *dcbnl_ops;
> +	const struct dcbnl_rtnl_ops *dcbnl_ops;
>  #endif
>  
>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
