From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bonding: restrict the data protected by
 rcu_read_lock
Date: Tue, 12 Jul 2016 11:03:07 -0700 (PDT)
Message-ID: <20160712.110307.488699512483774239.davem@davemloft.net>
References: <1468308497-5384-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jay.vosburgh@canonical.com
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcGLSDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:03:09 -0400
In-Reply-To: <1468308497-5384-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>
Date: Tue, 12 Jul 2016 15:28:17 +0800

> In this function, origin is a pointer to struct aggregator.
> No matter what agg is changed to, it has nothing to do with origin.
> 
> CC: Jay Vosburgh <jay.vosburgh@canonical.com>
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>

I really hate changes like this.

Imagine if a inner function was called with RCU protection around
it, as a rule.

That's the same as what is happening here, the RCU locking is done
around the entire contents of the function and that is perfectly
fine even if one variable assignment or whatever is superfluously
contained inside of it.

I'm not applying this patch, sorry.
