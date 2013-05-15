From: Phil Sutter <phil@nwl.cc>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Thu, 16 May 2013 00:44:45 +0200
Message-ID: <20130515224452.7CAA6224C4@mail.nwl.cc>
References: <loom.20130515T144941-798@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ricardo =?utf-8?B?VHViw61v?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59493 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491Ab3EOWzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 18:55:54 -0400
Content-Disposition: inline
In-Reply-To: <loom.20130515T144941-798@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 15, 2013 at 12:53:55PM +0000, Ricardo Tub=C3=ADo wrote:
> Once I tell kernel to export the TX_RING through setsockopt() (see co=
de
> below) I always get an error (EBUSY) if i try to tell kernel to expor=
t the
> RX_RING with the same socket descriptor. Therefore, I have to open an
> additional socket for the RX_RING and I require of two sockets when I=
 though
> that I would only require of one socket for both TX and RX using mmap=
()ed
> memory.
>=20
> Do I need both sockets or am I doing something wrong?

After requesting the rings, a single mmap() call suffices for both. So
pseudo-code basically looks like this:

| setsockopt(fd, SOL_PACKET, PACKET_RX_RING, p, sizeof(p));
| setsockopt(fd, SOL_PACKET, PACKET_TX_RING, p, sizeof(p));
| rx_ring =3D mmap(NULL, ring_len * 2, PROT_READ | PROT_WRITE, MAP_SHAR=
ED, fd, 0);
| tx_ring =3D rx_ring + ring_len;

Note that packet_mmap() in net/packet/af_packet.c always maps the TX
ring memory right after the RX one.

HTH, Phil
