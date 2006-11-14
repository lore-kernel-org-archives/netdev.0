From: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Wed, 15 Nov 2006 01:29:59 +1100
Message-ID: <20061114142959.GA17486@keitarou>
References: <ej09qf$2nv$1@sea.gmane.org> <200611111607.05420.mb@bu3sch.de> <20061112012430.GA29648@keitarou> <200611120934.28133.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from betty.cbit.net.au ([202.55.154.10]:45277 "EHLO mail.cbit.net.au")
	by vger.kernel.org with ESMTP id S965871AbWKNO15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 09:27:57 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200611120934.28133.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 12, 2006 at 09:34:27AM +0100, Michael Buesch wrote:
> On Sunday 12 November 2006 02:24, Paul TBBle Hampson wrote:
>> On Sat, Nov 11, 2006 at 04:07:05PM +0100, Michael Buesch wrote:
> >> On Saturday 11 November 2006 07:32, Paul Hampson wrote:
> >>> Michael Buesch <mb <at> bu3sch.de> writes:
>>=20
> > >>> On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> > > >>> I've been backporting the bcm43xx-d80211 driver to whatever the r=
eleased
> > > >>> 2.6 kernel was using the rt2x00 project's d80211 stack (equivalen=
t to
> > > >>> current wireless-dev but with a workaround for not having a ieee8=
0211_dev
> > > >>> pointer and still using the _tfm interface instead of the _cypher=
 interface.)
>>=20
> > > >>> As of last night's wireless-dev tree bcm43xx, everything seems to=
 be
> > > >>> operating fine except incoming broadcast traffic is coming in 14 =
bytes too
> > > >>> long and scrambled. I presume this means it's not decrypting prop=
erly...
>>=20
> > >>> It sounds like a bug in the hardware decryption setup.
> > >>> Are you using TKIP or not?
>>=20
> >>> Yes, it's using TKIP. The router docs and the loading of the tkip mod=
ule
> >>> when I use the softmac driver agree on this.
>>=20
> >> TKIP is still software encryption. Did you try with WPA-AES, for examp=
le,
> >> which is hardware encryption?

I've just tried with WEP-104, which reports hardware encryption for all
four keys.

> Ah, and also note that you _need_ firmware from a v4 binary driver
> to have hardware encryption with bcm43xx.

Just to summarise results so far:

(Current version)
bcm43xx-d80211 w/v3 firmware and TKIP: Garbled broadcast RX
bcm43xx-d80211 w/v4 firmware and TKIP: Garbled broadcast RX
bcm43xx-d80211 w/v4 firmware and WEP-104: Correct broadcast RX

(version from wireless-dev before October 23rd, unsure of exact date)
bcm43xx (softmac) w/v3 firmware and TKIP: Correct broadcast RX

Still to test: bcm43xx-d80211 w/v3 firmware and WEP-104

I also tried looking at how the two drivers I've got here are clearing
their keys and comparing them to the bcm specs, and there's nothing
obviously wrong that I can see. Sadly I can't compare the drivers
directly since one is using the v3 specs and one the v4 specs... -_-

And to top it off, current wireless-dev's softmac bcm43xx driver doesn't
build against 2.6.18, and I'm not yet motivated into munging it into
doing so, unless it will have diagnostic advantage to this situation.
(It'll require also building a new ieee80211softmac at least)

--=20
-----------------------------------------------------------
Paul "TBBle" Hampson, B.Sc, LPI, MCSE
On-hiatus Asian Studies student, ANU
The Boss, Bubblesworth Pty Ltd (ABN: 51 095 284 361)
Paul.Hampson@Pobox.Com

Of course Pacman didn't influence us as kids. If it did,
we'd be running around in darkened rooms, popping pills and
listening to repetitive music.
 -- Kristian Wilson, Nintendo, Inc, 1989

License: http://creativecommons.org/licenses/by/2.1/au/
-----------------------------------------------------------

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFWdLmexDuohKLFuARAvZBAKCm8Hf0BJh9/3A16rDmnk6LQk1DmgCeL9cP
rMBPXPHtneN9xMv9Xkp666c=
=5L0D
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
