From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] netns:  Simplify the network namespace list locking rules.
Date: Thu, 27 Sep 2007 09:21:56 +0400
Message-ID: <46FB3DF4.10309@sw.ru>
References: <46F3C777.7070103@sw.ru> <m1r6kkrce0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:53018 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752571AbXI0FVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 01:21:20 -0400
In-Reply-To: <m1r6kkrce0.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
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
Acked-by: Denis V. Lunev <den@openvz.org>
