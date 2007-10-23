From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Tue, 23 Oct 2007 14:20:46 +1000
Message-ID: <1193113246.2898.18.camel@concordia>
References: <1192829817.22064.559.camel@teletran1>
	 <20071021.162131.43417026.davem@davemloft.net>
	 <1193017764.10318.17.camel@concordia>
	 <20071022181336.GC4280@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rS6NbzTo7X2Yz8xnYXOt"
Cc: David Miller <davem@davemloft.net>, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	mchan@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45491 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbXJWEUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 00:20:47 -0400
In-Reply-To: <20071022181336.GC4280@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rS6NbzTo7X2Yz8xnYXOt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2007-10-22 at 13:13 -0500, Linas Vepstas wrote:
> On Mon, Oct 22, 2007 at 11:49:24AM +1000, Michael Ellerman wrote:
> >=20
> > On pseries there's a chance it will work for PCI error recovery, but if
> > so it's just lucky that firmware has left everything configured the sam=
e
> > way.=20
>=20
> ? The papr is quite clear that i is up to the OS to restore the msi
> state after an eeh error.

Perhaps. I see R1-7.3.10.5.1-10, which says we should restore the config
space after a reset operation, but after an isolate/unisolate we must
recall RTAS. I thought EEH was doing the isolate/unisolate, but if it's
just a reset then just blatting the config space back should work.

> > Yes I think so. That way we can properly reconfigure via the firmware
> > interface. The other option would be to design some new arch hook to do
> > resume, but just doing a disable/enable seems simpler to me.
>=20
> Err, If you read the code for suspend/resume, it never actually calls
> disable/enable (and thus doesn't go to the firmware); it calls=20
> restore_msi_state() function!

I know. That was a proposed solution, to explicitly call disable/enable
instead of restore_msi_state().

> If suspend/resume needs to call firmware to restore the state, then,
> at the moment, suspend/resume is broken.  As I mentioned earlier,
> I presumed that no powerpc laptops currently use msi-enabled devices,
> as otherwise, this would have been flushed out.

On _pseries_ suspend/resume with MSI is broken. The other powerpc
platforms that implement MSI should be fine, although I don't think
anyone's tested them, because they're not laptops and so suspend/resume
is not that interesting.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-rS6NbzTo7X2Yz8xnYXOt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHHXaedSjSd0sB4dIRAqKvAKCYrQG/2dHtB1A/Qq58kkkZiGVItQCguiGm
f8YdD2ktBOrcKI3ozlJVErQ=
=RDRm
-----END PGP SIGNATURE-----

--=-rS6NbzTo7X2Yz8xnYXOt--

