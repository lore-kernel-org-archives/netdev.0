From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Wed, 10 Dec 2014 11:17:24 -0600
Message-ID: <20141210171724.GI4602@saruman>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman>
 <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y96v7rNg6HAoELs5"
Cc: Felipe Balbi <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38660 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbaLJRR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 12:17:29 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--y96v7rNg6HAoELs5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Dec 05, 2014 at 11:03:44AM +0100, Yegor Yefremov wrote:
> On Thu, Dec 4, 2014 at 5:56 PM, Felipe Balbi <balbi@ti.com> wrote:
> > Hi,
> >
> > On Thu, Dec 04, 2014 at 05:41:38PM +0100, Yegor Yefremov wrote:
> >> I have following problem. My systems reboots at high network load
> >> after this commit (found via git bissect):
> >>
> >> commit 55601c9f24670ba926ebdd4d712ac3b177232330
> >> Author: Felipe Balbi <balbi@ti.com>
> >> Date:   Mon Sep 8 17:54:58 2014 -0700
> >>
> >>     arm: omap: intc: switch over to linear irq domain
> >>
> >>     now that we don't need to support legacy board-files,
> >>     we can completely switch over to a linear irq domain
> >>     and make use of irq_alloc_domain_generic_chips() to
> >>     allocate all generic irq chips for us.
> >>
> >>     Signed-off-by: Felipe Balbi <balbi@ti.com>
> >>     Signed-off-by: Tony Lindgren <tony@atomide.com>
> >>
> >> and I get following error messages:
> >>
> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> >
> > irq 0 ? Weird, that's not a valid IRQ.
> >
> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> >> ->action():   (null)
> >>    IRQ_NOPROBE set
> >>  IRQ_NOREQUEST set
> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> >> ->action():   (null)
> >>    IRQ_NOPROBE set
> >>  IRQ_NOREQUEST set
> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> >> ->action():   (null)
> >>    IRQ_NOPROBE set
> >>  IRQ_NOREQUEST set
> >> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> >> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> >> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> >> ->action():   (null)
> >>
> >> My system: am335x with fast ethernet on the first slave and gigabit
> >> Ethernet on second CPSW slave. This issue occurs, when I ran nuttcp
> >> with default settings.
> >>
> >> With commit above I can at least see these messages, but 3.18-rc7 for
> >> example reboots without any messages.
> >>
> >> Any idea?
> >
> > if you take v3.18-rc7 and just revert that commit, does the problem go
> > away ?
>=20
> git revert failed as the driver has more changes meanwhile or I'm
> missing some params. I've tried to force the driver to use legacy
> routines, but then I don't get pass U-Boot's "Starting kernel ..." See
> attached patch.
>=20
> Compiler used:
>=20
> Linux version 3.18.0-rc7 (...) (gcc version 4.8.3 20140320
> (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #309 SMP Fri Dec 5
> 10:59:38 CET 2014
>=20
> Btw, what am335x based hardware do you have? I can run tests on both
> BBB and am335x-evmsk.

coming back to this. I have BBB only. Can you provide some extra
information on how I can trigger this problem here ?

cheers

--=20
balbi

--y96v7rNg6HAoELs5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUiIAkAAoJEIaOsuA1yqREwNwP/jFVAAIMWayhuTwQZpqmb+/i
mCj92FFu0Or/FjLTIccrImkxPu+DkokWLXBuyo3LlKLTZo/tZF6N7xBkw6CEHaaf
BqrhrL8QDknu344BCYGfsq8w8BzJJUeqftVLCi0duWevQ339Iz0qawbMbmaYD/AW
6QkARpEc+BUKI7cnlQwo+MTiVCtzMBsFG7e7P+iD3mVYWVD4BtmQyaFErb1t0C8k
l0at7KZICGMZCR01UgSy5fBQb0OTI/mo+tWTSIM1t4FpjWvuNxMdP/Hgyd+uLtZP
sbgvNuiiNZAJg3m3fN1mZxUkrJNPrur56cEPKn5mM/pR+nUMb/uILpWMb8Ry1AJ2
XpPMWInGoZ1CkGye6/eV9T0KM1cpz37lN6sIXBE+DtYHkQUUlUZ/obe1k/KIFXHS
70kd2hglmgJDyFgHR3q+os8vAex4z5BQZxqHPMT6GaruD4CIO96xzV01CJ0kYaj3
soOnmvspBq7JADZD4Mf9+RPKHa+nWhIpb/jziFq1WeDozGtQb5aSaO0hkQ6QCzVH
Kby0HZbe/6eOUUkyhf08Ubpd78nDtpqjayaM4Dfa6MgV9GULbalLPAv1K2ba9Skc
0uofvQwHKDB2geK1BuXl3HrLcGdxW8z/fO0w3jeHmTY22RVRYKn0qKKj44f4nX/k
aj/JEEpJYp4pnOnB/4Cj
=mNju
-----END PGP SIGNATURE-----

--y96v7rNg6HAoELs5--
