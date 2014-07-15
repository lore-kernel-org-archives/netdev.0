From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 3/3] bonding: add proper __rcu annotation for
 curr_active_slave
Date: Tue, 15 Jul 2014 12:38:58 +0200
Message-ID: <20140715103858.GD28235@mikrodark.usersys.redhat.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
 <1405417604-7828-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:51931 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758038AbaGOKl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 06:41:57 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so1897750wes.8
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 03:41:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405417604-7828-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 02:46:44AM -0700, Eric Dumazet wrote:
>RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.
>
>Using __rcu annotation actually helps to spot all accesses to bond->curr_active_slave
>are correctly protected, with LOCKDEP support.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks a lot for cleaning this up, it's really a huge mess here...

One question though:

...snip...
>@@ -2046,7 +2051,7 @@ static void bond_miimon_commit(struct bonding *bond)
> 				bond_alb_handle_link_change(bond, slave,
> 							    BOND_LINK_DOWN);
>
>-			if (slave == bond->curr_active_slave)
>+			if (slave == rcu_access_pointer(bond->curr_active_slave))

I guess you've meant rtnl_dereference()? As bond_miimon_commit() is ujnder
rtnl, not under rcu.

> 				goto do_failover;
>
> 			continue;
