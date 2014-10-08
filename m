From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Wed, 08 Oct 2014 14:32:41 -0700
Message-ID: <1412803961.2260.5.camel@jtkirshe-mobl.jf.intel.com>
References: <1412803407-10621-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dqJvVhnqAd7Sx+yzJd/9"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34476 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbaJHVcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 17:32:42 -0400
In-Reply-To: <1412803407-10621-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dqJvVhnqAd7Sx+yzJd/9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
> address to the VF on reset rather than a random one.
>=20
> However, that behavioral change also requires igbvf driver changes
> which can be hard especially when we want to talk to proprietary
> guest OSs.
>=20
> Looking at the code previous to the commit in Linux that made igbvf
> work with empty mac addresses (8d56b6d), we can see that on reset
> failure the driver will try to generate a new mac address with both
> the old and the new code.
>=20
> Furthermore, ixgbe does send reset failure when it detects an empty
> mac address (35055928c).
>=20
> So I think it's safe to make igb behave the same. With this patch I
> can successfully run a Windows 8.1 guest with an empty mac address
> and an assigned igbvf device that has no mac address set by the host.
>=20
> If anyone is aware of a guest driver that chokes on NACK returns of
> VF RESET commands, please speak up.
>=20
> Signed-off-by: Alexander Graf <agraf@suse.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethe=
rnet/intel/igb/igb_main.c
> index cb14bbd..e8c53b6 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6024,8 +6024,12 @@ static void igb_vf_reset_msg(struct igb_adapter *a=
dapter, u32 vf)
>  	adapter->vf_data[vf].flags |=3D IGB_VF_FLAG_CTS;
> =20
>  	/* reply to reset with ack and vf mac address */
> -	msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
> -	memcpy(addr, vf_mac, ETH_ALEN);
> +	if (!is_zero_ether_addr(vf_mac)) {
> +		msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
> +		memcpy(addr, vf_mac, ETH_ALEN);

I know we were using memcpy() before, but shouldn't we convert this to
use the preferred ether_addr_copy()?

> +	} else {
> +		msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_NACK;
> +	}
>  	igb_write_mbx(hw, msgbuf, 3, vf);
>  }
> =20



--=-dqJvVhnqAd7Sx+yzJd/9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNa15AAoJEOVv75VaS+3ODtMP/3bPq4exrIhXN7ORoX8fCHKp
Rsbk/Lpe74jFmrViSwa8OESYsiq72srxJkor1j4+Lup6oljjqHbO/ZEqG97qbRTj
BDzn5dP8PkXMRNJ2hDFH5uvzRiZKarm94fsvSWoNBOAii73sXv6bmGVJhsqh9Q3/
UUxLgHuBpZW9L7E1xdJgFYivfAKWSnCiylsH+RmUCv8Ws31/WazyiJeYOIAGgc6d
ABvjKfLq8/fdTcPnNhjEEKRp23sp+wSQ13dObDWTt7UKkrp+5UWT3wLIL40tNsGn
nJbBDRbjFm73N1XObGEczjoNkDQtueltYVVKj0D7SQ0/ea4g7hecJtlM/baGiEcw
tnUgmC8fWH33p2zAFa9mgSw5hHh+in7+CEHQR23ytk5hnJa4LvLXma71IRrtVMRG
fu/QqkUA91ejf05w7tGHpT03WcUYElFO0hQ4/JjIAaDKFg5tGZNwdeotkGPXVnGx
r6qXTr6APeVSHBQncGVxkk7kq/OqpcmnI8UOfx+1cOWRK6wpZS0vYH/ixFwmTIIT
Umj3PhJ+2H/FvR/PhWICYkiPboQz7bUhZJTBTrQd8mwDO0JKIC9LyOLNt1joLegj
/xCBm6Rik2Fn7EdCqKoyp7k1a/i8qslIOibH5lQ2dJh3rSslxgeHpAxjkHF49z8d
+TAS1X+Ts64r5U460+Rg
=yaGt
-----END PGP SIGNATURE-----

--=-dqJvVhnqAd7Sx+yzJd/9--
