From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Thu, 30 May 2013 22:20:59 -0700
Message-ID: <1369977659.10556.34.camel@joe-AO722>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
	 <51A6768B.5050603@cogentembedded.com> <87obbsohd1.fsf@nemi.mork.no>
	 <1369962688.1751.6.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44090 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750743Ab3EaFU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 01:20:59 -0400
In-Reply-To: <1369962688.1751.6.camel@buesod1.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 18:11 -0700, Davidlohr Bueso wrote:
> On Thu, 2013-05-30 at 13:08 +0200, Bj=F8rn Mork wrote:
> > Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:
> >=20
> > >     Why not "text:%#lx" as already used in this string? It's
> > > equivalent to "0x%lx".
> >=20
> > Well, I don't know the reasoning in this case, but I'd like to note=
 that
> > those are not strictly equivalent.  Personally I find the formattin=
g of 0
> > annoying enough to avoid %#x for any value which may be 0.  It's
> > especially bad if you try to line up things by adding leading zeros=
=2E
>=20
> Yep, I found that 0x%lx produced the same output as %p.

Don't use a standalone gcc compiled program to
determine what the kernel outputs.

lib/vsprintf.c does not output the same. (32 bit)

The kernel output is;

	printk("0x%lx\n", 0x100ul)		0x100
	printk("%p\n", (void *)0x100ul)		00000100
	printk("%#p\n", (void *)0x100ul)	0x00000100

The last one isn't used at all in kernel source. (gcc complains)
It's always "0x%p"
