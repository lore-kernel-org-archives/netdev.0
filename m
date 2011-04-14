From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 17:40:30 +0200
Message-ID: <1302795630.3248.10.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <1301784797.3110.4.camel@localhost>
	 <1301838968.2837.200.camel@edumazet-laptop>  <4DA70743.1050106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46479 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab1DNPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 11:40:37 -0400
Received: by wya21 with SMTP id 21so1513449wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 08:40:36 -0700 (PDT)
In-Reply-To: <4DA70743.1050106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 17:40 +0300, Avi Kivity a =C3=A9crit :
> On 04/03/2011 04:56 PM, Eric Dumazet wrote:
> > In order to speedup packet filtering, here is an implementation of =
a JIT
> > compiler for x86_64
> >
>=20
> Have you considered putting the compiler in userspace?
>=20

Hmm, to be honest no.

> You could have a trusted compile server waiting on a pipe and compili=
ng=20
> programs sent to it by the kernel, sending the results back down.  Us=
e=20
> the interpreter until the compiler returns; if it doesn't, use the=20
> interpreter forever.

I feel it might be too expensive in some cases, and kind of complex
architecture.

>=20
> The upside is that you can use established optimizing compilers like=20
> LLVM or GCC, which already support more target architectures.  It may=
=20
> not matter much for something simple like bpf, but other VMs may be a=
=20
> lot more complicated.
>=20

Not only bpf is very simple, but it needs to access skb fields and othe=
r
parts of the kernel, we would need to instruct userland compiler of all
these details.

We would need to load kind of a module (with dynamic loader)

Of course, making each bpf filter a module of his own has benefit for
perf profiling.



