From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Mon, 01 Sep 2014 15:35:59 -0700 (PDT)
Message-ID: <20140901.153559.1200380977792272217.davem@davemloft.net>
References: <1409601942.21965.23.camel@localhost>
	<20140901.145646.174847768842584425.davem@davemloft.net>
	<1409610669.21965.55.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	john.r.fastabend@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaIAWgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:36:01 -0400
In-Reply-To: <1409610669.21965.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 02 Sep 2014 00:31:09 +0200

> I am afraid that TX-lock is per nic-queue and it won't work out that
> easy because skbs for different queues can reside in a Qdisc.

Batching will help mostly when netif_queue_start() triggers, when we
are in steady state stopping and re-starting the txq.

What we really care about are the qdisc <--> txq one to one
relationship which is by far the most common case.

In the multiple txq to qdisc case, we still can benefit because
packets for one txq will still tend to bunch op and give deferral
opportunities.
