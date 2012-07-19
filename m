From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/16] ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 15:13:12 -0700 (PDT)
Message-ID: <20120719.151312.1882340232448320251.davem@davemloft.net>
References: <20120719.143540.747492487297004222.davem@davemloft.net>
	<1342735743.2626.5411.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab2GSWNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 18:13:13 -0400
In-Reply-To: <1342735743.2626.5411.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jul 2012 00:09:03 +0200

> If we find orig not null, what can protect another cpu from reading
> nh->nh_rth_output, then we dst_release(orig), and other cpu  does the
> dst_use() too late ?

Indeed, we'd have to defer it somehow.

Actually, we might be able to fake this by using __dst_free() on it
or something similar.

But safest would be RCU, whose protection we are still using on the
read side.

Any better ideas?
