From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] can: xilinx CAN controller support.
Date: Fri, 14 Feb 2014 10:13:20 +0100
Message-ID: <52FDDE30.8020405@monstr.eu>
References: <\> <0dc128ac-e5cd-47bd-9ab1-3a545c3e2043@CO9EHSMHS012.ehs.local> <52FD1B16.6020600@pengutronix.de> <52FDD9FE.8040908@monstr.eu> <52FDDC24.8070805@pengutronix.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IAqrsduxW59jcuq7j5qiGeoO7xK8x3mlo"
Cc: monstr@monstr.eu,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FDDC24.8070805@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IAqrsduxW59jcuq7j5qiGeoO7xK8x3mlo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/14/2014 10:04 AM, Marc Kleine-Budde wrote:
> On 02/14/2014 09:55 AM, Michal Simek wrote:
>> Hi Marc,
>>
>>>> +	int waiting_ech_skb_num;
>>>> +	int xcan_echo_skb_max_tx;
>>>> +	int xcan_echo_skb_max_rx;
>>>> +	struct napi_struct napi;
>>>> +	spinlock_t ech_skb_lock;
>>>> +	u32 (*read_reg)(const struct xcan_priv *priv, int reg);
>>>> +	void (*write_reg)(const struct xcan_priv *priv, int reg, u32 val);=

>>>
>>> Please remove read_reg, write_reg, as long as there isn't any BE supp=
ort
>>> in the driver, call them directly.
>>
>> That's not entirely truth. If you look at Microblaze then you will see=

>> that Microblaze can be BE and LE.
>> There is just missing endian detection which we will add to the next v=
ersion.
>=20
> As far as I know the endianess of the kernel is fixed and known during
> compile time. Correct me if I'm wrong. So there is no need for a runtim=
e
> detection of the endianess and so no need for {read,write}_reg function=

> pointers.

Endianess of the kernel is fixed and know during compile time
but what it is not fixed is endianess of that IP at compile time.

On fpga you can use bridges, partial reconfiguration, etc where
the only solution which is run-time endian detection via registers.

For example: drivers/block/xsysace.c, drivers/spi/spi-xilinx.c, etc

>> But because MB io helper functions are broken for a while you should b=
e
>> able to use this driver on both endianess.
>>
>> btw: I would prefer to use ioread32 and ioread32be instead of readl.
>> Is it OK for you?
>=20
> Make it so. :)

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--IAqrsduxW59jcuq7j5qiGeoO7xK8x3mlo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlL93jAACgkQykllyylKDCHSDACfc7WGeB91YLgi5VQKrYape2v9
T9cAnjfgT8wgB2bb5xILUuBM0TGFsCbB
=wKwg
-----END PGP SIGNATURE-----

--IAqrsduxW59jcuq7j5qiGeoO7xK8x3mlo--
