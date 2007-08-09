From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 24/24] document volatile atomic_read() behavior
Date: Thu, 9 Aug 2007 21:42:01 +0200
Message-ID: <0a08872e608cf5f7a3d9c0fc746a1051@kernel.crashing.org>
References: <20070809142430.GA19817@shell.boston.redhat.com> <8f6bb8a9e4f2819a161d732bdb6c70c0@kernel.crashing.org> <46BB403D.10202@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	schwidefsky@de.ibm.com, davem@davemloft.net, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50600 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbXHITsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 15:48:00 -0400
In-Reply-To: <46BB403D.10202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> Explicit
>>> +casting in atomic_read() ensures consistent behavior across 
>>> architectures
>>> +and compilers.
>> Even modulo compiler bugs, what makes you believe that?
>
> When you declare a variable volatile, you don't actually tell the 
> compiler where you want to override its default optimization behavior, 
> giving it some freedom to guess your intentions incorrectly.  When you 
> put the cast on the data access itself, there is no question about 
> precisely where in the code you want to override the compiler's 
> default optimization behavior.

...except for the small point that this isn't how volatile works.

Rule of thumb: even people who know the semantics of volatile
shouldn't use it.

> If the compiler doesn't do what you want with a volatile declaration, 
> it might have a plausible excuse in the ambiguity of the C standard.  
> If the compiler doesn't do what you want in a cast specific to a 
> single dereference, it's just plain broken.

The other way around.  "volatile" has pretty weak semantics, and
certainly not the semantics you think it has, or that you wish it
had; but *(volatile XX *) doesn't have *any* semantics.  However
much you cast that pointer it still doesn't point to a volatile
object.

GCC will generally take the path of least surprise and perform a
volatile access anyway, but this has only be decided recently (a
year ago or so), and there very likely still are some bugs in
that area.

> We try to be compatible with plausibly correct compilers, but if 
> they're completely broken, we're screwed no matter what.

If you don't know what to expect, you're screwed for sure.


Anyway, what's the supposed advantage of *(volatile *) vs. using
a real volatile object?  That you can access that same object in
a non-volatile way?


Segher

