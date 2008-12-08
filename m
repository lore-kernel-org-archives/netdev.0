From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] staging-winbond: Kill directly reference of netdev->priv
Date: Mon, 08 Dec 2008 13:33:22 +0800
Message-ID: <493CB1A2.7080005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52835 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbYLHFoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 00:44:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver is not yet finished.
At this time, we don't know how netdev be created and how
private data be allocated.
So, simply use netdev_priv() now and leave some temp comment.

Compile test only.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/staging/winbond/linux/wbusb.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/winbond/linux/wbusb.c b/drivers/staging/winbond/linux/wbusb.c
index f4a7875..39ca9b9 100644
--- a/drivers/staging/winbond/linux/wbusb.c
+++ b/drivers/staging/winbond/linux/wbusb.c
@@ -336,7 +336,11 @@ WbUsb_destroy(phw_data_t pHwData)
 
 int wb35_open(struct net_device *netdev)
 {
-	PADAPTER Adapter = (PADAPTER)netdev->priv;
+	/* netdev_priv() or netdev->ml_priv should reference to the address of
+	 * private data(PADAPTER). It depends on whether private data memory is
+	 * allocated when alloc_netdev().
+	 */
+	PADAPTER Adapter = (PADAPTER)netdev_priv(netdev);
 	phw_data_t pHwData = &Adapter->sHwData;
 
         netif_start_queue(netdev);
-- 
1.5.3.4




