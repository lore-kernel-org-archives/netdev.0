From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 09:57:03 -0800 (PST)
Message-ID: <20091124.095703.107687163.davem@davemloft.net>
References: <20091124093518.3909.16435.stgit@ppwaskie-hc2.jf.intel.com>
	<alpine.LFD.2.00.0911241151360.24119@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, linux-kernel@vger.kernel.org,
	arjan@linux.jf.intel.com, mingo@elte.hu, yong.zhang0@gmail.com,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933757AbZKXR4s@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0911241151360.24119@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 24 Nov 2009 12:07:35 +0100 (CET)

> And what does the kernel do with this information and why are we not
> using the existing device/numa_node information ?

It's a different problem space Thomas.

If the device lives on NUMA node X, we still end up wanting to
allocate memory resources (RX ring buffers) on other NUMA nodes on a
per-queue basis.

Otherwise a network card's forwarding performance is limited by the
memory bandwidth of a single NUMA node, and on a multiqueue cards we
therefore fare much better by allocating each device RX queue's memory
resources on a different NUMA node.

It is this NUMA usage that PJ is trying to export somehow to userspace
so that irqbalanced and friends can choose the IRQ cpu masks more
intelligently.
