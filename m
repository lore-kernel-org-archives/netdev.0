From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Fri, 18 Mar 2011 17:56:24 +1100
Message-ID: <1300431384.22236.1280.camel@pasglop>
References: <1300371834.6315.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1300371834.6315.93.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 15:23 +0100, Eric Dumazet wrote:
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

On powerpc, we use the generic one and it's fast :-) Well, at least on
ppc64, bcs we do lazy irq disabling, disabling/enabling interrupt is
basically just poking a byte in a per-cpu data structure (there's a tad
more work on enable in case the interrupt actually occured and we ended
up really disabling but that's not the common case). Overall faster than
using the atomic ops which have to go all the way to the L2 cache.

So if you define the above, please set in on powerpc despite the fact
that we use the generic implementation.

Cheers,
Ben.
