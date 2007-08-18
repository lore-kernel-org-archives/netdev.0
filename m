From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 15:41:13 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708181526270.30176@woody.linux-foundation.org>
References: <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
 <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au>
 <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708180709060.3666@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
 <20070818215409.GC7628@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:32883 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753709AbXHRWsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 18:48:39 -0400
In-Reply-To: <20070818215409.GC7628@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Paul E. McKenney wrote:
> 
> One of the gcc guys claimed that he thought that the two-instruction
> sequence would be faster on some x86 machines.  I pointed out that
> there might be a concern about code size.  I chose not to point out
> that people might also care about the other x86 machines.  ;-)

Some (very few) x86 uarchs do tend to prefer "load-store" like code 
generation, and doing a "mov [mem],reg + op reg" instead of "op [mem]" can 
actually be faster on some of them. Not any that are relevant today, 
though.

Also, that has nothing to do with volatile, and should be controlled by 
optimization flags (like -mtune). In fact, I thought there was a separate 
flag to do that (ie something like "-mload-store"), but I can't find it, 
so maybe that's just my fevered brain..

			Linus
