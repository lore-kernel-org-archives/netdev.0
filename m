From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 16:39:15 +0200
Message-ID: <0e3d1956b0b85feb2bdbdba07fad6a08@kernel.crashing.org>
References: <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org> <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com> <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org> <20070820224859.GA16162@flint.arm.linux.org.uk> <2bdb04581125f22122f1d230e991ea92@kernel.crashing.org> <20070821070555.GA32036@flint.arm.linux.org.uk>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
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
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42512 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336AbXHUOou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 10:44:50 -0400
In-Reply-To: <20070821070555.GA32036@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> And no, RMW on MMIO isn't "problematic" at all, either.
>>>>
>>>> An RMW op is a read op, a modify op, and a write op, all rolled
>>>> into one opcode.  But three actual operations.
>>>
>>> Maybe for some CPUs, but not all.  ARM for instance can't use the
>>> load exclusive and store exclusive instructions to MMIO space.
>>
>> Sure, your CPU doesn't have RMW instructions -- how to emulate
>> those if you don't have them is a totally different thing.
>
> Let me say it more clearly: On ARM, it is impossible to perform atomic
> operations on MMIO space.

It's all completely beside the point, see the other subthread, but...

Yeah, you can't do LL/SC to MMIO space; ARM isn't alone in that.
You could still implement atomic operations on MMIO space by taking
a lock elsewhere, in normal cacheable memory space.  Why you would
do this is a separate question, you probably don't want it :-)


Segher

