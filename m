From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 2/5] qlcnic: reset loopback mode if promiscous mode setting fails.
Date: Fri, 28 Oct 2011 15:57:12 -0700
Message-ID: <1319842636-14936-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:56471
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933783Ab1J1XJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 19:09:52 -0400
In-Reply-To: <1319842636-14936-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

If promiscous mode setting fails, reset loopback mode setting in firmware.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 74e9d7b..bcb81e4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -566,7 +566,7 @@ int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 		return -EIO;
 
 	if (qlcnic_nic_set_promisc(adapter, VPORT_MISS_MODE_ACCEPT_ALL)) {
-		qlcnic_set_fw_loopback(adapter, mode);
+		qlcnic_set_fw_loopback(adapter, 0);
 		return -EIO;
 	}
 
-- 
1.7.4.1
