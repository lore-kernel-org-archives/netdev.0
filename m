From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 18:53:26 +0300
Message-ID: <4DA71876.803@redhat.com>
References: <1301783301.2837.77.camel@edumazet-laptop>	 <1301784797.3110.4.camel@localhost>	 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>	 <0a7fdea6b816da546ea71f752d36b5c2@localhost>  <4DA715BB.6050307@redhat.com> <1302795951.3248.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759208Ab1DNPxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 11:53:36 -0400
In-Reply-To: <1302795951.3248.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2011 06:45 PM, Eric Dumazet wrote:
> Le jeudi 14 avril 2011 =C3=A0 18:41 +0300, Avi Kivity a =C3=A9crit :
>
> >  I'm talking about optimizing the generated code.  For example, bpf=
 has
> >  just two registers so a complex program generates a lot of loads a=
nd
> >  stores.  An optimizing compiler can use extra target registers to =
avoid
> >  those spills, and doesn't need to keep A and X in fixed registers.
> >
>
> Thats not exactly true.
>
> A bpf filter also uses up to 16 mem[] 'registers'.
>

That's what I referred as loads and stores.  Since you can't use mem[]=20
to index into a packet, you have to spill X into mem[], calculate a new=
=20
X, use it to access the packet, and reload X.

> A risc cpu (with a lot of registers) could use registers to hold part=
 of
> the mem[] array.

An optimizing compiler will dynamically assign mem[] into registers,=20
even on i386.  Liveness analysis means the same machine register can be=
=20
used for different mem[] locations.

> >  If you translate the bpf program to C and optimize that with gcc y=
ou'll
> >  probably get much better machine code that the jit in the patch.
> >
>
> Well, gcc wont optimize a lot a bpf program if you ask me.

IMO, it will.  I'll try to have gcc optimize your example filter later.

> You would better make tcpdump not generate bpf but direct C code.

That involves breaking the interface (plus, we might not trust tcpdump)=
=2E

--=20
error compiling committee.c: too many arguments to function

