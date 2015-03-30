From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 12:16:32 +0200
Message-ID: <55192280.8090505@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519210E.40005@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="xqX5KKE7hsCwRwAOtLTW28vtiW1UPnkgW"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34259 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbbC3KQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 06:16:37 -0400
In-Reply-To: <5519210E.40005@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xqX5KKE7hsCwRwAOtLTW28vtiW1UPnkgW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/30/2015 12:10 PM, Marc Kleine-Budde wrote:
> On 03/29/2015 08:09 PM, Oliver Hartkopp wrote:
>> The CAN_RAW socket can set multiple CAN identifier specific filters th=
at lead
>> to multiple filters in the af_can.c filter processing. These filters a=
re
>> indenpendent from each other which leads to logical OR'ed filters when=
 applied.
       ^
independent

>> This patch makes sure that every CAN frame which is filtered for a spe=
cific
>> socket is only delivered once to the user space. This is independent f=
rom the
>> number of matching CAN filters of this socket.
>>
>> As the can_raw() function is executed from NET_RX softirq the introduc=
ed
>> variables are implemented as per-CPU variables to avoid extensive lock=
ing at
>> CAN frame reception time.
>>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

>> +	/* eliminate multiple filter matches for the same skb */
>> +	if (*this_cpu_ptr(ro->uniq_skb) =3D=3D oskb &&
>> +	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>> +			return;
>> +	} else {
>> +		*this_cpu_ptr(ro->uniq_skb) =3D oskb;
>> +		*this_cpu_ptr(ro->uniq_tstamp) =3D oskb->tstamp;
>> +	}
>> +
>=20
> What happens if you're preempted somewhere in this code, it's not
> atomic? I think, if we only have to take care about the skb, an atomic
> compare exchange would work. But we have two variables....If you use a
> struct (see previous mail), I think the usage of get_cpu_ptr(),
> git_cpu_ptr() ensures that we're not preempted.
  ^^^^^^^^^^^^^
put_cpu_ptr()

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xqX5KKE7hsCwRwAOtLTW28vtiW1UPnkgW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGSKDAAoJECte4hHFiupUBxcP/0yTERg0S89qQr22qirOk07s
HrOB+YrenWHBz24se2EPzp3qL2/c8MyTjmCC3VMiLkBnavMFdyfnVN+4F083uM+8
eCJG84YQ2pnNsZcgsoBsUbGmiZ3oer9YKzYr9CByMBUcNnCD/5j/O/vw7Ewc2aag
aQ4bmeMw9HmKsm5pse/ZpZUp0WOjXtwMsHEhUCnKfpOzl5+KyaZJTJC/qj0o7LqH
mOpxpzlyrv3xsR0M8rrChtcwnvXYh614mcGXZxPrTnHc4EhA1fIcdWHE1HtkZv1O
dw0tHnqqKSa0xDXW96ffsy/AYjp/8446h5SkSnN+MvDhyKZ7kjxTYMbZ7iY/XpHe
+wASW1taKHVC0D7D+vjXofAOuJTcl/GoytoZP/VlRHcWN7JU3vj5gdW9oy7WOSGI
jp5M5r1EUXsoi9WbO+Isx5GHOK02557cxwIQAaFk7U/MDrD/FcAq9RCbkZe1ayTF
L5GnYO8JHLZuMOuAr/TmmbUcJERZpTBEHhPrTlraU4p8CGekd95GT0ArdBIDJlQx
tImQSbqnpYCnZyZcXd50paNgnVt8Cxd88SE2LMPtpzzPy3LIwgIepQd6AT9HRz67
yy51JPOYzOKwDb13e/UASoquDiQFS5hGb5rTxxqmIC9zvR2FpltXZmxDPWw+XjwA
SS0QsLNRv5w19Hn/A1Ea
=mCBl
-----END PGP SIGNATURE-----

--xqX5KKE7hsCwRwAOtLTW28vtiW1UPnkgW--
