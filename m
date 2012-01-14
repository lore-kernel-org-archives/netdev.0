From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] sha512: make it work, undo percpu message schedule
Date: Sat, 14 Jan 2012 22:46:50 +0100
Message-ID: <1326577610.5287.38.camel@edumazet-laptop>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
	 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
	 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120114182024.GA4207@p183.telecom.by>
	 <20120114182737.GB4207@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120114182737.GB4207@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 14 janvier 2012 =C3=A0 21:27 +0300, Alexey Dobriyan a =C3=A9c=
rit :
> commit f9e2bca6c22d75a289a349f869701214d63b5060
> aka "crypto: sha512 - Move message schedule W[80] to static percpu ar=
ea"
> created global message schedule area.


> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: stable@vger.kernel.org
> ---
>=20
>  crypto/sha512_generic.c |    6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
>=20
> --- a/crypto/sha512_generic.c
> +++ b/crypto/sha512_generic.c
> @@ -21,8 +21,6 @@
>  #include <linux/percpu.h>
>  #include <asm/byteorder.h>
> =20
> -static DEFINE_PER_CPU(u64[80], msg_schedule);
> -
>  static inline u64 Ch(u64 x, u64 y, u64 z)
>  {
>          return z ^ (x & (y ^ z));
> @@ -89,7 +87,7 @@ sha512_transform(u64 *state, const u8 *input)
>  	u64 a, b, c, d, e, f, g, h, t1, t2;
> =20
>  	int i;
> -	u64 *W =3D get_cpu_var(msg_schedule);
> +	u64 W[80];
> =20
>  	/* load the input */
>          for (i =3D 0; i < 16; i++)
> @@ -128,8 +126,6 @@ sha512_transform(u64 *state, const u8 *input)
> =20
>  	/* erase our data */
>  	a =3D b =3D c =3D d =3D e =3D f =3D g =3D h =3D t1 =3D t2 =3D 0;
> -	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
> -	put_cpu_var(msg_schedule);
>  }
> =20
>  static int

Is it just me or are you ignoring what crypto maintainer and others
thought of your patch ?

You are re-introducing a 640 bytes stack array, how comes it can be
really safe ?

This is too risky, and we provided an alternate patch, not just for fun=
=2E
