From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Fri, 10 Aug 2007 21:29:43 -0700
Message-ID: <20070811042943.GA13410@linux.vnet.ibm.com>
References: <46BCC26B.6080600@redhat.com> <E1IJfFe-0003Sq-00@gondolin.me.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, dhowells@redhat.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:54698 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbXHKE3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Aug 2007 00:29:55 -0400
Content-Disposition: inline
In-Reply-To: <E1IJfFe-0003Sq-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 11, 2007 at 08:54:46AM +0800, Herbert Xu wrote:
> Chris Snook <csnook@redhat.com> wrote:
> > 
> > cpu_relax() contains a barrier, so it should do the right thing.  For 
> > non-smp architectures, I'm concerned about interacting with interrupt 
> > handlers.  Some drivers do use atomic_* operations.
> 
> What problems with interrupt handlers? Access to int/long must
> be atomic or we're in big trouble anyway.

Reordering due to compiler optimizations.  CPU reordering does not
affect interactions with interrupt handlers on a given CPU, but
reordering due to compiler code-movement optimization does.  Since
volatile can in some cases suppress code-movement optimizations,
it can affect interactions with interrupt handlers.

						Thanx, Paul
