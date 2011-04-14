From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 18:45:20 +0300
Message-ID: <4DA71690.2020202@redhat.com>
References: <1301783301.2837.77.camel@edumazet-laptop>	 <1301784797.3110.4.camel@localhost>	 <1301838968.2837.200.camel@edumazet-laptop>  <4DA70743.1050106@redhat.com> <1302795630.3248.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab1DNPpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 11:45:32 -0400
In-Reply-To: <1302795630.3248.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2011 06:40 PM, Eric Dumazet wrote:
> Le jeudi 14 avril 2011 =C3=A0 17:40 +0300, Avi Kivity a =C3=A9crit :
> >  On 04/03/2011 04:56 PM, Eric Dumazet wrote:
> >  >  In order to speedup packet filtering, here is an implementation=
 of a JIT
> >  >  compiler for x86_64
> >  >
> >
> >  Have you considered putting the compiler in userspace?
> >
>
> Hmm, to be honest no.
>
> >  You could have a trusted compile server waiting on a pipe and comp=
iling
> >  programs sent to it by the kernel, sending the results back down. =
 Use
> >  the interpreter until the compiler returns; if it doesn't, use the
> >  interpreter forever.
>
> I feel it might be too expensive in some cases, and kind of complex
> architecture.

It is, but the kernel-side complexity is lower.  And since we have a=20
fallback, overall reliability is improved rather than reduced.

> >
> >  The upside is that you can use established optimizing compilers li=
ke
> >  LLVM or GCC, which already support more target architectures.  It =
may
> >  not matter much for something simple like bpf, but other VMs may b=
e a
> >  lot more complicated.
> >
>
> Not only bpf is very simple, but it needs to access skb fields and ot=
her
> parts of the kernel, we would need to instruct userland compiler of a=
ll
> these details.

A simple implementation would be to translate the bpf program into a C=20
function which receives the same arguments as your bpf runtime, and=20
optimize that with gcc.

> We would need to load kind of a module (with dynamic loader)

Well, we have one.

> Of course, making each bpf filter a module of his own has benefit for
> perf profiling.

And stack unwind info, etc.

--=20
error compiling committee.c: too many arguments to function

