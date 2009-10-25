From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sun, 25 Oct 2009 09:35:10 +0100
Message-ID: <4AE40DBE.8050505@gmail.com>
References: <20091017221857.GG1925@kvack.org> <20091024135214.GB6638@linux.vnet.ibm.com> <4AE30E1B.5080008@gmail.com> <200910250249.00382.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Benjamin LaHaise <bcrl@lhnet.ca>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39977 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbZJYIfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 04:35:25 -0400
In-Reply-To: <200910250249.00382.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
>=20
> Got some time today and did some experiments myself. The test is dele=
ting 1000=20
> dummy interfaces (interface status down, no IP/IPv6 addresses assigne=
d) on a=20
> UP non-preempt ppc750 @800Mhz system.
>=20
> 1. Ben's patch:
>=20
> real    0m 3.42s
> user    0m 0.00s
> sys     0m 0.00s
>=20
> 2. Eric's schedule_timeout_uninterruptible(1);
>=20
> real    0m 3.00s
> user    0m 0.00s
> sys     0m 0.00s
>=20
> 3. Simple synchronize_rcu_expedited()
>=20
> This doesn't seem to work well with the UP non-preempt case since=20
> synchronize_rcu_expedited() is a noop in this case - turning=20
> netdev_wait_allrefs() into a while(1) loop.
>=20

Thanks for these numbers. I presume HZ value is 1000 on this platform ?

Could you give us your scripts so that we can use same "benchmark" ?

BTW, I found I could not use IPV6 with many devices on x86_32, because =
of
the huge per_cpu allocations (on IPV6, each device has percpu SNMP coun=
ters)


