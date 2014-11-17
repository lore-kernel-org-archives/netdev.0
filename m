From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH v3] ixgbe: Look up MAC address in Open Firmware or IDPROM
Date: Mon, 17 Nov 2014 23:35:33 +0000
Message-ID: <394BF90F-72D3-4CFC-99F5-FCECFDC9358E@intel.com>
References: <yq17fyxus1y.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_491C4478-C5C7-4E97-A41B-1A125776B031";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Martin K. Petersen" <mkp@mkp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40885 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbaKQXff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 18:35:35 -0500
In-Reply-To: <yq17fyxus1y.fsf@sermon.lab.mkp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_491C4478-C5C7-4E97-A41B-1A125776B031
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 14, 2014, at 6:16 PM, Martin K. Petersen <mkp@mkp.net> wrote:

> @@ -7960,6 +7970,29 @@ int ixgbe_wol_supported(struct ixgbe_adapter =
*adapter, u16 device_id,
> }
>=20
> /**
> + * ixgbe_get_platform_mac_addr - Look up MAC address in Open Firmware =
/ IDPROM
> + * @adapter: Pointer to adapter struct
> + */
> +static void ixgbe_get_platform_mac_addr(struct ixgbe_adapter =
*adapter)

How about tagging adapter with __maybe_unused in this case to avoid =
warnings when neither CONFIG_OF or CONFIG_SPARC are defined?

> +{
> +#ifdef CONFIG_OF
> +	struct device_node *dp =3D pci_device_to_OF_node(adapter->pdev);
> +	struct ixgbe_hw *hw =3D &adapter->hw;
> +	const unsigned char *addr;
> +
> +	addr =3D of_get_mac_address(dp);
> +	if (addr) {
> +		ether_addr_copy(hw->mac.perm_addr, addr);
> +		return;
> +	}
> +#endif /* CONFIG_OF */
> +
> +#ifdef CONFIG_SPARC
> +	ether_addr_copy(hw->mac.perm_addr, idprom->id_ethaddr);
> +#endif /* CONFIG_SPARC */
> +}
> +
> +/**
>  * ixgbe_probe - Device Initialization Routine
>  * @pdev: PCI device information struct
>  * @ent: entry in ixgbe_pci_tbl

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_491C4478-C5C7-4E97-A41B-1A125776B031
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJUaoZEAAoJEDwO/+eO4+5u6RwQAJ3UA2qehiJbGmujPH0jPMPG
EQiNVRzzAY5e4ll+Hiby2/0P9rBukjqQBY3c5M3Z/iMha8Uxk1xlKOlWNyJe/Nix
H3UmXVW0mY5ZaRdPNBnkMVTq1udg6Qjx6Acyl/+0Af+GxoEI5sXHUR9MAWggBZk+
xjrGSYTztXKiX/zi1jJMy5A2SbpdMhFOcIKlKRq+9/e63vBoxD6Dx/KGTbiCvcOL
p5hW740uhNHNMAFrIWFOL4VjuAUuwgvldN+Cst8mSK6DWvTkRhAF5I0jp7/4qaRw
W4SXzxtQqxxBGIqpwMhP64de92QIDUfhTlGHu6/eyBtoJ4Hku5ItX6h36iTpKBk6
JxmIAfH8UdZcv8drbFQZvXnradu+nBzEB4VkD3Ly6cra0EiLEsBe4OWr314/rvKH
bu//ahSsvAMtGB9KQZUKpkI1WX6z3C0BjUDn5SSaD/MurBQQCIWJRoQTiXk9pQaD
O4QdlodQDQdEocKAstpPnuLwmA+aw68lT8+ua/4GJhsKFBfZqF6wfkCVFknfZC6d
UqLT8k7PHCs6J0JxWCQq5KLshDHIRPcqNAimR3EcSYYlLVS7xXRJ4cixPINKwoNM
Tsh4Dz3dBppE0E6v6MKdpMqnkS07B18QubEk5i9aLLYzRn+k+YlgH6IzgHoze7PF
OT0GVm3H/8WhH7q5UrgJ
=VWBS
-----END PGP SIGNATURE-----

--Apple-Mail=_491C4478-C5C7-4E97-A41B-1A125776B031--
