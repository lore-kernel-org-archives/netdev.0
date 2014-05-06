From: Steven Haigh <netwiz@crc.id.au>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Wed, 07 May 2014 04:07:24 +1000
Message-ID: <536924DC.9080606@crc.id.au>
References: <395225650.20140430124506@eikelenboom.it>	<536162D3.5080307@citrix.com>	<94755525.20140501002553@eikelenboom.it>	<53624E25.8040404@citrix.com>	<1810270947.20140501155911@eikelenboom.it>	<53626C39.3030304@citrix.com>	<928229683.20140501193936@eikelenboom.it>	<198418193.20140501213951@eikelenboom.it>	<5363A508.1000602@citrix.com>	<653156457.20140502160632@eikelenboom.it>	<5363AFED.5080601@citrix.com>	<1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>	<5363B929.1000502@citrix.com>	<35970097.20140502182818@eikelenboom.it>	<5363CBB0.6050804@citrix.com>	<15602339.20140505121912@eikelenboom.it>	<536916E9.7010509@crc.id.au> <53691848.5010809@citrix.com> <437888929.20140506193723@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="rECvAExJHckBTE8iSWVKnPqBTBtTOOQeL"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, "David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Sander Eikelenboom <linux@eikelenboom.it>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.crc.id.au ([203.56.246.92]:59993 "EHLO mail.crc.id.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbaEFSGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 14:06:55 -0400
In-Reply-To: <437888929.20140506193723@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rECvAExJHckBTE8iSWVKnPqBTBtTOOQeL
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 07/05/14 03:37, Sander Eikelenboom wrote:
>=20
> Tuesday, May 6, 2014, 7:13:44 PM, you wrote:
>=20
>> On 06/05/14 18:07, Steven Haigh wrote:
>>> On a related note, I'm seeing this on an Arch Linux DomU and kernel
>>> 3.14.2. Its running aria2c bit torrent client.
>>>
>>> The Dom0 is EL6 with Xen 4.2.4 / 3.14.2 kernel.
>>>
>>> I also lodged this on the Arch bug tracker:
>>>       https://bugs.archlinux.org/task/40244
>>>
>>> In a nutshell, I see:
>>> [ 7432.398096] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7434.270870] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7434.782199] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7435.184794] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7437.530677] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7437.973905] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 7438.383947] xen_netfront: xennet: skb rides the rocket: 19 slots
>=20
>> Can you also see packet corruption? You can find a testfile generator =
in=20
>> Sander's mail, downloading from an Apache server with wget seems to be=
 OK.
>=20
> The corruption shouldn't be there since he is running 3.14.2 which is f=
ine.
>=20
> And note that the corruption with 3.15 only seems to occur in traffic b=
etween=20
> guests  and not between dom0 and guest. The bit torrent traffic is prob=
ably=20
> inet <-> dom0 <-> guest, so shouldn't be affected, even with 3.15.

Well, I'm trying to get a test together - although I don't have webdav
anywhere... I was going to try it via FTP, however I'm hitting another
MMU bug in Xen:
	https://bugs.archlinux.org/task/38596

This references:
	https://lkml.org/lkml/2014/1/23/596

It says that should be fixed in 3.15-rc3 (if I understand properly) -
but I'm also hitting that on 3.14.2. Did these changes get ported back
to the 3.14 tree?

(also adding in Konrad vs the vsftp issue in Xen PV DomUs).

--=20
Steven Haigh

Email: netwiz@crc.id.au
Web: http://www.crc.id.au
Phone: (03) 9001 6090 - 0412 935 897
Fax: (03) 8338 0299


--rECvAExJHckBTE8iSWVKnPqBTBtTOOQeL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTaSTcAAoJEEGvNdV6fTHcL/IP/1R4imeROLycGhDI3EVN3rqA
LNVEVDJDB29w4Ivs8N1YSUAw7Gh/LCEeNJtbY8MPxlA+VhcXj+j+3DCp95KIeYiV
9HuYgogzNG/mQo6ntLyJAOaeLeLrd6oqwOj9zs7fIXovaeJ5IDgGag6p7UkhQfdZ
MEAXI7Lpud5xnHu+I+ac2mvpPf3sNnK4H4OPfQic6eU8H5BIcwWj3OTNa4rLcu9N
K4iO5R5xQ8Ke4hqZyGXS5eiS4fbqEGIaCwIgPhsrjCba1Hl2ORN1V/Ft9c2yX/Gl
QRloPFCQJEQOiGnJpTnbt17pQzPglJreKueMBwKywCbwNl+lnF2nejCL/O15pitH
FK+eY/bOyMbgQV0nWOgKQ3axoRJatLdcK0UhlHSy7LZpIIB1cOdkEzv+yyw9AmQj
bzGsaRNVch+wYRyFr51MraUTYg1EyWC+RJHcilJy5ToSTvTTdHk74Z/OojQU1DR4
CXujqRqal4uR2xliObfOIF2Kiugxx+dqlD/NZWpjhCawEeI8tCws65n1eYagk9mo
0dhJILvm1qIcmxu7+zEK7LM5MAtsTpdx3DCkp1OituTQwhaAUmLKsIGvsCsumHbt
zlGe6qaoKN+/YzDlFcsm5SrCJB/dHg/0lymb7wEs9vVe67UUDEC7I/wNd+3FOh+B
qgNrjDcr/M1v/dijjZUh
=rGf0
-----END PGP SIGNATURE-----

--rECvAExJHckBTE8iSWVKnPqBTBtTOOQeL--
