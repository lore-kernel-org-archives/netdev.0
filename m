From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: Fix bug in suspend/resume
Date: Fri, 14 Nov 2014 16:35:05 +0100
Message-ID: <54662129.3020907@pengutronix.de>
References: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl> <5465C34D.4030805@pengutronix.de> <e5f5913b51a54222aa1bb0680a77e56d@BN1AFFO11FD055.protection.gbl> <54661B2F.2000704@pengutronix.de> <8d29d376aa02429dabd754b505fb336d@BN1BFFO11FD041.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Xg4P6dfpv06MmhJdeeVHAVUEd4hc1gff1"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <8d29d376aa02429dabd754b505fb336d@BN1BFFO11FD041.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Xg4P6dfpv06MmhJdeeVHAVUEd4hc1gff1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2014 04:20 PM, S=C3=B6ren Brinkmann wrote:
>>>> Please look the at suspend/resume code and count the
>>>> clock_enable/disable manually. After a suspend/resume cycle, you hav=
e
>>>> enabled the clock twice, but disabled it once.
>>>>
>>>> I think you have to abstract the clock handling behind runtime PM. I=

>>>> haven't done this myself yet, but the strong feeling that this is a
>>>> possible solution to your problem. These links might help:
>>>
>>> I agree, the clock handling looks weird. Also the clk_disable calls i=
n
>>> xcan_get_berr_counter() look suspicious to me, but I might be wrong.
>>> I think you can take a look at gpio-zynq for an example for runtime_p=
m
>>> usage. I think the usage model in that driver is similar to here.
>>
>> The xcan_get_berr_counter() function is correct, when doing manual (i.=
e.
>> non runtime-pm) clock handling. This function might be called if the
>> interface is down, this means clocks are disabled.
>=20
> I see, thanks for the clarification. Guess that should become
> pm_runtime_get_sync() and pm_runtime_put() when converting to
> runtime_pm.

Yes, as far as I understand runtime pm.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Xg4P6dfpv06MmhJdeeVHAVUEd4hc1gff1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZiEpAAoJECte4hHFiupU9cYP/ixQ31Nj+LvNvHzrLNvY3yU8
3F6uZeXsPxIrBREkTPYFEemT5iQSl0rwyQC5dRz6nly0jyKzfMA6+NdbRl4JLHuk
9ifTPt4ckul1bGCOcuQJ4Qz6GzHGJvBtCL9TGCiTJ/HehbWqVm6oxwEANUTZo6aM
xia0jCQa/K1HysD73DGbxj1YXIgRAEWGm42UC7rQ2jfFLwoXLfDbsWQJUX3vGNx1
QL4Z2KGX+Oc2jKPpmE6DakJ1bzWe3n437knldU/ePAebrOV1marG9MKvI7BtK4Vq
Px31cvg4ZTkO3/WLIcIVAjVXnxulzxcdrXLe+RneHvVW9HPgjcCCHr+SWa/0EQV9
K3C/ZiGuBGPiQaP/HKS2G9ZbypPxvoDPZI/PGexLHKBlSR4Ghmth904g0sEZuF+/
K7PlE0aAN8SHX9DMb5UTEZA9HBJw0SRaKxURvvPnbSgr57oXdKvFZsH2lGHsV8vb
jbQzsUYcaWaVCPVodf8Dq9nUaQ/vJhAe/UATVW5VTA5LJbTbHaS3uk40D52JEwNb
WZcFK7jgCA7HFIy7kAQrkG5eavjWKD/OAd2B/Y+ASFEBimTdSh4ZvGUaH3q6dMWs
U5IHOBmY/cK4ppExEPcI/iu82LYH8HW/pOp2UAslqm+hQXRicjcOh0DvGlIACohB
0cHo2wDLepi+hVtRnxJu
=WXVK
-----END PGP SIGNATURE-----

--Xg4P6dfpv06MmhJdeeVHAVUEd4hc1gff1--
