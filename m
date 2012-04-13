From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 37/37] atl1c: cancel task when interface closed
Date: Fri, 13 Apr 2012 08:15:02 +0800
Message-ID: <1334276102-15866-38-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:48642 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966618Ab2DMAUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 20:20:54 -0400
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

common_task might be running while close routine is called,
wait/cancel it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 4b9865b..55a7eed 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2313,6 +2313,7 @@ static int atl1c_close(struct net_device *netdev)
 
 	WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));
 	atl1c_down(adapter);
+	cancel_work_sync(&adapter->common_task);
 	atl1c_free_ring_resources(adapter);
 	return 0;
 }
-- 
1.7.7
