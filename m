From: Phil Sutter <phil@nwl.cc>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Thu, 16 May 2013 12:45:41 +0200
Message-ID: <20130516104541.GB18282@orbit.nwl.cc>
References: <loom.20130515T144941-798@post.gmane.org>
 <20130515224452.7CAA6224C4@mail.nwl.cc>
 <loom.20130516T111446-437@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ricardo =?utf-8?B?VHViw61v?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38394 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763Ab3EPKqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 06:46:20 -0400
Content-Disposition: inline
In-Reply-To: <loom.20130516T111446-437@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 09:18:03AM +0000, Ricardo Tub=C3=ADo wrote:
> Phil Sutter <phil <at> nwl.cc> writes:
>=20
> >=20
> > On Wed, May 15, 2013 at 12:53:55PM +0000, Ricardo Tub=C3=ADo wrote:
> > > Once I tell kernel to export the TX_RING through setsockopt() (se=
e code
> > > below) I always get an error (EBUSY) if i try to tell kernel to e=
xport the
> > > RX_RING with the same socket descriptor. Therefore, I have to ope=
n an
> > > additional socket for the RX_RING and I require of two sockets wh=
en I though
> > > that I would only require of one socket for both TX and RX using =
mmap()ed
> > > memory.
> > >=20
> > > Do I need both sockets or am I doing something wrong?
> >=20
> > After requesting the rings, a single mmap() call suffices for both.=
 So
> > pseudo-code basically looks like this:
> >=20
> > | setsockopt(fd, SOL_PACKET, PACKET_RX_RING, p, sizeof(p));
> > | setsockopt(fd, SOL_PACKET, PACKET_TX_RING, p, sizeof(p));
> > | rx_ring =3D mmap(NULL, ring_len * 2, PROT_READ | PROT_WRITE, MAP_=
SHARED,
> fd, 0);
> > | tx_ring =3D rx_ring + ring_len;
> >=20
> > Note that packet_mmap() in net/packet/af_packet.c always maps the T=
X
> > ring memory right after the RX one.
> >=20
> > HTH, Phil
> >=20
>=20
> Phil, the issue comes precisely when I try to do that: the second cal=
l to
> setsockopt() returns an "EBUSY" error message from the kernel. It see=
ms that
> if you have initialized one socket for beeing either TX_RING or RX_RI=
NG, you
> cannot initialize the same socket again for the other option (RX_RING=
 or
> TX_RING).

So you do not call init_ring() twice as one may imply when reading your
first mail? Please provide a complete code sample.
