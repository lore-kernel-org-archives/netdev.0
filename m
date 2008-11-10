From: Mike Galbraith <efault@gmx.de>
Subject: Re: [regression]  benchmark throughput loss from a622cf6..f7160c7
	pull
Date: Mon, 10 Nov 2008 14:22:10 +0100
Message-ID: <1226323330.4846.3.camel@marge.simson.net>
References: <1226313350.10058.16.camel@marge.simson.net>
	 <20081110125001.GA28643@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Miklos Szeredi <mszeredi@suse.cz>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Travis <travis@sgi.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34579 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754290AbYKJNWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 08:22:15 -0500
In-Reply-To: <20081110125001.GA28643@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-10 at 13:50 +0100, Ingo Molnar wrote:
> * Mike Galbraith <efault@gmx.de> wrote:
> 
> > Greetings,
> > 
> > While retesting that recent scheduler fixes/improvements had 
> > survived integration into mainline, I found that we've regressed a 
> > bit since.. yesterday.  In testing, it seems that CFS has finally 
> > passed what the old O(1) scheduler could deliver in scalability and 
> > throughput, but we already lost a bit.
> 
> but CFS backported to a kernel with no other regressions measurably 
> surpasses O(1) performance in all the metrics you are following, 
> right?

Yes.

> i.e. the current state of things, when comparing these workloads to 
> 2.6.22 is that we slowed down in non-scheduler codepaths and the CFS 
> speedups helps offset some of that slowdown.

That's the way it looks to me, yes.

> But not all of it, and we also have new slowdowns:
> 
> > Reverting 984f2f3 cd83e42 2d3854a and 6209344 recovered the loss.
> 
> hm, that's two changes in essence:
> 
>  2d3854a: cpumask: introduce new API, without changing anything
>  6209344: net: unix: fix inflight counting bug in garbage collector
> 
> i'm surprised about the cpumask impact, it's just new APIs in essence, 
> with little material changes elsewhere.

Dunno, I try not to look while testing, just test/report, look later.

	-Mike

