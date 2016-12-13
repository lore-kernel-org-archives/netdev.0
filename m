From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [v1] net:ethernet:cavium:octeon:octeon_mgmt: Handle return NULL error from devm_ioremap
Date: Tue, 13 Dec 2016 20:04:30 +0530
Message-ID: <1481639670-17888-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peter.chen@nxp.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34972 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932617AbcLMOey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 09:34:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here, If devm_ioremap will fail. It will return NULL.
Kernel can run into a NULL-pointer dereference.
This error check will avoid NULL pointer dereference.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index 4ab404f..4d9528f 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -1479,6 +1479,12 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	p->agl = (u64)devm_ioremap(&pdev->dev, p->agl_phys, p->agl_size);
 	p->agl_prt_ctl = (u64)devm_ioremap(&pdev->dev, p->agl_prt_ctl_phys,
 					   p->agl_prt_ctl_size);
+	if (!p->mix || !p->agl || !p->agl_prt_ctl) {
+		dev_err(dev, "failed to map I/O memory\n");
+		result = -ENOMEM;
+		goto err;
+	}
+
 	spin_lock_init(&p->lock);
 
 	skb_queue_head_init(&p->tx_list);
-- 
2.7.4
