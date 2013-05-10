From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] virtio_net: use default napi weight by default
Date: Fri, 10 May 2013 13:50:51 +0800
Message-ID: <1368165051-11476-1-git-send-email-amwang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab3EJFu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 May 2013 01:50:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 82dc3c63c692b1e1d5937(net: introduce NAPI_POLL_WEIGHT)
we warn drivers when they use napi weight higher than NAPI_POLL_WEIGHT,
but virtio_net still uses 128 by default. This patch makes its default
value to NAPI_POLL_WEIGHT.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3c23fdc..655bb25 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -28,7 +28,7 @@
 #include <linux/slab.h>
 #include <linux/cpu.h>
 
-static int napi_weight = 128;
+static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
 
 static bool csum = true, gso = true;
