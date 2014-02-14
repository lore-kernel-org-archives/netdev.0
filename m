From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: xilinx CAN controller support.
Date: Fri, 14 Feb 2014 10:04:36 +0100
Message-ID: <52FDDC24.8070805@pengutronix.de>
References: <\> <0dc128ac-e5cd-47bd-9ab1-3a545c3e2043@CO9EHSMHS012.ehs.local> <52FD1B16.6020600@pengutronix.de> <52FDD9FE.8040908@monstr.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="QhcbUJm1L074aQpAKcGGCRCkpNnfCnO7s"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52FDD9FE.8040908@monstr.eu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QhcbUJm1L074aQpAKcGGCRCkpNnfCnO7s
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/14/2014 09:55 AM, Michal Simek wrote:
> Hi Marc,
>=20
>>> +	int waiting_ech_skb_num;
>>> +	int xcan_echo_skb_max_tx;
>>> +	int xcan_echo_skb_max_rx;
>>> +	struct napi_struct napi;
>>> +	spinlock_t ech_skb_lock;
>>> +	u32 (*read_reg)(const struct xcan_priv *priv, int reg);
>>> +	void (*write_reg)(const struct xcan_priv *priv, int reg, u32 val);
>>
>> Please remove read_reg, write_reg, as long as there isn't any BE suppo=
rt
>> in the driver, call them directly.
>=20
> That's not entirely truth. If you look at Microblaze then you will see
> that Microblaze can be BE and LE.
> There is just missing endian detection which we will add to the next ve=
rsion.

As far as I know the endianess of the kernel is fixed and known during
compile time. Correct me if I'm wrong. So there is no need for a runtime
detection of the endianess and so no need for {read,write}_reg function
pointers.

> But because MB io helper functions are broken for a while you should be=

> able to use this driver on both endianess.
>=20
> btw: I would prefer to use ioread32 and ioread32be instead of readl.
> Is it OK for you?

Make it so. :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--QhcbUJm1L074aQpAKcGGCRCkpNnfCnO7s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL93CQACgkQjTAFq1RaXHPgUgCaAxkVSdTX0cNtvohBtAgv42pR
Ue0An3otnOhoPcqnhLS2Zv6TrAQDRA0N
=RVq8
-----END PGP SIGNATURE-----

--QhcbUJm1L074aQpAKcGGCRCkpNnfCnO7s--
