From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 17:40:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708151736180.10497@schroedinger.engr.sgi.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
 <18115.39815.730873.346526@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:55902 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937402AbXHPAkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 20:40:35 -0400
In-Reply-To: <18115.39815.730873.346526@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007, Paul Mackerras wrote:

> Those barriers are for when we need ordering between atomic variables
> and other memory locations.  An atomic variable by itself doesn't and
> shouldn't need any barriers for other CPUs to be able to see what's
> happening to it.

It does not need any barriers. As soon as one cpu acquires the 
cacheline for write it will be invalidated in the caches of the others. So 
the other cpu will have to refetch. No need for volatile.

The issue here may be that the compiler has fetched the atomic variable 
earlier and put it into a register. However, that prefetching is limited 
because it cannot cross functions calls etc. The only problem could be 
loops where the compiler does not refetch the variable since it assumes 
that it does not change and there are no function calls in the body of the 
loop. But AFAIK these loops need cpu_relax and other measures anyways to 
avoid bad effects from busy waiting.

