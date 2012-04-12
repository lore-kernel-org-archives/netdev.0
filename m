From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 18:53:41 -0700
Message-ID: <20120412015341.GA2497@linux.vnet.ibm.com>
References: <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
 <20120411.201854.1070083308359208025.davem@davemloft.net>
 <20120412004507.GF2473@linux.vnet.ibm.com>
 <20120411.210319.370705937753558953.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mroos@linux.ee,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120411.210319.370705937753558953.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2012 at 09:03:19PM -0400, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 11 Apr 2012 17:45:07 -0700
> 
> > On Wed, Apr 11, 2012 at 08:18:54PM -0400, David Miller wrote:
> >> From: Stephen Hemminger <shemminger@vyatta.com>
> >> Date: Wed, 11 Apr 2012 17:10:04 -0700
> >> 
> >> > On Wed, 11 Apr 2012 16:08:37 -0700
> >> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> >> > 
> >> >> Hmmm...  What CPU family is this running on?  From the look of the
> >> >> stack, it is sneaking out of idle into softirq without telling RCU.
> >> >> This would cause RCU to complain bitterly about being invoked from
> >> >> the idle loop -- and RCU ignores CPUs in the idle loop.
> >> >> 
> >> >> 							Thanx, Paul
> >> > 
> >> > Sun4... Ping David.
> >> 
> >> So is there anything specific I need to do in the sparc64
> >> idle loop?
> > 
> > Hmmm...  I must confess that I don't immediately see how control
> > is passing from cpu_idle() in arch/sparc/kernel/process_64.c to
> > __handle_softirq().
> > 
> > But it looks like a simple function call in the call trace:
> 
> It's coming from the trap return code path at the end of hardware
> interrupt processing, on the IRQ stack.

Ah!  I should have guessed something like that was happening given
that __handle_softirq() is written in assembly.

							Thanx, Paul
