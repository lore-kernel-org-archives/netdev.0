From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 7/9] virtio-net: forbid XDP when
	VIRTIO_NET_F_GUEST_UFO is support
Date: Fri, 23 Dec 2016 08:02:53 -0800
Message-ID: <585D4AAD.4030702@gmail.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-8-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-8-git-send-email-jasowang@redhat.com>
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

On 16-12-23 06:37 AM, Jason Wang wrote:
> When VIRTIO_NET_F_GUEST_UFO is negotiated, host could still send UFO
> packet that exceeds a single page which could not be handled
> correctly by XDP. So this patch forbids setting XDP when GUEST_UFO is
> supported. While at it, forbid XDP for ECN (which comes only from GRO)
> too to prevent user from misconfiguration.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 77ae358..c1f66d8 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1684,7 +1684,9 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  	int i, err;
>  
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
> -	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
> +	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
> +	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
> +	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_UFO)) {
>  		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
>  		return -EOPNOTSUPP;
>  	}
> 

Acked-by: John Fastabend <john.r.fastabend@intel.com>
