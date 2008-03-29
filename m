From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Sat, 29 Mar 2008 13:52:28 +0100
Message-ID: <47EE3B8C.8090707@gmail.com>
References: <20080328000013.GA8193@codemonkey.org.uk>	 <20080328.173414.22278840.davem@davemloft.net>	 <1206752049.22530.105.camel@johannes.berg>	 <20080328.180631.91055366.davem@davemloft.net> <1206784948.22530.128.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:2778 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbYC2Mqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 08:46:38 -0400
Received: by fg-out-1718.google.com with SMTP id l27so781721fgb.17
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 05:46:37 -0700 (PDT)
In-Reply-To: <1206784948.22530.128.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote, On 03/29/2008 11:02 AM:

... 
> When you call cancel_work_sync(), the work struct will be grabbed by the
> code (really __cancel_work_timer) and removed from the queue. That just
> operates on bits and a spinlock, not locks held across the struct work
> function execution, and ensures it is race-free without needing any such
> locks

...

> However, as I just tried to explain, cancel_work_sync() _is_ safe to run
> while holding the RTNL because it doesn't need any runqueue lock.

These issues are so seldom now that I forget these details each time

"after use", so maybe I miss something again, but shouldn't this rather
read something like this?:

cancel_work_sync() _is_ safe to run while holding the RTNL against
works which don't take RTNL.

Regards,
Jarek P.
