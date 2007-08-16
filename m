From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 04:07:01 +0200
Message-ID: <e21c163fdfa7f2fa9428816d6ba69671@kernel.crashing.org>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51652 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbXHPCJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:09:02 -0400
In-Reply-To: <18115.44462.622801.683446@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> A volatile default would disable optimizations for atomic_read.
>> atomic_read without volatile would allow for full optimization by the
>> compiler. Seems that this is what one wants in many cases.
>
> Name one such case.
>
> An atomic_read should do a load from memory.  If the programmer puts
> an atomic_read() in the code then the compiler should emit a load for
> it, not re-use a value returned by a previous atomic_read.  I do not
> believe it would ever be useful for the compiler to collapse two
> atomic_read statements into a single load.

An atomic_read() implemented as a "normal" C variable read would
allow that read to be combined with another "normal" read from
that variable.  This could perhaps be marginally useful, although
I'd bet you cannot see it unless counting cycles on a simulator
or counting bits in the binary size.

With an asm() implementation, the compiler can not do this; with
a "volatile" implementation (either volatile variable or volatile-cast),
this invokes undefined behaviour (in both C and GCC).


Segher

