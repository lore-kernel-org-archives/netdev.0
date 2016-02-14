From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V4 6/8] i40e: queue-specific settings for interrupt
 moderation
Date: Sun, 14 Feb 2016 18:57:34 +0000
Message-ID: <1455476254.2801.149.camel@decadent.org.uk>
References: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
	 <1454917540-10648-7-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AY30Atr6NB145MeSWHKb"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58129 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751091AbcBNS5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 13:57:41 -0500
In-Reply-To: <1454917540-10648-7-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AY30Atr6NB145MeSWHKb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-08 at 02:45 -0500, Kan Liang wrote:
[...]
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -1849,23 +1849,37 @@ static int i40e_set_phys_id(struct net_device *ne=
tdev,
> =C2=A0 * 125us (8000 interrupts per second) =3D=3D ITR(62)
> =C2=A0 */
> =C2=A0
> -static int i40e_get_coalesce(struct net_device *netdev,
> -			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_coalesce *ec)
> +static int __i40e_get_coalesce(struct net_device *netdev,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_coalesce *ec=
,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int queue)
> =C2=A0{
> =C2=A0	struct i40e_netdev_priv *np =3D netdev_priv(netdev);
> =C2=A0	struct i40e_vsi *vsi =3D np->vsi;
> +	struct i40e_pf *pf =3D vsi->back;
> =C2=A0
> =C2=A0	ec->tx_max_coalesced_frames_irq =3D vsi->work_limit;
> =C2=A0	ec->rx_max_coalesced_frames_irq =3D vsi->work_limit;
> =C2=A0
> -	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting))
> +	/* rx and tx usecs has per queue value. If user doesn't specify the que=
ue,
> +	=C2=A0* return queue 0's value to represent.
> +	=C2=A0*/
> +	if (queue < 0) {
> +		queue =3D 0;
> +	} else if (queue >=3D vsi->num_queue_pairs) {
> +		netif_info(pf, drv, netdev, "Invalid queue value, queue range is 0 - %=
d\n",
> +			=C2=A0=C2=A0=C2=A0vsi->num_queue_pairs - 1);
[...]

Don't log this error message; it allows an unprivileged user to spam
the system log.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-AY30Atr6NB145MeSWHKb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsDOHue/yOyVhhEJAQqpeBAAlmgVj+eGn1hWQXkuc+C53O73OHbcqVD8
JTz9Wnd7GWTbjz/mPYXV9AxhOmR30pp+clOgUjZiX1g21ISDnC2OKF/s4Da8vhzh
8H9SRaYVBY33hCz/DuG0n5Mbz1elnHsT5D0kp9Wzwj73eEwmF/3CBGmxQN2Rb5bG
mQC0yfhh7JYNxfh2ifCEMcB22ccq28cuGLXg5l5P6fNQu8ChqXqjwtPIgMWsCCwG
VpiBLV8QFfdZ7ROSqvIHQL9KvZ/XTBPiD67WtB8GmiW8k1Ti07+bdSOyyoh3bul0
zPlGhL8VripliLM/gIJrtkuKRZLkc0sf1qUg2PUVoZdqARTXiwYDOvCjQieSDO2X
IUy4kAIyS09yhgUqxVEdkr3Aq4S68Tdnagnqw+P94AGpTimZw88KtqvU+tqJ6hJF
q14S96EllvCrrBGNUmgcVwbDDvcH9a40E0x6LWu/x3Qm72uQfsisEEI1kyMh3Ay1
rAyxA457jhFpFVbwQGN1NTF8USVXXtRbcF7+QELtUbfYJBxDAfAY7GvpNfVUjvc5
Cm9bRBotsO06sRgMxwCtpZf4TMHKEbbhROQLn3nvdsDzasvIsoliJ9IZBZWDo1iY
XhS4JPbONmiKYmpyfTItiugS6ZE01md4gM87lBMtwreFag6ovHdYLbUvt+5Q4VXA
WTdJcetnaqo=
=Gcc/
-----END PGP SIGNATURE-----

--=-AY30Atr6NB145MeSWHKb--
