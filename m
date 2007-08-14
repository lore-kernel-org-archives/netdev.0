From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 14 Aug 2007 16:26:22 -0700
Message-ID: <20070814232622.GG8243@linux.vnet.ibm.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:49320 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760635AbXHNX03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 19:26:29 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 04:38:54AM +0530, Satyam Sharma wrote:
> 
> 
> On Tue, 14 Aug 2007, Christoph Lameter wrote:
> 
> > On Thu, 9 Aug 2007, Chris Snook wrote:
> > 
> > > This patchset makes the behavior of atomic_read uniform by removing the
> > > volatile keyword from all atomic_t and atomic64_t definitions that currently
> > > have it, and instead explicitly casts the variable as volatile in
> > > atomic_read().  This leaves little room for creative optimization by the
> > > compiler, and is in keeping with the principles behind "volatile considered
> > > harmful".
> > 
> > volatile is generally harmful even in atomic_read(). Barriers control
> > visibility and AFAICT things are fine.
> 
> Frankly, I don't see the need for this series myself either. Personal
> opinion (others may differ), but I consider "volatile" to be a sad /
> unfortunate wart in C (numerous threads on this list and on the gcc
> lists/bugzilla over the years stand testimony to this) and if we _can_
> steer clear of it, then why not -- why use this ill-defined primitive
> whose implementation has often differed over compiler versions and
> platforms? Granted, barrier() _is_ heavy-handed in that it makes the
> optimizer forget _everything_, but then somebody did post a forget()
> macro on this thread itself ...
> 
> [ BTW, why do we want the compiler to not optimize atomic_read()'s in
>   the first place? Atomic ops guarantee atomicity, which has nothing
>   to do with "volatility" -- users that expect "volatility" from
>   atomic ops are the ones who must be fixed instead, IMHO. ]

Interactions between mainline code and interrupt/NMI handlers on the same
CPU (for example, when both are using per-CPU variables.  See examples
previously posted in this thread, or look at the rcu_read_lock() and
rcu_read_unlock() implementations in http://lkml.org/lkml/2007/8/7/280.

						Thanx, Paul
