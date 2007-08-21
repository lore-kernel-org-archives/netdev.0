From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Mon, 20 Aug 2007 22:46:47 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708202244520.30176@woody.linux-foundation.org>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
 <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
 <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org>
 <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au>
 <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in>
 <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in>
 <46C56ADF.8010501@cyberone.com.au> <alpine.LFD.0.999.0708171612440.3666@enigma.security.iitk.ac.in>
 <46C59717.4020108@cyberone.com.au> <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
 <46C993DF.4080400@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35559 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752322AbXHUFtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 01:49:17 -0400
In-Reply-To: <46C993DF.4080400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 20 Aug 2007, Chris Snook wrote:
>
> What about barrier removal?  With consistent semantics we could optimize a
> fair amount of code.  Whether or not that constitutes "premature" optimization
> is open to debate, but there's no question we could reduce our register wiping
> in some places.

Why do people think that barriers are expensive? They really aren't. 
Especially the regular compiler barrier is basically zero cost. Any 
reasonable compiler will just flush the stuff it holds in registers that 
isn't already automatic local variables, and for regular kernel code, that 
tends to basically be nothing at all.

Ie a "barrier()" is likely _cheaper_ than the code generation downside 
from using "volatile".

		Linus
