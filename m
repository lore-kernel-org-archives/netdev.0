From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 17:29:47 +1000
Message-ID: <1192519787.7205.3.camel@pasglop>
References: <200709071137.02801.ossthema@de.ibm.com>
	 <20070912.055004.88490155.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49144 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760993AbXJPHaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 03:30:04 -0400
In-Reply-To: <20070912.055004.88490155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jumping on an old train ...

On Wed, 2007-09-12 at 05:50 -0700, David Miller wrote:
> 
> > This would mean we have a problem on all SMP machines right now.
> 
> This is not a correct statement.
> 
> Only on your platform do network device interrupts get moved
> around, no other platform does this.
> 
> Sparc64 doesn't, all interrupts stay in one location after
> the cpu is initially choosen.
> 
> x86 and x86_64 specifically do not move around network
> device interrupts, even though other device types do
> get dynamic IRQ cpu distribution.
> 
> That's why you are the only person seeing this problem.
> 
> I agree that it should be fixed, but we should also fix the IRQ
> distribution scheme used on powerpc platforms which is totally
> broken in these cases.

So the powerpc platform just honors the affinity mask, and depending on
the PIC does things that range from nothing to spreading interrupts to
CPUs in the affinity mask.

All interrupts by defaults are spread to all CPUs (full balancing).

At this stage, it's afaik userland business to enforce different
policies by changing the affinities via /proc/irq/*.

Do you have any pointer to how that is done on x86 or sparc64 ? On my
x86 laptop using ubuntu gutsy, I definitely see the IRQ on which the
network card is connected (e1000) happily spread between the 2 cores
just like powerpc would do.

Cheers,
Ben.


