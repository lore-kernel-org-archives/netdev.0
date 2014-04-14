From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 4/6] qlcnic: Fix PVID configuration on eSwitch port.
Date: Mon, 14 Apr 2014 10:02:21 -0400
Message-ID: <1397484143-9708-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:26342 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752540AbaDNOkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:40:01 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Clear older PVID before adding a newer PVID to the eSwicth port

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index a81ad50..c1e11f5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -1354,6 +1354,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 			arg2 &= ~BIT_3;
 		break;
 	case QLCNIC_ADD_VLAN:
+			arg1 &= ~(0x0ffff << 16);
 			arg1 |= (BIT_2 | BIT_5);
 			arg1 |= (esw_cfg->vlan_id << 16);
 			break;
-- 
1.8.1.4
