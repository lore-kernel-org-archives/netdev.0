From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 11/14] i40e: Ioremap changes
Date: Fri, 06 Mar 2015 00:16:18 +0000
Message-ID: <1425600978.8804.6.camel@decadent.org.uk>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1425573992-30955-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XCB7hOpICJJ2vAhGLXro"
Cc: davem@davemloft.net, Anjali Singhai <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46116 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbbCFAQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 19:16:39 -0500
In-Reply-To: <1425573992-30955-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XCB7hOpICJJ2vAhGLXro
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-05 at 08:46 -0800, Jeff Kirsher wrote:
[...]
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -9459,6 +9459,7 @@ static int i40e_probe(struct pci_dev *pdev, const s=
truct pci_device_id *ent)
>  	struct i40e_pf *pf;
>  	struct i40e_hw *hw;
>  	static u16 pfs_found;
> +	u32 ioremap_len;
>  	u16 link_status;
>  	int err =3D 0;
>  	u32 len;
> @@ -9507,8 +9508,11 @@ static int i40e_probe(struct pci_dev *pdev, const =
struct pci_device_id *ent)
> =20
>  	hw =3D &pf->hw;
>  	hw->back =3D pf;
> -	hw->hw_addr =3D ioremap(pci_resource_start(pdev, 0),
> -			      pci_resource_len(pdev, 0));
> +
> +	ioremap_len =3D min_t(int, pci_resource_len(pdev, 0),
> +			    I40E_MAX_CSR_SPACE);

What type do you really want ioremap_len to be, u32 or int?  (I think
the correct answer is unsigned long as that's the ioremap() parameter
type.)

Ben.

> +	hw->hw_addr =3D ioremap(pci_resource_start(pdev, 0), ioremap_len);
>  	if (!hw->hw_addr) {
>  		err =3D -EIO;
>  		dev_info(&pdev->dev, "ioremap(0x%04x, 0x%04x) failed: 0x%x\n",

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at once.

--=-XCB7hOpICJJ2vAhGLXro
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVPjx3ue/yOyVhhEJAQoyBg//fT6S/fOoyQ0d7+qB7xyAK4LK/LnAXskZ
IeXh4HeLFgFKlvQo5gPYytl1ILXOaxyvxA/mDdBrHE6fUjiCjXv2s8oeH51zl1Hc
V+4KgN6v4WOYKayYJS4POamitxBdArt4vDjDveJA1+XdJ7rdXOkEfDx3XIRNPGl/
IYAb+v9hMhYRCOE0N0RWLCpVgOP4mDm3Xbbi68LE1XANckKQyv4GlY9/k/Sl309U
xKj92kTXQVTvJxAd1qLpqTyGfAbDHZDvU/TFh4FlT/3PZPx5S6dBskd94bFP5Yg/
iY7nt7SJBEsev4Fb18q+etWR1j8/5CjJWAEW23bsQ/ep34XyEMfMKq84qLN7Rhhs
gMoC1V7B/5LqJWuT2D28nFBQQ+grxoYfGkCLILAZ3yAfCGjCilfjc5gST4JVuEyV
fHQZoB65g52OQALpXeCmo8FMIeUIwCzX5NIHGU28NeSv5RMpRv/DX0JuAZ6mK53c
pUEAypW4WC5Pd673hAbcGanl086SeucFyTTiXVo74Fe/lywSnvKGNVTedLOJ3x8L
O3uwA364C3AVRZnefw8KeIKwJaWcAjfFjfVKyEK7sXKIHTGJO+WIhiKCDU77xtUK
aojw5HxYNTBILbAVgtySe1fjhuXEtA0P85hxycGi9exddXxLoqjke2uTOIDZ5EE9
KRWMaFZq1Jc=
=dzas
-----END PGP SIGNATURE-----

--=-XCB7hOpICJJ2vAhGLXro--
