From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 1/4] qlcnic: Fix potential NULL dereference
Date: Tue,  2 Apr 2013 11:34:40 -0400
Message-ID: <1364916883-10109-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24856 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761342Ab3DBP5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:57:51 -0400
In-Reply-To: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[net-next:master 301/302] drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:563
 qlcnic_set_multi() error: potential null dereference 'cur'. (kzalloc returns null)

o Break out of the loop after memory allocation failure. Program all the
  MAC addresses that were cached in the return path.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index ddc130b..253b3ac 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -560,6 +560,8 @@ void qlcnic_set_multi(struct net_device *netdev)
 			netdev_for_each_mc_addr(ha, netdev) {
 				cur = kzalloc(sizeof(struct qlcnic_mac_list_s),
 					      GFP_ATOMIC);
+				if (cur == NULL)
+					break;
 				memcpy(cur->mac_addr,
 				       ha->addr, ETH_ALEN);
 				list_add_tail(&cur->list, &adapter->vf_mc_list);
-- 
1.6.3.3
