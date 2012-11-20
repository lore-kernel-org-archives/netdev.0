From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] net: fix build failure in xilinx
Date: Tue, 20 Nov 2012 15:23:13 -0500
Message-ID: <50ABE6B1.7060308@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Xiaotian Feng <dannyfeng@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42573 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab2KTUXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 15:23:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 71c6c837 (drivers/net: fix tasklet misuse issue) introduced a
build failure in the xilinx driver. axienet_dma_err_handler isn't
declared before its use in axienet_open.

This patch provides the prototype before axienet_open.

Cc: Xiaotian Feng <dannyfeng@tencent.com>
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -894,6 +894,8 @@ out:
 	return IRQ_HANDLED;
 }
 
+static void axienet_dma_err_handler(unsigned long data);
+
 /**
  * axienet_open - Driver open routine.
  * @ndev:	Pointer to net_device structure


--
Jeff Mahoney
SUSE Labs
