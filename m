From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: move TCQ_F_THROTTLED flag
Date: Thu, 20 Jan 2011 16:56:42 -0800 (PST)
Message-ID: <20110120.165642.170095653.davem@davemloft.net>
References: <1295518636.2825.4.camel@edumazet-laptop>
	<1295531299.2825.175.camel@edumazet-laptop>
	<1295537236.2825.286.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, hawk@diku.dk,
	jarkao2@gmail.com, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754874Ab1AUA4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:56:08 -0500
In-Reply-To: <1295537236.2825.286.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jan 2011 16:27:16 +0100

> In commit 371121057607e (net: QDISC_STATE_RUNNING dont need atomic bit
> ops) I moved QDISC_STATE_RUNNING flag to __state container, located in
> the cache line containing qdisc lock and often dirtied fields.
> 
> I now move TCQ_F_THROTTLED bit too, so that we let first cache line read
> mostly, and shared by all cpus. This should speedup HTB/CBQ for example.
> 
> Not using test_bit()/__clear_bit()/__test_and_set_bit allows to use an
> "unsigned int" for __state container, reducing by 8 bytes Qdisc size.
> 
> Introduce helpers to hide implementation details.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
