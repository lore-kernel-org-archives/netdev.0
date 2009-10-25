From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 21:47:55 -0700
Message-ID: <20091025044755.GA6678@linux.vnet.ibm.com>
References: <20091017221857.GG1925@kvack.org> <20091024135214.GB6638@linux.vnet.ibm.com> <4AE30E1B.5080008@gmail.com> <200910250249.00382.opurdila@ixiacom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:56344 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbZJYEx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2009 00:53:57 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9P4oibd020062
	for <netdev@vger.kernel.org>; Sun, 25 Oct 2009 00:50:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9P4s1a8090336
	for <netdev@vger.kernel.org>; Sun, 25 Oct 2009 00:54:01 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9P4s0sS008075
	for <netdev@vger.kernel.org>; Sun, 25 Oct 2009 00:54:01 -0400
Content-Disposition: inline
In-Reply-To: <200910250249.00382.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2009 at 02:49:00AM +0300, Octavian Purdila wrote:
> On Saturday 24 October 2009 17:24:27 you wrote:
> > Paul E. McKenney a =E9crit :
> > > On Sat, Oct 24, 2009 at 10:49:55AM +0200, Eric Dumazet wrote:
> > >> On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms
> > >
> > > That sounds like the right range, depending on what else is happe=
ning
> > > on the machine at the time.
> > >
> > > The synchronize_rcu_expedited() primitive would run in the 10s-10=
0s
> > > of microseconds.  It involves a pair of wakeups and a pair of con=
text
> > > switches on each CPU.
> >=20
> > Hmm... I'll make some experiments Monday and post results, but it s=
eems
> >  very promising.
> >=20
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

Indeed -- but then again, in the UP case, synchronize_rcu() itself
is pretty much a no-op.  So if your main target is UP, you should
be able to have seriously fast RCU updates.

(I know, I know, you want SMP to run fast as well...)

						Thanx, Paul
