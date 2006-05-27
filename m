From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: CRC16 in rt2x00
Date: Sat, 27 May 2006 22:46:22 +0200
Message-ID: <200605272246.30450.IvDoorn@gmail.com>
References: <200605271327.18879.IvDoorn@gmail.com> <200605271624.11062.IvDoorn@gmail.com> <20060527163059.GB14973@procyon.home>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5896709.lkciMdT1vV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:38024 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964948AbWE0Unv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 16:43:51 -0400
Received: by nf-out-0910.google.com with SMTP id l36so74831nfa
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 13:43:50 -0700 (PDT)
To: Sergey Vlasov <vsu@altlinux.ru>
In-Reply-To: <20060527163059.GB14973@procyon.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5896709.lkciMdT1vV
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 27 May 2006 18:30, Sergey Vlasov wrote:
> On Sat, May 27, 2006 at 04:24:07PM +0200, Ivo van Doorn wrote:
> > On Saturday 27 May 2006 15:55, Sergey Vlasov wrote:
> [skip]
> > > However, fs/udf/crc.c has exactly the same CRC table as rt2x00:
> [skip]
> > > This is a bit-reversed form of CRC-CCITT supported by lib/crc-ccitt.c.
> > > Unfortunately, this does not help much, because converting one form to
> > > the other is too expensive (you would need to reverse bits in all data
> > > bytes, and then reverse bits in the 16-bit result).
> > >=20
> > > BTW, there is more CRC code duplication in drivers/bluetooth/hci_bcsp=
=2Ec
> > > (bcsp_crc_update() seems to give the same result as crc_ccitt_byte()).
> > >=20
> > > In drivers/media/dvb/frontends/nxt200x.c, nxt200x_crc() seems to give
> > > the same result as rt2x00crc_byte() (but without using a table).
> > >=20
> > > drivers/net/wan/cycx_drv.c:checksum() is also some mutated version of
> > > CRC-CCITT (adding two additional zero bytes at the end of data makes =
it
> > > return the same result as rt2x00crc()).
>=20
> More stealth CRC implementations:
>=20
> - drivers/ieee1394/csr.c:csr_crc16() - the same as rt2x00crc();
>=20
> - drivers/ieee1394/csr1212.c:csr1212_crc16() - again the same as
>   rt2x00crc(), except the final byteswap;
>=20
> - drivers/net/wireless/wavelan.c:psa_crc() is plain crc16(); it is
>   duplicated in drivers/net/wireless/wavelan_cs.c;
>=20
> - drivers/scsi/FlashPoint.c:FPT_CalcCrc16() is also crc16();
>=20
> > Interesting, so it would actually be usefull to move the nxt200x
> > crc16 implemetation into the crc16 library (Is not using a table
> > preferred over using a table?)
>=20
> Using a table is probably faster, but consumes more memory.
>=20
> > And make rt2x00 and fs/udf/crc.c make use of this library?
> >=20
> > And perhaps hci_bcsp could be updated to use crc_ccitt_byte() instead?

Thanks,
I will take another look at the drivers as well and see which drivers
could best be udpated to use the kernel library instead of using
its own implementation.
This will take a couple of days, but then I should have a couple of
patches ready to add some crc libs and update the drivers to make
use of these labs.

Ivo

--nextPart5896709.lkciMdT1vV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEeLqmaqndE37Em0gRAmSQAJ0Xyru3rc2YvBD910jrVRAzFyoAVACgyEQ3
4vsRHZXd7YJpJ0pmKd6m/tk=
=72YM
-----END PGP SIGNATURE-----

--nextPart5896709.lkciMdT1vV--
