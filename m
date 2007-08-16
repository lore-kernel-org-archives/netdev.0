From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 11:54:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708161151270.17049@schroedinger.engr.sgi.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
 <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
	segher@kernel.crashing.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:60603 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758646AbXHPSy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 14:54:56 -0400
In-Reply-To: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007, Paul Mackerras wrote:

> The uses of atomic_read where one might want it to allow caching of
> the result seem to me to fall into 3 categories:
> 
> 1. Places that are buggy because of a race arising from the way it's
>    used.
> 
> 2. Places where there is a race but it doesn't matter because we're
>    doing some clever trick.
> 
> 3. Places where there is some locking in place that eliminates any
>    potential race.
> 
> In case 1, adding volatile won't solve the race, of course, but it's
> hard to argue that we shouldn't do something because it will slow down
> buggy code.  Case 2 is hopefully pretty rare and accompanied by large
> comment blocks, and in those cases caching the result of atomic_read
> explicitly in a local variable would probably make the code clearer.
> And in case 3 there is no reason to use atomic_t at all; we might as
> well just use an int.

In 2 + 3 you may increment the atomic variable in some places. The value 
of the atomic variable may not matter because you only do optimizations.

Checking a atomic_t for a definite state has to involve either
some side conditions (lock only taken if refcount is <= 0 or so) or done 
by changing the state (see f.e. atomic_inc_unless_zero).

> So I don't see any good reason to make the atomic API more complex by
> having "volatile" and "non-volatile" versions of atomic_read.  It
> should just have the "volatile" behaviour.

If you want to make it less complex then drop volatile which causes weird 
side effects without solving any problems as you just pointed out.
