From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2] virtio-net: drop NETIF_F_FRAGLIST
Date: Thu, 6 Aug 2015 16:13:11 +0300
Message-ID: <20150806161042-mutt-send-email-mst@redhat.com>
References: <1438742044-31064-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1438742044-31064-1-git-send-email-jasowang@redhat.com>
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

On Wed, Aug 05, 2015 at 10:34:04AM +0800, Jason Wang wrote:
> virtio declares support for NETIF_F_FRAGLIST, but assumes
> that there are at most MAX_SKB_FRAGS + 2 fragments which isn't
> always true with a fraglist.
> 
> A longer fraglist in the skb will make the call to skb_to_sgvec overflow
> the sg array, leading to memory corruption.
> 
> Drop NETIF_F_FRAGLIST so we only get what we can handle.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I noticed only now that this didn't Cc Dave, so of course it's
not applied. I'm preparing a pull request anyway, so
I'll merge this through my tree, and add Cc stable.
Dave - ok with you?

> ---
> - Change from V1: coding style fixes.
> - The patch is needed for stable.
> ---
>  drivers/net/virtio_net.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7fbca37..237f8e5 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1756,9 +1756,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	/* Do we support "hardware" checksums? */
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
>  		/* This opens up the world of extra features. */
> -		dev->hw_features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
> +		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_SG;
>  		if (csum)
> -			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
> +			dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
>  
>  		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
>  			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
> -- 
> 2.1.4
