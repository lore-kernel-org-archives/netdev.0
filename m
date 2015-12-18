From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: sja1000: of: add compatibility with Technologic
 Systems version
Date: Fri, 18 Dec 2015 22:05:01 +0100
Message-ID: <567474FD.8060002@pengutronix.de>
References: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450469845-12900-2-git-send-email-damien.riegel@savoirfairelinux.com>
 <56746F8B.8030008@pengutronix.de> <20151218210231.GA6116@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="wS553UexLThcrXRBR3TNpQcWxVXNHn6s6"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20151218210231.GA6116@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wS553UexLThcrXRBR3TNpQcWxVXNHn6s6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/18/2015 10:02 PM, Damien Riegel wrote:
> On Fri, Dec 18, 2015 at 09:41:47PM +0100, Marc Kleine-Budde wrote:
>> On 12/18/2015 09:17 PM, Damien Riegel wrote:
>>> Technologic Systems provides an IP compatible with the SJA1000,
>>> instantiated in an FPGA. Because of some bus widths issue, access to
>>> registers is made through a "window" that works like this:
>>>
>>>     base + 0x0: address to read/write
>>>     base + 0x2: 8-bit register value
>>>
>>> This commit adds a new compatible device, "technologic,sja1000", with=

>>> read and write functions using the window mechanism.
>>>
>>> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
>>> ---
>>>  drivers/net/can/sja1000/sja1000_platform.c | 30 ++++++++++++++++++++=
++++++++--
>>>  1 file changed, 28 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net=
/can/sja1000/sja1000_platform.c
>>> index 0552ed4..6cbf251 100644
>>> --- a/drivers/net/can/sja1000/sja1000_platform.c
>>> +++ b/drivers/net/can/sja1000/sja1000_platform.c
>>> @@ -70,6 +70,18 @@ static void sp_write_reg32(const struct sja1000_pr=
iv *priv, int reg, u8 val)
>>>  	iowrite8(val, priv->reg_base + reg * 4);
>>>  }
>>> =20
>>> +static u8 ts4800_read_reg16(const struct sja1000_priv *priv, int reg=
)
>>> +{
>>> +	sp_write_reg16(priv, 0,  reg);
>>> +	return sp_read_reg16(priv, 2);
>>
>> This is racy, please add a spinlock.
>>
>>> +}
>>> +
>>> +static void ts4800_write_reg16(const struct sja1000_priv *priv, int =
reg, u8 val)
>>> +{
>>> +	sp_write_reg16(priv, 0, reg);
>>> +	sp_write_reg16(priv, 2, val);
>>
>> This is racy, too.
>>
>> Have a look at https://marc.info/?l=3Dlinux-can&m=3D137149497403825&w=3D=
2
>=20
> Thank you for the link. In my situation, I don't think there is a race
> issue at the bus level, so a per-device spinlock should be enough. Woul=
d
> that be an acceptable patch? It would look a lot like the patch you
> suggested in the thread you linked, just rebased on current version.

Yes, but for a device spinlock you probably have to remove "const" from
the priv pointer.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--wS553UexLThcrXRBR3TNpQcWxVXNHn6s6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWdHT9AAoJEP5prqPJtc/HHZAH/3QNBSewfzL9MV4t4jfQRQ/X
CClVbeH51HeYV9GSyUwLY4C7xV10jTVCH4nYs7inSlQgVWTD/ki3LlIc/tEsxnd1
MhNYwAEN59YxtLDMZcpcLTDDY8n/OcxW7cxKmgPtGURLvDv5YDxPEN/i1NWolRau
ZHn4kd3KTOjTW3qwhPyinz/YWHHMOBdGeQBknRnWCiZH/vWdu+4eX7W3WBxDaSo+
6mQKX7LjUHlUEu/UNLtgp0FBMsPCuC4WXiMhB2DFkws+bk54m5XKJ3LLa+WqH3JF
TUV8ena0US27d7byssdZAP5K65q4i4srPK3LUQGXZrsqHNwlPmgtY5tAKBpOnl0=
=kvbJ
-----END PGP SIGNATURE-----

--wS553UexLThcrXRBR3TNpQcWxVXNHn6s6--
