From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 15:33:33 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171521230.3666@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au>
 <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de>
 <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com>
 <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de>
 <46C556F1.8000407@yahoo.com.au> <alpine.LFD.0.999.0708171420060.3666@enigma.security.iitk.ac.in>
 <46C5672E.4060003@cyberone.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
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
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41953 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbXHQJvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:51:33 -0400
In-Reply-To: <46C5672E.4060003@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> > 
> > On Fri, 17 Aug 2007, Nick Piggin wrote:
> 
> > > > Sure, now
> > > > that I learned of these properties I can start to audit code and insert
> > > > barriers where I believe they are needed, but this simply means that
> > > > almost all occurrences of atomic_read will get barriers (unless there
> > > > already are implicit but more or less obvious barriers like msleep).
> > > 
> > > You might find that these places that appear to need barriers are
> > > buggy for other reasons anyway. Can you point to some in-tree code
> > > we can have a look at?
> > 
> > 
> > Such code was mentioned elsewhere (query nodemgr_host_thread in cscope)
> > that managed to escape the requirement for a barrier only because of
> > some completely un-obvious compilation-unit-scope thing. But I find such
> > an non-explicit barrier quite bad taste. Stefan, do consider plunking an
> > explicit call to barrier() there.
> 
> It is very obvious. msleep calls schedule() (ie. sleeps), which is
> always a barrier.

Probably you didn't mean that, but no, schedule() is not barrier because
it sleeps. It's a barrier because it's invisible.

> The "unobvious" thing is that you wanted to know how the compiler knows
> a function is a barrier -- answer is that if it does not *know* it is not
> a barrier, it must assume it is a barrier.

True, that's clearly what happens here. But are you're definitely joking
that this is "obvious" in terms of code-clarity, right?

Just 5 minutes back you mentioned elsewhere you like seeing lots of
explicit calls to barrier() (with comments, no less, hmm? :-)
