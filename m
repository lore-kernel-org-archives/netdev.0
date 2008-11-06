From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] virtio_net: don't set NETIF_F_FRAGLIST
Date: Thu, 06 Nov 2008 00:43:22 -0500
Message-ID: <491283FA.1020404@garzik.org>
References: <> <1225888486-977-1-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	Mark McLoughlin <markmc@redhat.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34718 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300AbYKFFn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:43:26 -0500
In-Reply-To: <1225888486-977-1-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> We don't handle skb_shared_info->frag_list, so we shouldn't
> be setting the NETIF_F_FRAGLIST flag.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> ---
>  drivers/net/virtio_net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 0196a0d..9d4fdad 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -505,7 +505,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	/* Do we support "hardware" checksums? */
>  	if (csum && virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
>  		/* This opens up the world of extra features. */
> -		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
> +		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG;
>  		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
>  			dev->features |= NETIF_F_TSO | NETIF_F_UFO
>  				| NETIF_F_TSO_ECN | NETIF_F_TSO6;

applied this and tun patch

