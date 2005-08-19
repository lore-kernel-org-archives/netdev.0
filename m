From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using jumbo
 frame
Date: Fri, 19 Aug 2005 20:10:56 +0200
Message-ID: <1124475056.23996.15.camel@localhost.localdomain>
References: <1124326404.5546.215.camel@localhost.localdomain>
	 <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
	 <20050819170248.GH3953@verdi.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-E/GRTRKlDhJOSXHKvo8X"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ming Zhang <mingz@ele.uri.edu>,
	E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <iscsitarget-devel-admin@lists.sourceforge.net>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050819170248.GH3953@verdi.suse.de>
Sender: iscsitarget-devel-admin@lists.sourceforge.net
Errors-To: iscsitarget-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:iscsitarget-devel@lists.sourceforge.net>
List-Help: <mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=iscsitarget-devel>
List-Id: netdev.vger.kernel.org


--=-E/GRTRKlDhJOSXHKvo8X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-08-19 at 19:02 +0200, Andi Kleen wrote:
> > I guess we need to approach the memory manager guys and ask them why th=
e=20
> > current kernels are having so much trouble getting contiguous memory.=20
>=20
> Because memory fragments.
>=20
> The only long term reliable way is to not allocate buffers > PAGE_SIZE.
> The stack supports paged skbs for that.

And the e1000 supports receiving/transmitting packets containing several
buffers according to the SDM, it just uses more descriptors in the rx/tx
rings.
Maybe it should allocate PAGE_SIZE large buffers, a 9kB packet would
then use 3 such buffers.

And it of course means more and smaller DMA transfers than when using
larger buffers.

--=20
/Martin

--=-E/GRTRKlDhJOSXHKvo8X
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDBiCwWm2vlfa207ERAr47AJ0YeIL6HeHl55HQBeyQaQMtRUVVEACgi+1t
V7GsG0qyBFcCjyp8ASYkack=
=XLEl
-----END PGP SIGNATURE-----

--=-E/GRTRKlDhJOSXHKvo8X--



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
