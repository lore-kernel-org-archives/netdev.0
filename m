From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 23 Jul 2004 15:57:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090612669.1218.47.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: shemminger@osdl.org, "David S. Miller" <davem@redhat.com>,
        arekm@pld-linux.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-23 at 11:00, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:

>=20
> BTW, what's for rcnt etc.? I don't see the point.=20
>=20
> They're not (effectively) used in kernel.

It is transported to user space for analysis of how to reorganize
hash table optimally.

> I'd suggest to remove these things and to maintain the original ABI.
>=20
> If rcnt etc. are for other purposes, such as statistics for userspace,
> please allocate another structure / interface for it.

I could send a separate TLV, i dont think this will resolve the problem
of ABI breakage but it will be more of a cleans. Part of the counters i n=
eed for analysis is in the
key structure.

> (And... cheking size is too strict;
> we need to relax it to accept old binaries if we add something
> at the tail of structure.)

A lot of size checks for every structure at both kernel/userspace is
needed. Not much is done today as is - which means old binaries may
break when modified structures are transported to user space.
I think one of the main challenges with the u32 structures is the keys[]
table. In the future if we could make that a TLV it would help.=20
We need not just be backward compatible but also forward compatible.

I will do some testing when i get back next week to see if current patch
breaks anything.

cheers,
jamal
