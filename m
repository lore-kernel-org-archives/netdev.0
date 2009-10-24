From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sun, 25 Oct 2009 02:49:00 +0300
Message-ID: <200910250249.00382.opurdila@ixiacom.com>
References: <20091017221857.GG1925@kvack.org> <20091024135214.GB6638@linux.vnet.ibm.com> <4AE30E1B.5080008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Benjamin LaHaise <bcrl@lhnet.ca>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:22943 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751997AbZJXXvx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 19:51:53 -0400
In-Reply-To: <4AE30E1B.5080008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 24 October 2009 17:24:27 you wrote:
> Paul E. McKenney a =E9crit :
> > On Sat, Oct 24, 2009 at 10:49:55AM +0200, Eric Dumazet wrote:
> >> On my dev machine, a synchronize_rcu() lasts between 2 an 12 ms
> >
> > That sounds like the right range, depending on what else is happeni=
ng
> > on the machine at the time.
> >
> > The synchronize_rcu_expedited() primitive would run in the 10s-100s
> > of microseconds.  It involves a pair of wakeups and a pair of conte=
xt
> > switches on each CPU.
>=20
> Hmm... I'll make some experiments Monday and post results, but it see=
ms
>  very promising.
>=20

Got some time today and did some experiments myself. The test is deleti=
ng 1000=20
dummy interfaces (interface status down, no IP/IPv6 addresses assigned)=
 on a=20
UP non-preempt ppc750 @800Mhz system.

1. Ben's patch:

real    0m 3.42s
user    0m 0.00s
sys     0m 0.00s

2. Eric's schedule_timeout_uninterruptible(1);

real    0m 3.00s
user    0m 0.00s
sys     0m 0.00s

3. Simple synchronize_rcu_expedited()

This doesn't seem to work well with the UP non-preempt case since=20
synchronize_rcu_expedited() is a noop in this case - turning=20
netdev_wait_allrefs() into a while(1) loop.

tavi




