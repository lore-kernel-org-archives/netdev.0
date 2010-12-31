From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH/RFC] Re: Compilation of pktgen fails for ARCH=um
Date: Fri, 31 Dec 2010 11:26:29 +0100
Message-ID: <201012311126.30027.christoph.paasch@uclouvain.be>
References: <201012301133.14524.christoph.paasch@uclouvain.be> <20101230093925.3d6b567e.randy.dunlap@oracle.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20101230093925.3d6b567e.randy.dunlap@oracle.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thursday, December 30, 2010 wrote Randy Dunlap:
> or ndelay() in arch/um/include/asm/delay.y can be removed completely
> and then the default implementation of ndelay() will be used from
> include/linux/delay.h.
> This builds cleanly, but I don't know how well it would work.
This will do a rounded up micro-second sleep. I think that it's ok.

Christoph

> ---
> From: Randy Dunlap <randy.dunlap@oracle.com>
>=20
> Allow uml to use the default implementation of ndelay() from
> <linux/delay.h>.  Fixes build error:
>=20
> net/built-in.o: In function `spin':
> pktgen.c:(.text+0x27391): undefined reference to `__unimplemented_nde=
lay'
>=20
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  arch/um/include/asm/delay.h |    5 -----
>  1 file changed, 5 deletions(-)
>=20
> --- linux-next-20101214.orig/arch/um/include/asm/delay.h
> +++ linux-next-20101214/arch/um/include/asm/delay.h
> @@ -12,9 +12,4 @@ extern void __delay(unsigned long loops)
>  #define udelay(n) ((__builtin_constant_p(n) && (n) > 20000) ? \
>  	__bad_udelay() : __udelay(n))
>=20
> -/* It appears that ndelay is not used at all for UML, and has never =
been
> - * implemented. */
> -extern void __unimplemented_ndelay(void);
> -#define ndelay(n) __unimplemented_ndelay()
> -
>  #endif

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
