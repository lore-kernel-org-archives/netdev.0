From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: linux-next: manual merge of the vhost tree with the net-next tree
Date: Thu, 19 Apr 2012 08:40:29 +0300
Message-ID: <20120419054028.GB22408@redhat.com>
References: <20120419153547.c9e4cf4865b28c61668a2be1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120419153547.c9e4cf4865b28c61668a2be1@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 19, 2012 at 03:35:47PM +1000, Stephen Rothwell wrote:
> Hi Michael,
> 
> Today's linux-next merge of the vhost tree got a conflict in
> drivers/net/virtio_net.c between commit 586d17c5a01b ("virtio-net: send
> gratuitous packets when needed") from the net-next tree and commit
> 66fdfb7bc203 ("virtio-net: remove useless disable on freeze") from the
> vhost tree.
> 
> Just context changes.  I fixed it up (I think - see below) and can carry
> the fix as necessary.

The fix looks right, thanks a lot.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc drivers/net/virtio_net.c
> index fa58c78,3e4767f..0000000
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@@ -1224,16 -1183,6 +1224,11 @@@ static int virtnet_freeze(struct virtio
>   {
>   	struct virtnet_info *vi = vdev->priv;
>   
>  +	/* Prevent config work handler from accessing the device */
>  +	mutex_lock(&vi->config_lock);
>  +	vi->config_enable = false;
>  +	mutex_unlock(&vi->config_lock);
>  +
> - 	virtqueue_disable_cb(vi->rvq);
> - 	virtqueue_disable_cb(vi->svq);
> - 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
> - 		virtqueue_disable_cb(vi->cvq);
> - 
>   	netif_device_detach(vi->dev);
>   	cancel_delayed_work_sync(&vi->refill);
>   
