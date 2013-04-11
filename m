From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH 1/2] virtio-net: initialize vlan_features
Date: Thu, 11 Apr 2013 12:55:17 +0300
Message-ID: <20130411095516.GB21362@redhat.com>
References: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
 <1365672742-42258-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1365672742-42258-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 05:32:21PM +0800, Jason Wang wrote:
> There's nothing that prevent passing the device features of virtio_net to its
> vlan device. So this patch simply passes those to vlan device to benefit from
> advanced features.
> 
> Netperf shows better sending performance for vlan device since TSO can work on
> vlan now.
> 
> before:
> netperf -H 192.168.5.2
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.5.2 ()
> port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    4162.35
> 
> after:
> netperf -H 192.168.5.2
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.5.2 ()
> port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    9365.42
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f7d67e8..8fdfde6 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1511,6 +1511,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		/* (!csum && gso) case will be fixed by register_netdev() */
>  	}
>  
> +	dev->vlan_features = dev->features;
> +
>  	/* Configuration may specify what MAC to use.  Otherwise random. */
>  	if (virtio_config_val_len(vdev, VIRTIO_NET_F_MAC,
>  				  offsetof(struct virtio_net_config, mac),
> -- 
> 1.7.1
