From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Wed, 19 Aug 2015 16:24:16 +0200
Message-ID: <20150819142416.GA26271@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
 <20150819091318.GV17917@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
 <20150819130744.GA24832@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
To: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>, Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:58459 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbbHSOYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 10:24:20 -0400
Content-Disposition: inline
In-Reply-To: <20150819130744.GA24832@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 19 15:07, Corinna Vinschen wrote:
> On Aug 19 09:31, Hayes Wang wrote:
> > Corinna Vinschen [mailto:vinschen@redhat.com]
> > > Sent: Wednesday, August 19, 2015 5:13 PM
> > [...]
> > > > It could be cleared by setting bit 0, such as rtl_tally_reset() of =
r8152.
> > >=20
> > > Is it safe to assume that this is implemented in all NICs covered by =
r8169?=20
> >=20
> > It is supported from RTL8111C. That is, RTL_GIGA_MAC_VER_19 and later.
>=20
> Thanks.  In that case I would prefer the same generic method for all
> chip versions, so I'd opt for storing the offset values at rtl_open
> time as my patch is doing right now.  Is that acceptable?
>=20
> If so, wouldn't it make even more sense to use the hardware collected
> information in @get_stats64 throughout, except for the numbers collected
> *only* in software? =20
>=20
> I would be willing to propose a matching patch.

It just occured to me that the combination of resetting the counters on
post-RTL_GIGA_MAC_VER_19 chips plus offset handling would be quite
nice, because it would reset also the small 16 and 32 bit counters.

So I'd like to propose a patch which combines both techniques, if that's
an acceptable way to go forward.

Btw., does setting the reset bit in CounterAddrLow work the same way as
setting the CounterDump flag?  I.e, does the driver have to wait for the
hardware to set the bit to 0 again to be sure the reset is finished?


Thanks in advance,
Corinna

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1JGQAAoJEPU2Bp2uRE+gxrsP/iPOzdSvwRuRjShjWJNO2qbJ
yS+ftyNjGNeNiRt1GF7n4/fGJtWqo0qASXJFcjTg0j7l9WLlkXfrw3tq2BFXjoC8
nMp4nNH0meMjcOqM/ibIGVgo5jG+pWQ+Xtj/kV12vQRUIz8veyDfIk8CvDj4LPsu
+oQ0zqORrZlwedW1J8/BYQTaaxNrfNilq/dyGGrbVummKe/t7S71iGn8hbgL/Gsa
bghZK7qA/SSHU919cNBtKOkJ3LbeAmBylHMDPrFArFoPf/DhSN3LaZ/MPVDltBZA
khkSR0C8V7CAQC2Yn0RaiN5tHluz0HRS2CDOFQ9O5nsiZlnSMk6Vbt9CQlJs2hpP
Da068Kin50myVuiUsDpQtGVUG0H81AQKHiKf0L/dPVzyA1zkMERru9aYoUfKYtbp
j/xKSYkFbwDHCEVhZhV52AD/2ltmm9bUJaPuTZ1VPkWZgMXiY6kAKPs/it72yqED
IyLqdBPGqfdRVDmwk/elr/SIG6CQrrLmL+FYLFVgwVW6BrM2HBgmCCZbXw6aGeE4
hsvStyBhRogbkRKC4UuqU6rqPLhWRLFCQuvtBV+UbMyczIH06JI4/pqTtqGRiwqX
0cVOg2g0sAhamI1feWiaxLHQ3iqCmUBruv8OfGRK7YI9bLDeOYELOeR0DPmaObS2
gGjntDPS17pfvQsJC48u
=YNfq
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
