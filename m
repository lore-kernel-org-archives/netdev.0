From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Sun, 12 Aug 2007 23:03:02 -0700
Message-ID: <20070813060302.GF13410@linux.vnet.ibm.com>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, dhowells@redhat.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42823 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712AbXHMGDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:03:08 -0400
Content-Disposition: inline
In-Reply-To: <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 01:15:52PM +0800, Herbert Xu wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > On Sat, Aug 11, 2007 at 08:54:46AM +0800, Herbert Xu wrote:
> >> Chris Snook <csnook@redhat.com> wrote:
> >> > 
> >> > cpu_relax() contains a barrier, so it should do the right thing.  For 
> >> > non-smp architectures, I'm concerned about interacting with interrupt 
> >> > handlers.  Some drivers do use atomic_* operations.
> >> 
> >> What problems with interrupt handlers? Access to int/long must
> >> be atomic or we're in big trouble anyway.
> > 
> > Reordering due to compiler optimizations.  CPU reordering does not
> > affect interactions with interrupt handlers on a given CPU, but
> > reordering due to compiler code-movement optimization does.  Since
> > volatile can in some cases suppress code-movement optimizations,
> > it can affect interactions with interrupt handlers.
> 
> If such reordering matters, then you should use one of the
> *mb macros or barrier() rather than relying on possibly
> hidden volatile cast.

If communicating among CPUs, sure.  However, when communicating between
mainline and interrupt/NMI handlers on the same CPU, the barrier() and
most expecially the *mb() macros are gross overkill.  So there really
truly is a place for volatile -- not a large place, to be sure, but a
place nonetheless.

						Thanx, Paul
