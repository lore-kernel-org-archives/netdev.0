From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 3/3] qlcnic: Fix protcol type in case of inband vlan.
Date: Wed,  6 Jun 2012 13:35:08 -0400
Message-ID: <1339004108-7356-4-git-send-email-anirban.chakraborty@qlogic.com>
References: <1339004108-7356-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47331 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756352Ab2FFRuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 13:50:52 -0400
In-Reply-To: <1339004108-7356-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Use correct l3 (ETH_IP or ETH_IPV6)protcol in case
of inband vlan. Because of incorrect protcol type driver
was setting incorrect opcode. This resulted in adapter calculating
checksum incorrectly.
o Updated driver version to 5.0.29

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index df4552f..eaa1db9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 28
-#define QLCNIC_LINUX_VERSIONID  "5.0.28"
+#define _QLCNIC_LINUX_SUBVERSION 29
+#define QLCNIC_LINUX_VERSIONID  "5.0.29"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 707b5ca..33c3e46 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2033,6 +2033,7 @@ qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
 		vh = (struct vlan_ethhdr *)skb->data;
 		flags = FLAGS_VLAN_TAGGED;
 		vlan_tci = vh->h_vlan_TCI;
+		protocol = ntohs(vh->h_vlan_encapsulated_proto);
 	} else if (vlan_tx_tag_present(skb)) {
 		flags = FLAGS_VLAN_OOB;
 		vlan_tci = vlan_tx_tag_get(skb);
-- 
1.7.4.1
