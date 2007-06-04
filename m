From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 04 Jun 2007 21:00:47 +0200
Message-ID: <1180983647.4404.38.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
	 <200706031826.06891.maxi@daemonizer.de> <1180939188.4404.5.camel@chaos>
	 <20070604090918.42386fbb@freepuppy> <1180974958.4404.24.camel@chaos>
	 <20070604095924.651d91c8@freepuppy> <1180978368.4404.29.camel@chaos>
	 <20070604105158.31ede1f5@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@gmail.com>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:46992 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759969AbXFDTBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 15:01:05 -0400
In-Reply-To: <20070604105158.31ede1f5@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-04 at 10:51 -0700, Stephen Hemminger wrote:
> > I doubt that. This is in the iperf code itself.
> > 
> > void thread_rest ( void ) {
> > #if defined( HAVE_THREAD )
> > #if defined( HAVE_POSIX_THREAD )
> >     // TODO add checks for sched_yield or pthread_yield and call that
> >     // if available
> >     usleep( 0 );
> > 
> > ----------^^^^
> > 
> > It results in a nanosleep({0,0}, NULL)
> > 
> > 	tglx
> > 
> 
> Yes, the following patch makes iperf work better than ever.
> But are other broken applications going to have same problem.
> Sounds like the old "who runs first" fork() problems.

Not really. The fork() "who runs first" problem is nowhere specified.

usleep(0) is well defined:

.... If the value of useconds is 0, then the call has no effect.

So the call into the kernel has been wrong for quite a time.

	tglx


