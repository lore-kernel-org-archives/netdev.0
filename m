From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 11:03:35 +0100
Message-ID: <87bps8fkaw.fsf@basil.nowhere.org>
References: <20090309112521.GB37984@bts.sk>
	<1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	<20090309200505.GA58375@bts.sk>
	<20090309.170927.130334650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: md@bts.sk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39944 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbZCKKF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 06:05:59 -0400
In-Reply-To: <20090309.170927.130334650.davem@davemloft.net> (David Miller's message of "Mon, 09 Mar 2009 17:09:27 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Marian =C4=8Eurkovi=C4=8D <md@bts.sk>
> Date: Mon, 9 Mar 2009 21:05:05 +0100
>
>> Well, in practice that was always limited by receive window size, wh=
ich
>> was by default 64 kB on most operating systems. So this undesirable =
behavior
>> was limited to hosts where receive window was manually increased to =
huge
>> values.
>
> You say "was" as if this was a recent change.  Linux has been doing
> receive buffer autotuning for at least 5 years if not longer.

I think his point was the only now does it become a visible problem
as >=3D 1GB of memory is wide spread, which leads to 4MB rx buffer size=
s.

Perhaps this points to the default buffer sizing heuristics to=20
be too aggressive for >=3D 1GB?

Perhaps something like this patch? Marian, does that help?

-Andi

TCP: Lower per socket RX buffer sizing threshold=20

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 net/ipv4/tcp.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.28-test/net/ipv4/tcp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.28-test.orig/net/ipv4/tcp.c	2009-02-09 11:06:52.000000000=
 +0100
+++ linux-2.6.28-test/net/ipv4/tcp.c	2009-03-11 11:01:53.000000000 +010=
0
@@ -2757,9 +2757,9 @@
 	sysctl_tcp_mem[1] =3D limit;
 	sysctl_tcp_mem[2] =3D sysctl_tcp_mem[0] * 2;
=20
-	/* Set per-socket limits to no more than 1/128 the pressure threshold=
 */
-	limit =3D ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
-	max_share =3D min(4UL*1024*1024, limit);
+	/* Set per-socket limits to no more than 1/256 the pressure threshold=
 */
+	limit =3D ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 8);
+	max_share =3D min(2UL*1024*1024, limit);
=20
 	sysctl_tcp_wmem[0] =3D SK_MEM_QUANTUM;
 	sysctl_tcp_wmem[1] =3D 16*1024;


--=20
ak@linux.intel.com -- Speaking for myself only.
