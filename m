From: Nick Piggin <piggin@cyberone.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 22:56:41 +1000
Message-ID: <46C59B09.8040004@cyberone.com.au>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de> <46C556F1.8000407@yahoo.com.au> <alpine.LFD.0.999.0708171420060.3666@enigma.security.iitk.ac.in> <46C5672E.4060003@cyberone.com.au> <alpine.LFD.0.999.0708171521230.3666@enigma.security.iitk.ac.in> <46C58B93.5000408@cyberone.co
 m.au> <alpine.LFD.0.999.0708171737060.3666@enigma.security.iitk.ac.in>
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
Received: from webmail.icp-qv1-irony3.iinet.net.au ([203.59.1.108]:32270 "EHLO
	webmail.icp-qv1-irony3.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758923AbXHQM4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 08:56:48 -0400
In-Reply-To: <alpine.LFD.0.999.0708171737060.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:

>
>On Fri, 17 Aug 2007, Nick Piggin wrote:
>
>
>>Satyam Sharma wrote:
>>
>>>On Fri, 17 Aug 2007, Nick Piggin wrote:
>>>
>>>>Satyam Sharma wrote:
>>>>
>>>>It is very obvious. msleep calls schedule() (ie. sleeps), which is
>>>>always a barrier.
>>>>
>>>Probably you didn't mean that, but no, schedule() is not barrier because
>>>it sleeps. It's a barrier because it's invisible.
>>>
>>Where did I say it is a barrier because it sleeps?
>>
>
>Just below. What you wrote:
>
>
>>It is always a barrier because, at the lowest level, schedule() (and thus
>>anything that sleeps) is defined to always be a barrier.
>>
>
>"It is always a barrier because, at the lowest level, anything that sleeps
>is defined to always be a barrier".
>

... because it must call schedule and schedule is a barrier.


>>Regardless of
>>whatever obscure means the compiler might need to infer the barrier.
>>
>>In other words, you can ignore those obscure details because schedule() is
>>always going to have an explicit barrier in it.
>>
>
>I didn't quite understand what you said here, so I'll tell what I think:
>
>* foo() is a compiler barrier if the definition of foo() is invisible to
>  the compiler at a callsite.
>
>* foo() is also a compiler barrier if the definition of foo() includes
>  a barrier, and it is inlined at the callsite.
>
>If the above is wrong, or if there's something else at play as well,
>do let me know.
>

Right.


>>>>The "unobvious" thing is that you wanted to know how the compiler knows
>>>>a function is a barrier -- answer is that if it does not *know* it is not
>>>>a barrier, it must assume it is a barrier.
>>>>
>>>True, that's clearly what happens here. But are you're definitely joking
>>>that this is "obvious" in terms of code-clarity, right?
>>>
>>No. If you accept that barrier() is implemented correctly, and you know
>>that sleeping is defined to be a barrier,
>>
>
>Curiously, that's the second time you've said "sleeping is defined to
>be a (compiler) barrier".
>

_In Linux,_ sleeping is defined to be a compiler barrier.

>How does the compiler even know if foo() is
>a function that "sleeps"? Do compilers have some notion of "sleeping"
>to ensure they automatically assume a compiler barrier whenever such
>a function is called? Or are you saying that the compiler can see the
>barrier() inside said function ... nopes, you're saying quite the
>opposite below.
>

You're getting too worried about the compiler implementation. Start
by assuming that it does work ;)


>>then its perfectly clear. You
>>don't have to know how the compiler "knows" that some function contains
>>a barrier.
>>
>
>I think I do, why not? Would appreciate if you could elaborate on this.
>

If a function is not completely visible to the compiler (so it can't
determine whether a barrier could be in it or not), then it must always
assume it will contain a barrier so it always does the right thing.
