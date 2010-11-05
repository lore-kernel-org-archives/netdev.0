From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Fri, 05 Nov 2010 12:11:44 -0700
Message-ID: <1288984304.3091.11.camel@jtkirshe-MOBL1>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-xTm4/pjn9lJTswB1Ih0k"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4660 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646Ab0KETLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 15:11:44 -0400
In-Reply-To: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xTm4/pjn9lJTswB1Ih0k
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
> On transmit, the ixgb driver will only use vlan acceleration if a
> vlan group is configured.  This can lead to tags getting dropped
> when bridging because the networking core assumes that a driver
> that claims vlan acceleration support can do it at all times.  This
> change should have been part of commit eab6d18d "vlan: Don't check for
> vlan group before vlan_tx_tag_present." but was missed.
>=20
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
>  drivers/net/ixgb/ixgb_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index caa8192..d18194e 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -1498,7 +1498,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_dev=
ice *netdev)
>                       DESC_NEEDED)))
>  		return NETDEV_TX_BUSY;
> =20
> -	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
> +	if (vlan_tx_tag_present(skb)) {
>  		tx_flags |=3D IXGB_TX_FLAGS_VLAN;
>  		vlan_id =3D vlan_tx_tag_get(skb);
>  	}

After further review, NAK because this will cause a bug.  With this
patch it would be possible to overrun the buffers, so the correct fix is
to increase max_frame_size by VLAN_TAG_SIZE in ixgb/igb_change_mtu.

Alex has said that he will generate the patches for the alternate fix.

--=-xTm4/pjn9lJTswB1Ih0k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM1FbNAAoJECTsCADr/EWUvQkH/0QSmBNjvLJVJa5XRGx/zpv4
MDVotpzw5/zOdAG0q1NWt1drtdTNn9ur3e+iRZgUf12sGGTLjXEioHGb0RZ5K+s/
hThE3y8wmuyWftvn7/wuJ05nt7pqtGz65dczvoeJdJ83mLfmrS4QhP+RopCcBFDj
UzS4b65O0DAMTL3J/1gTxtjC5wuO1ihblDRg1NlEnGvIuJS8MSPunqf9XogN9Ydf
DFrhApQuiuJt7V1PkaYFBHsfff1SjUO+rjVVo15b8zRyPnSE3mqEMb0DTWE38aXE
UPVoUpYMVJw3Guc8UsLNJufId56XyiulvtWTJYLLBKkqk3VQA3iHDeKIsl71cfI=
=P34z
-----END PGP SIGNATURE-----

--=-xTm4/pjn9lJTswB1Ih0k--

