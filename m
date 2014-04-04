From: roy.qing.li@gmail.com
Subject: [PATCH] Documentation: document the gianfar tx vlan offload issue
Date: Fri,  4 Apr 2014 11:04:45 +0800
Message-ID: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
Cc: claudiu.manoil@freescale.com, Yanjun.Zhu@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:40646 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbaDDDE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 23:04:58 -0400
Received: by mail-qa0-f49.google.com with SMTP id j7so2543812qaq.36
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 20:04:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The commit b852b72087[gianfar: fix bug caused by 87c288c6e9] and e2c53be223
[gianfar: fix default tx vlan offload feature flag] disabled tx vlan offload
from dev->feature, since enabling vlan tag insertion leads to unusable
connections on some configurations.

But this feature is in dev->hw_feature still, and a user can enable it by
"ethtool", so document the tx vlan offload issue.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 Documentation/networking/gianfar.txt |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/networking/gianfar.txt b/Documentation/networking/gianfar.txt
index ad474ea..2d3dbe6 100644
--- a/Documentation/networking/gianfar.txt
+++ b/Documentation/networking/gianfar.txt
@@ -51,6 +51,18 @@ configuring VLANs.  The gianfar driver supports hardware insertion and
 extraction of VLAN headers, but not filtering.  Filtering will be
 done by the kernel.
 
+But if tx vlan tag hardware insertion is enabled, and a vlan-device is
+created, the physical device which vlan device is on will be unable to
+work, like:
+
+	$ethtool -K eth0 tx-vlan-stag-hw-insert on
+	$ifconfig eth0 192.168.1.13/24 up
+
+	$vconfig add eth0 4091
+	$ifconfig eth0.4091 10.1.1.13/24 up
+eth0.4091 can work, but eth0 can not work, since eth0 sends the insane
+packets out.
+
 MULTICASTING
 
 The gianfar driver supports using the group hash table on the
-- 
1.7.10.4
