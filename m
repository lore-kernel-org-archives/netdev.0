From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] route: move lwtunnel state to a single place
Date: Mon, 25 Apr 2016 16:20:22 -0400 (EDT)
Message-ID: <20160425.162022.201046855400100518.davem@davemloft.net>
References: <c59d9a13e4171a887d6dd2acdce216c51a006993.1461321556.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lrichard@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964774AbcDYUUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:20:25 -0400
In-Reply-To: <c59d9a13e4171a887d6dd2acdce216c51a006993.1461321556.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 22 Apr 2016 12:40:02 +0200

> Commit 751a587ac9f9 ("route: fix breakage after moving lwtunnel state")
> moved lwtstate to the end of dst_entry for 32bit archs. This makes it share
> the cacheline with __refcnt which had an unkown effect on performance. For
> this reason, the pointer was kept in place for 64bit archs.
> 
> However, later performance measurements showed this is of no concern. It
> turns out that every performance sensitive path that accesses lwtstate
> accesses also struct rtable or struct rt6_info which share the same cache
> line.
> 
> Thus, to get rid of a few #ifdefs, move the field to the end of the struct
> also for 64bit.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Fair enough, applied, thanks Jiri.
