From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for
	ORCHIDaddresses
Date: Mon, 3 Mar 2008 13:19:57 +0200
Message-ID: <20080303111957.GU5813@verkkotelakka.net>
References: <20080302215954.GS5813@verkkotelakka.net> <04ba29fb2d9e370fd968ee2906a149c1@chewa.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DFFMAMYvrfM3lt66"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Remi Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from refraktori.verkkotelakka.net ([79.171.233.68]:51041 "EHLO
	refraktori.verkkotelakka.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbYCCLUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 06:20:03 -0500
Content-Disposition: inline
In-Reply-To: <04ba29fb2d9e370fd968ee2906a149c1@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DFFMAMYvrfM3lt66
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 03, 2008 at 11:19:40AM +0100, Remi Denis-Courmont wrote:
> On Sun, 2 Mar 2008 23:59:54 +0200, Juha-Matti Tapio
> <jmtapio@verkkotelakka.net> wrote:
> >> Then, what you should do is to appropriately configure your policy
> >> (label) table via the addrlabel subsystem.
> > That would propably mean doing something like merging labels 1 (::/0),
> > 2 (6to4) and 6 (Teredo) together? I suppose that could be possible,
> > since after all there is also the workaround of just getting separate
> > 6to4 addresses for all the necessary interfaces.
> Please do NOT do this.
>=20
> 6to4 and Teredo have separate labels for a reason: 6to4-to-6to4 is
> reliable, and Teredo-to-Teredo is fairly OK. 6to4-to-native often fails,
> and Teredo-to-native very often fails due to missing, congested or even
> mis-configured relays between the native IPv6 bone, and these two
> transition mechanism.

I meant merging them locally on the system where there are ORCHID and
6to4/Teredo addresses but not native global addresses. Merging the
generic default labels together would clearly break a lot of stuff.

Then again, I feel putting this configuration burden for the local
sysadmin is a bit too much as this is a complex matter.

> Unfortunately, glibc has the settings
> _wrong_ (IMHO): while it has the same labels has the kernel, the way glibc
> does private IPv4 addresses scoping breaks at Rule 2, which bypasses the
> IPv6 transition mechanism labels at Rule 5. And will also break the ORCHID
> label when it is added :( That's a different story, but you may want to
> make that is not where you problems are coming from.

I had not thought originally about glibc-issues, and I should look
into it a bit. But the kernel update alone was enough to fix my test
system. Besides, the bug I encountered is with source address
selection.

I'm not sure there even is a problem with destination address
selection and ORCHID. It propably is not a good idea to mix
native and ORCHID addresses in DNS for the same name because this
would break hosts without any ORCHID support.



--=20
Tmi Juha-Matti Tapio    Puh/Tel. +358-50-5419230
Y-tunnus 1911527-0

--DFFMAMYvrfM3lt66
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHy97dRGhQc/k/gTsRAlLwAKCKAi5WMokEgPh02FQ3Tkb9NbtbnQCgnZaE
X3bZXwlTbWxPyWcPwufDY/A=
=72uM
-----END PGP SIGNATURE-----

--DFFMAMYvrfM3lt66--
