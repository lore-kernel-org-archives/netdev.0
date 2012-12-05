From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv5] virtio-spec: virtio network device RFS support
Date: Wed, 5 Dec 2012 20:39:26 +0000
Message-ID: <1354739966.2655.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121203105843.GA26194@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <rusty@rustcorp.com.au>,
	<virtualization@lists.linux-foundation.org>,
	<netdev@vger.kernel.org>, <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42298 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab2LEUja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 15:39:30 -0500
In-Reply-To: <20121203105843.GA26194@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-03 at 12:58 +0200, Michael S. Tsirkin wrote:
> Add RFS support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_RFS for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_RFS to program
> packet steering for unidirectional protocols.
[...]
> +Programming of the receive flow classificator is implicit.
> + Transmitting a packet of a specific flow on transmitqX will cause incoming
> + packets for this flow to be steered to receiveqX.
> + For uni-directional protocols, or where no packets have been transmitted
> + yet, device will steer a packet to a random queue out of the specified
> + receiveq0..receiveqn.
[...]

It doesn't seem like this is usable to implement accelerated RFS in the
guest, though perhaps that doesn't matter.  On the host side, presumably
you'll want vhost_net to do the equivalent of sock_rps_record_flow() -
only without a socket?  But in any case, that requires an rxhash, so I
don't see how this is supposed to work.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
