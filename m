From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] tcp: add generic netlink support for tcp_metrics
Date: Tue, 04 Sep 2012 15:47:08 -0400 (EDT)
Message-ID: <20120904.154708.2099268692603008096.davem@davemloft.net>
References: <1346564178-1794-2-git-send-email-ja@ssi.bg>
	<1346633144.2563.97.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1209031041340.1663@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757696Ab2IDTrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:47:10 -0400
In-Reply-To: <alpine.LFD.2.00.1209031041340.1663@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 3 Sep 2012 11:22:15 +0300 (EEST)

> 	BTW, is it appropriate to use kmem_cache for
> metrics and as result call_rcu for freeing?

I think it would work as things are implemented currently in
slab/slub/slob, however I would not rely upon it.

If you do move to a SLAB cache for the tcp metrics objects,
you might consider SLAB_DESTROY_BY_RCU.  It's a very delicate
facility (read the huge comment in linux/slab.h) but I think
it provides the semantics we need for TCP metrics blobs.

Looking forward to v3 :-)
