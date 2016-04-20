From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: drop all fragments inside tx queue if one gets dropped
Date: Wed, 20 Apr 2016 16:15:34 -0400
Message-ID: <11312.1461183334@obiwan.sandelman.ca>
References: <57175156.3050501@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Alexander Aring <aar@pengutronix.de>
To: netdev@vger.kernel.org, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.249.19]:55567 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbcDTUXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:23:17 -0400
In-Reply-To: <57175156.3050501@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain


{adding some more comments from the -wpan side of things}

Alexander Aring <aar@pengutronix.de> wrote:
    > On linux-wpan we had a discussion about setting the right tx_queue_len
    > and came to some issues in 802.15.4 6LoWPAN networks.

...

    > And then a lot of fragments laying inside the tx_queue and waits to
    > transfer to the transceiver which has only one framebuffer to transmit
    > one frame and waits for tx completion to transfer the next one.

    > My question is, if qdisc drops some fragment because the queue is full
    > or something else. Exists there some way to remove all fragments inside
    > the queue? If one fragment will be dropped and all related are still
    > inside the queue then we send mostly garbage.

The big concern is that if we make tx_queue_len too big, we are effectively
introducing bloat.
If we make it too small, then we might drop one fragment, when we would
prefer to drop the entire packet.

It seems that maybe we ought to have a queue in the upper interface and fill
the lower interface with at most two packets' worth of fragments.

    > I want to add a behaviour which drops all related fragments for 6LoWPAN
    > fragmentation at first, if the payload is above 1280 bytes, then we
    > have also IPv6 fragmentation on it. In future I also like to remove all
    > related 6LoWPAN fragments which are related according to the IPv6
    > fragment.

It would still be useful to be able to do this in general: this kind of
operation would also benefit sending large UDP packets over ethernet when we
have to do IP-layer fragmentation.
--=-=-=--
