From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: avoid unregistering inet6_dev for loopback
Date: Thu, 22 Jun 2017 13:24:49 -0400 (EDT)
Message-ID: <20170622.132449.27833256808523188.davem@davemloft.net>
References: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, dlezcano@fr.ibm.com,
        dsahern@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751598AbdFVRYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:24:51 -0400
In-Reply-To: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 21 Jun 2017 14:34:58 -0700

> The per netns loopback_dev->ip6_ptr is unregistered and set to
> NULL when its mtu is set to smaller than IPV6_MIN_MTU, this
> leads to that we could set rt->rt6i_idev NULL after a
> rt6_uncached_list_flush_dev() and then crash after another
> call.
> 
> In this case we should just bring its inet6_dev down, rather
> than unregistering it, at least prior to commit 176c39af29bc
> ("netns: fix addrconf_ifdown kernel panic") we always
> override the case for loopback.
> 
> Thanks a lot to Andrey for finding a reliable reproducer.
> 
> Fixes: 176c39af29bc ("netns: fix addrconf_ifdown kernel panic")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Daniel Lezcano <dlezcano@fr.ibm.com>
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
