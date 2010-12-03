From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 2/4] qlcnic: validate eswitch config values for
 PF
Date: Thu, 2 Dec 2010 22:41:43 -0800
Message-ID: <alpine.OSX.2.00.1012022233030.19027@n6030irds86zn1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:53793 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab0LCGmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 01:42:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Currently driver set default eswitch configuration values for PF function,
instead of validating values sent by application.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 08d4b37..4e8466b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3537,9 +3537,12 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 		case QLCNIC_PORT_DEFAULTS:
 			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
 						QLCNIC_NON_PRIV_FUNC) {
-				esw_cfg[i].mac_anti_spoof = 0;
-				esw_cfg[i].mac_override = 1;
-				esw_cfg[i].promisc_mode = 1;
+				if (esw_cfg[i].mac_anti_spoof != 0)
+					return QL_STATUS_INVALID_PARAM;
+				if (esw_cfg[i].mac_override != 1)
+					return QL_STATUS_INVALID_PARAM;
+				if (esw_cfg[i].promisc_mode != 1)
+					return QL_STATUS_INVALID_PARAM;
 			}
 			break;
 		case QLCNIC_ADD_VLAN:
-- 
1.5.4.5

