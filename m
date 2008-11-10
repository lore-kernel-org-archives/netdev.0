From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression]  benchmark throughput loss from a622cf6..f7160c7
	pull
Date: Mon, 10 Nov 2008 13:50:01 +0100
Message-ID: <20081110125001.GA28643@elte.hu>
References: <1226313350.10058.16.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Miklos Szeredi <mszeredi@suse.cz>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Travis <travis@sgi.com>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:44766 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbYKJMu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 07:50:27 -0500
Content-Disposition: inline
In-Reply-To: <1226313350.10058.16.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Mike Galbraith <efault@gmx.de> wrote:

> Greetings,
> 
> While retesting that recent scheduler fixes/improvements had 
> survived integration into mainline, I found that we've regressed a 
> bit since.. yesterday.  In testing, it seems that CFS has finally 
> passed what the old O(1) scheduler could deliver in scalability and 
> throughput, but we already lost a bit.

but CFS backported to a kernel with no other regressions measurably 
surpasses O(1) performance in all the metrics you are following, 
right?

i.e. the current state of things, when comparing these workloads to 
2.6.22 is that we slowed down in non-scheduler codepaths and the CFS 
speedups helps offset some of that slowdown.

But not all of it, and we also have new slowdowns:

> Reverting 984f2f3 cd83e42 2d3854a and 6209344 recovered the loss.

hm, that's two changes in essence:

 2d3854a: cpumask: introduce new API, without changing anything
 6209344: net: unix: fix inflight counting bug in garbage collector

i'm surprised about the cpumask impact, it's just new APIs in essence, 
with little material changes elsewhere.

	Ingo
