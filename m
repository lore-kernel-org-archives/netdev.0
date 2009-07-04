From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Sat, 4 Jul 2009 08:36:46 +0200
Message-ID: <20090704063646.GA3410@ami.dom.local>
References: <20090703120301.GD4847@ff.dom.local> <20090703.132220.57384838.davem@davemloft.net> <20090703225640.GA3639@ami.dom.local> <20090703.185553.218218176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andres@anarazel.de, arun@linux.vnet.ibm.com, tglx@linutronix.de,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755009AbZGDGhS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090703.185553.218218176.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 03, 2009 at 06:55:53PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 4 Jul 2009 00:56:40 +0200
> 
> > On Fri, Jul 03, 2009 at 01:22:20PM -0700, David Miller wrote:
> >> Well, if you look at that commit the bisect pointed to Jarek, it is a
> >> change which starts causing a situation which never happened before.
> >> Namely, timers added on one cpu can be migrated and fire on another.
> >> 
> >> So this could be exposing races in the networking that technically
> >> always existed.
> > 
> > I'm not sure I get your point; could you give some example?
> > Actually, I've suspected races in timers code.
> 
> Let's say that a particular networking timer always gets
> re-added on the cpu where the timer fires.
> 
> In that case, beforehand, no inter-cpu races could possibly
> be tested.  But with the new timer code, such races could
> now be potentially triggered.

Maybe I still miss something, but even if it were possible, lockdep
should have reported such things long ago.

Jarek P.
