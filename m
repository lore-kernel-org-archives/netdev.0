From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/flow: remove sleeping and deferral mechanism from
 flow_cache_flush
Date: Tue, 27 Sep 2011 15:28:36 -0400 (EDT)
Message-ID: <20110927.152836.1747700807304689813.davem@davemloft.net>
References: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, timo.teras@iki.fi
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab1I0T2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:28:47 -0400
In-Reply-To: <1317056956-23644-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Mon, 26 Sep 2011 20:09:16 +0300

> flow_cache_flush must not sleep as it can be called in atomic context;
> removed the schedule_work as the deferred processing lead to the flow
> cache gc never being actually run under heavy network load
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>

How is this called in an atomic context?  The only caller of
flow_cache_flush() is __xfrm_garbage_collect() which is only invoked
during a NETDEV_DOWN event which ought to be non-atomic.

afinfo->garbage_collect is the only other place __xfrm_garbage_collect
is referenced, and that is completely unused and should thus be deleted
(I'll take care of that in net-next).

If NETDEV_DOWN notifier is in an atomic context, we need to accomodate
or fix that somehow.
