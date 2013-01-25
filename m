From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 5/8] qlcnic: Fix LED/Beaconing tests to work on all ports of an adapter.
Date: Fri, 25 Jan 2013 15:20:38 -0500
Message-ID: <1359145241-5175-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49016 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752361Ab3AYUl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:26 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Provide port number in command payload for LED/Beaconing tests.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index eb1f3cc..3d84c04 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1380,7 +1380,7 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	word = QLCNIC_H2C_OPCODE_CONFIG_LED | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
 
-	req.words[0] = cpu_to_le64((u64)rate << 32);
+	req.words[0] = cpu_to_le64(((u64)rate << 32) | adapter->portnum);
 	req.words[1] = cpu_to_le64(state);
 
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-- 
1.7.1
