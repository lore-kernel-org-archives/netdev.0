From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 17:59:30 +1030
Message-ID: <200903121759.31024.rusty@rustcorp.com.au>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pantelis Koukousoulas <pktoss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42891 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbZCLH3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 03:29:37 -0400
In-Reply-To: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 11 March 2009 22:27:22 Pantelis Koukousoulas wrote:
> For now the semantics are simple: There is always carrier.
> 
> This allows a seamless experience with e.g., qemu/kvm
> where NetworkManager just configures and sets up
> everything automagically.

So, NetworkManager ignores the device because it doesn't support
carrier detection?

That seems weird, but I have nothing against this patch in general.

Thanks,
Rusty.

> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -612,6 +612,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
>  	.set_tx_csum = virtnet_set_tx_csum,
>  	.set_sg = ethtool_op_set_sg,
>  	.set_tso = ethtool_op_set_tso,
> +	.get_link = ethtool_op_get_link,
>  };
>  
>  #define MIN_MTU 68
> @@ -739,6 +740,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		goto unregister;
>  	}
>  
> +	netif_carrier_on(dev);
> +
>  	pr_debug("virtnet: registered device %s\n", dev->name);
>  	return 0;

