From: Chris Snook <csnook@redhat.com>
Subject: Re: LDD3 pitfalls (was Re: [PATCH 0/24] make atomic_read() behave
 consistently across all architectures)
Date: Mon, 20 Aug 2007 09:28:05 -0400
Message-ID: <46C996E5.90503@redhat.com>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de> <46C556F1.8000407@yahoo.com.au> <46C703C9.9060507@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755705AbXHTN3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 09:29:16 -0400
In-Reply-To: <46C703C9.9060507@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Richter wrote:
> Nick Piggin wrote:
>> Stefan Richter wrote:
>>> Nick Piggin wrote:
>>>
>>>> I don't know why people would assume volatile of atomics. AFAIK, most
>>>> of the documentation is pretty clear that all the atomic stuff can be
>>>> reordered etc. except for those that modify and return a value.
>>>
>>> Which documentation is there?
>> Documentation/atomic_ops.txt
>>
>>
>>> For driver authors, there is LDD3.  It doesn't specifically cover
>>> effects of optimization on accesses to atomic_t.
>>>
>>> For architecture port authors, there is Documentation/atomic_ops.txt.
>>> Driver authors also can learn something from that document, as it
>>> indirectly documents the atomic_t and bitops APIs.
>>>
>> "Semantics and Behavior of Atomic and Bitmask Operations" is
>> pretty direct :)
>>
>> Sure, it says that it's for arch maintainers, but there is no
>> reason why users can't make use of it.
> 
> 
> Note, LDD3 page 238 says:  "It is worth noting that most of the other
> kernel primitives dealing with synchronization, such as spinlock and
> atomic_t operations, also function as memory barriers."
> 
> I don't know about Linux 2.6.10 against which LDD3 was written, but
> currently only _some_ atomic_t operations function as memory barriers.
> 
> Besides, judging from some posts in this thread, saying that atomic_t
> operations dealt with synchronization may not be entirely precise.

atomic_t is often used as the basis for implementing more sophisticated 
synchronization mechanisms, such as rwlocks.  Whether or not they are designed 
for that purpose, the atomic_* operations are de facto synchronization primitives.

	-- Chris
