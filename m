From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] drivers/net/ibmveth.c: memset fix
Date: Mon, 6 Aug 2007 22:17:04 +0200
Message-ID: <200708062217.04361.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santil@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:3391 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846AbXHFURF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 16:17:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	Looks like memset() is zeroing wrong nr of bytes.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/ibmveth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.23-rc1-mm2-a/drivers/net/ibmveth.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/ibmveth.c	2007-08-06 20:34:44.000000000 +0200
@@ -963,7 +963,7 @@ static int __devinit ibmveth_probe(struc
 {
 	int rc, i;
 	struct net_device *netdev;
-	struct ibmveth_adapter *adapter = NULL;
+	struct ibmveth_adapter *adapter;

 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -997,7 +997,7 @@ static int __devinit ibmveth_probe(struc
 	SET_MODULE_OWNER(netdev);

 	adapter = netdev->priv;
-	memset(adapter, 0, sizeof(adapter));
+	memset(adapter, 0, sizeof(*adapter));
 	dev->dev.driver_data = netdev;

 	adapter->vdev = dev;
