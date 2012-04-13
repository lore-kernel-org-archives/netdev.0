From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Fri, 13 Apr 2012 10:55:56 -0400 (EDT)
Message-ID: <20120413.105556.73360716787161031.davem@davemloft.net>
References: <20120412045428.GB2497@linux.vnet.ibm.com>
	<alpine.SOC.1.00.1204131444150.2736@math.ut.ee>
	<20120413133513.GB2457@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120413133513.GB2457@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 13 Apr 2012 06:35:13 -0700

DANGER WILL ROBINSON, McKenney is hacking sparc64 assembler!
:-))))

> My main concern about my patch is my removal of this line:
> 
> 	bne,pn			%icc, __handle_softirq
> 
> It is quite possible that this should instead change to look as follows:
> 
> 	bne,pn			%icc, __handle_preemption
> 

I would say it should not, because the __handle_softirq code path,
if taken, unconditionally branches to the very next instruction
after this branch and it's delay slot.

> Anyway, patch with updated changelog below.

Great work, I'll apply this after I test it out a bit myself.

Thanks a lot Paul!
