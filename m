From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH] loopback: Force LOOPBACK_IFINDEX for registration
Date: Fri, 16 Jun 2017 15:10:03 +0300
Message-ID: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34983 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752619AbdFPMKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 08:10:18 -0400
Received: by mail-lf0-f68.google.com with SMTP id v20so3986455lfa.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 05:10:17 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id j19sm554008lfk.67.2017.06.16.05.10.15
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 05:10:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now with commit 9c7dafb (net: Allow to create links with
given ifindex) support registration of network devices
with specific ifindex is added.

We can force loopback network device index before call to
register_netdev() to ensure we always configure it with
LOOPBACK_IFINDEX.

Kill BUG_ON() since system can continue without network
namespace failed in loopback init path, unless it is
init_net namespace where we panic() anyway.

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 drivers/net/loopback.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 3061249..d7233aa 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -210,12 +210,13 @@ static __net_init int loopback_net_init(struct net *net)
 	if (!dev)
 		goto out;
 
+	dev->ifindex = LOOPBACK_IFINDEX;
+
 	dev_net_set(dev, net);
 	err = register_netdev(dev);
 	if (err)
 		goto out_free_netdev;
 
-	BUG_ON(dev->ifindex != LOOPBACK_IFINDEX);
 	net->loopback_dev = dev;
 	return 0;
 
-- 
1.8.3.1
