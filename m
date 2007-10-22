From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 11:49:24 +1000
Message-ID: <1193017764.10318.17.camel@concordia>
References: <1192829817.22064.559.camel@teletran1>
	 <20071021.162131.43417026.davem@davemloft.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-eRZzph4WCtjgwernsoX+"
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linas@austin.ibm.com,
	mchan@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36761 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbXJVBt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 21:49:26 -0400
In-Reply-To: <20071021.162131.43417026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eRZzph4WCtjgwernsoX+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-10-21 at 16:21 -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Fri, 19 Oct 2007 14:36:56 -0700
>=20
> > This patch exports the pci_restore_msi_state() function.  This function
> > is needed to restore the MSI state during PCI error recovery.
> >=20
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
>=20
> I'm not so sure about this.

On pseries there's a chance it will work for PCI error recovery, but if
so it's just lucky that firmware has left everything configured the same
way. For actual suspend/resume it will never work, we need to ask
firmware to configure things.

> Perhaps, instead, you should do a pci_msi_disable() and
> pci_msi_enable() in the error detection and recovery sequence.

Yes I think so. That way we can properly reconfigure via the firmware
interface. The other option would be to design some new arch hook to do
resume, but just doing a disable/enable seems simpler to me.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-eRZzph4WCtjgwernsoX+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHHAGkdSjSd0sB4dIRAuAcAKDN9ww2L20UWqzhKcAwCPxjIDX8tACgyyR1
nlVp3pd3dMeMZDrlG5K3NbY=
=kRb4
-----END PGP SIGNATURE-----

--=-eRZzph4WCtjgwernsoX+--

