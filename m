From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 5/9] qlcnic: Fix panic while setting VF's MAC address
Date: Fri, 19 Jul 2013 16:56:30 -0400
Message-ID: <1374267394-27697-6-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:40783 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751971Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o "qlcnic_sriov" structure pointer should be accessed only
  when SR-IOV is enabled. Access this pointer after SR-IOV
  PF check.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index ee0c1d3..b9b88f3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1621,13 +1621,15 @@ int qlcnic_sriov_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
-	int i, num_vfs = sriov->num_vfs;
+	int i, num_vfs;
 	struct qlcnic_vf_info *vf_info;
 	u8 *curr_mac;
 
 	if (!qlcnic_sriov_pf_check(adapter))
 		return -EOPNOTSUPP;
 
+	num_vfs = sriov->num_vfs;
+
 	if (!is_valid_ether_addr(mac) || vf >= num_vfs)
 		return -EINVAL;
 
-- 
1.7.1
