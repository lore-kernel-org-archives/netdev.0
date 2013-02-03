From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] inet: Get critical word in first 64bit of
 cache line
Date: Sun, 03 Feb 2013 16:08:55 -0500 (EST)
Message-ID: <20130203.160855.1118626925419072868.davem@davemloft.net>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	<1359817435.30177.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ling.ma.program@gmail.com, netdev@vger.kernel.org, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab3BCVI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:08:57 -0500
In-Reply-To: <1359817435.30177.70.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Feb 2013 07:03:55 -0800

> From: Ma Ling <ling.ma.program@gmail.com>
> 
> In order to reduce memory latency when last level cache miss occurs,
> modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
> Early Restart(ER) to get data ASAP. For CWF if critical word is first
> member
> in cache line, memory feed CPU with critical word, then fill others
> data in cache line one by one, otherwise after critical word it must
> cost more cycle to fill the remaining cache line. For Early First CPU
> will restart until critical word in cache line reaches.
> 
> Hash value is critical word, so in this patch we place it as first
> member in cache line (sock address is cache-line aligned), and it is
> also good for Early Restart platform as well .
> 
> [edumazet: respin on net-next after commit ce43b03e8889]
> 
> Signed-off-by: Ma Ling <ling.ma.program@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I completely agree with the other response to this patch in that
the description is bogus.

If CWF is implemented in the cpu, it should exactly relieve us from
having to move things around in structures so carefully like this.

Either the patch should be completely dropped (modern cpus don't
need this) or the commit message changed to reflect reality.

It really makes a terrible impression upon me when the patch says
something which in fact is 180 degrees from reality.
