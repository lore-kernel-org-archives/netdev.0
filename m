From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 22:58:04 +0200
Message-ID: <cbd19eac9a1f0d22bfb0dac0ad0a4d76@kernel.crashing.org>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in> <20070815142516.GB9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708152048270.16414@enigma.security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50843 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbXHOVAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 17:00:05 -0400
In-Reply-To: <alpine.LFD.0.999.0708152048270.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> Of course, if we find there are more callers in the kernel who want 
>>> the
>>> volatility behaviour than those who don't care, we can re-define the
>>> existing ops to such variants, and re-name the existing definitions 
>>> to
>>> somethine else, say "atomic_read_nonvolatile" for all I care.
>>
>> Do we really need another set of APIs?
>
> Well, if there's one set of users who do care about volatile behaviour,
> and another set that doesn't, it only sounds correct to provide both
> those APIs, instead of forcing one behaviour on all users.

But since there currently is only one such API, and there are
users expecting the stronger behaviour, the only sane thing to
do is let the API provide that behaviour.  You can always add
a new API with weaker behaviour later, and move users that are
okay with it over to that new API.


Segher

