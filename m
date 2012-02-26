From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#659499: bash fails to properly read /proc files
Date: Sun, 26 Feb 2012 00:11:59 +0000
Message-ID: <1330215119.8460.18.camel@deadeye>
References: <20120211162451.3805.76693.reportbug@annuminas.home.mathom.us>
	 <20120218010548.GE18080@mraw.org> <20120219221413.GA14935@mraw.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9BBok8IuUJp8IHSn1QPg"
Cc: Michael Stone <mstone@debian.org>, 659499@bugs.debian.org,
	debian-kernel@lists.debian.org, Cyril Brulebois <kibi@debian.org>,
	Jean-Michel =?ISO-8859-1?Q?Vourg=E8re?= <jmv_deb@nirgal.com>,
	netdev <netdev@vger.kernel.org>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50245 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704Ab2BZAMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 19:12:07 -0500
In-Reply-To: <20120219221413.GA14935@mraw.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9BBok8IuUJp8IHSn1QPg
Content-Type: multipart/mixed; boundary="=-HQwybk6KsHZKFtM7T7DB"


--=-HQwybk6KsHZKFtM7T7DB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-02-19 at 23:14 +0100, Cyril Brulebois wrote:
> Hi kernel folks,
>=20
> here's a tiny analysis I tried to perform on bash's having issues with
> reading /proc files, which I think is related to seeking in those files.
> I can't play much with other kernel versions right now though. My tests
> were performed with squeeze's bpo kernel: 3.2.0-0.bpo.1-amd64 (Debian
> 3.2.4-1~bpo60+1).

The specific problem with seeking in /proc/net/dev appears to be caused
by this change:

commit f04565ddf52e401880f8ba51de0dff8ba51c99fd
Author: Mihai Maruseac <mihai.maruseac@gmail.com>
Date:   Thu Oct 20 20:45:10 2011 +0000

    dev: use name hash for dev_seq_ops

Ben.

[...]
> Attached is a reduced (as in =E2=80=9Clighter than bash=E2=80=9D) test ca=
se. The code is
> ugly but I'm throwing it over the wall before the BSP's end: built with
> bufsize=3D8000, everything is fine for my 600-ish bytes /proc/net/dev;
> built with bufsize=3D128, read()+lseek() seem to trigger nasty stuff as I
> suspected.
>=20
> Here's the output for bufsize=3D8000:
> | $ gcc mini-test.c && ./a.out=20
> | Warning: no file specified, defaulting to /proc/net/dev
> | Info: /proc/net/dev opened successfully
> | Read: 694
> | Found newline: 76 char-long line: with 617 extra chars:
> | Inter-|   Receive                                                |  Tra=
nsmit
> | Read: 617
> | Found newline: 122 char-long line: with 494 extra chars:
> |  face |bytes    packets errs drop fifo frame compressed multicast|bytes=
    packets errs drop fifo colls carrier compressed
> | Read: 494
> | Found newline: 122 char-long line: with 371 extra chars:
> |     lo:   63886     451    0    0    0     0          0         0    63=
886     451    0    0    0     0       0          0
> | Read: 371
> | Found newline: 122 char-long line: with 248 extra chars:
> |   pan0:       0       0    0    0    0     0          0         0      =
  0       0    0    0    0     0       0          0
> | Read: 248
> | Found newline: 124 char-long line: with 123 extra chars:
> |  wlan0: 151354717  197302    0    0    0     0          0         0 220=
11993  189809    0    0    0     0       0          0
> | Read: 123
> | Found newline: 122 char-long line: with 0 extra chars:
> |   eth0:       0       0    0    0    0     0          0         0      =
  0       0    0    0    0     0       0          0
> | Final position: 694
> =E2=86=92 OK
>=20
> Here's the output for bufsize=3D128:
> | $ gcc mini-test.c && ./a.out=20
> | Warning: no file specified, defaulting to /proc/net/dev
> | Info: /proc/net/dev opened successfully
> | Read: 128
> | Found newline: 76 char-long line: with 51 extra chars:
> | Inter-|   Receive                                                |  Tra=
nsmit
> | Read: 128
> | Found newline: 122 char-long line: with 5 extra chars:
> |  face |bytes    packets errs drop fifo frame compressed multicast|bytes=
    packets errs drop fifo colls carrier compressed
> | Read: 128
> | Found newline: 122 char-long line: with 5 extra chars:
> |   pan0:       0       0    0    0    0     0          0         0      =
  0       0    0    0    0     0       0          0
> | Final position: 323
>=20
> Has anything like that been reported/fixed recently?
>=20
>=20
> (Probably my last one:) Thanks to IRILL for sponsoring this BSP in Paris.
>=20
> Mraw,
> KiBi.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-HQwybk6KsHZKFtM7T7DB
Content-Disposition: attachment; filename="mini-test.c"
Content-Type: text/x-csrc; name="mini-test.c"; charset="UTF-8"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8dW5pc3RkLmg+DQojaW5jbHVkZSA8c3lzL3R5
cGVzLmg+DQojaW5jbHVkZSA8c3lzL3N0YXQuaD4NCiNpbmNsdWRlIDxmY250bC5oPg0KI2luY2x1
ZGUgPGVycm5vLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQoNCmNvbnN0IGNoYXIgZGVmYXVsdF9p
bnB1dFtdID0gIi9wcm9jL25ldC9kZXYiOw0KDQppbnQgbWFpbihpbnQgYXJnYywgY29uc3QgY2hh
ciAqKmFyZ3YpIHsNCiAgY29uc3QgY2hhciAqaW5wdXQgPSBkZWZhdWx0X2lucHV0Ow0KDQogIC8q
ICJ1c2FnZSIgKi8NCiAgaWYgKGFyZ2MgPCAyKSB7DQogICAgcHJpbnRmKCJXYXJuaW5nOiBubyBm
aWxlIHNwZWNpZmllZCwgZGVmYXVsdGluZyB0byAlc1xuIiwgZGVmYXVsdF9pbnB1dCk7DQogIH0g
ZWxzZSB7DQogICAgaW5wdXQgPSBhcmd2WzFdOw0KICAgIHByaW50ZigiSW5mbzogdXNpbmcgJXMg
YXMgc3BlY2lmaWVkXG4iLCBhcmd2WzFdKTsNCiAgfQ0KICANCiAgaW50IGZpbGUgPSBvcGVuKGlu
cHV0LCAwKTsNCiAgaWYgKGZpbGUgPCAwKSB7DQogICAgcHJpbnRmKCJFcnJvcjogdW5hYmxlIHRv
IG9wZW4gJXM6ICVzXG4iLCBpbnB1dCwgc3RyZXJyb3IoZXJybm8pKTsNCiAgICByZXR1cm4gMTsN
CiAgfSBlbHNlIHsNCiAgICBzc2l6ZV90IHJldDsNCiAgICBzc2l6ZV90IGN1cnJlbnQgPSAwOw0K
ICAgIHNzaXplX3QgZXh0cmEgPSAwOw0KDQogICAgcHJpbnRmKCJJbmZvOiAlcyBvcGVuZWQgc3Vj
Y2Vzc2Z1bGx5XG4iLCBpbnB1dCk7DQoNCiAgICAvKiB0aGlzIGlzIHVnbHkgYnV0IG9oIHdlbGwg
Ki8NCiAgICAjZGVmaW5lIGJ1ZnNpemUgKDgwMDApDQoNCiAgICBjaGFyIGJ1ZltidWZzaXplKzFd
ID0gIiI7DQogICAgd2hpbGUgKChyZXQgPSByZWFkKGZpbGUsIGJ1ZiwgYnVmc2l6ZSkpID4gMCkg
ew0KICAgICAgcHJpbnRmKCJSZWFkOiAldVxuIiwgcmV0KTsNCiAgICAgIGNoYXIgKm5ld2xpbmUg
PSBzdHJjaHIoYnVmLCAnXG4nKTsNCiAgICAgIGlmIChuZXdsaW5lKSB7DQogICAgICAgIGN1cnJl
bnQgKz0gKG5ld2xpbmUtYnVmKTsNCiAgICAgICAgKm5ld2xpbmUgPSAnXDAnOw0KICAgICAgICBl
eHRyYSA9IHJldC0obmV3bGluZS1idWYrMSk7DQogICAgICAgIHByaW50ZigiRm91bmQgbmV3bGlu
ZTogJXUgY2hhci1sb25nIGxpbmU6IHdpdGggJXUgZXh0cmEgY2hhcnM6XG4lc1xuIiwgY3VycmVu
dCwgZXh0cmEsIGJ1Zik7DQogICAgICAgIGxzZWVrKGZpbGUsIC1leHRyYSwgU0VFS19DVVIpOw0K
ICAgICAgICBjdXJyZW50ID0gMDsNCiAgICAgIH0NCiAgICB9DQogICAgcHJpbnRmKCJGaW5hbCBw
b3NpdGlvbjogJXVcbiIsIGxzZWVrKGZpbGUsIDAsIFNFRUtfQ1VSKSk7IA0KICAgIGNsb3NlKGZp
bGUpOw0KICB9DQoNCiAgcmV0dXJuIDA7DQp9DQo=


--=-HQwybk6KsHZKFtM7T7DB--

--=-9BBok8IuUJp8IHSn1QPg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUAT0l4z+e/yOyVhhEJAQoMtQ//SC44H4x/wIMj6TH0t/YOPh7SkCdWW1gS
RmWcqWaln3OyVcGb9QCGn5hiEKV3zPBxX38fkPwsUg4f71vL1l3/+MFu77BEDE1a
E/7gCFycx4o2sDLUx129FSK3AxCyuZ7DxRxCq6xqXe/Ukv6cClkYIUSeEr2KExKc
qvbkhsF3ycgdhy7+pCvX56uxt9f4r6bclcEc4eXeLgcy3yQWK6xC8cBTMrP7Y/T5
Tn6OH52KGn12ysn4Xr+cu7y3oQGqm27foXPP22yMe1QcqWtH9vLs5JJQ24w+8UdZ
TWy+rx6e9mgwijVViIgzITYzjsuYWTnwKQNjd1iQcfyMe/7Ep/KBYr+fZ9C0vdp5
2pcE16LkUIl12wgs+4WIVrZzZUK2PFeTZ0efwQKhE50sXAIfVtFnKGkjVSL9AAbJ
c3kXfpacaCI5t3A70qdyY4fAcLbwIQyAKdrdViCsVj5ZjjmfaEzt+KPwet06cmHO
K1xJUjFD5TtMpysglzPxDMCm3nAmAZWw13TirffLm40XkEZrlAm5LkBn3F2ThodZ
KLrnkyULGMDzESodzzV3fntuD4mRIOca+w9qe7MHJezgOUob8t8bhy4m5IFS4ZBZ
ZLX0c54ivKZbHepzE/srtGpOdfTIDIzLx0erlYCwK/lQ8KQxLqusUxoEmXpImfu/
rrGz2dskKx0=
=UlRt
-----END PGP SIGNATURE-----

--=-9BBok8IuUJp8IHSn1QPg--
