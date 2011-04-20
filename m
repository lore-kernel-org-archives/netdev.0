From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 10:41:59 +0300
Message-ID: <4DAE8E47.7040409@redhat.com>
References: <1301783301.2837.77.camel@edumazet-laptop>	 <1301784797.3110.4.camel@localhost>	 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>	 <0a7fdea6b816da546ea71f752d36b5c2@localhost> <4DA715BB.6050307@redhat.com>	 <1302795951.3248.14.camel@edumazet-laptop> <4DA71876.803@redhat.com> <1302797147.3248.32.camel@edumazet-laptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:10690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab1DTHmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:42:17 -0400
In-Reply-To: <1302797147.3248.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2011 07:05 PM, Eric Dumazet wrote:
> Le jeudi 14 avril 2011 =C3=A0 18:53 +0300, Avi Kivity a =C3=A9crit :
>
> >  IMO, it will.  I'll try to have gcc optimize your example filter l=
ater.
>
> Sure you can JIT a C program from bpf. It should take maybe 30 minute=
s.
> It certainly is more easy than JIT an binary/assembly code :)
>
> Now take a look how I call slowpath, I am not sure gcc will actually
> generate better code because of C conventions.

Some things will be the same (like calling a function outside the jit).=
 =20
Some things will be faster.

> Loading a filter should be fast.
> Invoking a compiler is just too much work for BPF.
> Remember loading a filter is available to any user.

Like I mentioned before, use the interpreter until the result of the=20
jitter is available.

> This idea would be good for netfilter stuff, because we dont load
> iptables rules that often.
>
> But still, the netfilter mainloop can be converted as a kernel JIT, m=
ost
> probably. All the complex stuff (matches, targets) must call external
> procedures anyway.

We could convert some matches to bytecode, probably.

To avoid getting into an infinite loop (btw, does you jit avoid infinit=
e=20
loops in the generated code?) I'll restate what I think are an external=
=20
jit's advantages and then stop harping on the subject:

- less effort
- less kernel code
- better arch support
- better optimization
- better profiler/debugger integration
- multiple optimization levels (can use your jitter in userspace, or=20
gcc, or llvm)

--=20
error compiling committee.c: too many arguments to function

