From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 05:43:57 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.054357.17283294.davem@redhat.com>
References: <E791C176A6139242A988ABA8B3D9B38A01085638@hasmsx403.iil.intel.com>
	<Pine.LNX.4.44.0303271406230.7106-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dane@aiinet.com, bonding-devel@lists.sourceforge.net,
   bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   torvalds@transmeta.com, mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <Pine.LNX.4.44.0303271406230.7106-100000@jrslxjul4.npdj.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: shmulik.hen@intel.com
   Date: Thu, 27 Mar 2003 15:32:02 +0200 (IST)

   Further more, holding a lock_irq doesn't mean bottom halves are disabled
   too, it just means interrupts are disabled and no *new* softirq can be
   queued. Consider the following situation:
   
I think local_bh_enable() should check irqs_disabled() and honour that.
What you are showing here, that BH's can run via local_bh_enable()
even when IRQs are disabled, is a BUG().

IRQ disabling is meant to be stronger than softint disabling.

Ingo/Linus?
