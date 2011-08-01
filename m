From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT] Networking
Date: Mon, 1 Aug 2011 17:13:08 +0200
Message-ID: <20110801151308.GA31256@elte.hu>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:50564 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab1HAPOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 11:14:05 -0400
Content-Disposition: inline
In-Reply-To: <20110722.073339.1236244143490935644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

>       forcedeth: do vlan cleanup

Trying to bring latest -git into latest -tip today i managed to 
bisect back to a pretty bad networking breakage on one of my 
testboxes back to this commit - where i have discovered that it has 
been fixed freshly.

This bug cost me multiple days of debugging so here's a bit of a post 
mortem.

The bit that IMO wasnt very optimal was the timing of the merge path:

 -                  AuthorDate: Wed Jul 20 04:54:38 2011 +0000
 -                  CommitDate: Thu Jul 21 13:47:57 2011 -0700
 - tree Linus merge CommitDate: Fri Jul 22 14:43:13 2011 -0700
 -        first lkml bugreport: Sun Jul 24 16:10:59 2011 -0700
 -              fix CommitDate: Wed Jul 27 22:39:30 2011 -0700
 - fix  Linus merge CommitDate: Thu Jul 28 05:58:19 2011 -0700

So you can see that the commit was committed to net-next within 24 
hours of it being submitted, the (bad) breakage was not discovered 
until 4 days down the road.

I submit that *no one* with real forcedeth hardware actually tested 
this commit before it hit upstream. It has not touched linux-next 
before going to Linus and it took 8 days for the fix to get upstream.

If the latency of common driver bugfixes is on the order of 1 week 
then the golden rule is that commits must be tested for at least 1 
week as well. One day of testing was *way* too short.

Furthermore, the changelog of the fix:

 0891b0e08937: forcedeth: fix vlans

Doesn't contain any reference to the bisection work done by
walt <w41ter@gmail.com> nor by any of the other bugreporters.

So this really sucked all around - could we please improve on it?

Thanks,

	Ingo
