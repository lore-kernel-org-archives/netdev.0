From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 05/11] firewire net: Fix memory leakage in fwnet_remove().
Date: Fri, 08 Mar 2013 10:42:50 +0900
Message-ID: <5139421A.6020905@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39209 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755826Ab3CHBmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:42:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 9a2634a..d9b2105 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1626,6 +1626,8 @@ static int fwnet_remove(struct device *_dev)
 		fwnet_fifo_stop(dev);
 		if (dev->broadcast_rcv_context) {
 			fw_iso_context_stop(dev->broadcast_rcv_context);
+			kfree(dev->broadcast_rcv_buffer_ptrs);
+			dev->broadcast_rcv_buffer_ptrs = NULL;
 			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
 					      dev->card);
 			fw_iso_context_destroy(dev->broadcast_rcv_context);
-- 
1.7.9.5
