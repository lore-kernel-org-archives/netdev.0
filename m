From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 10:01:12 +0200
Message-ID: <1287648072.6871.15.camel@edumazet-laptop>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
	 <201010201025.20950.hans.schillstrom@ericsson.com>
	 <20101020160205.GB2386@linux.vnet.ibm.com>
	 <201010210945.55252.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	"lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>,
	"wensong@linux-vs.org" <wensong@linux-vs.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201010210945.55252.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 21 octobre 2010 =C3=A0 09:45 +0200, Hans Schillstrom a =C3=A9c=
rit :
> I do have this (and some debuging)
> __rcu_read_lock()
> =3D> 0xffffffff8108bcf3 <+0>:	push   %rbp
>    0xffffffff8108bcf4 <+1>:	mov    %rsp,%rbp
>    0xffffffff8108bcf7 <+4>:	nopl   0x0(%rax,%rax,1)
>    0xffffffff8108bcfc <+9>:	mov    %gs:0xb540,%rax
>    0xffffffff8108bd05 <+18>:	mov    0x108(%rax),%edx
>    0xffffffff8108bd0b <+24>:	inc    %edx
>    0xffffffff8108bd0d <+26>:	mov    %edx,0x108(%rax)
>    0xffffffff8108bd13 <+32>:	leaveq
>    0xffffffff8108bd14 <+33>:	retq
>=20
> which is not that many, actually imprerssing few instructions :-)

nopl   0x0(%rax,%rax,1) is a filler because of extra instrumentation in
your kernel.

Maybe you could find out why your compiler dont use

	incl 0x108(%rax)

instead of

	mov    0x108(%rax),%edx
	inc    %edx
	mov    %edx,0x108(%rax)


So rcu_read_lock() is really _two_ instructions.

I agree with Paul with the "few" qualification... :-)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
