From: Nick Piggin <piggin@cyberone.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 21:50:43 +1000
Message-ID: <46C58B93.5000408@cyberone.com.au>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de> <46C556F1.8000407@yahoo.com.au> <alpine.LFD.0.999.0708171420060.3666@enigma.security.iitk.ac.in> <46C5672E.4060003@cyberone.com.au> <alpine.LFD.0.999.0708171521230.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.icp-qv1-irony2.iinet.net.au ([203.59.1.107]:38245 "EHLO
	webmail.icp-qv1-irony2.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759944AbXHQLuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 07:50:50 -0400
In-Reply-To: <alpine.LFD.0.999.0708171521230.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:

>
>On Fri, 17 Aug 2007, Nick Piggin wrote:
>
>
>>Satyam Sharma wrote:
>>
>>It is very obvious. msleep calls schedule() (ie. sleeps), which is
>>always a barrier.
>>
>
>Probably you didn't mean that, but no, schedule() is not barrier because
>it sleeps. It's a barrier because it's invisible.
>

Where did I say it is a barrier because it sleeps?

It is always a barrier because, at the lowest level, schedule() (and thus
anything that sleeps) is defined to always be a barrier. Regardless of
whatever obscure means the compiler might need to infer the barrier.

In other words, you can ignore those obscure details because schedule() is
always going to have an explicit barrier in it.


>>The "unobvious" thing is that you wanted to know how the compiler knows
>>a function is a barrier -- answer is that if it does not *know* it is not
>>a barrier, it must assume it is a barrier.
>>
>
>True, that's clearly what happens here. But are you're definitely joking
>that this is "obvious" in terms of code-clarity, right?
>

No. If you accept that barrier() is implemented correctly, and you know
that sleeping is defined to be a barrier, then its perfectly clear. You
don't have to know how the compiler "knows" that some function contains
a barrier.


>Just 5 minutes back you mentioned elsewhere you like seeing lots of
>explicit calls to barrier() (with comments, no less, hmm? :-)
>

Sure, but there are well known primitives which contain barriers, and
trivial recognisable code sequences for which you don't need comments.
waiting-loops using sleeps or cpu_relax() are prime examples.
