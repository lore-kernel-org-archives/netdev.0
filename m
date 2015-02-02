From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: rocker: Change netdev names to include slot number
Date: Sun,  1 Feb 2015 23:03:05 -0700
Message-ID: <1422856985-16530-1-git-send-email-dsahern@gmail.com>
Cc: sfeldma@gmail.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:32938 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbbBBGDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:03:15 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so15438554iec.11
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2015 22:03:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, rocker devices are given eth%d names. If you have multiple
rocker devices it is difficult to easily correlate eth%d names to a
rocker device and port. Change the device name to sw + PCI slot
number + p + id (sw%dp%d). This makes the device names easier to
correlate. ie., Rather than eth0, ..., eth N (N = number of ports in
device) the ports get netdev names like sw5p0, ..., sw5pN.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 11f4ffcc113d..1d1cf84e6f47 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4010,8 +4010,11 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
 	int err;
+	char str[IFNAMSIZ];
 
-	dev = alloc_etherdev(sizeof(struct rocker_port));
+	snprintf(str, sizeof(str), "sw%dp%%d", pdev->slot->number);
+	dev = alloc_netdev_mqs(sizeof(struct rocker_port),
+			       str, NET_NAME_UNKNOWN, ether_setup, 1, 1);
 	if (!dev)
 		return -ENOMEM;
 	rocker_port = netdev_priv(dev);
-- 
1.9.3 (Apple Git-50)
