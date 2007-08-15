From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 15:11:29 +0200
Message-ID: <46C2FB81.8040307@s5r6.in-berlin.de>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
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
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:38193 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbXHONLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 09:11:30 -0400
In-Reply-To: <46C2FADB.7020407@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote:
> static inline void A(atomic_t *a)
> {
> 	int b = atomic_read(a);
> 	if (b)
> 		do_something_time_consuming();
> }
> 
> static inline void B(atomic_t *a)
> {
> 	int b = atomic_read(a);
> 	if (b)
> 		do_something_more();
> }
> 
> static void C(atomic_t *a)
> {
> 	A(a);
> 	B(b);
	/* ^ typo */
	B(a);
> }
> 
> Would this need forget(a) after A(a)?
> 
> (Is the latter actually answered in C99 or is it compiler-dependent?)


-- 
Stefan Richter
-=====-=-=== =--- -====
http://arcgraph.de/sr/
