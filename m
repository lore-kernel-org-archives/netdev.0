From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [RFC PATCH 1/1] ethtool: adding support for multiple slave port
 configuration
Date: Sun, 27 Jul 2014 03:47:01 +0100
Message-ID: <1406429221.29010.151.camel@deadeye.wl.decadent.org.uk>
References: <1406291305-22286-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KYnuXAhc5cLSnEbs1fqH"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1406291305-22286-1-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-KYnuXAhc5cLSnEbs1fqH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-07-25 at 17:58 +0530, Mugunthan V N wrote:
> Some Ethernet Swtich controllers like CPSW in AM335x, TI814x, DRA7x and
> AM43xx SoCs, Network Coprocessor in AM5K2E0x, Realtek Switch controllers
> etc has to capability of conneting multiple networks using L2 switching
> and has multiple phys. With the existing code, ethtool can communicate
> only to one phy.
>=20
> To enable user to communicate multiple phy connected to single Ethernet
> Switch controller, intoducing a optional new parameter in Ethtool interfa=
ce
> to pass which slave to set/get the phy configuration.

There was some discussion about configuration APIs for hardware/firmware
bridges earlier this year and I thought there was a consensus for
assigning a network device to each port.  This would remove the need to
identify ports within a device.  But I may have misremembered.

> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> ---
>  include/uapi/linux/ethtool.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 96ade34..3011427 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -60,6 +60,9 @@
>   *	and other link features that the link partner advertised
>   *	through autonegotiation; 0 if unknown or not applicable.
>   *	Read-only.
> + * @slave_port: Specify which slave port to be used to set/get
> + *	parmeters, for example which slave port phy to be used for
> + *	set/get phy capabilities

The difficulty with assigning the reserved fields in struct ethtool_cmd
is that nothing has ever checked that they are set to 0.  So if we were
to assign this field and support it in ethtool, someone might run it on
an older kernel version and all configuration changes will be made to
port 0 rather than the one they specified.  I don't think it would be
acceptable to tell users that 'oh, the port number option silently fails
on older kernel versions'.

So at the very least you would also need to add some way for userland to
find out whether the driver will check the value of this field.

Ben.

>   * The link speed in Mbps is split between @speed and @speed_hi.  Use
>   * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
> @@ -107,7 +110,8 @@ struct ethtool_cmd {
>  	__u8	eth_tp_mdix;
>  	__u8	eth_tp_mdix_ctrl;
>  	__u32	lp_advertising;
> -	__u32	reserved[2];
> +	__u32	slave_port;
> +	__u32	reserved;
>  };
> =20
>  static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-KYnuXAhc5cLSnEbs1fqH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU9RoKue/yOyVhhEJAQpkHQ/8DxYhjnBZN0JCfeowRW7y2q2AXu48uC0o
o7ARtOlIZcpGKYNmQT/cYxheLGOPfaN9UmhoPMuKYLfEqYiNrXDHqhDlCpwZzTzA
2T3ngvd+pCb0tqAMxEWStN7oSPgq4QnrMgBCMBtmcbtzeH9c1V6+ZHknJkHC7Kv3
RNWilpL9mt/E4AAjAwoY33J/WZmaq6BtOHnDLafJlP4jEfcp1BPbOdjZpnipn3Ol
F1c/G5mEHXXaEcAMo8A9U4tFkvU970G7nuuJG5ltRlCVZ9A7r0WGenZgzsXJY1fy
jv2mIJXEY/BRuNf1CNkEWzl2fMDnqUhD2ajsU0zzPlEw4X3hW79MBF7hRf8T0vKF
ZZrffxpoo/E9d6edM9GNVwJSBnSjOU/bnAVYC1LFLNoQ1T2kimQDgg2tPaqALM1E
K5p60JC53i2+892dbgFQg0961M2rSzqbtuze7RzVPNgRcVEw/WJZPVgM4Bc4PEYi
Kjj4FWOZPp9mt431GyvVk7njPFi0yacYPJmX6ZSULXQX5dpjAQzHCK9ZynQCakcv
lgu95uvpvCAew7PtKGImM9HMflzh5OFHqGxoa5G6CEMnIlclewsvwsQsnvnONseT
26DJwOkpMoZqQ5lDcrjV+zMFdSmvEZ+4n0YbWtvm9j+YvFWKRmZxt/aKggEcfC9O
VdY1Q9V5rNo=
=GvEY
-----END PGP SIGNATURE-----

--=-KYnuXAhc5cLSnEbs1fqH--
