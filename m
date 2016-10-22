From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: use the right lock for ping_group_range
Date: Sat, 22 Oct 2016 16:24:12 -0400 (EDT)
Message-ID: <20161022.162412.770873082924010369.davem@davemloft.net>
References: <1476998386-20935-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, salo@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754877AbcJVUYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 16:24:13 -0400
In-Reply-To: <1476998386-20935-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 20 Oct 2016 14:19:46 -0700

> This reverts commit a681574c99be23e4d20b769bf0e543239c364af5
> ("ipv4: disable BH in set_ping_group_range()") because we never
> read ping_group_range in BH context (unlike local_port_range).
> 
> Then, since we already have a lock for ping_group_range, those
> using ip_local_ports.lock for ping_group_range are clearly typos.
> 
> We might consider to share a same lock for both ping_group_range
> and local_port_range w.r.t. space saving, but that should be for
> net-next.
> 
> Fixes: a681574c99be ("ipv4: disable BH in set_ping_group_range()")
> Fixes: ba6b918ab234 ("ping: move ping_group_range out of CONFIG_SYSCTL")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Eric Salo <salo@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
