From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 23:37:21 -0400
Message-ID: <20070815233721.91032366.billfink@mindspring.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
	<Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
	<46C2D6F3.3070707@s5r6.in-berlin.de>
	<alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:39750 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933124AbXHPDhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 23:37:38 -0400
In-Reply-To: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Aug 2007, Satyam Sharma wrote:

> (C)
> $ cat tp3.c
> int a;
> 
> void func(void)
> {
> 	*(volatile int *)&a = 10;
> 	*(volatile int *)&a = 20;
> }
> $ gcc -Os -S tp3.c
> $ cat tp3.s
> ...
> movl    $10, a
> movl    $20, a
> ...

I'm curious about one minor tangential point.  Why, instead of:

	b = *(volatile int *)&a;

why can't this just be expressed as:

	b = (volatile int)a;

Isn't it the contents of a that's volatile, i.e. it's value can change
invisibly to the compiler, and that's why you want to force a read from
memory?  Why do you need the "*(volatile int *)&" construct?

						-Bill
