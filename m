From: Paul Fulghum <paulkf@microgate.com>
Subject: Re: [janitor] use netdev_priv() in synclink (char. driver)
Date: 05 Mar 2004 09:15:09 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078499709.2076.5.camel@deimos.microgate.com>
References: <20040303142907.09d0f7bd.rddunlap@osdl.org>
	 <20040303150105.7ff770b0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20040303150105.7ff770b0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-03-03 at 17:01, Randy.Dunlap wrote:
> | 
> | From: Carlo Perassi <carlo@linux.it>
> | and Randy.Dunlap <rddunlap@osdl.org>
> 
> 
> Jeff, can you add this patch and the fusion/mptlan driver
> patch as well?
> 
> --
> ~Randy
> 
> 
> 
> 
>  linux-264-302-priv-rddunlap/drivers/char/synclink.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff -puN drivers/char/synclink.c~synclink_casts drivers/char/synclink.c
> --- linux-264-302-priv/drivers/char/synclink.c~synclink_casts	2004-03-02 12:56:23.000000000 -0800
> +++ linux-264-302-priv-rddunlap/drivers/char/synclink.c	2004-03-02 13:01:39.000000000 -0800
> @@ -7878,7 +7878,7 @@ void mgsl_sppp_delete(struct mgsl_struct
>  
>  int mgsl_sppp_open(struct net_device *d)
>  {
> -	struct mgsl_struct *info = d->priv;
> +	struct mgsl_struct *info = netdev_priv(d);
>  	int err;
>  	unsigned long flags;
>  
> @@ -7920,7 +7920,7 @@ open_fail:
>  
>  void mgsl_sppp_tx_timeout(struct net_device *dev)
>  {
> -	struct mgsl_struct *info = dev->priv;
> +	struct mgsl_struct *info = netdev_priv(dev);
>  	unsigned long flags;
>  
>  	if (debug_level >= DEBUG_LEVEL_INFO)
> @@ -7938,7 +7938,7 @@ void mgsl_sppp_tx_timeout(struct net_dev
>  
>  int mgsl_sppp_tx(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct mgsl_struct *info = dev->priv;
> +	struct mgsl_struct *info = netdev_priv(dev);
>  	unsigned long flags;
>  
>  	if (debug_level >= DEBUG_LEVEL_INFO)
> @@ -7964,7 +7964,7 @@ int mgsl_sppp_tx(struct sk_buff *skb, st
>  
>  int mgsl_sppp_close(struct net_device *d)
>  {
> -	struct mgsl_struct *info = d->priv;
> +	struct mgsl_struct *info = netdev_priv(d);
>  	unsigned long flags;
>  
>  	if (debug_level >= DEBUG_LEVEL_INFO)
> @@ -8014,7 +8014,7 @@ void mgsl_sppp_tx_done(struct mgsl_struc
>  
>  struct net_device_stats *mgsl_net_stats(struct net_device *dev)
>  {
> -	struct mgsl_struct *info = dev->priv;
> +	struct mgsl_struct *info = netdev_priv(dev);
>  	if (debug_level >= DEBUG_LEVEL_INFO)
>  		printk("mgsl_net_stats(%s)\n",info->netname);	
>  	return &info->netstats;
> @@ -8022,7 +8022,7 @@ struct net_device_stats *mgsl_net_stats(
>  
>  int mgsl_sppp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> -	struct mgsl_struct *info = (struct mgsl_struct *)dev->priv;
> +	struct mgsl_struct *info = netdev_priv(dev);
>  	if (debug_level >= DEBUG_LEVEL_INFO)
>  		printk("%s(%d):mgsl_ioctl %s cmd=%08X\n", __FILE__,__LINE__,
>  			info->netname, cmd );
> 
> _


This patch breaks the driver.

The pointer stored in dev->priv points to a structure that is
allocated and maintained by the driver.

Changing from dev->priv to netdev_priv(dev) returns a pointer
to memory at the end of the net_device structure.

These are two different things.

So with the patch, the driver gets a pointer to something
other than the device private information that it needs.

Please dont apply this patch.

-- 
Paul Fulghum
paulkf@microgate.com
