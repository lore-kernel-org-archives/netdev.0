From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] net: thunderx: Fix error return code in nicvf_open()
Date: Wed, 11 Jan 2017 16:32:51 +0000
Message-ID: <20170111163251.19367-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33810 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdAKQc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:32:58 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so54139278pgc.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 08:32:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Fixes: 712c31853440 ("net: thunderx: Program LMAC credits based on MTU")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 273eafd..a25bb6e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1274,7 +1274,8 @@ int nicvf_open(struct net_device *netdev)
 	/* Configure receive side scaling and MTU */
 	if (!nic->sqs_mode) {
 		nicvf_rss_init(nic);
-		if (nicvf_update_hw_max_frs(nic, netdev->mtu))
+		err = nicvf_update_hw_max_frs(nic, netdev->mtu);
+		if (err)
 			goto cleanup;
 
 		/* Clear percpu stats */
