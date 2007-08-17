From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 00:09:45 +0200
Message-ID: <784250b50ba166650cbbb4de29b5559b@kernel.crashing.org>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <18117.1287.779351.836552@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.
 0708161953310.30176@woody.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	Netdev <netdev@vger.kernel.org>, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, wensong@linux-vs.org,
	wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47882 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbXHQWMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 18:12:13 -0400
In-Reply-To: <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Of course, since *normal* accesses aren't necessarily limited wrt
> re-ordering, the question then becomes one of "with regard to *what* 
> does
> it limit re-ordering?".
>
> A C compiler that re-orders two different volatile accesses that have a
> sequence point in between them is pretty clearly a buggy compiler. So 
> at a
> minimum, it limits re-ordering wrt other volatiles (assuming sequence
> points exists). It also means that the compiler cannot move it
> speculatively across conditionals, but other than that it's starting to
> get fuzzy.

This is actually really well-defined in C, not fuzzy at all.
"Volatile accesses" are a side effect, and no side effects can
be reordered with respect to sequence points.  The side effects
that matter in the kernel environment are: 1) accessing a volatile
object; 2) modifying an object; 3) volatile asm(); 4) calling a
function that does any of these.

We certainly should avoid volatile whenever possible, but "because
it's fuzzy wrt reordering" is not a reason -- all alternatives have
exactly the same issues.


Segher

