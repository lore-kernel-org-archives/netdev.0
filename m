From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH 2/2] loopback: bringup 'lo' by default at initialization
Date: Tue,  4 Jul 2017 12:16:23 -0700
Message-ID: <20170704191623.6583-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biederman <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34029 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdGDTQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 15:16:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id j186so28407007pge.1
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 12:16:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

loopback devices are always brought up right after its initialization
including the case of network namespace creation. e.g.

    ip netns add foo
    ip -netns foo link set lo up

This patch will eliminate the need to do that separately and would bring
it up as part of the loopback initialization.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/loopback.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 30612497643c..3216977935d1 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -217,6 +217,12 @@ static __net_init int loopback_net_init(struct net *net)
 
 	BUG_ON(dev->ifindex != LOOPBACK_IFINDEX);
 	net->loopback_dev = dev;
+
+	/* Set the loopback device UP */
+	rtnl_lock();
+	dev_open(net->loopback_dev);
+	rtnl_unlock();
+
 	return 0;
 
 out_free_netdev:
-- 
2.13.2.725.g09c95d1e9-goog
