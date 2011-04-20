From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 10:07:58 +0200
Message-ID: <1303286878.3186.17.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <1301784797.3110.4.camel@localhost>
	 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>
	 <0a7fdea6b816da546ea71f752d36b5c2@localhost> <4DA715BB.6050307@redhat.com>
	 <1302795951.3248.14.camel@edumazet-laptop> <4DA71876.803@redhat.com>
	 <1302797147.3248.32.camel@edumazet-laptop>  <4DAE8E47.7040409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63895 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab1DTIID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:08:03 -0400
Received: by wwa36 with SMTP id 36so578249wwa.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 01:08:01 -0700 (PDT)
In-Reply-To: <4DAE8E47.7040409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 10:41 +0300, Avi Kivity a =C3=A9crit :
> On 04/14/2011 07:05 PM, Eric Dumazet wrote:
> > Le jeudi 14 avril 2011 =C3=A0 18:53 +0300, Avi Kivity a =C3=A9crit =
:
> >
> > >  IMO, it will.  I'll try to have gcc optimize your example filter=
 later.
> >
> > Sure you can JIT a C program from bpf. It should take maybe 30 minu=
tes.
> > It certainly is more easy than JIT an binary/assembly code :)
> >
> > Now take a look how I call slowpath, I am not sure gcc will actuall=
y
> > generate better code because of C conventions.
>=20
> Some things will be the same (like calling a function outside the jit=
). =20
> Some things will be faster.
>=20
> > Loading a filter should be fast.
> > Invoking a compiler is just too much work for BPF.
> > Remember loading a filter is available to any user.
>=20
> Like I mentioned before, use the interpreter until the result of the=20
> jitter is available.
>=20
> > This idea would be good for netfilter stuff, because we dont load
> > iptables rules that often.
> >
> > But still, the netfilter mainloop can be converted as a kernel JIT,=
 most
> > probably. All the complex stuff (matches, targets) must call extern=
al
> > procedures anyway.
>=20
> We could convert some matches to bytecode, probably.
>=20
> To avoid getting into an infinite loop (btw, does you jit avoid infin=
ite=20
> loops in the generated code?) I'll restate what I think are an extern=
al=20
> jit's advantages and then stop harping on the subject:
>=20
> - less effort
> - less kernel code
> - better arch support
> - better optimization
> - better profiler/debugger integration
> - multiple optimization levels (can use your jitter in userspace, or=20
> gcc, or llvm)
>=20

No problem, I'll wait your work on this then.

I disagree having a gcc on production machines, I'm not sure it will
please admins...

Thanks


