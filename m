From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 15:36:48 +0200
Message-ID: <1288100208.3169.112.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59416 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933206Ab0JZNgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 09:36:53 -0400
Received: by ywk9 with SMTP id 9so2857672ywk.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 06:36:53 -0700 (PDT)
In-Reply-To: <4CC6D7CC.5040608@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 09:29 -0400, Joe Buehler a =C3=A9crit :
> Eric Dumazet wrote:
>=20
> > With a normal workload, on a dual cpu machine, a missing memory bar=
rier
> > can stay un-noticed for quite a long time. The race window is so sm=
all
> > that probability for the bug might be 0.0000001 % or something like
> > that :(
>=20
> I'm looking at the LINUX source at the moment and not liking what I s=
ee
> in include/asm-mips/barrier.h:
>=20
> #define smp_mb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memory=
")
> #ifdef CONFIG_CPU_CAVIUM_OCTEON
> #define smp_rmb()	barrier()
> #define smp_wmb()	barrier()
> #else
> #define smp_rmb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memor=
y")
> #define smp_wmb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memor=
y")
> #endif
>=20
> The Octeon documentation explicitly says that neither loads nor store=
s
> need execute in program order, so the definitions for smp_rmb and
> smp_wmb appear to be wrong wrong wrong.
>=20
> It appears that smp_wmb should be making use of SYNCW and smp_rmb sho=
uld
> be making use of SYNC.
>=20
> Should I pursue this question on the main LINUX kernel list?

Well, it would be surprising this being wrong and crash only once in a
while in fib_rules_lookup

Did you tried my last patch ?



