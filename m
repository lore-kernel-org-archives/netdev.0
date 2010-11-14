From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] net: bnx2x: fix error value sign
Date: Sun, 14 Nov 2010 23:08:34 +0300
Message-ID: <1289765315-6028-1-git-send-email-segoon@openwall.com>
Cc: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37539 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530Ab0KNUIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 15:08:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_init_one() should return negative value on error.
By mistake it returns ENODEV instead of -ENODEV.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.

 drivers/net/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 4a6f0ea..be52edc 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9064,7 +9064,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	default:
 		pr_err("Unknown board_type (%ld), aborting\n",
 			   ent->driver_data);
-		return ENODEV;
+		return -ENODEV;
 	}
 
 	cid_count += CNIC_CONTEXT_USE;
-- 
1.7.0.4

