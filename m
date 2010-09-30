From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: code cleanups
Date: Thu, 30 Sep 2010 14:09:19 +0800
Message-ID: <AANLkTimVngrNU+PLbaf8r42J3HrvURpY8KUPa+--KvLC@mail.gmail.com>
References: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com> <1285823808.5211.627.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57723 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab0I3GJk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 02:09:40 -0400
Received: by wwi17 with SMTP id 17so15098wwi.1
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 23:09:39 -0700 (PDT)
In-Reply-To: <1285823808.5211.627.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 1:16 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 30 septembre 2010 =E0 10:24 +0800, Changli Gao a =E9crit :
>> Compare operations are more readable, and compilers generate the sam=
e code
>> for the both.
>>
>
> You have a buggy compiler then.

gcc version 4.4.3 (Gentoo 4.4.3-r2 p1.2)

             rth =3D rcu_dereference(rth->dst.rt_next)) {
                if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr=
) |
                     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr=
) |
                     (rth->fl.iif ^ iif) |
    2f12:       44 3b 80 dc 00 00 00    cmp    0xdc(%rax),%r8d
    2f19:       0f 85 a2 00 00 00       jne    2fc1 <ip_route_input_com=
mon+0x145
>
                     rth->fl.oif |
    2f1f:       83 b8 d8 00 00 00 00    cmpl   $0x0,0xd8(%rax)
    2f26:       0f 85 95 00 00 00       jne    2fc1 <ip_route_input_com=
mon+0x145
>
        tos &=3D IPTOS_RT_MASK;
        hash =3D rt_hash(daddr, saddr, iif, rt_genid(net));

        for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
             rth =3D rcu_dereference(rth->dst.rt_next)) {
                if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr=
) |
    2f2c:       44 3b b8 e4 00 00 00    cmp    0xe4(%rax),%r15d
    2f33:       0f 85 88 00 00 00       jne    2fc1
<ip_route_input_common+0x145>
                     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr=
) |
    2f39:       44 3b b0 e8 00 00 00    cmp    0xe8(%rax),%r14d
    2f40:       75 7f                   jne    2fc1
<ip_route_input_common+0x145>


>
> I know this code is ugly, but please keep it as is, dont add conditio=
nal
> branches on hot paths.
>

If the compiler doesn't generate conditional branches, we have to
touch every necessary field of all the cache entries in one hash
bucket. Is it better than condition branch? I think the compiler
developers know it better.

And the compiler reorders the conditional branches, is it expected?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
