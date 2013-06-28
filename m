From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH next] xen: Use more current logging styles
Date: Fri, 28 Jun 2013 09:11:42 -0400
Message-ID: <20130628131142.GB3532@phenom.dumpdata.com>
References: <1372395469.2060.36.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, xen-devel@lists.xensource.com,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "virtualization@lists.osdl.org"
	<virtualization@lists.linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1372395469.2060.36.camel@joe-AO722>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 27, 2013 at 09:57:49PM -0700, Joe Perches wrote:
> Instead of mixing printk and pr_<level> forms,
> just use pr_<level>
> 
> Miscellaneous changes around these conversions:
> 
> Add a missing newline to avoid message interleaving,
> coalesce formats, reflow modified lines to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/xen-netback/netback.c |  7 +++----
>  drivers/net/xen-netfront.c        | 28 +++++++++++++---------------

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>  2 files changed, 16 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 130bcb2..64828de 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1890,9 +1890,8 @@ static int __init netback_init(void)
>  		return -ENODEV;
>  
>  	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
> -		printk(KERN_INFO
> -		       "xen-netback: fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
> -		       fatal_skb_slots, XEN_NETBK_LEGACY_SLOTS_MAX);
> +		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
> +			fatal_skb_slots, XEN_NETBK_LEGACY_SLOTS_MAX);
>  		fatal_skb_slots = XEN_NETBK_LEGACY_SLOTS_MAX;
>  	}
>  
> @@ -1921,7 +1920,7 @@ static int __init netback_init(void)
>  					     "netback/%u", group);
>  
>  		if (IS_ERR(netbk->task)) {
> -			printk(KERN_ALERT "kthread_create() fails at netback\n");
> +			pr_alert("kthread_create() fails at netback\n");
>  			del_timer(&netbk->net_timer);
>  			rc = PTR_ERR(netbk->task);
>  			goto failed_init;
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 76a2236..ff7f111 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -29,6 +29,8 @@
>   * IN THE SOFTWARE.
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/netdevice.h>
> @@ -385,9 +387,8 @@ static void xennet_tx_buf_gc(struct net_device *dev)
>  			skb = np->tx_skbs[id].skb;
>  			if (unlikely(gnttab_query_foreign_access(
>  				np->grant_tx_ref[id]) != 0)) {
> -				printk(KERN_ALERT "xennet_tx_buf_gc: warning "
> -				       "-- grant still in use by backend "
> -				       "domain.\n");
> +				pr_alert("%s: warning -- grant still in use by backend domain\n",
> +					 __func__);
>  				BUG();
>  			}
>  			gnttab_end_foreign_access_ref(
> @@ -804,14 +805,14 @@ static int xennet_set_skb_gso(struct sk_buff *skb,
>  {
>  	if (!gso->u.gso.size) {
>  		if (net_ratelimit())
> -			printk(KERN_WARNING "GSO size must not be zero.\n");
> +			pr_warn("GSO size must not be zero\n");
>  		return -EINVAL;
>  	}
>  
>  	/* Currently only TCPv4 S.O. is supported. */
>  	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
>  		if (net_ratelimit())
> -			printk(KERN_WARNING "Bad GSO type %d.\n", gso->u.gso.type);
> +			pr_warn("Bad GSO type %d\n", gso->u.gso.type);
>  		return -EINVAL;
>  	}
>  
> @@ -910,9 +911,8 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>  		break;
>  	default:
>  		if (net_ratelimit())
> -			printk(KERN_ERR "Attempting to checksum a non-"
> -			       "TCP/UDP packet, dropping a protocol"
> -			       " %d packet", iph->protocol);
> +			pr_err("Attempting to checksum a non-TCP/UDP packet, dropping a protocol %d packet\n",
> +			       iph->protocol);
>  		goto out;
>  	}
>  
> @@ -1359,14 +1359,14 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>  	/* A grant for every tx ring slot */
>  	if (gnttab_alloc_grant_references(TX_MAX_TARGET,
>  					  &np->gref_tx_head) < 0) {
> -		printk(KERN_ALERT "#### netfront can't alloc tx grant refs\n");
> +		pr_alert("can't alloc tx grant refs\n");
>  		err = -ENOMEM;
>  		goto exit_free_stats;
>  	}
>  	/* A grant for every rx ring slot */
>  	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
>  					  &np->gref_rx_head) < 0) {
> -		printk(KERN_ALERT "#### netfront can't alloc rx grant refs\n");
> +		pr_alert("can't alloc rx grant refs\n");
>  		err = -ENOMEM;
>  		goto exit_free_tx;
>  	}
> @@ -1430,16 +1430,14 @@ static int netfront_probe(struct xenbus_device *dev,
>  
>  	err = register_netdev(info->netdev);
>  	if (err) {
> -		printk(KERN_WARNING "%s: register_netdev err=%d\n",
> -		       __func__, err);
> +		pr_warn("%s: register_netdev err=%d\n", __func__, err);
>  		goto fail;
>  	}
>  
>  	err = xennet_sysfs_addif(info->netdev);
>  	if (err) {
>  		unregister_netdev(info->netdev);
> -		printk(KERN_WARNING "%s: add sysfs failed err=%d\n",
> -		       __func__, err);
> +		pr_warn("%s: add sysfs failed err=%d\n", __func__, err);
>  		goto fail;
>  	}
>  
> @@ -2116,7 +2114,7 @@ static int __init netif_init(void)
>  	if (xen_hvm_domain() && !xen_platform_pci_unplug)
>  		return -ENODEV;
>  
> -	printk(KERN_INFO "Initialising Xen virtual ethernet driver.\n");
> +	pr_info("Initialising Xen virtual ethernet driver\n");
>  
>  	return xenbus_register_frontend(&netfront_driver);
>  }
> 
> 
