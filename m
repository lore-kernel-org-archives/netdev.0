From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 15:31:06 +0200
Message-ID: <200604281531.06896.IvDoorn@gmail.com>
References: <200604280003.12743.IvDoorn@gmail.com> <200604281459.24186.IvDoorn@gmail.com> <20060428131430.GA3288@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2683977.pKz4eUQjbd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:45064 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030380AbWD1N35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:29:57 -0400
Received: by nproxy.gmail.com with SMTP id x30so1493635nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:29:56 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060428131430.GA3288@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2683977.pKz4eUQjbd
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:14, Christoph Hellwig wrote:
> On Fri, Apr 28, 2006 at 02:59:23PM +0200, Ivo van Doorn wrote:
> > I am not sure if that would be a wise idea,
> > there is no byte ordering done in rt2500usb except for the EEPROM
> > contents which is little endian.
> > So when the module is used on a normal x86 platform, there won't be
> > any big endian structures or fields.
>=20
> Well, then you'll need __le* annotation and the le*_to_cpu/cpu_to_le*
> instead.  Any new driver should be endian clean.

Not exactly true for rt2570, to correctly operate with the device, no
endian conversions should be made at all. Not to big endian and not
to little endian. The register should be send as a regular value with the
byteordering equal to the byteordering of the currently used CPU.
It has been tested to send only little endian or big endian values to
the device on all CPU's, and in all cases it meant that the device would no=
t function on
CPU's with the other byte ordering.

--nextPart2683977.pKz4eUQjbd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhkaaqndE37Em0gRAuALAJ45nbkGmCKZnuABI+UR9Von8KEqSQCdHqUh
jWjM/1OIi3f/zTiL06T5+nc=
=4Dss
-----END PGP SIGNATURE-----

--nextPart2683977.pKz4eUQjbd--
