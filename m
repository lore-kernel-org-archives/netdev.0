From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 07:31:40 +0000
Message-ID: <20080813073139.GA5367@ff.dom.local>
References: <E1KT803-00086Y-00@gondolin.me.apana.org.au> <20080812.221103.91087925.davem@davemloft.net> <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:38824 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbYHMHbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 03:31:46 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1591966fgg.17
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 00:31:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813065302.GB4251@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 06:53:02AM +0000, Jarek Poplawski wrote:
...
> Thats why I still think a "common" RCU with rcu_dereference() (from
> dev_queue pointer)

I hope nobody read this literally: I mean using dev_queue pointer
for dereferencing Qdisc pointer...

> in net_tx_action() should be enough: after
> synchronize_rcu() in dev_deactivate() we are sure any qdisc_run(),
> from dev_queue_xmit() or net_tx_action() can only see and lock
> noop_qdisc. Any activities on qdisc_sleeping can't happen so no
> need to wait for this. There could be some skbs enqueued just before
> synchronize, and they could be ->reset() and ->destroy() just after,
> even without rcu_call().

BTW, this all is easy to verify: simply adding debugging waiting loops
with checking the state of qdisc_sleeping after synchronize_rcu.

Jarek P. 
