From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: Problems with a PCI SMC2802W
Date: Thu, 10 Mar 2005 11:30:07 -0500
Message-ID: <20050310163007.GK17854@ruslug.rutgers.edu>
References: <422F118D.8070704@voicenet.com>
	<20050309160744.GN4017@Redstar.dorchain.net>
	<20050309202718.4f94b871@veagle.suse.cz>
	<20050310021724.GD17854@ruslug.rutgers.edu>
	<42302133.2060103@voicenet.com>
	<20050310103608.GB1416@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0911153445=="
Cc: prism54-devel@prism54.org, Feyd <feyd@seznam.cz>
To: Chris Wedgwood <cw@f00f.org>, Jeff Garzik <jgarzik@pobox.com>,
	Netdev <netdev@oss.sgi.com>
In-Reply-To: <20050310103608.GB1416@taniwha.stupidest.org>
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


--===============0911153445==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="e5bfZ/T2xnjpUIbw"
Content-Disposition: inline


--e5bfZ/T2xnjpUIbw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 10, 2005 at 02:36:08AM -0800, Chris Wedgwood wrote:
> On Thu, Mar 10, 2005 at 05:28:03AM -0500, Adam K Kirchhoff wrote:
>=20
> > Unfortunately, the latest svn checkout doesn't want to compile for
> > me on 2.6.11:
>=20
> I have these diffs.  Forward to the list if you like since it never
> accepts email from me (grr)
>=20
>=20
> Index: ksrc/islpci_eth.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- ksrc/islpci_eth.c	(revision 528)
> +++ ksrc/islpci_eth.c	(working copy)
> @@ -90,7 +90,9 @@
>  	struct sk_buff *newskb;
>  	int newskb_offset;
>  	unsigned long flags;
> +#ifdef CONFIG_PRISM54_WDS
>  	unsigned char wds_mac[6];
> +#endif
>  	u32 curr_frag;
>  	int err =3D 0;
> =20
> @@ -362,9 +364,9 @@
>  	struct sk_buff *skb;
>  	u16 size;
>  	u32 index, offset;
> -	unsigned char *src;
>  	int discard =3D 0;
>  #ifdef CONFIG_PRISM54_WDS
> +	unsigned char *src;
>  	struct wds_priv *wdsp =3D priv->wdsp;
>  	struct net_device *wds_dev =3D NULL;
>  	struct wds_net_local *wds_lp;
> Index: ksrc/islpci_hotplug.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- ksrc/islpci_hotplug.c	(revision 528)
> +++ ksrc/islpci_hotplug.c	(working copy)
> @@ -277,7 +277,7 @@
>  	printk(KERN_NOTICE "%s: got suspend request (state %d)\n",
>  	       ndev->name, state);
> =20
> -	pci_save_state(pdev, priv->pci_state);
> +	pci_save_state(pdev);
> =20
>  	/* tell the device not to trigger interrupts for now... */
>  	isl38xx_disable_interrupts(priv->device_base);
> @@ -303,7 +303,7 @@
> =20
>  	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
> =20
> -	pci_restore_state(pdev, priv->pci_state);
> +	pci_restore_state(pdev);
> =20
>  	/* alright let's go into the PREBOOT state */
>  	islpci_reset(priv, 1);
> Index: ksrc/islpci_dev.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- ksrc/islpci_dev.h	(revision 528)
> +++ ksrc/islpci_dev.h	(working copy)
> @@ -112,7 +112,6 @@
> =20
>  	/* PCI bus allocation & configuration members */
>  	struct pci_dev *pdev;	/* PCI structure information */
> -	u32 pci_state[16];	/* used for suspend/resume */
>  	char firmware[33];
> =20
>  	void __iomem *device_base;	/* ioremapped device base address */
> Index: ksrc/islpci_mgt.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- ksrc/islpci_mgt.c	(revision 528)
> +++ ksrc/islpci_mgt.c	(working copy)
> @@ -345,7 +345,7 @@
>  		}
> =20
>  		/* Ensure the results of device DMA are visible to the CPU. */
> -		pci_dma_sync_single(priv->pdev, buf->pci_addr,
> +		pci_dma_sync_single_for_cpu(priv->pdev, buf->pci_addr,
>  				frag_len, PCI_DMA_FROMDEVICE);
> =20
>  		/* Perform endianess conversion for PIMFOR header in-place. */

Thanks, but the pci_[restore|save]_state changes requires testing/backporti=
ng to 2.4.=20
Same goes for pci_dma_sync_single_for_cpu(). We can macro this but ugh, it'=
s just so=20
horrible.

Margit, where are you?

Jeff, what's better a prismcompat24.h edit or a check for
LINUX_VERSION_CODE here?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--e5bfZ/T2xnjpUIbw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCMHYPat1JN+IKUl4RAkmpAJ9l42Hx+rOgOdrcMInC2xeiEJGsSACgjB2p
Q+qntGGYlnHLfbv3IK0WgEc=
=aCFv
-----END PGP SIGNATURE-----

--e5bfZ/T2xnjpUIbw--

--===============0911153445==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0911153445==--
