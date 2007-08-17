From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 20:03:55 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Satyam Sharma <satyam@infradead.org>,
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
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59802 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750800AbXHQDF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 23:05:57 -0400
In-Reply-To: <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Paul Mackerras wrote:
>
> Volatile doesn't mean it can't be reordered; volatile means the
> accesses can't be eliminated.

It also does limit re-ordering. 

Of course, since *normal* accesses aren't necessarily limited wrt 
re-ordering, the question then becomes one of "with regard to *what* does 
it limit re-ordering?".

A C compiler that re-orders two different volatile accesses that have a 
sequence point in between them is pretty clearly a buggy compiler. So at a 
minimum, it limits re-ordering wrt other volatiles (assuming sequence 
points exists). It also means that the compiler cannot move it 
speculatively across conditionals, but other than that it's starting to 
get fuzzy.

In general, I'd *much* rather we used barriers. Anything that "depends" on 
volatile is pretty much set up to be buggy. But I'm certainly also willing 
to have that volatile inside "atomic_read/atomic_set()" if it avoids code 
that would otherwise break - ie if it hides a bug.

		Linus
