From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 13:29:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.132954.96279785.davem@redhat.com>
References: <Pine.LNX.4.44.0303271120230.31459-100000@home.transmeta.com>
	<20030327.113933.123322481.davem@redhat.com>
	<20030327.125507.104718048.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dane@aiinet.com, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, bonding-announce@lists.sourceforge.net,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com
In-Reply-To: <20030327.125507.104718048.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "David S. Miller" <davem@redhat.com>
   Date: Thu, 27 Mar 2003 12:55:07 -0800 (PST)

Alexey has pointed out a bug in my changes.

   @@ -1088,6 +1086,9 @@ void smp_percpu_timer_interrupt(struct p
    				     : /* no outputs */
    				     : "r" (pstate));
    	} while (time_after_eq(tick, compare));
   +
   +	local_irq_enable();
   +	irq_exit();
    }
    
    static void __init smp_setup_percpu_timer(void)

Of course this is bogus.

The IRQ enable needs to occur in the irq_exit() branch right
before do_softirq() is invoked.
