From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] macvtap/macvlan: use IFF_NO_QUEUE
Date: Tue, 25 Aug 2015 13:17:30 +0300
Message-ID: <20150825131608-mutt-send-email-mst@redhat.com>
References: <1440405192-25926-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440405192-25926-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2015 at 04:33:12PM +0800, Jason Wang wrote:
> For macvlan, switch to use IFF_NO_QUEUE instead of tx_queue_len = 0.
> 
> For macvtap, after commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
> ("macvtap: Add support of packet capture on macvtap
> device."). Multiqueue macvtap suffers from single qdisc lock
> contention. This is because macvtap claims a non zero tx_queue_len and
> it reuses this value as it socket receive queue size.Thanks to
> IFF_NO_QUEUE, we can remove the lock contention without breaking
> existing socket receive queue length logic.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Seems to make sense. Give me a day or two to get over the jet lag
(and get out from under the pile of mail accumulated while I was traveling),
I'll review properly and ack.

> ---
>  drivers/net/macvlan.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 47da435..09d8718 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -1056,7 +1056,7 @@ void macvlan_common_setup(struct net_device *dev)
>  
>  	dev->priv_flags	       &= ~IFF_TX_SKB_SHARING;
>  	netif_keep_dst(dev);
> -	dev->priv_flags	       |= IFF_UNICAST_FLT;
> +	dev->priv_flags	       |= IFF_UNICAST_FLT | IFF_NO_QUEUE;
>  	dev->netdev_ops		= &macvlan_netdev_ops;
>  	dev->destructor		= free_netdev;
>  	dev->header_ops		= &macvlan_hard_header_ops;
> @@ -1067,7 +1067,6 @@ EXPORT_SYMBOL_GPL(macvlan_common_setup);
>  static void macvlan_setup(struct net_device *dev)
>  {
>  	macvlan_common_setup(dev);
> -	dev->tx_queue_len	= 0;
>  }
>  
>  static int macvlan_port_create(struct net_device *dev)
> -- 
> 2.1.4
