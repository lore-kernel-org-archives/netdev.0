From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Re: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Wed, 15 May 2013 13:32:41 +0000 (UTC)
Message-ID: <loom.20130515T152203-727@post.gmane.org>
References: <loom.20130515T144941-798@post.gmane.org> <51938BAD.5050502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59435 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759053Ab3EONdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 09:33:00 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UcbpA-00062m-LC
	for netdev@vger.kernel.org; Wed, 15 May 2013 15:32:56 +0200
Received: from static-adsl-c-5-188.ipcom.comunitel.net ([static-adsl-c-5-188.ipcom.comunitel.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:32:56 +0200
Received: from rtpardavila by static-adsl-c-5-188.ipcom.comunitel.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:32:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <dborkman <at> redhat.com> writes:

>=20
> On 05/15/2013 02:53 PM, Ricardo Tub=C3=ADo wrote:
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
> >
> > Do I need both sockets or am I doing something wrong?
>=20
> The second time you call init_ring() in your code e.g. with TX_RING, =
where
> you have previously set it up for the RX_RING. The kernel will give y=
ou
> -EBUSY because the packet socket is already mmap(2)'ed.
>=20

Ok, so if I make the following system calls:

void *ring=3DNULL;
setsockopt(socket_fd, SOL_PACKET, PACKET_RX_RING, p, LEN__TPACKET_REQ);
ring =3D mmap(NULL, ring_len, ring_access_flags, MAP_SHARED, socket_fd,=
 0);

Would I be permitted to use the ring map obtained both for RX and for T=
X? If
so, for me it is confusing to use PACKET_RX_RING if I can also TX data
through that ring...
