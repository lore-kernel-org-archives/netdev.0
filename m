From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: revert 8728c544a9c ("net: dev_pick_tx() fix")
Date: Fri, 30 Aug 2013 17:48:37 -0400 (EDT)
Message-ID: <20130830.174837.1340852981940136289.davem@davemloft.net>
References: <1377738643.8277.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	xii@google.com, therbert@google.com, nuclearcat@nuclearcat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615Ab3H3Vsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:48:46 -0400
In-Reply-To: <1377738643.8277.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Aug 2013 18:10:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 8728c544a9cbdc ("net: dev_pick_tx() fix") and commit
> b6fe83e9525a ("bonding: refine IFF_XMIT_DST_RELEASE capability")
> are quite incompatible : Queue selection is disabled because skb
> dst was dropped before entering bonding device.
> 
> This causes major performance regression, mainly because TCP packets
> for a given flow can be sent to multiple queues.
> 
> This is particularly visible when using the new FQ packet scheduler
> with MQ + FQ setup on the slaves.
> 
> We can safely revert the first commit now that 416186fbf8c5b
> ("net: Split core bits of netdev_pick_tx into __netdev_pick_tx")
> properly caps the queue_index.
> 
> Reported-by: Xi Wang <xii@google.com>
> Diagnosed-by: Xi Wang <xii@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
