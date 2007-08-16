From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 15:48:54 -0400
Message-ID: <46C4AA26.4060707@redhat.com>
References: <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbXHPUCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 16:02:05 -0400
In-Reply-To: <20070816081049.GA1431@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 16, 2007 at 10:06:31AM +0200, Stefan Richter wrote:
>>> Do you (or anyone else for that matter) have an example of this?
>> The only code I somewhat know, the ieee1394 subsystem, was perhaps
>> authored and is currently maintained with the expectation that each
>> occurrence of atomic_read actually results in a load operation, i.e. is
>> not optimized away.  This means all atomic_t (bus generation, packet and
>> buffer refcounts, and some other state variables)* and likewise all
>> atomic bitops in that subsystem.
> 
> Can you find an actual atomic_read code snippet there that is
> broken without the volatile modifier?

A whole bunch of atomic_read uses will be broken without the volatile 
modifier once we start removing barriers that aren't needed if volatile 
behavior is guaranteed.

barrier() clobbers all your registers.  volatile atomic_read() only 
clobbers one register, and more often than not it's a register you 
wanted to clobber anyway.

	-- Chris
