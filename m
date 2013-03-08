From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 01/11] firewire net: No need to reset dev->local_fifo
 after failure of fw_core_add_address_handler().
Date: Fri, 08 Mar 2013 10:42:07 +0900
Message-ID: <513941EF.5070805@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39182 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752804Ab3CHBmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:42:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fwnet_broadcast_start() try to register address handler at first
if it was not registered yet; dev->local_fifo ==
FWNET_NO_FIFO_ADDR.

Since dev->local_info not changed if fw_core_add_address_hander()
has failed, we do not need to set dev->local_info to
FWNET_NO_FIFO_ADDR.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2b27bff..a7a0e82 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1220,8 +1220,8 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
 	fw_core_remove_address_handler(&dev->handler);
- failed_initial:
 	dev->local_fifo = FWNET_NO_FIFO_ADDR;
+ failed_initial:
 
 	return retval;
 }
-- 
1.7.9.5
