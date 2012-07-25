From: David Miller <davem@davemloft.net>
Subject: Re: open sockets preventing unregister_netdevice from completing
 in linux-next (next-20120724)
Date: Wed, 25 Jul 2012 15:17:37 -0700 (PDT)
Message-ID: <20120725.151737.1807149851147342859.davem@davemloft.net>
References: <87boj4hs3k.fsf@nemi.mork.no>
	<1343227128.2626.11157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab2GYWRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:17:38 -0400
In-Reply-To: <1343227128.2626.11157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jul 2012 16:38:48 +0200

> Yes, we miss what was done with rt_cache_flush() : find all cached
> routes and release all dev references...

We can fix this with a two-pronged approach:

1) Walk the FIB info nexthops and invalidate.

2) Entries not cached in the FIB info nexthops go into a
   per-netns list which is scanned as well.

I'll try to work on this if nobody beats me to it.
