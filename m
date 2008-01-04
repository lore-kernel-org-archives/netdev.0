From: David Miller <davem@davemloft.net>
Subject: Re: lockless pagecache Cassini regression
Date: Fri, 04 Jan 2008 03:58:31 -0800 (PST)
Message-ID: <20080104.035831.52071724.davem@davemloft.net>
References: <20080103.193245.15134133.davem@davemloft.net>
	<20080104113351.GA12706@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: npiggin@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbYADL6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:58:31 -0500
In-Reply-To: <20080104113351.GA12706@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Piggin <npiggin@suse.de>
Date: Fri, 4 Jan 2008 12:33:52 +0100

> Just for interest, the lockless pagecache actually makes
> page->_count unstable for all pages that _have ever_ been pagecache
> pages (since the last quiescent rcu state, anyway). Basically, it
> looks up and takes a ref on the struct page without ever having a
> prior pin or reference on that page. It can do this because it knows
> the struct page won't actually get freed. After taking the ref, it
> rechecks that it has got the right page...

Ok, I understand the needs now.

I think the way the drivers/net/niu.c driver handles things
would work better.  It only performs get_page(), atomic
increments on compound_head(page)->_count, and __free_page().
Is that all legal with the lockless pagecache?

If so I can likely rework the Cassini page management to
behave similarly.

> Acked-by: Nick Piggin <npiggin@suse.de>

Thanks for reviewing.
