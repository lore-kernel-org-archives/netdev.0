From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 9 Aug 2010 13:48:56 -0400
Message-ID: <20100809174856.GS30010@kvack.org>
References: <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org> <20091029233848.GV3141@kvack.org> <4C603999.1030801@candelatech.com> <20100809173429.GR30010@kvack.org> <4C603E6E.1060309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57093 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab0HIRs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 13:48:57 -0400
Content-Disposition: inline
In-Reply-To: <4C603E6E.1060309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 09, 2010 at 10:44:14AM -0700, Ben Greear wrote:
> We also have a few rules per interface, and notice that it takes around 10ms
> per rule when we are removing them, even when using batching in 'ip':
...
> Patrick thought had an idea, but I don't think he had time to
> look at it further:
> 
> "Its probably the synchronize_rcu() in fib_nl_delrule() and
> the route flushing happening after rule removal."

Yes, that would be a problem, but the issue is deeper than that -- if I'm 
not mistaken it's on the packet processing path that iptables doesn't scale 
for 100k interfaces with 1 rule per interface.  It's been a while since I 
ran the tests, but I don't think it's changed much.

		-ben
