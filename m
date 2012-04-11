From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 16:08:37 -0700
Message-ID: <20120411230837.GC2473@linux.vnet.ibm.com>
References: <alpine.SOC.1.00.1203281134090.13691@math.ut.ee>
 <20120328.174559.650861844028495880.davem@davemloft.net>
 <alpine.SOC.1.00.1204111807420.26884@math.ut.ee>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.SOC.1.00.1204111807420.26884@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2012 at 06:08:53PM +0300, Meelis Roos wrote:
> > > Is this the same RCU problem that was fixed after 3.3 (fix a potential 
> > > rcu_read_lock() imbalance in rt6_fill_node())? My problem does not seem 
> > > to be ipv6-only, most traces are from IPv6 but some for ip.
> > 
> > It's hard to say because the ipv6 RCU problem causes the warning to
> > trigger somewhere away from the ipv6 code that had the RCU locking
> > bug.
> 
> Tested todays 3.4.0-rc2-00016-ga9e1e53 on the same with flood ping and 
> still got RCU warning:

Hmmm...  What CPU family is this running on?  From the look of the
stack, it is sneaking out of idle into softirq without telling RCU.
This would cause RCU to complain bitterly about being invoked from
the idle loop -- and RCU ignores CPUs in the idle loop.

							Thanx, Paul

> [36456.693191] 
> [36456.712658] ===============================
> [36456.767614] [ INFO: suspicious RCU usage. ]
> [36456.822588] 3.4.0-rc2-00016-ga9e1e53 #36 Not tainted
> [36456.887835] -------------------------------
> [36456.942804] include/linux/netpoll.h:70 suspicious rcu_dereference_check() usage!
> [36457.040083] 
> [36457.040089] other info that might help us debug this:
> [36457.040098] 
> [36457.145306] 
> [36457.145312] RCU used illegally from idle CPU!
> [36457.145320] rcu_scheduler_active = 1, debug_locks = 0
> [36457.288293] RCU used illegally from extended quiescent state!
> [36457.363834] no locks held by swapper/0.
> [36457.414221] 
> [36457.414227] stack backtrace:
> [36457.471471] Call Trace:
> [36457.503600]  [0000000000489834] lockdep_rcu_suspicious+0xd4/0x100
> [36457.583727]  [00000000006755a8] __netif_receive_skb+0x368/0xa80
> [36457.661536]  [0000000000675e6c] netif_receive_skb+0x4c/0x60
> [36457.734787]  [000000000063fd74] tulip_poll+0x3b4/0x6a0
> [36457.802327]  [00000000006794d8] net_rx_action+0x118/0x1e0
> [36457.873299]  [00000000004560fc] __do_softirq+0x9c/0x140
> [36457.941984]  [000000000042b1c4] do_softirq+0x84/0xc0
> [36458.007229]  [0000000000404a40] __handle_softirq+0x0/0x10
> [36458.078199]  [000000000042b688] cpu_idle+0x48/0x100
> [36458.142314]  [0000000000722db8] rest_init+0x160/0x188
> [36458.208711]  [00000000008c87b0] start_kernel+0x32c/0x33c
> [36458.278530]  [0000000000722c50] tlb_fixup_done+0x88/0x90
> [36458.348346]  [0000000000000000]           (null)
> 
> 
> -- 
> Meelis Roos (mroos@linux.ee)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
