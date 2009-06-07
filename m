From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH qemu-kvm] Enable UFO on virtio-net/tap devices
Date: Sun, 07 Jun 2009 09:21:39 +0300
Message-ID: <4A2B5C73.5050907@redhat.com>
References: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, herbert.xu@redhat.com, rusty@rustcorp.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42248 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466AbZFGGVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2009 02:21:48 -0400
In-Reply-To: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala wrote:
> Enable UFO on the host tap device if supported and allow setting UFO
> on virtio-net in the guest.
>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>
>
> diff --git a/hw/virtio-net.c b/hw/virtio-net.c
> index 3c77b99..8a53e27 100644
> --- a/hw/virtio-net.c
> +++ b/hw/virtio-net.c
> @@ -134,7 +134,8 @@ static uint32_t virtio_net_get_features(VirtIODevice *vdev)
>          features |= (1 << VIRTIO_NET_F_HOST_TSO6);
>          features |= (1 << VIRTIO_NET_F_HOST_ECN);
>          features |= (1 << VIRTIO_NET_F_MRG_RXBUF);
> -        /* Kernel can't actually handle UFO in software currently. */
> +       // features |= (1 << VIRTIO_NET_F_HOST_UFO);
> +        features |= (1 << VIRTIO_NET_F_GUEST_UFO);
>   

Where are these defined?

> @@ -990,8 +990,13 @@ static int tap_probe_vnet_hdr(int fd)
>  }
>  
>  #ifdef TUNSETOFFLOAD
> +
> +#ifndef TUN_F_UFO
> +#define TUN_F_UFO	0x10
> +#endif
> +
>   

Should just use the definition in the kernel header.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

