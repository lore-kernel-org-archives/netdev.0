From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/2] virtio_net: validate ethtool port setting and explain the user validation
Date: Sun,  7 Feb 2016 21:52:24 +0100
Message-ID: <1454878344-21730-3-git-send-email-razor@blackwall.org>
References: <1454878344-21730-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33550 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbcBGUwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 15:52:30 -0500
Received: by mail-wm0-f65.google.com with SMTP id r129so12588107wmr.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 12:52:30 -0800 (PST)
In-Reply-To: <1454878344-21730-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We should validate the port setting that we got from the user and check
if it's what we've set it to (PORT_OTHER), also add explanation that
ignoring advertising is good as long as we don't have autonegotiation.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/virtio_net.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c9fd52a8e6ec..fb0eae42bf39 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1386,11 +1386,13 @@ static bool virtnet_validate_ethtool_cmd(const struct ethtool_cmd *cmd)
 	struct ethtool_cmd diff1 = *cmd;
 	struct ethtool_cmd diff2 = {};
 
-	/* advertising and cmd are usually set, ignore port because we set it */
+	/* cmd is always set so we need to clear it, validate the port type
+	 * and also without autonegotiation we can ignore advertising
+	 */
 	ethtool_cmd_speed_set(&diff1, 0);
+	diff2.port = PORT_OTHER;
 	diff1.advertising = 0;
 	diff1.duplex = 0;
-	diff1.port = 0;
 	diff1.cmd = 0;
 
 	return !memcmp(&diff1, &diff2, sizeof(diff1));
-- 
2.4.3
