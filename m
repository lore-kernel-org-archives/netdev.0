From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: Problems with a PCI SMC2802W
Date: Wed, 16 Mar 2005 11:24:48 -0500
Message-ID: <20050316162448.GR17854@ruslug.rutgers.edu>
References: <422F118D.8070704@voicenet.com>
	<20050309160744.GN4017@Redstar.dorchain.net>
	<20050309202718.4f94b871@veagle.suse.cz>
	<20050310021724.GD17854@ruslug.rutgers.edu>
	<42302133.2060103@voicenet.com>
	<20050310103608.GB1416@taniwha.stupidest.org>
	<20050310163007.GK17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0193208387=="
To: Chris Wedgwood <cw@f00f.org>, Jeff Garzik <jgarzik@pobox.com>,
	Netdev <netdev@oss.sgi.com>, Adam K Kirchhoff <adamk@voicenet.com>,
	prism54-devel@prism54.org, Feyd <feyd@seznam.cz>
In-Reply-To: <20050310163007.GK17854@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0193208387==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hqsgWuDCGoNNiKsj"
Content-Disposition: inline


--hqsgWuDCGoNNiKsj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Jeff/netdev,

If no comment is given on how we should deal with
pci_dma_sync_single/pci_dma_sync_single_for_cpu for 2.4 I'm just going
to put in a nasty ifdef there. Comemnts?

	Luis

On Thu, Mar 10, 2005 at 11:30:07AM -0500, Luis R. Rodriguez wrote:
> > Index: ksrc/islpci_mgt.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- ksrc/islpci_mgt.c	(revision 528)
> > +++ ksrc/islpci_mgt.c	(working copy)
> > @@ -345,7 +345,7 @@
> >  		}
> > =20
> >  		/* Ensure the results of device DMA are visible to the CPU. */
> > -		pci_dma_sync_single(priv->pdev, buf->pci_addr,
> > +		pci_dma_sync_single_for_cpu(priv->pdev, buf->pci_addr,
> >  				frag_len, PCI_DMA_FROMDEVICE);
> > =20
> >  		/* Perform endianess conversion for PIMFOR header in-place. */
>=20
> Thanks, but the pci_[restore|save]_state changes requires testing/backpor=
ting to 2.4.=20
> Same goes for pci_dma_sync_single_for_cpu(). We can macro this but ugh, i=
t's just so=20
> horrible.
>=20
> Margit, where are you?
>=20
> Jeff, what's better a prismcompat24.h edit or a check for
> LINUX_VERSION_CODE here?
>=20
> 	Luis
>=20
> --=20
> GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 5=
25E



--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--hqsgWuDCGoNNiKsj
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCOF3Qat1JN+IKUl4RApPLAJ99O8gqzvH+s1E0S6OI78+trbIVWgCeM4fb
hvE0RtuTkCURb5qCtJPCW1g=
=hSOy
-----END PGP SIGNATURE-----

--hqsgWuDCGoNNiKsj--

--===============0193208387==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0193208387==--
