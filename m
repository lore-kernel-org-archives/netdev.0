From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual interface support
Date: Thu, 4 May 2006 22:55:58 +0200
Message-ID: <200605042256.02333.IvDoorn@gmail.com>
References: <200605012135.00895.mb@bu3sch.de> <20060502132037.059a7cb2@griffin.suse.cz> <e3dkfd$pc5$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3449645.TcGz06YUtC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:11054 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751175AbWEDVMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 17:12:17 -0400
Received: by nf-out-0910.google.com with SMTP id m18so248713nfc
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 14:12:16 -0700 (PDT)
To: Marcus Better <marcus@better.se>
In-Reply-To: <e3dkfd$pc5$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3449645.TcGz06YUtC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 4 May 2006 21:26, Marcus Better wrote:
> Jiri Benc wrote:
> > This is unnecessary. AFAIK bcm43xx hardware doesn't support more than o=
ne
> > interface at a time (not counting monitor interfaces as those are somew=
hat
> > special).
>=20
> I wonder what exactly is causing this limitation? Why isn't it just a mat=
ter
> of software support?

Hardware limitations probably. For example the Ralink devices.
The MAC address must be written into the registers for correct behaviour.
When multiple virtual interfaces are going to be used, the device
should be working under multiple MAC addresses. While the device
could be tricked into doing that (I believe rt61 and rt73 drivers from Rali=
nk
are making such an attempt) it could give quite some overhead when for
each frame that is being send the driver should sort out from which
virtual interface it came, write the matching MAC address to the register,
and hope that the device will like it when the MAC address is changed so of=
ten
and the RX is not being affected because of some hardware filter.

--nextPart3449645.TcGz06YUtC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEWmpiaqndE37Em0gRAmb1AJ9L5gIU6baytIGCKK9LHL5ASAyb3gCdGPwj
nwwxkKpIgV/opfWnfcwYXv8=
=AtjK
-----END PGP SIGNATURE-----

--nextPart3449645.TcGz06YUtC--
