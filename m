From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Re: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Thu, 16 May 2013 09:18:03 +0000 (UTC)
Message-ID: <loom.20130516T111446-437@post.gmane.org>
References: <loom.20130515T144941-798@post.gmane.org> <20130515224452.7CAA6224C4@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43469 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072Ab3EPJSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 05:18:22 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UcuKI-0006EY-Qh
	for netdev@vger.kernel.org; Thu, 16 May 2013 11:18:19 +0200
Received: from toxo.com.uvigo.es ([193.146.38.146])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:18:18 +0200
Received: from rtpardavila by toxo.com.uvigo.es with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:18:18 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter <phil <at> nwl.cc> writes:

>=20
> On Wed, May 15, 2013 at 12:53:55PM +0000, Ricardo Tub=C3=ADo wrote:
> > Once I tell kernel to export the TX_RING through setsockopt() (see =
code
> > below) I always get an error (EBUSY) if i try to tell kernel to exp=
ort the
> > RX_RING with the same socket descriptor. Therefore, I have to open =
an
> > additional socket for the RX_RING and I require of two sockets when=
 I though
> > that I would only require of one socket for both TX and RX using mm=
ap()ed
> > memory.
> >=20
> > Do I need both sockets or am I doing something wrong?
>=20
> After requesting the rings, a single mmap() call suffices for both. S=
o
> pseudo-code basically looks like this:
>=20
> | setsockopt(fd, SOL_PACKET, PACKET_RX_RING, p, sizeof(p));
> | setsockopt(fd, SOL_PACKET, PACKET_TX_RING, p, sizeof(p));
> | rx_ring =3D mmap(NULL, ring_len * 2, PROT_READ | PROT_WRITE, MAP_SH=
ARED,
fd, 0);
> | tx_ring =3D rx_ring + ring_len;
>=20
> Note that packet_mmap() in net/packet/af_packet.c always maps the TX
> ring memory right after the RX one.
>=20
> HTH, Phil
>=20

Phil, the issue comes precisely when I try to do that: the second call =
to
setsockopt() returns an "EBUSY" error message from the kernel. It seems=
 that
if you have initialized one socket for beeing either TX_RING or RX_RING=
, you
cannot initialize the same socket again for the other option (RX_RING o=
r
TX_RING).

Does anybody really know whether I am right or wrong?
