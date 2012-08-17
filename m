From: Ilya Shchepetkov <shchepetkov@ispras.ru>
Subject: Re: [PATCH] net: Fix incorrect comment in netif_tx_stop_queue()
Date: Fri, 17 Aug 2012 12:01:44 +0400
Message-ID: <1345190504-12184-1-git-send-email-shchepetkov@ispras.ru>
References: <20120814.144623.1855051650444819552.davem@davemloft.net>
Cc: Ilya Shchepetkov <shchepetkov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814.144623.1855051650444819552.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > netif_stop_queue() can be called before register_netdev() because now
> > TX queues are allocated inside alloc_netdev_mqs().
> > 
> > (since ed9af2e839c06c18f721da2c768fbb444c4a10e5 commit)
> > 
> > Found by Linux Driver Verification project (linuxtesting.org).
> > 
> > Signed-off-by: Ilya Shchepetkov <shchepetkov@ispras.ru>
> 
> You're not changing a "comment", you're changing a kernel log message.
> 
> Have you actually triggered this condition?
> 
> I doubt it, and I'm not applying this patch.

My test driver calls netif_carrier_off before register_netdev and works
well,
without "netif_stop_queue() cannot be called before register_netdev()"
message.

Also, there are drivers that call netif_tx_stop_queue directly
and possible error message (with a reference to netif_stop_queue) will
be wrong.

Look at these commits:
e6484930d7c73d324bccda7d43d131088da697b9
18543a643fae694982c7d89c22436885f3506497
ed9af2e839c06c18f721da2c768fbb444c4a10e5

After the third commit, the second one became unnecessary.

Thus, I suggest either to remove the misleading message, or to replace
it with this:

pr_info("netif_tx_stop_queue(): dev_queue is null()\n");
