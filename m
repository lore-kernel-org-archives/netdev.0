From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 13:37:51 +0200
Message-ID: <20070821113751.GG32640@bingen.suse.de>
References: <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com> <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org> <20070820224859.GA16162@flint.arm.linux.org.uk> <2bdb04581125f22122f1d230e991ea92@kernel.crashing.org> <20070821070555.GA32036@flint.arm.linux.org.uk> <18122.45437.807239.395869@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk+lkml@arm.linux.org.uk>,
	Segher Boessenkool <segher@kernel.crashing.org>,
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
Received: from cantor2.suse.de ([195.135.220.15]:57770 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756252AbXHUKoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 06:44:07 -0400
Content-Disposition: inline
In-Reply-To: <18122.45437.807239.395869@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2007 at 07:33:49PM +1000, Paul Mackerras wrote:
> So the whole discussion is irrelevant to ARM, PowerPC and any other
> architecture except x86[-64].

It's even irrelevant on x86 because all modifying operations on atomic_t 
are coded in inline assembler and will always be RMW no matter
if atomic_t is volatile or not.

[ignoring atomic_set(x, atomic_read(x) + 1) which nobody should do]

The only issue is if atomic_t should have a implicit barrier or not.
My personal opinion is yes -- better safe than sorry. And any code
impact it may have is typically dwarved by the next cache miss anyways,
so it doesn't matter much.

-Andi

