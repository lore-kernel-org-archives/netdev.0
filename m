From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 03:42:11 -0700 (PDT)
Message-ID: <20120810.034211.994338127277150687.davem@davemloft.net>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab2HJKmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 06:42:12 -0400
In-Reply-To: <1344590824.31104.1953.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Aug 2012 11:27:04 +0200

> NETDEV_UNREGISTER_BATCH seems unused we can probably remove it.

Indeed, the routing cache was the final real user.

> I am tracking a device refcount issue, delaying net device dismantle by
> 1 second in netdev_wait_allrefs()
> 
> I guess we need to add a notifier called _after_ the final
> synchronize_net() in rollback_registered_many()

It's essentially caused by DST_GC_INC, right?
