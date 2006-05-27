From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: CRC16 in rt2x00
Date: Sat, 27 May 2006 20:30:59 +0400
Message-ID: <20060527163059.GB14973@procyon.home>
References: <200605271327.18879.IvDoorn@gmail.com> <20060527175516.600f450c.vsu@altlinux.ru> <200605271624.11062.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E39vaYmALEf/7YXx"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.altlinux.org ([62.118.250.235]:37125 "EHLO
	master.altlinux.org") by vger.kernel.org with ESMTP id S964879AbWE0Qb1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 12:31:27 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200605271624.11062.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--E39vaYmALEf/7YXx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 27, 2006 at 04:24:07PM +0200, Ivo van Doorn wrote:
> On Saturday 27 May 2006 15:55, Sergey Vlasov wrote:
[skip]
> > However, fs/udf/crc.c has exactly the same CRC table as rt2x00:
[skip]
> > This is a bit-reversed form of CRC-CCITT supported by lib/crc-ccitt.c.
> > Unfortunately, this does not help much, because converting one form to
> > the other is too expensive (you would need to reverse bits in all data
> > bytes, and then reverse bits in the 16-bit result).
> >=20
> > BTW, there is more CRC code duplication in drivers/bluetooth/hci_bcsp.c
> > (bcsp_crc_update() seems to give the same result as crc_ccitt_byte()).
> >=20
> > In drivers/media/dvb/frontends/nxt200x.c, nxt200x_crc() seems to give
> > the same result as rt2x00crc_byte() (but without using a table).
> >=20
> > drivers/net/wan/cycx_drv.c:checksum() is also some mutated version of
> > CRC-CCITT (adding two additional zero bytes at the end of data makes it
> > return the same result as rt2x00crc()).

More stealth CRC implementations:

- drivers/ieee1394/csr.c:csr_crc16() - the same as rt2x00crc();

- drivers/ieee1394/csr1212.c:csr1212_crc16() - again the same as
  rt2x00crc(), except the final byteswap;

- drivers/net/wireless/wavelan.c:psa_crc() is plain crc16(); it is
  duplicated in drivers/net/wireless/wavelan_cs.c;

- drivers/scsi/FlashPoint.c:FPT_CalcCrc16() is also crc16();

> Interesting, so it would actually be usefull to move the nxt200x
> crc16 implemetation into the crc16 library (Is not using a table
> preferred over using a table?)

Using a table is probably faster, but consumes more memory.

> And make rt2x00 and fs/udf/crc.c make use of this library?
>=20
> And perhaps hci_bcsp could be updated to use crc_ccitt_byte() instead?

--E39vaYmALEf/7YXx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEeH7CW82GfkQfsqIRAiG9AJ9y7SFBktyQ/gBDR48+ym/6o78cxACfUad3
4yZmFoS9pRTC3Scc+YX06Qs=
=YTaU
-----END PGP SIGNATURE-----

--E39vaYmALEf/7YXx--
