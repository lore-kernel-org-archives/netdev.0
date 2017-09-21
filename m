From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid a full fib lookup when rp_filter
 is disabled.
Date: Thu, 21 Sep 2017 15:15:36 -0700 (PDT)
Message-ID: <20170921.151536.638017079860512925.davem@davemloft.net>
References: <597db26b5e57eb89d2ff27454cce997fa6c0f5aa.1505924560.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWPh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:15:37 -0400
In-Reply-To: <597db26b5e57eb89d2ff27454cce997fa6c0f5aa.1505924560.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 20 Sep 2017 18:26:53 +0200

> Since commit 1dced6a85482 ("ipv4: Restore accept_local behaviour
> in fib_validate_source()") a full fib lookup is needed even if
> the rp_filter is disabled, if accept_local is false - which is
> the default.
> 
> What we really need in the above scenario is just checking
> that the source IP address is not local, and in most case we
> can do that is a cheaper way looking up the ifaddr hash table.
> 
> This commit adds a helper for such lookup, and uses it to
> validate the src address when rp_filter is disabled and no
> 'local' routes are created by the user space in the relevant
> namespace.
> 
> A new ipv4 netns flag is added to account for such routes.
> We need that to preserve the same behavior we had before this
> patch.
> 
> It also drops the checks to bail early from __fib_validate_source,
> added by the commit 1dced6a85482 ("ipv4: Restore accept_local
> behaviour in fib_validate_source()") they do not give any
> measurable performance improvement: if we do the lookup with are
> on a slower path.
> 
> This improves UDP performances for unconnected sockets
> when rp_filter is disabled by 5% and also gives small but
> measurable performance improvement for TCP flood scenarios.
> 
> v1 -> v2:
>  - use the ifaddr lookup helper in __ip_dev_find(), as suggested
>    by Eric
>  - fall-back to full lookup if custom local routes are present
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Looks good, applied, thanks!
