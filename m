From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix netns vs. netlink table locking (2)
Date: Thu, 24 Sep 2009 15:45:44 -0700 (PDT)
Message-ID: <20090924.154544.101536082.davem@davemloft.net>
References: <1253698470.4458.48.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752739AbZIXWpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:45:25 -0400
In-Reply-To: <1253698470.4458.48.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 23 Sep 2009 11:34:30 +0200

> Similar to commit d136f1bd366fdb7e747ca7e0218171e7a00a98a5,
> there's a bug when unregistering a generic netlink family,
> which is caught by the might_sleep() added in that commit:
> 
>     BUG: sleeping function called from invalid context at net/netlink/af_netlink.c:183
>     in_atomic(): 1, irqs_disabled(): 0, pid: 1510, name: rmmod
>     2 locks held by rmmod/1510:
>      #0:  (genl_mutex){+.+.+.}, at: [<ffffffff8138283b>] genl_unregister_family+0x2b/0x130
>      #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8138270c>] __genl_unregister_mc_group+0x1c/0x120
>     Pid: 1510, comm: rmmod Not tainted 2.6.31-wl #444
>     Call Trace:
>      [<ffffffff81044ff9>] __might_sleep+0x119/0x150
>      [<ffffffff81380501>] netlink_table_grab+0x21/0x100
>      [<ffffffff813813a3>] netlink_clear_multicast_users+0x23/0x60
>      [<ffffffff81382761>] __genl_unregister_mc_group+0x71/0x120
>      [<ffffffff81382866>] genl_unregister_family+0x56/0x130
>      [<ffffffffa0007d85>] nl80211_exit+0x15/0x20 [cfg80211]
>      [<ffffffffa000005a>] cfg80211_exit+0x1a/0x40 [cfg80211]
> 
> Fix in the same way by grabbing the netlink table lock
> before doing rcu_read_lock().
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied.
