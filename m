From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/2] net: make dev_disable_lro use physical device if passed a vlan dev (v2)
Date: Tue, 24 May 2011 14:31:09 -0400
Message-ID: <1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60557 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab1EXSbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 14:31:31 -0400
In-Reply-To: <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device passed into dev_disable_lro is a vlan, then repoint the dev
poniter so that we actually modify the underlying physical device.

Signed-of-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net
CC: bhutchings@solarflare.com
---
 net/core/dev.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d945379..da16c6a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1308,6 +1308,13 @@ void dev_disable_lro(struct net_device *dev)
 {
 	u32 flags;
 
+	/*
+ 	 * If we're trying to disable lro on a vlan device
+ 	 * use the underlying physical device instead
+ 	 */
+	if (is_vlan_dev(dev))
+		dev = vlan_dev_real_dev(dev);
+
 	if (dev->ethtool_ops && dev->ethtool_ops->get_flags)
 		flags = dev->ethtool_ops->get_flags(dev);
 	else
-- 
1.7.5.1

