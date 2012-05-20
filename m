From: Djalal Harouni <tixxdz@opendz.org>
Subject: [PATCH] drivers/net/stmmac: seq_file fix memory leak
Date: Mon, 21 May 2012 00:55:30 +0100
Message-ID: <20120520235530.GA22698@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numidia.opendz.org ([98.142.220.152]:53722 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab2ETX7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 19:59:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use single_release() instead of seq_release() to free memory allocated
by single_open().

Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 48d56da..a27e46c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1584,7 +1584,7 @@ static const struct file_operations stmmac_rings_status_fops = {
 	.open = stmmac_sysfs_ring_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = seq_release,
+	.release = single_release,
 };
 
 static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
@@ -1656,7 +1656,7 @@ static const struct file_operations stmmac_dma_cap_fops = {
 	.open = stmmac_sysfs_dma_cap_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = seq_release,
+	.release = single_release,
 };
 
 static int stmmac_init_fs(struct net_device *dev)
-- 
1.7.1
