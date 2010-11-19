From: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
Subject: [net-2.6 PATCH] be2net: Fix to avoid firmware update when
 interface is not open.
Date: Fri, 19 Nov 2010 15:14:45 +0530
Message-ID: <20101119094445.GA10165@emulex.com>
Reply-To: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:50731 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751559Ab0KSJqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 04:46:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since interrupts are enabled only when open is called on the interface,
Attempting a firmware update operation when interface is down could lead to
partial success or failure of operation. This fix fails the request if
netif_running is false.

Signed-off-by: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
---
 drivers/net/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c36cd2f..93354ee 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2458,6 +2458,12 @@ int be_load_fw(struct be_adapter *adapte
 	int status, i = 0, num_imgs = 0;
 	const u8 *p;
 
+	if (!netif_running(adapter->netdev)) {
+		dev_err(&adapter->pdev->dev,
+			"Firmware load not allowed (interface is down)\n");
+		return -EPERM;
+	}
+
 	strcpy(fw_file, func);
 
 	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
-- 
1.4.0

