From: Amos Kong <kongjianjun@gmail.com>
Subject: [PATCH v3] net/hyperv: fix wrong length of mac address
Date: Sat, 19 Jan 2013 10:52:09 +0800
Message-ID: <1358563929-10942-1-git-send-email-kongjianjun@gmail.com>
References: <20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>
Cc: netdev@vger.kernel.org, devel@linuxdriverproject.org,
	Amos Kong <kongjianjun@gmail.com>
To: davem@davemloft.net, kys@microsoft.com, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab3ASCwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 21:52:09 -0500
In-Reply-To: <20130118083031.GA2303@ppwaskie-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixed wrong mac length, it should be ETH_ALEN,
also replaced the hardcode 6 in hyperv_net.h

Signed-off-by: Amos Kong <kongjianjun@gmail.com>
---
v2: update commitlog, fix cc list
v3: fix hardcode length in hyperv_net.h
---
 drivers/net/hyperv/hyperv_net.h | 2 +-
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5fd6f46..e6fe0d8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -84,7 +84,7 @@ struct hv_netvsc_packet {
 };
 
 struct netvsc_device_info {
-	unsigned char mac_adr[6];
+	unsigned char mac_adr[ETH_ALEN];
 	bool link_state;	/* 0 - link up, 1 - link down */
 	int  ring_size;
 };
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f825a62..8264f0e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -349,7 +349,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	struct net_device_context *ndevctx = netdev_priv(ndev);
 	struct hv_device *hdev =  ndevctx->device_ctx;
 	struct sockaddr *addr = p;
-	char save_adr[14];
+	char save_adr[ETH_ALEN];
 	unsigned char save_aatype;
 	int err;
 
-- 
1.7.11.7
