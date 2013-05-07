From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 8/8] qlcnic: Fix validation of link event command.
Date: Tue, 7 May 2013 15:55:06 -0400
Message-ID: <1367956506-3290-9-git-send-email-shahed.shaikh@qlogic.com>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:52562
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752695Ab3EGUUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 16:20:30 -0400
In-Reply-To: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o VF driver that has enabled asynchronous link events
  may not set BIT_8 in the request, if it does not require
  link state in the response.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index c81be2d..1a66ccd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1133,9 +1133,6 @@ static int qlcnic_sriov_validate_linkevent(struct qlcnic_vf_info *vf,
 	if ((cmd->req.arg[1] >> 16) != vf->rx_ctx_id)
 		return -EINVAL;
 
-	if (!(cmd->req.arg[1] & BIT_8))
-		return -EINVAL;
-
 	return 0;
 }
 
-- 
1.5.6
