From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 12:18:29 -0700
Message-ID: <20070815191829.GJ9645@linux.vnet.ibm.com>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com> <46BFFDBD.6080804@redhat.com> <46C140DD.3060509@yahoo.com.au> <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com,
	David Howells <dhowells@redhat.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:33754 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbXHOTSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 15:18:32 -0400
Content-Disposition: inline
In-Reply-To: <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 08:51:58PM +0200, Segher Boessenkool wrote:
> >Well if there is only one memory location involved, then smp_rmb() 
> >isn't
> >going to really do anything anyway, so it would be incorrect to use it.
> 
> rmb() orders *any* two reads; that includes two reads from the same
> location.

If the two reads are to the same location, all CPUs I am aware of
will maintain the ordering without need for a memory barrier.

						Thanx, Paul

> >Consider that smp_rmb basically will do anything from flushing the
> >pipeline to invalidating loads speculatively executed out of order. 
> >AFAIK
> >it will not control the visibility of stores coming from other CPUs 
> >(that
> >is up to the cache coherency).
> 
> The writer side should typically use wmb() whenever the reader side
> uses rmb(), sure.
> 
> 
> Segher
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
