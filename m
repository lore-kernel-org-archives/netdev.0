From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH 1/2] qlcnic: Add default swtich case in 'qlcnic_can_start_firmware()'
Date: Mon,  9 Apr 2012 11:29:47 +0530
Message-ID: <1333951187-4395-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: sony.chacko@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: anirban.chakraborty@qlogic.com, rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:65249 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab2DIGBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 02:01:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

QLCRD32() may return bad state.
Its good to have default switch case:
	1. to avoid unexpected system behaviour.
	2. to avoid extra computation thats happening
	   after switch case.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 75c32e8..d30b9b8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2787,6 +2787,11 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	case QLCNIC_DEV_INITIALIZING:
 	case QLCNIC_DEV_QUISCENT:
 		break;
+
+	default:
+		dev_err(&adapter->pdev->dev, "Invalid state\n");
+		qlcnic_api_unlock(adapter);
+		return -EINVAL;
 	}
 
 	qlcnic_api_unlock(adapter);
-- 
1.7.4.4
