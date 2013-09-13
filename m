From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix VF reset recovery
Date: Fri, 13 Sep 2013 06:13:47 -0400
Message-ID: <1379067227-10362-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:21746 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751589Ab3IMKoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 06:44:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o At the time of firmware hang "adapter->need_fw_reset" variable gets
  set but after re-initialization of firmware OR at the time of VF
  re-initialization that variable was not getting cleared which
  was leading to failure in VF reset recovery.Fix it by clearing
  this variable before re-initializing VF

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 652cc13..392b9bd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -1561,6 +1561,7 @@ static int qlcnic_sriov_vf_reinit_driver(struct qlcnic_adapter *adapter)
 {
 	int err;
 
+	adapter->need_fw_reset = 0;
 	qlcnic_83xx_reinit_mbx_work(adapter->ahw->mailbox);
 	qlcnic_83xx_enable_mbx_interrupt(adapter);
 
-- 
1.5.6
