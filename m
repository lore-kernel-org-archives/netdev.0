From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6] IB/{nes,
 ipoib}: Pass supported flags to ethtool_op_set_flags()
Date: Tue, 06 Jul 2010 09:22:58 -0700
Message-ID: <4C335862.5060703@oracle.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>	
	<20100702095514.7fb324c8.randy.dunlap@oracle.com>	
	<20100702.220711.39188625.davem@davemloft.net>	
	<20100703120729.f2a2715b.randy.dunlap@oracle.com>	
	<1278184884.4878.559.camel@localhost>
	<1278186089.4878.570.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, linux-net-drivers@solarflare.com, dm@chelsio.com,
	sgruszka@redhat.com, amwang@redhat.com,
	Faisal Latif <faisal.latif@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	anirban.chakraborty@qlogic.com, jgarzik@redhat.com,
	vkolluri@cisco.com, Chien Tung <chien.tin.tung@intel.com>,
	brice@myri.com, gallatin@myri.com, linux-rdma@vger.kernel.org,
	scofeldm@cisco.com, Roland Dreier <rolandd@cisco.com>,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
	roprabhu@cisco.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1278186089.4878.570.camel@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 07/03/10 12:41, Ben Hutchings wrote:
> Following commit 1437ce3983bcbc0447a0dedcd644c14fe833d266 "ethtool:
> Change ethtool_op_set_flags to validate flags", ethtool_op_set_flags
> takes a third parameter and cannot be used directly as an
> implementation of ethtool_ops::set_flags.
> 
> Changes nes and ipoib driver to pass in the appropriate value.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This is compile-tested only.

Ack, thanks.

> Dave, Roland, you'd better decide between yourselves should apply this.
> 
> Ben.
> 
>  drivers/infiniband/hw/nes/nes_nic.c          |    8 +++++++-
>  drivers/infiniband/ulp/ipoib/ipoib_ethtool.c |    7 ++++++-
>  2 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
> index 5cc0a9a..42e7aad 100644
> --- a/drivers/infiniband/hw/nes/nes_nic.c
> +++ b/drivers/infiniband/hw/nes/nes_nic.c
> @@ -1567,6 +1567,12 @@ static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd
>  }
>  
> 
> +static int nes_netdev_set_flags(struct net_device *netdev, u32 flags)
> +{
> +	return ethtool_op_set_flags(netdev, flags, ETH_FLAG_LRO);
> +}
> +
> +
>  static const struct ethtool_ops nes_ethtool_ops = {
>  	.get_link = ethtool_op_get_link,
>  	.get_settings = nes_netdev_get_settings,
> @@ -1588,7 +1594,7 @@ static const struct ethtool_ops nes_ethtool_ops = {
>  	.get_tso = ethtool_op_get_tso,
>  	.set_tso = ethtool_op_set_tso,
>  	.get_flags = ethtool_op_get_flags,
> -	.set_flags = ethtool_op_set_flags,
> +	.set_flags = nes_netdev_set_flags,
>  };
>  
> 
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
> index 40e8584..1a1657c 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
> @@ -147,6 +147,11 @@ static void ipoib_get_ethtool_stats(struct net_device *dev,
>  	data[index++] = priv->lro.lro_mgr.stats.no_desc;
>  }
>  
> +static int ipoib_set_flags(struct net_device *dev, u32 flags)
> +{
> +	return ethtool_op_set_flags(dev, flags, ETH_FLAG_LRO);
> +}
> +
>  static const struct ethtool_ops ipoib_ethtool_ops = {
>  	.get_drvinfo		= ipoib_get_drvinfo,
>  	.get_rx_csum		= ipoib_get_rx_csum,
> @@ -154,7 +159,7 @@ static const struct ethtool_ops ipoib_ethtool_ops = {
>  	.get_coalesce		= ipoib_get_coalesce,
>  	.set_coalesce		= ipoib_set_coalesce,
>  	.get_flags		= ethtool_op_get_flags,
> -	.set_flags		= ethtool_op_set_flags,
> +	.set_flags		= ipoib_set_flags,
>  	.get_strings		= ipoib_get_strings,
>  	.get_sset_count		= ipoib_get_sset_count,
>  	.get_ethtool_stats	= ipoib_get_ethtool_stats,


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
