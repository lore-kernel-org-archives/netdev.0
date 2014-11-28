From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 34/46] virtio_net: disable mac write for virtio 1.0
Date: Fri, 28 Nov 2014 08:48:24 +0008
Message-ID: <1417164024.5822.11@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-35-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, rusty@au1.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417118789-18231-35-git-send-email-mst@redhat.com>
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



On Fri, Nov 28, 2014 at 4:10 AM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> The spec states that mac in config space is only driver-writable in 
> the
> legacy case.  Fence writing it in virtnet_set_mac_address() in the
> virtio 1.0 case.
> 
> Suggested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c6a72d3..9ab3c50 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1030,7 +1030,8 @@ static int virtnet_set_mac_address(struct 
> net_device *dev, void *p)
>  				 "Failed to set mac address by vq command.\n");
>  			return -EINVAL;
>  		}
> -	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
> +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
> +		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
>  		unsigned int i;
>  
>  		/* Naturally, this has an atomicity problem. */
> -- 
> MST

Does this mean there's no way to setting mac addres
if ctrl mac addr is disabled in virtio-1?

If yes, we'd better keep this compatibility somehow. 
