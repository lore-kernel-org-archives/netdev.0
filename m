From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: "ss -p" segfaults
Date: Wed, 15 Jul 2015 18:02:23 +0300
Message-ID: <20150715150223.GA27095@angus-think.wlc.globallogic.com>
References: <2282663.K45lFmE7Zp@fb07-iapwap2>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marc Dietrich <marvin24@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38019 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbGOPEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 11:04:30 -0400
Received: by wicmv11 with SMTP id mv11so574754wic.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 08:04:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2282663.K45lFmE7Zp@fb07-iapwap2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 04:09:03PM +0200, Marc Dietrich wrote:
> Hi,
>=20
> ss -p segfaults here with some kind of memory corruption:
>=20
> *** Error in `/work/iproute2/misc/ss': free(): invalid pointer:=20
> 0x0000000000623000 ***
> =3D=3D=3D=3D=3D=3D=3D Backtrace: =3D=3D=3D=3D=3D=3D=3D=3D=3D
> /lib64/libc.so.6(+0x71c6d)[0x7ffff7885c6d]
> /lib64/libc.so.6(+0x771be)[0x7ffff788b1be]
> /lib64/libc.so.6(+0x7799b)[0x7ffff788b99b]
> /work/iproute2/misc/ss[0x403de1]
> /work/iproute2/misc/ss[0x408247]
> /work/iproute2/misc/ss[0x403295]
> /lib64/libc.so.6(__libc_start_main+0xf0)[0x7ffff7834790]
> /work/iproute2/misc/ss[0x4037f9]
> =3D=3D=3D=3D=3D=3D=3D Memory map: =3D=3D=3D=3D=3D=3D=3D=3D
> 00400000-00416000 r-xp 00000000 00:33 4207305                        =
   =20
> /work/iproute2/misc/ss
> 00616000-00617000 r--p 00016000 00:33 4207305                        =
   =20
> /work/iproute2/misc/ss
> 00617000-0061b000 rw-p 00017000 00:33 4207305                        =
   =20
> /work/iproute2/misc/ss
> 0061b000-0065f000 rw-p 00000000 00:00 0                              =
   =20
> [heap]
> 7ffff6f6d000-7ffff6f83000 r-xp 00000000 00:21 16154175               =
   =20
> /lib64/libgcc_s.so.1
> 7ffff6f83000-7ffff7182000 ---p 00016000 00:21 16154175               =
   =20
> /lib64/libgcc_s.so.1
> 7ffff7182000-7ffff7183000 r--p 00015000 00:21 16154175               =
   =20
> /lib64/libgcc_s.so.1
> 7ffff7183000-7ffff7184000 rw-p 00016000 00:21 16154175               =
   =20
> /lib64/libgcc_s.so.1
> 7ffff7184000-7ffff719c000 r-xp 00000000 00:21 16694826               =
   =20
> /lib64/libpthread-2.21.so
> 7ffff719c000-7ffff739b000 ---p 00018000 00:21 16694826               =
   =20
> /lib64/libpthread-2.21.so
> 7ffff739b000-7ffff739c000 r--p 00017000 00:21 16694826               =
   =20
> /lib64/libpthread-2.21.so
> 7ffff739c000-7ffff739d000 rw-p 00018000 00:21 16694826               =
   =20
> /lib64/libpthread-2.21.so
> 7ffff739d000-7ffff73a1000 rw-p 00000000 00:00 0=20
> 7ffff73a1000-7ffff73a4000 r-xp 00000000 00:21 16694804               =
   =20
> /lib64/libdl-2.21.so
> 7ffff73a4000-7ffff75a3000 ---p 00003000 00:21 16694804               =
   =20
> /lib64/libdl-2.21.so
> 7ffff75a3000-7ffff75a4000 r--p 00002000 00:21 16694804               =
   =20
> /lib64/libdl-2.21.so
> 7ffff75a4000-7ffff75a5000 rw-p 00003000 00:21 16694804               =
   =20
> /lib64/libdl-2.21.so
> 7ffff75a5000-7ffff7613000 r-xp 00000000 00:21 16153198               =
   =20
> /usr/lib64/libpcre.so.1.2.5
> 7ffff7613000-7ffff7812000 ---p 0006e000 00:21 16153198               =
   =20
> /usr/lib64/libpcre.so.1.2.5
> 7ffff7812000-7ffff7813000 r--p 0006d000 00:21 16153198               =
   =20
> /usr/lib64/libpcre.so.1.2.5
> 7ffff7813000-7ffff7814000 rw-p 0006e000 00:21 16153198               =
   =20
> /usr/lib64/libpcre.so.1.2.5
> 7ffff7814000-7ffff79ad000 r-xp 00000000 00:21 16694798               =
   =20
> /lib64/libc-2.21.so
> 7ffff79ad000-7ffff7bac000 ---p 00199000 00:21 16694798               =
   =20
> /lib64/libc-2.21.so
> 7ffff7bac000-7ffff7bb1000 r--p 00198000 00:21 16694798               =
   =20
> /lib64/libc-2.21.so
> 7ffff7bb1000-7ffff7bb3000 rw-p 0019d000 00:21 16694798               =
   =20
> /lib64/libc-2.21.so
> 7ffff7bb3000-7ffff7bb7000 rw-p 00000000 00:00 0=20
> 7ffff7bb7000-7ffff7bd8000 r-xp 00000000 00:21 16155991               =
   =20
> /lib64/libselinux.so.1
> 7ffff7bd8000-7ffff7dd7000 ---p 00021000 00:21 16155991               =
   =20
> /lib64/libselinux.so.1
> 7ffff7dd7000-7ffff7dd8000 r--p 00020000 00:21 16155991               =
   =20
> /lib64/libselinux.so.1
> 7ffff7dd8000-7ffff7dd9000 rw-p 00021000 00:21 16155991               =
   =20
> /lib64/libselinux.so.1
> 7ffff7dd9000-7ffff7ddb000 rw-p 00000000 00:00 0=20
> 7ffff7ddb000-7ffff7dfc000 r-xp 00000000 00:21 16694791               =
   =20
> /lib64/ld-2.21.so
> 7ffff7fb5000-7ffff7fba000 rw-p 00000000 00:00 0=20
> 7ffff7ff5000-7ffff7ff8000 rw-p 00000000 00:00 0=20
> 7ffff7ff8000-7ffff7ffa000 r--p 00000000 00:00 0                      =
   =20
> [vvar]
> 7ffff7ffa000-7ffff7ffc000 r-xp 00000000 00:00 0                      =
   =20
> [vdso]
> 7ffff7ffc000-7ffff7ffd000 r--p 00021000 00:21 16694791               =
   =20
> /lib64/ld-2.21.so
> 7ffff7ffd000-7ffff7ffe000 rw-p 00022000 00:21 16694791               =
   =20
> /lib64/ld-2.21.so
> 7ffff7ffe000-7ffff7fff000 rw-p 00000000 00:00 0=20
> 7ffffffdd000-7ffffffff000 rw-p 00000000 00:00 0                      =
   =20
> [stack]
> ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0              =
   =20
> [vsyscall]
>=20
> Program received signal SIGABRT, Aborted.
> 0x00007ffff7847638 in raise () from /lib64/libc.so.6
> Missing separate debuginfos, use: zypper install libgcc_s1-
> debuginfo-5.1.1+r224716-1.2.x86_64 libpcre1-debuginfo-8.37-1.18.x86_6=
4=20
> libselinux1-debuginfo-2.3-5.18.x86_64
> (gdb) bt full
> #0  0x00007ffff7847638 in raise () from /lib64/libc.so.6
> No symbol table info available.
> #1  0x00007ffff7848a1a in abort () from /lib64/libc.so.6
> No symbol table info available.
> #2  0x00007ffff7885c72 in __libc_message () from /lib64/libc.so.6
> No symbol table info available.
> #3  0x00007ffff788b1be in malloc_printerr () from /lib64/libc.so.6
> No symbol table info available.
> #4  0x00007ffff788b99b in _int_free () from /lib64/libc.so.6
> No symbol table info available.
> #5  0x0000000000403de1 in unix_list_free (list=3D0x6251a0, list@entry=
=3D0x645b50)=20
> at ss.c:2516
>         s =3D 0x623010
>         name =3D 0x272 <error: Cannot access memory at address 0x272>
> #6  0x0000000000408247 in unix_show (f=3D0x61cdf0 <current_filter>) a=
t ss.c:2798
>         buf =3D "ffff880205a15b00: 00000003 00000000 00000000 0001 03=
=20
> 84307\n\000/tmp/.X11-
> unix/X0\n\000/stdout\n\000adiserver.socket\n\000\n\000c\n\000cket\n",=
 '\000'=20
> <repeats 12 times>,=20
> "q\017A\000\000\000\000\000p\205\201\367\377\177\000\000x\323\377\377=
\377\177\000\000\067\v\000\000\000\000\000\000h\323\377\377\377\177\000=
\000\060\374\336\367\377\177\000\000\000U\000\000\005\000\000\000\277\0=
00\000\000;
> \212\000\000\000\003\034\177\025\004\000\001"...
>         name =3D "\000/tmp/.X11-
> unix/X0\000l/stdout\000nadiserver.socket\000\071\000ec\000ocket\000\0=
21@\000\000\000\000\000\377\377\377\377\000\000\000\000\b\321\377\377\3=
77\177\000\000p\205\201\367\377\177\000\000=D0=94\373\367\377\177\000\0=
00\330|
> \335\367\377\177\000\000\226\226\204\367\377\177\000\000\370\n@\000\0=
00\000\000\000\070\254a\000\000\000\000"
>         newformat =3D 0
>         cnt =3D 734
>         list =3D <optimized out>
> #7  0x0000000000403295 in main (argc=3D<optimized out>, argv=3D0x7fff=
ffffd378) at=20
> ss.c:3921
>         saw_states =3D <optimized out>
>         saw_query =3D 0
>         do_summary =3D <optimized out>
>         dump_tcpdiag =3D 0x0
>         filter_fp =3D 0x0
>         ch =3D <optimized out>
>         state_filter =3D 2871
> (gdb)=20
>=20
> git bisect shows bad commit ec4d0d8 (ss: Replace unixstat struct by n=
ew=20
> sockstat struct)
>=20
> This is with a 4.1.2 kernel. Strange thing is, that this segfault doe=
s not=20
> happen on my distro kernel (also v4.1) (openSUSE). Seems to be some r=
andom=20
> stuff or kernel config problem maybe.
>=20
> Marc



Hm, I can reproduce this only when use proc:
    $ PROC_ROOT=3D/proc ss -ap

I will fix this.
