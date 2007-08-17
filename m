From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 13:08:26 +0200
Message-ID: <46C581AA.7020807@s5r6.in-berlin.de>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <18117.1287.779351.836552@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org> <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au> <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in> <46C55E90.7010407@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:45182 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758915AbXHQLI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 07:08:28 -0400
In-Reply-To: <46C55E90.7010407@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nick Piggin wrote:
> Satyam Sharma wrote:
>> And we have driver / subsystem maintainers such as Stefan
>> coming up and admitting that often a lot of code that's written to use
>> atomic_read() does assume the read will not be elided by the compiler.
> 
> So these are broken on i386 and x86-64?

The ieee1394 and firewire subsystems have open, undiagnosed bugs, also
on i386 and x86-64.  But whether there is any bug because of wrong
assumptions about atomic_read among them, I don't know.  I don't know
which assumptions the authors made, I only know that I wasn't aware of
all the properties of atomic_read until now.

> Are they definitely safe on SMP and weakly ordered machines with
> just a simple compiler barrier there? Because I would not be
> surprised if there are a lot of developers who don't really know
> what to assume when it comes to memory ordering issues.
> 
> This is not a dig at driver writers: we still have memory ordering
> problems in the VM too (and probably most of the subtle bugs in
> lockless VM code are memory ordering ones). Let's not make up a
> false sense of security and hope that sprinkling volatile around
> will allow people to write bug-free lockless code. If a writer
> can't be bothered reading API documentation

...or, if there is none, the implementation specification (as in case of
the atomic ops), or, if there is none, the implementation (as in case of
a some infrastructure code here and there)...

> and learning the Linux memory model, they can still be productive
> writing safely locked code.

Provided they are aware that they might not have the full picture of the
lockless primitives.  :-)
-- 
Stefan Richter
-=====-=-=== =--- =---=
http://arcgraph.de/sr/
