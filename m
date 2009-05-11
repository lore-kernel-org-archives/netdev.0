From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 14:31:08 -0700
Message-ID: <1242077468.7214.127.camel@localhost.localdomain>
References: <20090511142101.639cb5d6@penta.localdomain>
	 <1242066617.6656.1311.camel@laptop>
	 <ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
	 <1242073557.8257.116.camel@laptop>
	 <20090511165024.5da4e3f2@penta.localdomain>
	 <1242076361.8257.168.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Yury Polyanskiy <ypolyans@Princeton.EDU>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
	mingo@elte.hu, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36586 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754692AbZEKVbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 17:31:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4BLXZMB014549
	for <netdev@vger.kernel.org>; Mon, 11 May 2009 17:33:35 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4BLVMqx187498
	for <netdev@vger.kernel.org>; Mon, 11 May 2009 17:31:22 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4BLVKT6006714
	for <netdev@vger.kernel.org>; Mon, 11 May 2009 17:31:21 -0400
In-Reply-To: <1242076361.8257.168.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 23:12 +0200, Peter Zijlstra wrote:
> On Mon, 2009-05-11 at 16:50 -0400, Yury Polyanskiy wrote:
> > On Mon, 11 May 2009 22:25:57 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > > >>   Due to (2) I am copying the authors of the hrtimer's patch.
> > > > >> Unless there is an alternative (to hrtimer_start) way of
> > > > >> requesting a CLOCK_REALTIME softirq callback the only solution I
> > > > >> could think of is to hook into
> > > > >> PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the timers
> > > > >> on xfrm_state_all list to go off after resume.
> > > > >
> > > > > Given that the whole problem is suspend related, this last option
> > > > > sounds like the best thing.
> > > > >
> > > > 
> > > > Can somebody from the Networking Team please confirm that the other
> > > > sources of time leaps can indeed be neglected? (such as ntp
> > > > corrections e.g.)
> > > 
> > > ntp time adjustments are very fine grained and should not distort
> > > time. Setting the system clock otoh might screw you over though.
> > 
> > Isn't ntp sometimes used for initial clock setting? (i.e. host boots
> > with sysclock set to 1971 and then ntp makes it to the correct 2009).
> 
> ntp (as in the userspace software bits) would use something like
> sys_settimeofday() to move the clock, after that they use sys_adjtimex()
> to keep in sync.

ntp will use settimeofday() to set the clock in the following
conditions:
1) If the step-tickers option is used, it will set the clock at bootup.
2) If the time offset becomes greater then the slew boundary (0.128s)

Otherwise it will slew the clock by making a freq adjustments via
adjtimex().

thanks
-john

