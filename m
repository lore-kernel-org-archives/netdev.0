From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 6/7] cxgb4: Inform caller if driver didn't upgrade firmware
Date: Wed, 26 Sep 2012 18:09:41 +0530
Message-ID: <1348663182-20190-7-git-send-email-vipul@chelsio.com>
References: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com, felix@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9552 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755984Ab2IZMnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:43:31 -0400
In-Reply-To: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a card had already been initialized, on reloading cxgb4 driver firmware
required an upgrade but the upgrade did not happen. In that case a mailbox
timeout would occur during T4 configuration file stuff. The fix is to let the
caller know the firmware was not upgraded so a reset would be issued before
starting the T4 config stuff.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b9cd08d..a3f866d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -933,7 +933,13 @@ static int upgrade_fw(struct adapter *adap)
 		if (!ret)
 			dev_info(dev, "firmware upgraded to version %pI4 from "
 				 FW_FNAME "\n", &hdr->fw_ver);
+	} else {
+		/*
+		 * Tell our caller that we didn't upgrade the firmware.
+		 */
+		ret = -EINVAL;
 	}
+
 out:	release_firmware(fw);
 	return ret;
 }
-- 
1.7.1
