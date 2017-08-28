From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: set dst.obsolete when a cached route has
 expired
Date: Mon, 28 Aug 2017 15:45:39 -0700 (PDT)
Message-ID: <20170828.154539.1594777445985915210.davem@davemloft.net>
References: <cd3d9312a3d31ee72b9377e7200898c30f73ab8e.1503749410.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdH1Wpk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:45:40 -0400
In-Reply-To: <cd3d9312a3d31ee72b9377e7200898c30f73ab8e.1503749410.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 26 Aug 2017 20:10:10 +0800

> Now it doesn't check for the cached route expiration in ipv6's
> dst_ops->check(), because it trusts dst_gc that would clean the
> cached route up when it's expired.
> 
> The problem is in dst_gc, it would clean the cached route only
> when it's refcount is 1. If some other module (like xfrm) keeps
> holding it and the module only release it when dst_ops->check()
> fails.
> 
> But without checking for the cached route expiration, .check()
> may always return true. Meanwhile, without releasing the cached
> route, dst_gc couldn't del it. It will cause this cached route
> never to expire.
> 
> This patch is to set dst.obsolete with DST_OBSOLETE_KILL in .gc
> when it's expired, and check obsolete != DST_OBSOLETE_FORCE_CHK
> in .check.
> 
> Note that this is even needed when ipv6 dst_gc timer is removed
> one day. It would set dst.obsolete in .redirect and .update_pmtu
> instead, and check for cached route expiration when getting it,
> just like what ipv4 route does.
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
