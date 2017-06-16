From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH 3/3] veth: Set ifindex only if given and not negative
Date: Fri, 16 Jun 2017 17:23:53 +0300
Message-ID: <86924b2059b7460b8998fac46f0d7262d7c358d4.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33110 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753832AbdFPOYX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 10:24:23 -0400
Received: by mail-lf0-f65.google.com with SMTP id u62so4370779lfg.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 07:24:22 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id z10sm486566lja.6.2017.06.16.07.24.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 07:24:20 -0700 (PDT)
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is already check for ifindex being non negative in
register_netdevice(). Do the same here for convenience.

Fixes: e6f8f1a739b6 ("veth: Allow to create peer link with given ifindex")
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 drivers/net/veth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0156fe8..0689433 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -405,7 +405,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	if (tbp[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(peer);
 
-	if (ifmp && (dev->ifindex != 0))
+	if (ifmp && dev->ifindex > 0)
 		peer->ifindex = ifmp->ifi_index;
 
 	err = register_netdevice(peer);
-- 
1.8.3.1
