From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Wed, 19 Aug 2015 11:10:37 +0200
Message-ID: <20150819091037.GU17917@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <20150818.190537.1494539251161022002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="UExESr5xZTMxdOWv"
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
	ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:53258 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbbHSJdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 05:33:43 -0400
Content-Disposition: inline
In-Reply-To: <20150818.190537.1494539251161022002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UExESr5xZTMxdOWv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 18 19:05, David Miller wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Tue, 18 Aug 2015 23:40:17 +0200
>=20
> > Corinna Vinschen <vinschen@redhat.com> :
> >> The r8169 driver collects statistical information returned by
> >> @get_stats64 by counting them in the driver itself, even though many
> >> (but not all) of the values are already collected by tally counters
> >> (TCs) in the NIC.  Some of these TC values are not returned by
> >> @get_stats64.  Especially the received multicast packages are missing
> >> from /proc/net/dev.
> >> Rectify this by fetching the TCs and returning them from
> >> rtl8169_get_stats64.
> >=20
> > It is not exactly a some / many / not all / confused [*] picture
> > - get_stats64 provides software managed values
> > - ethtool provides hardware only values
> >=20
> > [*] ok, rx_missed is kinda special.
> >=20
> >> The counters collected in the driver obviously disappear as soon as the
> >> driver is unloaded so after a driver is loaded the counters always sta=
rt
> >> at 0.  The TCs are only reset by a power cycle and there's no known way
> >> to reset them programatically. Without further considerations the valu=
es
> >> collected by the driver would not match up against the TC values.
> >=20
> > I'd rather:
> > 1. keep software and hardware stats separated
> > 2. push to userspace the responsibility to offset device specific hardw=
are
> >    values jumps
> >=20
> > My 0.02 =E2=82=AC.
>=20
> Any value that is provided by ->get_stats64() should be provided by whate=
ver
> mechanism is available and determined to be "prudent" for the device in
> question.  If the device is not tracking the event, this means pure softw=
are
> counters.
>=20
> If the device tracks the event, you should attempt to use the hardware
> facility to provide the ->get_stats64() values.
>=20
> If the hardware provides counters not starting at zero on driver load,
> one option to handle that is to load the initial values of all of
> those counters and calculate diffs at ->get_stats64() time.

That's what my code is doing, just for a limited set of values.

I was already wondering why some values available in the hardware tally
counters are additionally counted in software.  I was planning to
propose to use the hardware counters in @get_stats64 in the first place
and only count values in the driver which are not provided by the
hardware


Corinna

--UExESr5xZTMxdOWv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1EgNAAoJEPU2Bp2uRE+gKbUP/jncZJDJhLgzt7H6nbzHLGTs
EY2CRHGXqeFzrqh50fEueekk05Jx9BKzNQUZxuerz950mZSNc9BpMkPZaLbip/Ka
dI8NZwjY9eIQ8wg/X+NNrQnoYw/FqfSBsm9Q97jjJAiEdHzeUqlEx2mcqNUEH7oQ
cUVPKgFlXtbJiCAxePYhoNXvW2VIbOJJuvvhlYuaYhnKL+v0nmX7DERa9MaZlwrW
4aRDU6DFXgqeK2zPSWZ3HLvjAIedIzOnT2cES+fB4fa71fg5/v9Jxgp1jYcj849z
/vQug88GVyxrPpknWTXNi/sYxiGVDYtSnfYP0tb9LlAvtYlNI0ok40UIaiedGcB+
o4ThINe1GIo4OCO40EFs3MbH3G/+AEKgjR5pYcwwDlfotCgFsRwcLp4uGHpDpSBq
gme5KO5LAFe2cw2/7Ir2BFeyA5viuys1b4hwHXFJMlM5bz5QsxZAPLsMtEzauJp3
b2r/pB2dUMgT0iB//Z+VqBNEoT9bB3SfdwrJkW4hvu2K8myr/PWvP5Bkbe/xF1SA
dKo+Jr6nNb9cbRjd5FNHbIksnSovHH5URjuNr0kNkwVPXUt9bUpc+r607OuybxPQ
EKd9Wlpj3I5JsKavxhdOFGkEr4vA5TbTa7ocps2NKkzZAGwjwJnvwteOFn9vntEJ
Hf7ZOez9CMeh7+pgmIa+
=lenh
-----END PGP SIGNATURE-----

--UExESr5xZTMxdOWv--
