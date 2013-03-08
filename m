From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 06/11] firewire net: Clear dev->broadcast_rcv_context
 and dev->broadcast_state after destruction of context.
Date: Fri, 08 Mar 2013 10:42:59 +0900
Message-ID: <51394223.3000504@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39215 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755826Ab3CHBnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:43:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear dev->broadcast_rcv_context to NULL and set dev->broadcast_state
to FWNET_BROADCAST_ERROR after descruction of broadcast context.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index d9b2105..efed4a6 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1626,11 +1626,14 @@ static int fwnet_remove(struct device *_dev)
 		fwnet_fifo_stop(dev);
 		if (dev->broadcast_rcv_context) {
 			fw_iso_context_stop(dev->broadcast_rcv_context);
+
 			kfree(dev->broadcast_rcv_buffer_ptrs);
 			dev->broadcast_rcv_buffer_ptrs = NULL;
 			fw_iso_buffer_destroy(&dev->broadcast_rcv_buffer,
 					      dev->card);
 			fw_iso_context_destroy(dev->broadcast_rcv_context);
+			dev->broadcast_rcv_context = NULL;
+			dev->broadcast_state = FWNET_BROADCAST_ERROR;
 		}
 		for (i = 0; dev->queued_datagrams && i < 5; i++)
 			ssleep(1);
-- 
1.7.9.5
