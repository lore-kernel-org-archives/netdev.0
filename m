From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Fix enviroment variable for udev event generation during FW dump
Date: Fri, 29 Jul 2011 16:30:25 -0700
Message-ID: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:25747
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753058Ab1G2Xjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 19:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver was not generating the environment variable for the FW dump event correctly.
Fix it by formatting it properly.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 4055c21..74e9d7b 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1773,8 +1773,8 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		goto error;
 	} else {
 		fw_dump->clr = 1;
-		snprintf(mesg, sizeof(mesg), "FW dump for device: %d\n",
-			adapter->pdev->devfn);
+		snprintf(mesg, sizeof(mesg), "FW_DUMP=%s",
+			adapter->netdev->name);
 		dev_info(&adapter->pdev->dev, "Dump data, %d bytes captured\n",
 			fw_dump->size);
 		/* Send a udev event to notify availability of FW dump */
-- 
1.7.4.1


