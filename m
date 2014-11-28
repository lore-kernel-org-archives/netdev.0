From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 26/46] virtio_net: bigger header when VERSION_1 is set
Date: Fri, 28 Nov 2014 08:39:57 +0008
Message-ID: <1417163517.5822.6@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-27-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, rusty@au1.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417118789-18231-27-git-send-email-mst@redhat.com>
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
> With VERSION_1 virtio_net uses same header size
> whether mergeable buffers are enabled or not.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 098f443..a0e64cf 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1805,7 +1805,8 @@ static int virtnet_probe(struct virtio_device 
> *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
>  		vi->mergeable_rx_bufs = true;
>  
> -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
> +	    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
>  		vi->hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>  	else
>  		vi->hdr_len = sizeof(struct virtio_net_hdr);
> -- 
> MST

Reviewed-by: Jason Wang <jasowang@redhat.com>
