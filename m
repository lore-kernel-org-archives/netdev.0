From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Wed, 10 Dec 2008 10:26:36 +1030
Message-ID: <200812101026.36538.rusty@rustcorp.com.au>
References: <1228817973.26198.1.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1228817973.26198.1.camel@blaa>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 December 2008 20:49:33 Mark McLoughlin wrote:
> Allow the host to inform us that the link is down by adding
> a VIRTIO_NET_F_STATUS which indicates that device status is
> available in virtio_net config.

This has been a TODO for a while, thanks!

> +	if (vi->status == v)
> +		return;
> +
> +	vi->status = v;
> +
> +	if (vi->status & VIRTIO_NET_S_LINK_UP) {
> +		netif_carrier_on(vi->dev);
> +		netif_wake_queue(vi->dev);
> +	} else {
> +		netif_carrier_off(vi->dev);
> +		netif_stop_queue(vi->dev);
> +	}

New status bits will screw this logic unless we count
on the host not to set them.  I suggest:

	/* Ignore unknown (future) status bits */
	v &= VIRTIO_NET_S_LINK_UP;

Cheers,
Rusty.
