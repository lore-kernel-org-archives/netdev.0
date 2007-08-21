From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 16:48:51 +0200
Message-ID: <33412cad5894a9cbdc85482db5e9a0a0@kernel.crashing.org>
References: <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org> <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com> <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org> <20070820224859.GA16162@flint.arm.linux.org.uk> <2bdb04581125f22122f1d230e991ea92@kernel.crashing.org> <20070821070555.GA32036@flint.arm.linux.org.uk> <18122.45437.807239.395869@cargo.ozlabs.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk+lkml@arm.linux.org.uk>,
	Christoph Lameter <clameter@sgi.com>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, rpjday@mindspring.com,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	satyam@infradead.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45964 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758485AbXHUOze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 10:55:34 -0400
In-Reply-To: <18122.45437.807239.395869@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Let me say it more clearly: On ARM, it is impossible to perform atomic
>> operations on MMIO space.
>
> Actually, no one is suggesting that we try to do that at all.
>
> The discussion about RMW ops on MMIO space started with a comment
> attributed to the gcc developers that one reason why gcc on x86
> doesn't use instructions that do RMW ops on volatile variables is that
> volatile is used to mark MMIO addresses, and there was some
> uncertainty about whether (non-atomic) RMW ops on x86 could be used on
> MMIO.  This is in regard to the question about why gcc on x86 always
> moves a volatile variable into a register before doing anything to it.

This question is GCC PR33102, which was incorrectly closed as a 
duplicate
of PR3506 -- and *that* PR was closed because its reporter seemed to
claim the GCC generated code for an increment on a volatile (namely, 
three
machine instructions: load, modify, store) was incorrect, and it has to
be one machine instruction.

> So the whole discussion is irrelevant to ARM, PowerPC and any other
> architecture except x86[-64].

And even there, it's not something the kernel can take advantage of
before GCC 4.4 is in widespread use, if then.  Let's move on.


Segher

