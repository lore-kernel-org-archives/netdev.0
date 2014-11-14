From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: Fix bug in suspend/resume
Date: Fri, 14 Nov 2014 09:54:37 +0100
Message-ID: <5465C34D.4030805@pengutronix.de>
References: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ltEHrpT5jBt0FRIGHauvjCHACWPVtkxvj"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, grant.likely@linaro.org,
	robh+dt@kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ltEHrpT5jBt0FRIGHauvjCHACWPVtkxvj
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2014 09:16 AM, Kedareswara rao Appana wrote:
> The drvdata in the suspend/resume is of type struct net_device,
> not the platform device.Enable the clocks in the suspend before
> accessing the registers of the CAN.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Changes for v2:
>   - Removed the struct platform_device* from suspend/resume
>     as suggest by Lothar.
>   - The clocks are getting disabled and un prepared at the end of the p=
robe.=20
>     In the suspend the driver is doing a register write.In order
>     To do that register write we have to again enable and prepare the c=
locks.

Please look the at suspend/resume code and count the
clock_enable/disable manually. After a suspend/resume cycle, you have
enabled the clock twice, but disabled it once.

I think you have to abstract the clock handling behind runtime PM. I
haven't done this myself yet, but the strong feeling that this is a
possible solution to your problem. These links might help:

http://lwn.net/Articles/505683/
http://www.slideshare.net/linaroorg/runtime-pm
http://www.slideshare.net/linaroorg/lca14-407-deployingruntimepmonarmsocs=

http://www.slideshare.net/SamsungOSG/shuah-khan-lpcpmops

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ltEHrpT5jBt0FRIGHauvjCHACWPVtkxvj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZcNNAAoJECte4hHFiupU2BcP/2PbjcCxYTc2eER4ciRO5yVW
/EdpvEwBdceEoEvsAg0QTe0tguA24+dVLIh6nR0ytWUFcjqAjUnPV9uTJIWNUP2n
1/x1DtPz/ZGa13UZiLrJCqo6ycFBmw6ug7LUtVG7WGjiDsu/Msj5APFOIrP/ROnP
nwUZa8YXolJt7IfuLAvcUpfzM05zkuXJd2LRajyqeeeUydy1mVkEiIt/4g8N+fo/
3CjVafqo26QmWoTjDLqmCqFl0doEIz2uzpMZKoGokmZAF0++mVK9fNJVmi3FTv3j
HVOTyYtNj3qkQooN0SaJ6071Vny6pbbK0/1bU3GELoxZSPZOgmjNo/cyP1zTsTYZ
JbkAVayRUzngd83WtLsaNmkbhyDKUrNs+oXKBshZrLxnUQG2PcyzZdaOYdzV+DrQ
NQUqG/ZGSKhOQds9VzNdHNgzv7CtOZJhdok6ghLc7uPyvJ1KqcljYTCTJL8QLebc
ed4ht/9XRd6s3l8iFB3IUgv3XStk7f6NzzMopgJG0zKIdDlO80s9du2zBysBHbq9
0fuyEbFXs1x94k9WQgFzkF7C6RmxMApnjRhTe0DmN7hj32iqCYDlxkyl0LykwBFK
QAcBXf00Jha7yLFcNKFmV9y7fHWEIm547eM8/l/3uwSm41Du9ckiCMem4hR044sG
PM8jxtvSuScx01KRx5t5
=QqCy
-----END PGP SIGNATURE-----

--ltEHrpT5jBt0FRIGHauvjCHACWPVtkxvj--
