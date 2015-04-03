From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: move fib_rules_unregister() under rtnl lock
Date: Thu, 02 Apr 2015 20:53:44 -0400 (EDT)
Message-ID: <20150402.205344.2010884938148163682.davem@davemloft.net>
References: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427824907-13331-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@redhat.com, tgraf@suug.ch
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbbDCAxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 20:53:46 -0400
In-Reply-To: <1427824907-13331-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 31 Mar 2015 11:01:46 -0700

> We have to hold rtnl lock for fib_rules_unregister()
> otherwise the following race could happen:
> 
> fib_rules_unregister():	fib_nl_delrule():
> ...				...
> ...				ops = lookup_rules_ops();
> list_del_rcu(&ops->list);
> 				list_for_each_entry(ops->rules) {
> fib_rules_cleanup_ops(ops);	  ...
>   list_del_rcu();		  list_del_rcu();
> 				}
> 
> Note, net->rules_mod_lock is actually not needed at all,
> either upper layer netns code or rtnl lock guarantees
> we are safe.
> 
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
