From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Sun, 03 Apr 2011 05:23:10 +0100
Message-ID: <1301804590.4157.53.camel@localhost>
References: <1300603423.1869.18.camel@dan>
	 <1300639685.26693.286.camel@localhost>
	 <20110331180225.GA6677@midget.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-Zela8St/cLZAugdg765C"
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, ralf@linux-mips.org,
	davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49903 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885Ab1DCEXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 00:23:24 -0400
In-Reply-To: <20110331180225.GA6677@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Zela8St/cLZAugdg765C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-03-31 at 20:02 +0200, Jiri Bohac wrote:
[...]
> This last hunk does not look correct. In the default branch of
> the switch, you set len =3D 1, which means=20
> 	p +=3D 2; facilities_len -=3D 2.
>=20
> The original code does=20
> 	facilities_len--; p++;
> ... and it looks correct. So, to get the old behaviour back:
>=20
> diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
> index f6c71ca..9777700 100644
> --- a/net/rose/rose_subr.c
> +++ b/net/rose/rose_subr.c
> @@ -418,7 +418,7 @@ int rose_parse_facilities(unsigned char *p, unsigned =
packet_len,
> =20
>  		default:
>  			printk(KERN_DEBUG "ROSE: rose_parse_facilities - unknown facilities f=
amily %02X\n", *p);
> -			len =3D 1;
> +			len =3D 0;
>  			break;
>  		}

Yes, agreed.

> However, I wonder how much sense it makes to continue parsing the
> facilities if an unknown facility family appears. We don't know
> the length of its data, so we will interpret each 16 bytes a new
> facilities header, hopefully soon bailing out on *p !=3D 0x00.
>
> In case of a long packet where every other byte is zero, the loop
> will spam the kernel log with the printk ... which could probably
> be classified as a security problem on its own. So how about the
> following instead? I have no idea if this breaks some rose
> specification, though.=20
[...]

I don't know any more than you do; maybe Ralf knows or can find out.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-Zela8St/cLZAugdg765C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATZf2KOe/yOyVhhEJAQocfw//S3L5q7+L7HlTk/OI1k37XYNoBGvhppa6
d8NBOlWqF7JMOaFCEc5q3VsBRbK9NUwO6YtJeXN1Byb2PALUZ+qVDGg/h7EaQBD/
jRqw2YtVQLFQ9LEZps1Di9mZWpphIZ9EpjglfPguvZ0FneLGus/KD3/ODy+p10BD
jrGekJojoCL2DK1BLoGD/SeF78KSapJps7Q9Lgme8pJflXe4wTgzbJc5et9scpt+
aXw+rKigTAlJIw7xHLwnRVEmTkOV9vhw0D79QTu1c6Yc0tmnbjAW/fOpY37SmTCC
gp1YLj9pt7OHvN5uyBvHydiqrfqZyjhk5CK/o+ETVef30IXLMDG71QVSIWMdr7OY
Yhuuf1Bil211HG8kFPVwC8n3Ip4D7x73/ICZOuEUcVTV1TDAwm7UX8tT2vlYQ49e
TfLd1CKtXqx5Om41B/Nu1aFZ4lKQVB7VivY4jJymP+pjn+RzrnIG2bDs+KKIkPOG
bHamDZOGIVBvQP3vxWYnJQKZ7LJ0aF3KskrHLMyYSY0DoOZ3gBx+mYR3xRdCRN8+
ikmiyDeoAh1t09WOcQAXufZyqACo/DYLd2XAUwzjQiVcUNu/3wSVMEfxxnZgw/d1
ojiHMMWgT9N/ZGOC7pNLrpXY2qvQRZ8rTM58v++Q3/Hw9BI1+MQTQDNOUlu4FxG7
QSwv8qlAUOE=
=dn3T
-----END PGP SIGNATURE-----

--=-Zela8St/cLZAugdg765C--
