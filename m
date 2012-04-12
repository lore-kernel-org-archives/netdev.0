From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 21:08:43 -0400 (EDT)
Message-ID: <20120411.210843.716144028821174908.davem@davemloft.net>
References: <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
	<20120411.201854.1070083308359208025.davem@davemloft.net>
	<20120412004507.GF2473@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mroos@linux.ee,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120412004507.GF2473@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 11 Apr 2012 17:45:07 -0700

> If I am confused about the simple function call, and if control is really
> passing via an interrupt or exception, then rcu_irq_enter() should be
> called on entry to the interrupt or exception and rcu_irq_exit() should
> be called on exit.

Hmm, it seems the convention changed such that platforms aren't
supposed to invoke do_softirq() from their trap return trap any more.
It's handled completely by irq_exit().

When did that start happening? :-)

Anyways I bet that's the problem, sparc64 invokes do_softirq() in it's
trap return path if softirqs are pending, and that doesn't do any
of the RCU frobbing you mention.
