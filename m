From: Bin Li <libin.charles@gmail.com>
Subject: Re: [PATCH] iproute2: Conforming to -D_FORTIFY_SOURCE=2 restrictions
Date: Wed, 19 Oct 2011 17:15:26 +0800
Message-ID: <CAGBH1r66sTJUiq=EaqgsW-3nKzhhJoQ1Bwd9EC6AmsEd-E8SRQ@mail.gmail.com>
References: <CAGBH1r6P_nmVhSQ7d9sj1qU_1VY7QssWm3ftS4mNcQjyAuCcqA@mail.gmail.com>
	<20111017082307.46a994a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47659 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab1JSJP1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 05:15:27 -0400
Received: by gyb13 with SMTP id 13so1443407gyb.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 02:15:26 -0700 (PDT)
In-Reply-To: <20111017082307.46a994a8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

 You can reproduce this issue in 2.6.37 like below. And the previous
gdb log is after the install the debuginfo package in SUSE.

# ip -6 xfrm state add src 3ffe:501:ffff:ff03:21a:64ff:fe12:e4c1 dst
3ffe:501:ffff:ff05:200:ff:fe00:c1c1 proto ah spi 0x1000 mode transport
auth md5 "TAHITEST89ABCDEF"

*** buffer overflow detected ***: ip terminated
=3D=3D=3D=3D=3D=3D=3D Backtrace: =3D=3D=3D=3D=3D=3D=3D=3D=3D
/lib/libc.so.6(__fortify_fail+0x40)[0xb76d0070]
/lib/libc.so.6(+0xe8e27)[0xb76cde27]
/lib/libc.so.6(+0xe8317)[0xb76cd317]
ip[0x806d6c4]
ip(do_xfrm_state+0x120)[0x806dc70]
ip(do_xfrm+0x81)[0x806ad51]
ip[0x804c355]
ip(main+0x476)[0x804caa6]
/lib/libc.so.6(__libc_start_main+0xfe)[0xb75fbc2e]
ip[0x804c261]
=3D=3D=3D=3D=3D=3D=3D Memory map: =3D=3D=3D=3D=3D=3D=3D=3D
08048000-08087000 r-xp 00000000 08:01 4465       /sbin/ip
08087000-08088000 r--p 0003e000 08:01 4465       /sbin/ip
08088000-0808a000 rw-p 0003f000 08:01 4465       /sbin/ip
0808a000-080ad000 rw-p 00000000 00:00 0          [heap]
b75c6000-b75e2000 r-xp 00000000 08:01 131084     /lib/libgcc_s.so.1
b75e2000-b75e3000 r--p 0001b000 08:01 131084     /lib/libgcc_s.so.1
b75e3000-b75e4000 rw-p 0001c000 08:01 131084     /lib/libgcc_s.so.1
b75e4000-b75e5000 rw-p 00000000 00:00 0
b75e5000-b774b000 r-xp 00000000 08:01 131375     /lib/libc-2.11.3.so
b774b000-b774c000 ---p 00166000 08:01 131375     /lib/libc-2.11.3.so
b774c000-b774e000 r--p 00166000 08:01 131375     /lib/libc-2.11.3.so
b774e000-b774f000 rw-p 00168000 08:01 131375     /lib/libc-2.11.3.so
b774f000-b7752000 rw-p 00000000 00:00 0
b7752000-b7755000 r-xp 00000000 08:01 131428     /lib/libdl-2.11.3.so
b7755000-b7756000 r--p 00002000 08:01 131428     /lib/libdl-2.11.3.so
b7756000-b7757000 rw-p 00003000 08:01 131428     /lib/libdl-2.11.3.so
b7774000-b7775000 rw-p 00000000 00:00 0
b7775000-b7794000 r-xp 00000000 08:01 154467     /lib/ld-2.11.3.so
b7794000-b7795000 r--p 0001e000 08:01 154467     /lib/ld-2.11.3.so
b7795000-b7796000 rw-p 0001f000 08:01 154467     /lib/ld-2.11.3.so
bfa02000-bfa23000 rw-p 00000000 00:00 0          [stack]
ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
Aborted

And If without -D_FORTIFY_SOURCE=3D2 in gcc, it works fine, so It's a
bug in iproute2 which is not conforming to -D_FORTIFY_SOURCE=3D2
restrictions.

Thanks!

On Mon, Oct 17, 2011 at 11:23 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 17 Oct 2011 15:35:35 +0800
> Bin Li <libin.charles@gmail.com> wrote:
>
>> (gdb) l
>> 161 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D slen;
>> 162 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len > 0) {
>> 163 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len =
> max)
>> 164 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 invarg("\"ALGOKEY\" makes buffer
>> overflow\n", key);
>> 165
>> 166 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strncpy(=
buf, key, len);
>> 167 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> 168 =A0 =A0 =A0 =A0 =A0 =A0 }
>> 169
>> 170 =A0 =A0 =A0 =A0 =A0 =A0 alg->alg_key_len =3D len * 8;
>> (gdb) up
>> #8 =A0xfrm_state_modify (cmd=3D<optimized out>, flags=3D<optimized o=
ut>, argc=3D1,
>> =A0 =A0 argv=3D0x7fffffffe370) at xfrm_state.c:406
>> 406 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 xfrm_algo_parse((void *)&alg, type,
>> name, key,
>>
>> the compiler passes zero to __builtin___strncpy_chk as the buffer si=
ze.
>> xfrm_algo_parse is inlined into xfrm_state_modify.
>
> I don't understand, looks like a compiler bug. Call strncpy with
> 0 length should not be possible since the check was =A03 lines
> before for len > 0.
>
