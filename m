From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 19:22:02 +1000
Message-ID: <1311067322.25044.415.camel@pasglop>
References: <4E23E5C3.1070209@ozlabs.org>  <4E24E867.9050909@ozlabs.org>
	 <1311058260.16961.12.camel@edumazet-laptop>
	 <1311062135.25044.409.camel@pasglop>
	 <1311066368.2375.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Evans <matt@ozlabs.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52275 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332Ab1GSJWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 05:22:13 -0400
In-Reply-To: <1311066368.2375.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 11:06 +0200, Eric Dumazet wrote:
> Please Matt add to your next version this check. I dont think I have
> to
> submit a one line patch later...
> 
> On x86_64, cpu_number field is already 32bit, we have some time before
> it becomes 64bit ;)
> 
> We probably should add some extra check to make sure segment doesnt
> change (%gs on x86_64, r13 on ppc64) on a future linux version.

r13 isn't really a "segment" per-se, it can change if you aren't preempt
disabled, it's the PACA pointer, which is basically a low level per-cpu
data structure, so it will change if you migrate around (but if you are
in softirq context like most of the network stack, then it won't
change).

As for the CPU number being 16-bit, this is really due to how our
spinlocks work, using that as a lock token within the same 32-bit word
as the lock flag etc... We can easily fix that later if needed but I
don't see any emergency for us.

Cheers,
Ben.


