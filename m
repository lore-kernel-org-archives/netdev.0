From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 08/14] ixgbe: Add support for generic Tx checksums
Date: Mon, 04 Apr 2016 18:29:28 -0700
Message-ID: <1459819768.2965.0.camel@intel.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1459808097-26409-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5702EB85.5080307@intel.com>
	 <20160404.212739.417828551756386273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ibGpRSA0ijqB53cs+q6F"
Cc: aduyck@mirantis.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:39468 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbcDEB3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 21:29:37 -0400
In-Reply-To: <20160404.212739.417828551756386273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ibGpRSA0ijqB53cs+q6F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-04-04 at 21:27 -0400, David Miller wrote:
> From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
> Date: Mon, 04 Apr 2016 15:32:37 -0700
>=20
> >=20
> > On 4/4/2016 3:14 PM, Jeff Kirsher wrote:
> > >=20
> > > @@ -9190,41 +9148,37 @@ skip_sriov:
> > > =C2=A0=C2=A0=C2=A0=C2=A0#endif
> > > =C2=A0=C2=A0	netdev->features =3D NETIF_F_SG |
> > > -			=C2=A0=C2=A0=C2=A0NETIF_F_IP_CSUM |
> > > -			=C2=A0=C2=A0=C2=A0NETIF_F_IPV6_CSUM |
> > > -			=C2=A0=C2=A0=C2=A0NETIF_F_HW_VLAN_CTAG_TX |
> > > -			=C2=A0=C2=A0=C2=A0NETIF_F_HW_VLAN_CTAG_RX |
> > > =C2=A0=C2=A0			=C2=A0=C2=A0=C2=A0NETIF_F_TSO |
> > > =C2=A0=C2=A0			=C2=A0=C2=A0=C2=A0NETIF_F_TSO6 |
> > > =C2=A0=C2=A0			=C2=A0=C2=A0=C2=A0NETIF_F_RXHASH |
> > > -			=C2=A0=C2=A0=C2=A0NETIF_F_RXCSUM;
> > > -
> > > -	netdev->hw_features =3D netdev->features |
> > > NETIF_F_HW_L2FW_DOFFLOAD;
> > > +			=C2=A0=C2=A0=C2=A0NETIF_F_RXCSUM |
> > > +			=C2=A0=C2=A0=C2=A0NETIF_F_HW_CSUM |
> > > +			=C2=A0=C2=A0=C2=A0NETIF_F_SCTP_CRC |
> > > +			=C2=A0=C2=A0=C2=A0NETIF_F_HW_VLAN_CTAG_TX |
> > > +			=C2=A0=C2=A0=C2=A0NETIF_F_HW_VLAN_CTAG_RX;
> > > =C2=A0 -	switch (adapter->hw.mac.type) {
> > > -	case ixgbe_mac_82599EB:
> > > -	case ixgbe_mac_X540:
> > > -	case ixgbe_mac_X550:
> > > -	case ixgbe_mac_X550EM_x:
> > > +	if (hw->mac.type >=3D ixgbe_mac_82599EB)
> > > =C2=A0=C2=A0		netdev->features |=3D NETIF_F_SCTP_CRC;
> > > -		netdev->hw_features |=3D NETIF_F_SCTP_CRC |
> > > -				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_NTUPLE |
> > > -				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_HW_TC;
> > > -		break;
> > > -	default:
> > > -		break;
> > > -	}
> > > =C2=A0 -	netdev->hw_features |=3D NETIF_F_RXALL;
> > > +	/* copy netdev features into list of user selectable
> > > features */
> > > +	netdev->hw_features |=3D netdev->features;
> > > +	netdev->hw_features |=3D NETIF_F_RXALL |
> > > +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NETIF_F_HW_L2FW_DOFFLOA=
D;
> > > +
> > > +	if (hw->mac.type >=3D ixgbe_mac_82599EB)
> > > +		netdev->hw_features |=3D NETIF_F_NTUPLE;
> > looks like the cleanup missed moving NETIF_F_HW_TC flag here that
> > enables cls_u32 offloads via TC.
> Indeed, this is a regression.

I took care of it in v2.
--=-ibGpRSA0ijqB53cs+q6F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXAxT5AAoJEOVv75VaS+3OCuEP/0jmlz6IEBUIQiAh4sHuggIx
cLBnxtMVjc5ilL1iaQMjX4I/Zg0q1uESM51asE9TRahmLMCuhVTcK9b6et+dNa1W
fM4rrQJ9IfjANbZt4NDzglgHwNDFsCT4EpZWCiqGLhs9pQP3h0ik0B/O8i4OBCYJ
7QhqlKFfjHB6sbAQIOKTvx9YMzMAYVuSTsqMtjWGxoum6xFvK5la5Cw1psgBPawx
pFQTp0u3/RTW31J2iL2RoXqCXzhdidOpmAkeeqjab+mCBCw8VLYF+PkVVdg9F1TD
1J/y+wK9B0eXEFKO68gNQHdpKCJ5TG0qdFenxljZqoCj1zKZx0icTUbwKs9OpMbt
dpXQx4NB877BXyK6AXqeLo9VvSjJhIrEdUupkaJC5rbDSNiQZ4ofMp/kR1c/EdRk
Eyd1x/N8RrPVVah06R94CMayPy2KYyLW1TopzOTwx6PQe+xmhbkZSMb8CBu2M/gG
fSOpAwfoZRtkXmAbXyo2rndt09xTdvwuERyPWVbEiAzFFIu1sVp5cUb+ioFZlqlb
X1NoeE7ixGoHY8ktI1EXDpSXKizRwqtZFk2OSDFmNfEmhkEIccs4JR4o8EcPShQy
ay/38MR27gXW6bFNkvAIU5ZVGvwOYUNwg6uD7851xT2VXvtiGfPwMFwsmRCvuKui
erm2ARHGSX2A4i0pYQIe
=iD34
-----END PGP SIGNATURE-----

--=-ibGpRSA0ijqB53cs+q6F--
