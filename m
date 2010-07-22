From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Thu, 22 Jul 2010 18:24:14 +0200
Message-ID: <1279815854.2467.112.camel@edumazet-laptop>
References: <1279807385.2467.67.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
	 <1279811939.2467.79.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007221736150.12308@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007221736150.12308@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 17:39 +0200, Jan Engelhardt a =C3=A9cri=
t :

> Never say never. "long" already bit people in the past, and now we
> have that CONFIG_COMPAT stuff.
>=20

I know pretty well the "long" problem, I received one of the first alph=
a
machine ever built in the world (DEC 3000 AXP, with a fast 133 MHz
cpu ;) ), before I began to use Linux :)


> If invert is the only flag, perhaps it makes sense to use __u8=20
> for it.=20
>=20

Quite frankly it brings more problems than plain u32

- Possible security problems (padding bytes). Not applicable to
iptables.

- Some arches have slow byte/short accesses (21064 for example :) )

"int" is the natural type, fast on all arches.

- Given alignment requirements of iptables rules, using less than 32bit=
s
here saves no ram.

But I dont care that much.

I even see compiler doesnt want to use a XOR instruction :

00000018 <cpu_mt>:
  18:	55                   	push   %ebp
  19:	8b 42 04             	mov    0x4(%edx),%eax
  1c:	64 8b 15 00 00 00 00 	mov    %fs:0x0,%edx
  23:	89 e5                	mov    %esp,%ebp
  25:	5d                   	pop    %ebp
  26:	39 10                	cmp    %edx,(%eax)
  28:	0f 94 c2             	sete   %dl
  2b:	0f b6 d2             	movzbl %dl,%edx
  2e:	3b 50 04             	cmp    0x4(%eax),%edx
  31:	0f 95 c0             	setne  %al
  34:	c3                   	ret   =20




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
