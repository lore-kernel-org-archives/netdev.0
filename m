From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/5] qlcnic: Fix function return error check
Date: Fri, 21 Feb 2014 01:23:04 -0500
Message-ID: <1392963788-18341-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:5201 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbaBUG6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 01:58:30 -0500
In-Reply-To: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was treating -ve return value as success in case of
qlcnic_enable_msi_legacy() failure

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index ba78c74..149c4b6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -818,7 +818,7 @@ static int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter)
 			qlcnic_disable_multi_tx(adapter);
 
 			err = qlcnic_enable_msi_legacy(adapter);
-			if (!err)
+			if (err)
 				return err;
 		}
 	}
-- 
1.8.1.4
