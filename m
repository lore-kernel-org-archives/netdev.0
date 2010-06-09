From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
	representation
Date: Wed, 9 Jun 2010 11:22:44 -0700
Message-ID: <20100609182244.GC19804@dvomlehn-lnx2.corp.sa.net>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net> <20100608084456.4da00349@nehalam> <20100609084417.GW26335@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:16886 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab0FISWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 14:22:44 -0400
Content-Disposition: inline
In-Reply-To: <20100609084417.GW26335@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 03:44:17AM -0500, Nick Piggin wrote:
> On Tue, Jun 08, 2010 at 08:44:56AM -0700, Stephen Hemminger wrote:
> > On Mon, 7 Jun 2010 17:30:52 -0700
> > David VomLehn <dvomlehn@cisco.com> wrote:
> > > History
> > > v2	Support small callsite IDs and split out out-of-band parameter
> > > 	parsing.
> > > V1	Initial release
> > > 
> > > Signed-off-by: David VomLehn <dvomlehn@cisco.com>
> > 
> > This is really Linux Kernel Mailing List material (not just netdev). And it will
> > be a hard sell to get it accepted, because it is basically an alternative call
> > tracing mechanism, and there are already several of these in use or under development
> > (see perf and ftrace).
> 
> What about a generic extension or layer on top of stacktrace that
> does caching and unique IDs for stack traces. This way you can get
> callsites or _full_ stack traces if required, and it shouldn't require
> any extra magic in the net functions.

Since the code calls BUG() when it detects an error, you already get the
full stack trace of the location where the problem is detected. The question
is the relative cost and benefits of a full stack trace of the previous
sk_buff state modification. Since I'm working in a MIPS processor
environment, I am rather prejudiced against doing any stack trace I don't
have to; for now, at least, they are *very* expensive on MIPS.

The two times this code (or its ancestor) has found problems in a deployed
software stack, the engineers reported they there were able to immediately
find and fix the problem. This suggests that we don't need to take on the
complexity of the stack backtrace, at least for now. If this gets added to
the mainline and people find they need the extra information, I'd be all
for it.

> You would need a hash for stack traces to check for an existing trace,
> and an idr to assign ids to traces.

Once you have the trace, it should be pretty easy to do this. In theory there
could be a huge number of unique stack traces, but I don't that this would
be the case in practice.
-- 
David VL
