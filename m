From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] kvaser_usb: fix "dma on the stack" errors
Date: Fri, 23 Nov 2012 14:48:39 +0100
Message-ID: <50AF7EB7.5070701@pengutronix.de>
References: <50AF3856.8060808@pengutronix.de> <1353677428-15805-1-git-send-email-olivier@sobrie.be> <20121123134027.GA32098@hposo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7B393A15FAD7A95183D4D0E3"
Cc: linux-can@vger.kernel.org, Wolfgang Grandegge <wg@grandegger.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20121123134027.GA32098@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7B393A15FAD7A95183D4D0E3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/23/2012 02:40 PM, Olivier Sobrie wrote:
> On Fri, Nov 23, 2012 at 02:30:28PM +0100, Olivier Sobrie wrote:
>> The dma buffer given to usb_bulk_msg() must be allocated and not on
>> the stack.
>> See Documentation/DMA-API-HOWTO.txt section "What memory is DMA'able?"=

>>
>> Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
>> ---
>> Here is the incremental patch.
>> Thank you Greg !
>>
>> Olivier
>>
>>  drivers/net/can/usb/kvaser_usb.c |  110 ++++++++++++++++++++++++-----=
---------
>>  1 file changed, 69 insertions(+), 41 deletions(-)
>>
>> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kv=
aser_usb.c
>> index 8807bf8..7ac6e82 100644
>> --- a/drivers/net/can/usb/kvaser_usb.c
>> +++ b/drivers/net/can/usb/kvaser_usb.c
>> @@ -421,14 +421,21 @@ end:
>>  static int kvaser_usb_send_simple_msg(const struct kvaser_usb *dev,
>>  				      u8 msg_id, int channel)
>>  {
>> -	struct kvaser_msg msg =3D {
>> -		.len =3D MSG_HEADER_LEN + sizeof(struct kvaser_msg_simple),
>> -		.id =3D msg_id,
>> -		.u.simple.channel =3D channel,
>> -		.u.simple.tid =3D 0xff,
>> -	};
>> -
>> -	return kvaser_usb_send_msg(dev, &msg);
>> +	struct kvaser_msg *msg;
>> +	int rc;
>> +
>> +	msg =3D kmalloc(sizeof(*msg), GFP_KERNEL);
>> +	if (!msg)
>> +		return -ENOMEM;
>> +
>=20
> Doh! I removed by mistake the line "msg->id =3D msg_id"... grr

Please send a v2 version of this patch with this problem fixed.

MarcMarc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7B393A15FAD7A95183D4D0E3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCvfroACgkQjTAFq1RaXHPyOwCgjVhhNLScM16hJbKm38oIvk3Q
4cUAnRKuRgcOQxwVzm24bAsx6zePc7du
=G7ih
-----END PGP SIGNATURE-----

--------------enig7B393A15FAD7A95183D4D0E3--
