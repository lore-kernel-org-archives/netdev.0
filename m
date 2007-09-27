From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Simplify the network namespace list locking
 rules.
Date: Wed, 26 Sep 2007 22:40:22 -0700 (PDT)
Message-ID: <20070926.224022.54462669.davem@davemloft.net>
References: <46F3C777.7070103@sw.ru>
	<m1r6kkrce0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, benjamin.thery@bull.net, dev@sw.ru, den@sw.ru,
	containers@lists.osdl.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbXI0FkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:40:22 -0400
In-Reply-To: <m1r6kkrce0.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 21:54:47 -0600

> 
> Denis V. Lunev <den@sw.ru> noticed that the locking rules
> for the network namespace list are over complicated and broken.
> 
> In particular the current register_netdev_notifier currently
> does not take any lock making the for_each_net iteration racy
> with network namespace creation and destruction. Oops.
> 
> The fact that we need to use for_each_net in rtnl_unlock() when
> the rtnetlink support becomes per network namespace makes designing
> the proper locking tricky.  In addition we need to be able to call
> rtnl_lock() and rtnl_unlock() when we have the net_mutex held.
> 
> After thinking about it and looking at the alternatives carefully
> it looks like the simplest and most maintainable solution is
> to remove net_list_mutex altogether, and to use the rtnl_mutex instead.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks Eric.
