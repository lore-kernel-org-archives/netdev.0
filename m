From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [virtio-dev] [PATCH] virtio_net: don't require ANY_LAYOUT with
	VERSION_1
Date: Wed, 15 Jul 2015 14:55:11 +0200
Message-ID: <55A6582F.5070500@redhat.com>
References: <1436963135-16592-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtio-dev@lists.oasis-open.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1436963135-16592-1-git-send-email-mst@redhat.com>
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



On 15/07/2015 14:26, Michael S. Tsirkin wrote:
> ANY_LAYOUT is a compatibility feature. It's implied
> for VERSION_1 devices, and non-transitional devices
> might not offer it. Change code to behave accordingly.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 63c7810..7fbca37 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1828,7 +1828,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	else
>  		vi->hdr_len = sizeof(struct virtio_net_hdr);
>  
> -	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT))
> +	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT) ||
> +	    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
>  		vi->any_header_sg = true;
>  
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
> 

Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>
