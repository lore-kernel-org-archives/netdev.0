From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
	representation
Date: Tue, 8 Jun 2010 12:06:55 -0700
Message-ID: <20100608190655.GD31503@dvomlehn-lnx2.corp.sa.net>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net> <20100608084456.4da00349@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:13357 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322Ab0FHTGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 15:06:55 -0400
Content-Disposition: inline
In-Reply-To: <20100608084456.4da00349@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 08:44:56AM -0700, Stephen Hemminger wrote:
> On Mon, 7 Jun 2010 17:30:52 -0700
> David VomLehn <dvomlehn@cisco.com> wrote:
> 
> > This patch allows the location of a call to be recorded as a small integer,
> > with each call location ("callsite") assigned a new value the first time
> > the code in that location is executed. Locations can be recorded as a
> > an address or as a __FILE__/__LINE__ pair. The later is easier to read, but
> > requires significantly more space.
> > 
> > The goal here was to record the location in very few bits but, at the same
> > time, to have minimal overhead.  The key observation towards achieving this
> > goals is to note that there are are far fewer locations where calls of
> > interest are made than there are addresses. If the site of each call of
> > interest is assigned a unique ID, and there are fewer than n of them,
> > only log2(n) bits are required to identify the call site. If the IDs
> > are assigned dynamically and most call sites aren't reached, you can get
> > by with even fewer bits.
...
> This is really Linux Kernel Mailing List material (not just netdev). 

I'll submit revisions to there, as well.

> And it will
> be a hard sell to get it accepted, because it is basically an alternative call
> tracing mechanism, and there are already several of these in use or under development
> (see perf and ftrace).

The orignal code had a pointer in the sk_buff that indicated where the call
was made. I've replaced this with an index. The only time you see the call
location is when an error is detected and it is displayed with printk(); there
is no effort to stream information nor do I think this is useful.  Does that
make this a tracing mechanism? It certainly wasn't the way I was thinking
about it.
-- 
David VL
