From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 14 Aug 2007 19:04:42 -0400
Message-ID: <46C2350A.1010807@redhat.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765118AbXHNXF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 19:05:26 -0400
In-Reply-To: <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> 
> On Tue, 14 Aug 2007, Christoph Lameter wrote:
> 
>> On Thu, 9 Aug 2007, Chris Snook wrote:
>>
>>> This patchset makes the behavior of atomic_read uniform by removing the
>>> volatile keyword from all atomic_t and atomic64_t definitions that currently
>>> have it, and instead explicitly casts the variable as volatile in
>>> atomic_read().  This leaves little room for creative optimization by the
>>> compiler, and is in keeping with the principles behind "volatile considered
>>> harmful".
>> volatile is generally harmful even in atomic_read(). Barriers control
>> visibility and AFAICT things are fine.
> 
> Frankly, I don't see the need for this series myself either. Personal
> opinion (others may differ), but I consider "volatile" to be a sad /
> unfortunate wart in C (numerous threads on this list and on the gcc
> lists/bugzilla over the years stand testimony to this) and if we _can_
> steer clear of it, then why not -- why use this ill-defined primitive
> whose implementation has often differed over compiler versions and
> platforms? Granted, barrier() _is_ heavy-handed in that it makes the
> optimizer forget _everything_, but then somebody did post a forget()
> macro on this thread itself ...
> 
> [ BTW, why do we want the compiler to not optimize atomic_read()'s in
>   the first place? Atomic ops guarantee atomicity, which has nothing
>   to do with "volatility" -- users that expect "volatility" from
>   atomic ops are the ones who must be fixed instead, IMHO. ]

Because atomic operations are generally used for synchronization, which requires 
volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
  Some forget to and we get bugs, because people assume that atomic_read() 
actually reads something, and atomic_write() actually writes something.  Worse, 
these are architecture-specific, even compiler version-specific bugs that are 
often difficult to track down.

	-- Chris
