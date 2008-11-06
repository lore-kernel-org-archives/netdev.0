From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: don't set NETIF_F_FRAGLIST
Date: Thu, 06 Nov 2008 10:56:14 +0000
Message-ID: <1225968974.7284.17.camel@blaa>
References: <> <1225888486-977-1-git-send-email-markmc@redhat.com>
	 <491283FA.1020404@garzik.org> <1225966352.7284.5.camel@blaa>
	 <4912CB66.2050107@garzik.org>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45397 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbYKFK5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 05:57:21 -0500
In-Reply-To: <4912CB66.2050107@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-06 at 05:48 -0500, Jeff Garzik wrote:
> Mark McLoughlin wrote:
> > On Thu, 2008-11-06 at 00:43 -0500, Jeff Garzik wrote:
> >> Mark McLoughlin wrote:
> >>> We don't handle skb_shared_info->frag_list, so we shouldn't
> >>> be setting the NETIF_F_FRAGLIST flag.
> >>>
> >>> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> >>> ---
> >>>  drivers/net/virtio_net.c |    2 +-
> >>>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>>
> >>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>> index 0196a0d..9d4fdad 100644
> >>> --- a/drivers/net/virtio_net.c
> >>> +++ b/drivers/net/virtio_net.c
> >>> @@ -505,7 +505,7 @@ static int virtnet_probe(struct virtio_device *vdev)
> >>>  	/* Do we support "hardware" checksums? */
> >>>  	if (csum && virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
> >>>  		/* This opens up the world of extra features. */
> >>> -		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
> >>> +		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG;
> >>>  		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
> >>>  			dev->features |= NETIF_F_TSO | NETIF_F_UFO
> >>>  				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
> >> applied this and tun patch
> > 
> > Sorry Jeff, Rusty correctly points out that we do in fact handle
> > shinfo->frags; just a moment of blindness on my part.
> 
> but what about frag_list ?

Yeah, I meant shinfo->frag_list.

virtio_net uses skb_to_sgvec() and tun uses skb_copy_datagram_iovec()

Both handle shinfo->frag_list correctly.

Thanks,
Mark.

