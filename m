From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: 27 Mar 2003 15:11:56 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <shssmt8vqz7.fsf@charged.uio.no>
References: <E791C176A6139242A988ABA8B3D9B38A01085638@hasmsx403.iil.intel.com>
	<Pine.LNX.4.44.0303271406230.7106-100000@jrslxjul4.npdj.intel.com>
	<20030327.054357.17283294.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shmulik.hen@intel.com, dane@aiinet.com,
	bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	torvalds@transmeta.com, mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030327.054357.17283294.davem@redhat.com>
List-Id: netdev.vger.kernel.org

>>>>> " " == David S Miller <davem@redhat.com> writes:

     >    From: shmulik.hen@intel.com Date: Thu, 27 Mar 2003 15:32:02
     >    +0200 (IST)

     >    Further more, holding a lock_irq doesn't mean bottom halves
     >    are disabled too, it just means interrupts are disabled and
     >    no *new* softirq can be queued. Consider the following
     >    situation:
   
     > I think local_bh_enable() should check irqs_disabled() and
     > honour that.  What you are showing here, that BH's can run via
     > local_bh_enable() even when IRQs are disabled, is a BUG().

     > IRQ disabling is meant to be stronger than softint disabling.

In that case, you'll need to have things like spin_lock_irqrestore()
call local_bh_enable() in order to run the pending softirqs. Is that
worth the trouble?

Cheers,
  Trond
