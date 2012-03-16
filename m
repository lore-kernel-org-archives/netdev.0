From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next] qlcnic: ethtool change to provide the dump_state information
Date: Fri, 16 Mar 2012 10:58:31 -0700
Message-ID: <1331920711-16049-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1331920711-16049-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:32975
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753795Ab2CPSMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 14:12:39 -0400
In-Reply-To: <1331920711-16049-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o dump_state will be either enabled/disabled that is 1/0

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 89ddf7f..56f7ebc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1136,6 +1136,12 @@ qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 		dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
 	else
 		dump->len = 0;
+
+	if (fw_dump->enable)
+		dump->dump_state = ETH_FW_DUMP_ENABLE;
+	else
+		dump->dump_state = ETH_FW_DUMP_DISABLE;
+
 	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
 	dump->version = adapter->fw_version;
 	return 0;
-- 
1.7.1
