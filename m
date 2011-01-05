From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: IP defragmentation must be ECN aware
Date: Wed, 5 Jan 2011 09:48:30 -0800
Message-ID: <20110105094830.63a68230@nehalam>
References: <1294186431.3420.19.camel@edumazet-laptop>
	<1294235942.2775.191.camel@edumazet-laptop>
	<20110105091340.3f8833ef@nehalam>
	<1294249261.10633.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab1AERsd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:48:33 -0500
In-Reply-To: <1294249261.10633.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 18:41:01 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 05 janvier 2011 =E0 09:13 -0800, Stephen Hemminger a =E9c=
rit :
> > On Wed, 05 Jan 2011 14:59:02 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > +
> > > +static inline int ip4_frag_ecn(int tos)
> >=20
> > Since tos is only a byte, this should be:
> >=20
> > static inline u8 ip4_frag_ecn(u8 tos)
> >=20
> >=20
>=20
> In fact, generated code is the same on x86, but some arches have fast=
er
> arithmetic on WORD units.
>=20
> And I added the 'inline' because on x86_64 gcc, compiler chose _not_ =
to
> inline this 6 instruction sequence ! Code was much larger.
>=20
> 31 d2                   xor    %edx,%edx
> 0f b6 40 01             movzbl 0x1(%rax),%eax
> 83 e0 03                and    $0x3,%eax
> ff c0                   inc    %eax
> a8 02                   test   $0x2,%al
> 0f 44 d0                cmove  %eax,%edx
>=20
>=20
> We do roughly the same (working on WORD arith) in=20
>
At least make it unsigned int?

--=20
