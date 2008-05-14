From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Wed, 14 May 2008 20:21:00 +0800
Message-ID: <20080514122100.GA22726@gondor.apana.org.au>
References: <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl> <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl> <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl> <BAY103-DAV745BB1E190B27DAD19A19B2CE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760247AbYENMVP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BAY103-DAV745BB1E190B27DAD19A19B2CE0@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 02:03:05PM +0200, Marco Berizzi wrote:
> game over :-((
>=20
> I was going forward with git bisect but now kernel
> doesn't compile anymore
>   LD      drivers/misc/built-in.o
>   CC      drivers/net/Space.o
>   CC      drivers/net/loopback.o
> In file included from include/net/sock.h:50,
>                  from drivers/net/loopback.c:53:
> include/linux/pcounter.h: In function 'pcounter_add':
> include/linux/pcounter.h:87: error: 'struct pcounter' has no member
> named 'value'
> make[2]: *** [drivers/net/loopback.o] Error 1
> make[1]: *** [drivers/net] Error 2

This patch should let you test that kernel:

commit e7d0362dd41e760f340c1b500646cc92522bd9d5
Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date:   Mon Nov 26 23:34:54 2007 +0800

    [PCOUNTER] Fix build error without CONFIG_SMP
   =20
    I keep getting this build error and couldn't find anyone fixing
    it in archives. ...Maybe all net developers except me build
    just SMP kernels :-).
   =20
    In file included from include/net/sock.h:50,
                     from ipc/mqueue.c:35:
    include/linux/pcounter.h: In function 'pcounter_add':
    include/linux/pcounter.h:87: error: 'struct pcounter' has no
    member named 'value'
    make[1]: *** [ipc/mqueue.o] Error 1
    make: *** [ipc] Error 2
   =20
    Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
    Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
index 620aade..9c4760a 100644
--- a/include/linux/pcounter.h
+++ b/include/linux/pcounter.h
@@ -84,7 +84,7 @@ static inline int pcounter_getval(const struct pcount=
er *self)
=20
 static inline void pcounter_add(struct pcounter *self, int inc)
 {
-	self->value +=3D inc;
+	self->val +=3D inc;
 }
=20
 static inline int pcounter_getval(const struct pcounter *self)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
