From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 5/7] gtp: Initialize 64-bit per-cpu stats correctly
Date: Tue,  1 Aug 2017 12:11:10 -0700
Message-ID: <20170801191113.8754-6-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org (open list:GTP (GPRS Tunneling
        Protocol)), linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35489 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752074AbdHATLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 15:11:39 -0400
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that by using netdev_alloc_pcpu_stats() instead of an open coded
allocation.

Fixes: 459aa660eb1d ("gtp: add initial driver for datapath of GPRS Tunneling Protocol (GTP-U)")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/gtp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1542e837fdfa..f38e32a7ec9c 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -364,7 +364,7 @@ static int gtp_dev_init(struct net_device *dev)
 
 	gtp->dev = dev;
 
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-- 
2.9.3
