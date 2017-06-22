From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: only call ip6_route_dev_notify() once for
 NETDEV_UNREGISTER
Date: Thu, 22 Jun 2017 11:07:23 -0400 (EDT)
Message-ID: <20170622.110723.1095460318299544942.davem@davemloft.net>
References: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffy.chen@rock-chips.com,
        dsahern@gmail.com
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbdFVPHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:07:40 -0400
In-Reply-To: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 20 Jun 2017 11:42:27 -0700

> In commit 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> I assumed NETDEV_REGISTER and NETDEV_UNREGISTER are paired,
> unfortunately, as reported by jeffy, netdev_wait_allrefs()
> could rebroadcast NETDEV_UNREGISTER event until all refs are
> gone.
> 
> We have to add an additional check to avoid this corner case.
> For netdev_wait_allrefs() dev->reg_state is NETREG_UNREGISTERED,
> for dev_change_net_namespace(), dev->reg_state is
> NETREG_REGISTERED. So check for dev->reg_state != NETREG_UNREGISTERED.
> 
> Fixes: 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> Reported-by: jeffy <jeffy.chen@rock-chips.com>
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
