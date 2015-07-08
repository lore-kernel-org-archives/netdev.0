From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix disabling of tx
 interrupt in rx isr
Date: Wed, 8 Jul 2015 11:10:22 -0500
Message-ID: <20150708161022.GA10350@saruman.tx.rr.com>
References: <1436338066-7685-1-git-send-email-mugunthanvnm@ti.com>
 <20150708073855.GA7277@saruman.tx.rr.com>
 <559CE48F.1070802@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Cc: <balbi@ti.com>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stable@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36883 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758692AbbGHQK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 12:10:26 -0400
Content-Disposition: inline
In-Reply-To: <559CE48F.1070802@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 08, 2015 at 02:21:27PM +0530, Mugunthan V N wrote:
> On Wednesday 08 July 2015 01:08 PM, Felipe Balbi wrote:
> > Hi,
> >=20
> > On Wed, Jul 08, 2015 at 12:17:46PM +0530, Mugunthan V N wrote:
> >> With the below commit, common isr is split into tx and rx, but in
> >> rx isr tx interrupt is also disabled. So tx packets are not handled
> >> during rx interrupts and rx napi completion. Fixing by disabling on
> >> rx interrupt in rx isr.
> >>
> >> Fixes: c03abd84634d ("net: ethernet: cpsw: don't requests IRQs we don'=
t use")
> >=20
> > why does this fix that commit ? What was the regression ? So RX IRQ fire
> > and both RX and TX are disabled, sure that's bad. But it should cause
> > lower throughput. At a minimum, I think your commit log needs some work.
>=20
> Agreed, will change the commit and resubmit the patch as it affects
> performance only and not a regression.

thanks

> > Also, disable_irq_nosync() shouldn't really be needed, you could just
> > mask the IRQ in the IRQ Enable register, but I guess that'd be v4.3
> > material.
>=20
> This was needed because there is a latch inbetween CPSW interrupt line
> and Interrupt Controller (to convert from pulse interrupt to level
> interrupt), because of this even though interrupt is disabled from the
> IP, CPU is held up in isr as it is not cleared or masked to Interrupt
> controller. Because of disable_irq_nosync() was added initially. I will
> revisit this but as you said it will be for 4.3

still, that shouldn't be needed. Just mask and clear the IRQ straight
away, then handle it.

> With this patch I am able to see +3 Mbps with omap2plus_defconfig and
> +40Mbps with having AM43xx SoC only and removing some kernel debugging
> options.

looks like this should be in commit log in some shape or form.

--=20
balbi

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVnUtuAAoJEIaOsuA1yqREyXkP/3Dq0EFfIqEHzd7dOO+E70Kp
yeZUaj5mt6OCkYpaul3G0eNlMvBOWwhjWgV8nP2o6iKcN8zDPnDo47H3LMw6lh6q
BivOi88jVjGPdF3Fj4HTdudE1K0M6XNpFKyKOk46fKiFVa1rjyF6CUW1GylLFAqn
7f1kQ1nbIPPL/5cBa+jHypvry3AUbTwPE6dVE/8P6MGZB5hCqCExjm15QLAB5yMP
EUrxXwzux7w6fVbTJd/p1cNCyL7g93ZWSLDm8CUMhPh56YXDbPpGvRub99lj0HpM
2cGTjwZ6OrLMPklTMlZqHMyZvPSdqwt4GlXkPETQogB8HV/KEq5heImWay400NrQ
DZ93pju+dArxLKwDq9fSkT6zMRtMDssIK7H0+ukP5OiYRRNhES0HxFKTGK5j4136
aMcQJsPLsA9+RE//m4bok2aXr5WVyWfWiO2/vFAl8JqPMTATdm44h/J2aAQ3rN9t
2/jjkYpN/GyZYtXYXrgbcdy4GCxcdJJyysdR82GmxBlVJUWiOISin6Z2n7Ly2Keh
cF26glYlb2WKSAydpA/n9FHj7SBIyGOJfAd1ScpJo/ZAvrSppOXOGnEJvt758oyZ
tHA7aO3LjyVkZz6WdUhToys+MAclNIVO5rxfovgOBYJjk0jfiVf27L61AXdygwo7
ZCo2xrnhisLjIPEzD08m
=KWYu
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--
