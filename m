From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Conforming to -D_FORTIFY_SOURCE=2
 restrictions
Date: Wed, 19 Oct 2011 09:50:52 -0700
Message-ID: <20111019095052.4e3001da@nehalam.linuxnetplumber.net>
References: <CAGBH1r6P_nmVhSQ7d9sj1qU_1VY7QssWm3ftS4mNcQjyAuCcqA@mail.gmail.com>
	<20111017082307.46a994a8@nehalam.linuxnetplumber.net>
	<CAGBH1r66sTJUiq=EaqgsW-3nKzhhJoQ1Bwd9EC6AmsEd-E8SRQ@mail.gmail.com>
	<1319023851.3103.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bin Li <libin.charles@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35632 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363Ab1JSQuz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 12:50:55 -0400
In-Reply-To: <1319023851.3103.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Oct 2011 13:30:51 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 19 octobre 2011 =E0 17:15 +0800, Bin Li a =E9crit :
> > Stephen,
> >=20
> >  You can reproduce this issue in 2.6.37 like below. And the previou=
s
> > gdb log is after the install the debuginfo package in SUSE.
> >=20
> > # ip -6 xfrm state add src 3ffe:501:ffff:ff03:21a:64ff:fe12:e4c1 ds=
t
> > 3ffe:501:ffff:ff05:200:ff:fe00:c1c1 proto ah spi 0x1000 mode transp=
ort
> > auth md5 "TAHITEST89ABCDEF"
> >=20
> > *** buffer overflow detected ***: ip terminated
> > =3D=3D=3D=3D=3D=3D=3D Backtrace: =3D=3D=3D=3D=3D=3D=3D=3D=3D
> > /lib/libc.so.6(__fortify_fail+0x40)[0xb76d0070]
> > /lib/libc.so.6(+0xe8e27)[0xb76cde27]
> > /lib/libc.so.6(+0xe8317)[0xb76cd317]
> > ip[0x806d6c4]
> > ip(do_xfrm_state+0x120)[0x806dc70]
> > ip(do_xfrm+0x81)[0x806ad51]
> > ip[0x804c355]
> > ip(main+0x476)[0x804caa6]
> > /lib/libc.so.6(__libc_start_main+0xfe)[0xb75fbc2e]
> > ip[0x804c261]
> > =3D=3D=3D=3D=3D=3D=3D Memory map: =3D=3D=3D=3D=3D=3D=3D=3D
> > 08048000-08087000 r-xp 00000000 08:01 4465       /sbin/ip
> > 08087000-08088000 r--p 0003e000 08:01 4465       /sbin/ip
> > 08088000-0808a000 rw-p 0003f000 08:01 4465       /sbin/ip
> > 0808a000-080ad000 rw-p 00000000 00:00 0          [heap]
> > b75c6000-b75e2000 r-xp 00000000 08:01 131084     /lib/libgcc_s.so.1
> > b75e2000-b75e3000 r--p 0001b000 08:01 131084     /lib/libgcc_s.so.1
> > b75e3000-b75e4000 rw-p 0001c000 08:01 131084     /lib/libgcc_s.so.1
> > b75e4000-b75e5000 rw-p 00000000 00:00 0
> > b75e5000-b774b000 r-xp 00000000 08:01 131375     /lib/libc-2.11.3.s=
o
> > b774b000-b774c000 ---p 00166000 08:01 131375     /lib/libc-2.11.3.s=
o
> > b774c000-b774e000 r--p 00166000 08:01 131375     /lib/libc-2.11.3.s=
o
> > b774e000-b774f000 rw-p 00168000 08:01 131375     /lib/libc-2.11.3.s=
o
> > b774f000-b7752000 rw-p 00000000 00:00 0
> > b7752000-b7755000 r-xp 00000000 08:01 131428     /lib/libdl-2.11.3.=
so
> > b7755000-b7756000 r--p 00002000 08:01 131428     /lib/libdl-2.11.3.=
so
> > b7756000-b7757000 rw-p 00003000 08:01 131428     /lib/libdl-2.11.3.=
so
> > b7774000-b7775000 rw-p 00000000 00:00 0
> > b7775000-b7794000 r-xp 00000000 08:01 154467     /lib/ld-2.11.3.so
> > b7794000-b7795000 r--p 0001e000 08:01 154467     /lib/ld-2.11.3.so
> > b7795000-b7796000 rw-p 0001f000 08:01 154467     /lib/ld-2.11.3.so
> > bfa02000-bfa23000 rw-p 00000000 00:00 0          [stack]
> > ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
> > Aborted
> >=20
> > And If without -D_FORTIFY_SOURCE=3D2 in gcc, it works fine, so It's=
 a
> > bug in iproute2 which is not conforming to -D_FORTIFY_SOURCE=3D2
> > restrictions.
> >=20
>=20
> FORTIFY assumes we cant copy a string on alg.u.alg.alg_key !
>=20
> This completely precludes 0-sized arrays
>=20
> struct xfrm_algo {
>         char            alg_name[64];
>         unsigned int    alg_key_len;    /* in bits */
>         char            alg_key[0];
> };
>=20
> struct {
>       union {
>           struct xfrm_algo alg;
>           struct xfrm_algo_aead aead;
>           struct xfrm_algo_auth auth;
>       } u;
>       char buf[XFRM_ALGO_KEY_BUF_SIZE];
> } alg =3D {};
>=20
> I would say its a FORTIFY bug. This kind of construct is perfectly
> valid.

Maybe it will handle flexible style arrays.
See also:
   http://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html

At this time, I won't accept the patch that uses alloca() just to deal
with this FORTIFY bug.
