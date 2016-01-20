From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 1/3] can: sja1000: of: add per-compatible init hook
Date: Wed, 20 Jan 2016 11:22:21 +0100
Message-ID: <569F5FDD.7050703@pengutronix.de>
References: <1452685566-27431-1-git-send-email-mkl@pengutronix.de>
 <1452685566-27431-2-git-send-email-mkl@pengutronix.de>
 <20160113155749.GB6219@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="qxtgDDaehR4EEiXkFSJC57HEsCjR4EtN1"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Damien Riegel <damien.riegel@savoirfairelinux.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160113155749.GB6219@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qxtgDDaehR4EEiXkFSJC57HEsCjR4EtN1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/13/2016 04:57 PM, Damien Riegel wrote:
>>  static int sp_probe(struct platform_device *pdev)
>>  {
>>  	int err, irq =3D 0;
>> @@ -163,6 +177,9 @@ static int sp_probe(struct platform_device *pdev)
>>  	struct resource *res_mem, *res_irq =3D NULL;
>>  	struct sja1000_platform_data *pdata;
>>  	struct device_node *of =3D pdev->dev.of_node;
>> +	const struct of_device_id *of_id;
>> +	const struct sja1000_of_data *of_data =3D NULL;
>> +	size_t priv_sz =3D 0;
>> =20
>>  	pdata =3D dev_get_platdata(&pdev->dev);
>>  	if (!pdata && !of) {
>> @@ -191,7 +208,13 @@ static int sp_probe(struct platform_device *pdev)=

>>  	if (!irq && !res_irq)
>>  		return -ENODEV;
>> =20
>> -	dev =3D alloc_sja1000dev(0);
>> +	of_id =3D of_match_device(sp_of_table, &pdev->dev);
>> +	if (of_id) {
>=20
> My personal preference here would be to test of_id && of_id->data. That=

> way, we could avoid the declaration of nxp_data. It would also be a bit=

> less error prone if someone adds a new compatible in the of device
> table.

Ok - please test v5.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qxtgDDaehR4EEiXkFSJC57HEsCjR4EtN1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn1/dAAoJEP5prqPJtc/HdUUH/A6ItfhdwMRL0/umVU2ZqlyA
dnzuhMYaAZO7pphXPpaHaKopXwSturS8JMiw1/2zAUT+iToh2eKa+wuvunQXqbiu
6hOSSRhpg/fqL9DKQqPyTSpYBu4I7AVYgpun1I1mT/7rhD/ORqlSorfqZXOLzP+p
DdxYgB8NepPhe2a7JJlgLEoS7F/pFDNe1IhMmaryRzr37ciujU2c7smQSDTkpcYi
lO7uGcPU3RKuTbmImhqBejf/NZyPN2JDnnoD08Oyj8cxW6lbyOXNsY7S0NPEDhQ9
EcLDdGQS/a/X7T/9/fdzJMOJYjeslp9zEuzFiJ/SdgyMNnAOj1zuCPiYCOPPuTY=
=n1PH
-----END PGP SIGNATURE-----

--qxtgDDaehR4EEiXkFSJC57HEsCjR4EtN1--
