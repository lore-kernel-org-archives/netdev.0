From: David Miller <davem@davemloft.net>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 08:14:20 -0700 (PDT)
Message-ID: <20110317.081420.71114992.davem@davemloft.net>
References: <1300371834.6315.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	cl@linux-foundation.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300371834.6315.93.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Mar 2011 15:23:54 +0100

> Hi
> 
> irqsafe_cpu_{dec|inc} are used in network stack since 2.6.37 (commit
> 29b4433d991c88), and I would like to use irqsafe_cpu_add() in netfilter
> fast path too, and SNMP counters eventually (to lower ram needs by 50%)
> 
> Initial support of irqsafe_ was given by Christoph in 2.6.34
> 
> It seems only x86 arch is using a native and efficient implementation.
> 
> Others use irqsafe_cpu_generic_to_op() and its pair of
> local_irq_save() / local_irq_restore()
> 
> Which other arches could use a native implementation ?
> 
> What about defining a HAVE_FAST_IRQSAFE_ADD ?

I had been meaning to bring this up from another perspective.

In networking, we often only ever access objects in base or
BH context.  Therefore in BH context cases we can do just
normal counter bumps without any of the special atomic or
IRQ disabling code at all.

This would help non-x86 architectures a lot, and depending upon
how the non-atomic case performs perhaps x86 too.
