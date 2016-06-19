From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/5] qed: Correct default vlan behavior
Date: Sun, 19 Jun 2016 15:18:11 +0300
Message-ID: <1466338695-15538-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49978 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751725AbcFSMSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:31 -0400
In-Reply-To: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When no vlan filter is configured, firmware has a configurable
default on whether to pass only untagged packets or all packets
regardless of their tagging. Driver currently doesn't set this
field in the necessary ramrod, causing the default to always be
'receive all'.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 8fba87dd..1aaea83 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -72,6 +72,7 @@ int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->mtu			= cpu_to_le16(p_params->mtu);
 	p_ramrod->inner_vlan_removal_en	= p_params->remove_inner_vlan;
 	p_ramrod->drop_ttl0_en		= p_params->drop_ttl0;
+	p_ramrod->untagged		= p_params->only_untagged;
 
 	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_UCAST_DROP_ALL, 1);
 	SET_FIELD(rx_mode, ETH_VPORT_RX_MODE_MCAST_DROP_ALL, 1);
-- 
1.9.3
