From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH 1/3] dev: Prevent creating network devices with negative ifindex
Date: Fri, 16 Jun 2017 17:23:51 +0300
Message-ID: <d365b6f06598d041a177b91b15929285c2649935.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34930 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754001AbdFPOYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 10:24:21 -0400
Received: by mail-lf0-f66.google.com with SMTP id v20so4379438lfa.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 07:24:20 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id z10sm486566lja.6.2017.06.16.07.24.18
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 07:24:19 -0700 (PDT)
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interface index is signed integer, we can pass ifm->ifi_index
from userspace via netlink and create network device with
negative ifindex value.

Fixes: 9c7dafbfab15 ("net: Allow to create links with given ifindex")
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8658074..dae8010 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7491,7 +7491,7 @@ int register_netdevice(struct net_device *dev)
 	}
 
 	ret = -EBUSY;
-	if (!dev->ifindex)
+	if (dev->ifindex <= 0)
 		dev->ifindex = dev_new_index(net);
 	else if (__dev_get_by_index(net, dev->ifindex))
 		goto err_uninit;
-- 
1.8.3.1
