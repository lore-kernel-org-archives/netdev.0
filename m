From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Thu, 18 Mar 2010 15:55:54 +0100
Message-ID: <4BA23EFA.9040906@gmail.com>
References: <1268753394-17765-1-git-send-email-jslaby@suse.cz>	 <1268759527.25503.2980.camel@calx>  <4B9FBE49.6010709@gmail.com> <1268762160.25503.2988.camel@calx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig500077E58B4802F6C66DE774"
Cc: Jiri Slaby <jirislaby@gmail.com>, Jiri Slaby <jslaby@suse.cz>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <danborkmann@googlemail.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268762160.25503.2988.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig500077E58B4802F6C66DE774
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Matt Mackall wrote:
> On Tue, 2010-03-16 at 18:22 +0100, Jiri Slaby wrote:
>> On 03/16/2010 06:12 PM, Matt Mackall wrote:
>>> I don't get it. The source of the branch tests for !ndev->npinfo and =
the
>>> original destination of the branch also tests for !ndev->npinfo. I do=
n't
>>> see how it gets dereferenced.
>> Let's look at more of the context:
>>          if (!ndev->npinfo) {
>>                  npinfo =3D kmalloc(sizeof(*npinfo), GFP_KERNEL);
>>                  if (!npinfo) {         // npinfo is NULL
>>                          err =3D -ENOMEM;
>>                          goto release;
>>                  }
>> ...
>> release:                           // npinfo is still NULL
>>          if (!ndev->npinfo) {       // condition is the same (holds)
>>               // dereference below: vvvvvvvvvvvvvvv
>>                  spin_lock_irqsave(&npinfo->rx_lock, flags);
>>                  list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx=
) {
>>                          npe->dev =3D NULL;
>>                  }
>>                  spin_unlock_irqrestore(&npinfo->rx_lock, flags);
>>
>>                  kfree(npinfo);
>>          }
>=20
> Ok, you're correct, I read the second test backwards.
>=20
> Acked-by: Matt Mackall <mpm@selenic.com>
>=20

Thanks for fixing this and sorry for not being responsive, obviously it
sucks when you have a broken leg and German hospitals do not really have
Internet access ... ;)

Thanks,
Daniel


--------------enig500077E58B4802F6C66DE774
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkuiPvoACgkQ5AxJm1m3CC/wEQCghGWwHVt7NijqebOOWkgg77pS
3mUAn1sAEJDz5JdOihUe47NSdYLJr23X
=isQZ
-----END PGP SIGNATURE-----

--------------enig500077E58B4802F6C66DE774--
