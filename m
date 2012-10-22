From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Date: Mon, 22 Oct 2012 18:06:55 +0600
Message-ID: <20121022180655.50a50401@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
	<20121021195701.7a5872e7@sacrilege>
	<20121022004332.7e3f3f29@sacrilege>
	<20121022015134.4de457b9@sacrilege>
	<1350856053.8609.217.camel@edumazet-glaptop>
	<20121022045850.788df346@sacrilege>
	<1350893743.8609.424.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/if_x9v05hnw75h0NfkjvVxf"; protocol="application/pgp-signature"
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org,
 linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1350893743.8609.424.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

--Sig_/if_x9v05hnw75h0NfkjvVxf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Oct 2012 10:15:43 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-10-22 at 04:58 +0600, Mike Kazantsev wrote:
>=20
> > I've grepped for "/org/free" specifically and sure enough, same scraps
> > of data seem to be in some of the (varied) dumps there.
>=20
> Content is not meaningful, as we dont initialize it.
> So you see previous content.
>=20
> Could you try the following :
>=20
...

With this patch on top of v3.7-rc2 (w/o patches from your previous
mail), leak seem to be still present.

If I understand correctly, WARN_ON_ONCE should've produced some output
in dmesg when the conditions passed to it were met.

They don't appear to be, as the only output in dmesg during
ipsec-related modules loading (I think openswan probes them manually)
is still "AVX instructions are not detected" (can be seen in tty on
boot) and the only post-boot dmesg output (incl. during leaks
happening) is from kmemleak ("kmemleak: ... new suspected memory
leaks").

Looks like kmem_cache_zalloc got rid of the content, though traces
still report it as "kmem_cache_alloc", but I guess it's because of its
"inline" nature.


--=20
Mike Kazantsev // fraggod.net

--Sig_/if_x9v05hnw75h0NfkjvVxf
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCFNuIACgkQASbOZpzyXnEezACeJTpjWFk9FTzO29QyFWgcVbOm
qyEAn3c2rjQ1bPJwVs4plAIMaeRHvUDj
=VZcE
-----END PGP SIGNATURE-----

--Sig_/if_x9v05hnw75h0NfkjvVxf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
