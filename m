From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] IFF_NO_QUEUE: Fix for drivers not calling
 ether_setup()
Date: Thu, 18 Feb 2016 14:57:35 -0500 (EST)
Message-ID: <20160218.145735.320352771512551627.davem@davemloft.net>
References: <1027362736.325.1455717462229.JavaMail.zimbra@efficios.com>
	<1455719863-25730-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org,
	jhs@mojatatu.com, netdev@vger.kernel.org, stable@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947644AbcBRT5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:57:36 -0500
In-Reply-To: <1455719863-25730-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 17 Feb 2016 15:37:43 +0100

> My implementation around IFF_NO_QUEUE driver flag assumed that leaving
> tx_queue_len untouched (specifically: not setting it to zero) by drivers
> would make it possible to assign a regular qdisc to them without having
> to worry about setting tx_queue_len to a useful value. This was only
> partially true: I overlooked that some drivers don't call ether_setup()
> and therefore not initialize tx_queue_len to the default value of 1000.
> Consequently, removing the workarounds in place for that case in qdisc
> implementations which cared about it (namely, pfifo, bfifo, gred, htb,
> plug and sfb) leads to problems with these specific interface types and
> qdiscs.
> 
> Luckily, there's already a sanitization point for drivers setting
> tx_queue_len to zero, which can be reused to assign the fallback value
> most qdisc implementations used, which is 1.
> 
> Fixes: 348e3435cbefa ("net: sched: drop all special handling of tx_queue_len == 0")
> Tested-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied and queued up for -stable, thanks.
