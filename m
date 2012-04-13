From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Fri, 13 Apr 2012 09:30:34 -0700
Message-ID: <20120413163029.GA2402@linux.vnet.ibm.com>
References: <20120412045428.GB2497@linux.vnet.ibm.com>
 <alpine.SOC.1.00.1204131444150.2736@math.ut.ee>
 <20120413133513.GB2457@linux.vnet.ibm.com>
 <20120413.105556.73360716787161031.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mroos@linux.ee, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34678 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab2DMQdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:33:51 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 13 Apr 2012 10:33:49 -0600
Content-Disposition: inline
In-Reply-To: <20120413.105556.73360716787161031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 13, 2012 at 10:55:56AM -0400, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Fri, 13 Apr 2012 06:35:13 -0700
> 
> DANGER WILL ROBINSON, McKenney is hacking sparc64 assembler!
> :-))))

;-) ;-) ;-)

> > My main concern about my patch is my removal of this line:
> > 
> > 	bne,pn			%icc, __handle_softirq
> > 
> > It is quite possible that this should instead change to look as follows:
> > 
> > 	bne,pn			%icc, __handle_preemption
> > 
> 
> I would say it should not, because the __handle_softirq code path,
> if taken, unconditionally branches to the very next instruction
> after this branch and it's delay slot.

Beginners luck beats skill.  Now I just have to be very careful to
avoid ever submitting a second sparc64 assembler patch.  ;-)

> > Anyway, patch with updated changelog below.
> 
> Great work, I'll apply this after I test it out a bit myself.

Cool!!!

							Thanx, Paul

> Thanks a lot Paul!
> 
