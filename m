From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: IP defragmentation must be ECN aware
Date: Wed, 05 Jan 2011 18:41:01 +0100
Message-ID: <1294249261.10633.54.camel@edumazet-laptop>
References: <1294186431.3420.19.camel@edumazet-laptop>
	 <1294235942.2775.191.camel@edumazet-laptop>
	 <20110105091340.3f8833ef@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39149 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1AERlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:41:09 -0500
Received: by wyb28 with SMTP id 28so15578967wyb.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 09:41:08 -0800 (PST)
In-Reply-To: <20110105091340.3f8833ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 09:13 -0800, Stephen Hemminger a =C3=
=A9crit :
> On Wed, 05 Jan 2011 14:59:02 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > +
> > +static inline int ip4_frag_ecn(int tos)
>=20
> Since tos is only a byte, this should be:
>=20
> static inline u8 ip4_frag_ecn(u8 tos)
>=20
>=20

In fact, generated code is the same on x86, but some arches have faster
arithmetic on WORD units.

And I added the 'inline' because on x86_64 gcc, compiler chose _not_ to
inline this 6 instruction sequence ! Code was much larger.

31 d2                   xor    %edx,%edx
0f b6 40 01             movzbl 0x1(%rax),%eax
83 e0 03                and    $0x3,%eax
ff c0                   inc    %eax
a8 02                   test   $0x2,%al
0f 44 d0                cmove  %eax,%edx


We do roughly the same (working on WORD arith) in=20

static inline int IP_ECN_set_ce(struct iphdr *iph)
{
u32 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
=2E..
}

What others think ? I have no real strong opinion.


