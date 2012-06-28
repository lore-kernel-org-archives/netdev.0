From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [patch net-next 2/4] virtio_net: use IFF_LIFE_ADDR_CHANGE
	priv_flag
Date: Thu, 28 Jun 2012 22:21:23 +0300
Message-ID: <20120628192123.GA14787@redhat.com>
References: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
	<1340892639-1111-3-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shimoda.hiroaki@gmail.com,
	virtualization@lists.linux-foundation.org,
	danny.kukawka@bisect.de, edumazet@google.com, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1340892639-1111-3-git-send-email-jpirko@redhat.com>
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

On Thu, Jun 28, 2012 at 04:10:37PM +0200, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

FWIW

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 36a16d5..6a0f526 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -679,12 +679,11 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct virtio_device *vdev = vi->vdev;
> -	struct sockaddr *addr = p;
> +	int ret;
>  
> -	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EADDRNOTAVAIL;
> -	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> -	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
> +	ret = eth_mac_addr(dev, p);
> +	if (ret)
> +		return ret;
>  
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
>  		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> @@ -1063,7 +1062,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		return -ENOMEM;
>  
>  	/* Set up network device as normal. */
> -	dev->priv_flags |= IFF_UNICAST_FLT;
> +	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIFE_ADDR_CHANGE;
>  	dev->netdev_ops = &virtnet_netdev;
>  	dev->features = NETIF_F_HIGHDMA;
>  
> -- 
> 1.7.10.4
