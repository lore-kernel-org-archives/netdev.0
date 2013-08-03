From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/8] qlcnic: Fix MAC address filter issue on 82xx adapter
Date: Fri, 2 Aug 2013 23:15:54 -0400
Message-ID: <1375499761-21141-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59763 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750695Ab3HCEAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 00:00:30 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was passing the address of a pointer instead of
the pointer itself.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index d3f8797..82a03d3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -262,7 +262,7 @@ void qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter, u64 *uaddr,
 
 	mac_req = (struct qlcnic_mac_req *)&(req->words[0]);
 	mac_req->op = vlan_id ? QLCNIC_MAC_VLAN_ADD : QLCNIC_MAC_ADD;
-	memcpy(mac_req->mac_addr, &uaddr, ETH_ALEN);
+	memcpy(mac_req->mac_addr, uaddr, ETH_ALEN);
 
 	vlan_req = (struct qlcnic_vlan_req *)&req->words[1];
 	vlan_req->vlan_id = cpu_to_le16(vlan_id);
-- 
1.5.6
