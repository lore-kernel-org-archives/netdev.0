From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: drop all fragments inside tx queue if one gets dropped
Date: Thu, 21 Apr 2016 13:48:24 -0400
Message-ID: <2319.1461260904@obiwan.sandelman.ca>
References: <57175156.3050501@pengutronix.de> <11312.1461183334@obiwan.sandelman.ca> <5717EA7E.1020606@hpe.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.249.19]:41803 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbcDURs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:48:27 -0400
In-Reply-To: <5717EA7E.1020606@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Rick Jones <rick.jones2@hpe.com> wrote:
    > I don't recall seeing similar poor behaviour in Linux; I would have
    > assumed
    > that the intra-stack flow-control "took care" of it.  Perhaps there is
    > something specific to wpan which precludes that?

The major user of big UDP packets in the 1990s was NFS.
I fondly recall deploying wsize=1024,rsize=1024 for NFS mounts between HPUX,
Apollo and Sun machines across the intersite Ottawa BNR "WAN"

NFS mounts now use TCP by default, and NFS is not a well used protocol
outside of clueful people (everyone else uses CIFS), and modern machines have
way DMA engines in their ethernet that can accomodate more than enough
xmit buffers to perhaps make this moot.  But, I dealt with this very problem
with a Linux NFS server that would get GbE XOFF's by a broken Cisco switch
that wouldn't always XON, and would seem to drop it's queue. (Turning QoS off
on the cisco switch made it tolerable.)

Still, Alex, it would be worth looking at whether the NFS UDP transmitter
does anything clueful to keep from overwhelming the ethernet layer.

wpan deals with sub-IP fragmentation of 1280 (or larger) IPv6 packets into
127 6lowpan fragments for transmission over 802.15.4 interfaces which run at
typically 250kb/s.   Those radios are typically SPI interfaced (often with
bit-banged SPI interfaces), and the radio MAC has only a single transmit
buffer (which is also the receive buffer!).

Packet trains would be nice to have.
--=-=-=--
