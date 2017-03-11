From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Subject: [PATCH] Enable tx timestamping on loopback and dummy
Date: Sat, 11 Mar 2017 20:28:03 +0000
Message-ID: <20170311202753.GA26476@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:9780 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754020AbdCKU2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 15:28:02 -0500
Received: from u480fcf44e5b8574c5490.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
        by email-inbound-relay-62010.pdx2.amazon.com (8.14.7/8.14.7) with ESMTP id v2BKRxMW022564
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 20:28:00 GMT
Received: from u480fcf44e5b8574c5490.ant.amazon.com (localhost [127.0.0.1])
        by u480fcf44e5b8574c5490.ant.amazon.com (8.14.4/8.14.4/Debian-4.1ubuntu1) with ESMTP id v2BKS3aX026792
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 20:28:03 GMT
Received: (from ezegomez@localhost)
        by u480fcf44e5b8574c5490.ant.amazon.com (8.14.4/8.14.4/Submit) id v2BKS3oX026788
        for netdev@vger.kernel.org; Sat, 11 Mar 2017 20:28:03 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables testing of SO_TIMESTAMPING options by targetting localhost
addresses.

Tested on qemu using txtimestamping.c from the kernel selftests.
---
 drivers/net/dummy.c    | 1 +
 drivers/net/loopback.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2c80611..32fdc00 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -125,6 +125,7 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	dstats->tx_bytes += skb->len;
 	u64_stats_update_end(&dstats->syncp);
 
+	skb_tx_timestamp(skb);
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 122cc2d..8bcf479 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -74,6 +74,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	struct pcpu_lstats *lb_stats;
 	int len;
 
+	skb_tx_timestamp(skb);
 	skb_orphan(skb);
 
 	/* Before queueing this packet to netif_rx(),
-- 
1.9.1

Amazon Data Services Ireland Limited registered office: One Burlington Plaza, Burlington Road, Dublin 4, Ireland. Registered in Ireland. Registration number 390566.
