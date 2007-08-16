From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 07:45:44 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
References: <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
 <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com>
 <20070816011414.GC9645@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
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
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58586 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbXHPCDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 22:03:22 -0400
In-Reply-To: <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Christoph Lameter wrote:

> On Wed, 15 Aug 2007, Paul E. McKenney wrote:
> 
> > Understood.  My point is not that the impact is precisely zero, but
> > rather that the impact on optimization is much less hurtful than the
> > problems that could arise otherwise, particularly as compilers become
> > more aggressive in their optimizations.
> 
> The problems arise because barriers are not used as required. Volatile 
> has wishy washy semantics and somehow marries memory barriers with data 
> access. It is clearer to separate the two. Conceptual cleanness usually 
> translates into better code. If one really wants the volatile then lets 
> make it explicit and use
> 
> 	atomic_read_volatile()

Completely agreed, again. To summarize again (had done so about ~100 mails
earlier in this thread too :-) ...

atomic_{read,set}_volatile() -- guarantees volatility also along with
atomicity (the two _are_ different concepts after all, irrespective of
whether callsites normally want one with the other or not)

atomic_{read,set}_nonvolatile() -- only guarantees atomicity, compiler
free to elid / coalesce / optimize such accesses, can keep the object
in question cached in a local register, leads to smaller text, etc.

As to which one should be the default atomic_read() is a question of
whether majority of callsites (more weightage to important / hot
codepaths, lesser to obscure callsites) want a particular behaviour.

Do we have a consensus here? (hoping against hope, probably :-)


[ This thread has gotten completely out of hand ... for my mail client
  alpine as well, it now seems. Reminds of that 1000+ GPLv3 fest :-) ]
