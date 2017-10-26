From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] tcp/dccp: fix other lockdep splats accessing
 ireq_opt
Date: Thu, 26 Oct 2017 17:42:13 +0900 (KST)
Message-ID: <20171026.174213.476814979488104324.davem@davemloft.net>
References: <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
        <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
        <1508858431.30291.112.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdJZImQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:42:16 -0400
In-Reply-To: <1508858431.30291.112.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Oct 2017 08:20:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In my first attempt to fix the lockdep splat, I forgot we could
> enter inet_csk_route_req() with a freshly allocated request socket,
> for which refcount has not yet been elevated, due to complex
> SLAB_TYPESAFE_BY_RCU rules.
> 
> We either are in rcu_read_lock() section _or_ we own a refcount on the
> request.
> 
> Correct RCU verb to use here is rcu_dereference_check(), although it is
> not possible to prove we actually own a reference on a shared
> refcount :/
> 
> In v2, I added ireq_opt_deref() helper and use in three places, to fix other
> possible splats.
 ...
> Fixes: a6ca7abe53633 ("tcp/dccp: fix lockdep splat in inet_csk_route_req()")
> Fixes: c92e8c02fe66 ("tcp/dccp: fix ireq->opt races")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Reported-by: Maciej ¯enczykowski <maze@google.com>
> ---
> v3: fix typo in predicate

Applied and queued up for -stable.
