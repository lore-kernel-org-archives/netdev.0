From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debugging kernel during packet drops
Date: Thu, 25 Mar 2010 12:02:08 +0100
Message-ID: <1269514928.3626.13.camel@edumazet-laptop>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>
	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>
	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>
	 <1269509574.3626.9.camel@edumazet-laptop>  <4BAB3C8B.3030104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAB3C8B.3030104@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 mars 2010 =C3=A0 11:35 +0100, Patrick McHardy a =C3=A9crit =
:
> Eric Dumazet wrote:
> > Here is patch I cooked for xt_hashlimit (on top of net-next-2.6) to=
 make
> > it use RCU and scale better in your case (allowing several concurre=
nt
> > cpus once RPS is activated), but also on more general cases.
> >=20
> > [PATCH] xt_hashlimit: RCU conversion
> >=20
> > xt_hashlimit uses a central lock per hash table and suffers from
> > contention on some workloads.
> >=20
> > After RCU conversion, central lock is only used when a writer wants=
 to
> > add or delete an entry. For 'readers', updating an existing entry, =
they
> > use an individual lock per entry.
>=20
> This clashes with some recent cleanups in nf-next-2.6.git. I'm
> also expecting a patch from Jan to remove the old v0 revision
> very soon (probably today). Please rediff once I've pushed that out.

Sure, this patch was mainly for Jorrit tests (and he uses net-next-2.6)=
,

I will submit several patches for mainline :)

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
