From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: bnx2 cards intermittantly going offline
Date: Sun, 16 Sep 2012 04:47:46 +0100
Message-ID: <1347767266.13258.227.camel@deadeye.wl.decadent.org.uk>
References: <20120913135108.GC3650@abomination.net.united.domain>
	 <5051FFAA.8060501@opera.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LEGCIiBtTaz1URDtc2WY"
Cc: netdev@vger.kernel.org, "Marc A. Donges" <marc.donges@1und1.de>,
	Michael Chan <mchan@broadcom.com>
To: Sven Ulland <sveniu@opera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53270 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269Ab2IPDr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:47:58 -0400
In-Reply-To: <5051FFAA.8060501@opera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LEGCIiBtTaz1URDtc2WY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-13 at 17:45 +0200, Sven Ulland wrote:
> On 09/13/2012 03:51 PM, Marc A. Donges wrote:
> > After 55 days of operation the machine (A) suddenly was no longer
> > reachable via network. Strangely, a second machine (B) that should
> > take over the IP addresses (keepalived) did not take over. Only
> > after shutting the switchport to which A is attached did B take
> > over.
>=20
> Hi. We've had the same symptom with our BCM5709S [14e4:163a] on
> Debian. Like you, we were on stable's 2.6.32-41squeeze2. Google led us
> to many similar issues [1,2,3]. They concluded with the fix being in
> mainline commit c441b8d2 [4]: "bnx2: Fix lost MSI-X problem on 5709
> NICs".
>
> Broadcom: Can you publish a tool that decodes ethtool -d dumps to make
> debugging easier, or do you deem it no longer necessary with the the
> register dump commits in 555069da?

This tool should be ethtool itself (it includes dump decoders for many
drivers).

> Now, Debian's 2.6.32-41squeeze2 is based on longterm release 2.6.32.54
> [5]. That version includes commit 0b7817ed [6], which is a backport of
> the already mentioned mainline commit c441b8d2.
>
> So we tried digging further and applying some seemingly relevant
> commits [7,8] to our 2.6.32, but without any change in behaviour. Our
> temporary fix was to run 'ethtool -t ethX' to reset the device every
> time it locked up.
>=20
> This dragged on with various builds, until we ended up on mainline
> 2.6.38 where we no longer saw any symptoms. I don't know in which
> kernel version it was fixed, but we ended up on that one, sort of by
> chance. Unfortunately, it had severe issues with kswapd memory
> compaction causing CPU soft lockups [9], so we went straight to
> squeeze-backports' 3.2.23-1~bpo60+2. We've been happy since then.
>
> > We have five pairs of basically identical machines performing the
> > same task (each pair for one site). The error has not occured with
> > any other one, but this site is the busiest:
>=20
> We also saw the issue only at a site with generally higher load
> compared to other sites.
>=20
> I'd love to know exactly which commit fixed the issue, but it's fairly
> tricky to reproduce the issue, and the bisect count is fairly high (it
> need not be a specific fix for bnx2).

I don't see any changes to the driver itself that look relevant.
Perhaps this was a firmware bug?

Ben.

--=20
Ben Hutchings
Experience is what causes a person to make new mistakes instead of old ones=
.

--=-LEGCIiBtTaz1URDtc2WY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVL4ue/yOyVhhEJAQp7VRAAvz58WrGbNepXjbZkRa51ZOR03P/xFbeE
KZsG5FhHAHRQG3kef5UbNkGy3XdyquI1Ayy+BqAHdeDkSmXAH/UblOK8LqSPJltn
ArI8h67UcEnkb3wH8Wi9wWcv8iIfDxlw+Cga0rxxZochHrvGiBO+mDdFBlna4dMe
lVisNCNpD0spzGxuEB5n8LLtnoUYC3KGgnZURUWbSFDGOMlyXZLG08vj5WhtiISX
kUIrmb98KWuewx5RFRElkCFcd7ETINxS4Zjp8q3plZNSnQAcDM/1nYDPkj9ku0f/
vTV5v24CFGus61vMpfkXuaahLNrizkB+MCJQehkNrjBRFhTpAjgKm31r3vZaochF
LTm+8wBR9aGPrOFDwAnK5I648cO5XEu9wq4iIpb/eyQm4tkju5RXmlbSG0SoPORU
5qNCbXtugSFEjj+hOY3th1jm0aD21yTFYL42l3Av1xInwyLLaFzn7jtO68nWZq8V
USqY7dUq3sU1+L0obKUMvIn2jJyHEl0TdL1vTtjOq2roTqoBy7avZ2i8BbzgSQ9n
M8EHmKn3/GOJ4sSxT7XxumOIpRkNe4hUvAgSGrWZGZgA6vRTPyLG0RNfqBy52zlB
WtdOg/fOAcNC7s7VIphfu9J/mFtOgjTWmc3fGCE8u13xWdoRwEbqGRSqfyDHn4cx
aUE0aRnbRcw=
=LDGR
-----END PGP SIGNATURE-----

--=-LEGCIiBtTaz1URDtc2WY--
