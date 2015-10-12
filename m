From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] switchdev: check if the vlan id is in the proper vlan range
Date: Mon, 12 Oct 2015 14:31:01 +0200
Message-ID: <1444653061-5850-1-git-send-email-razor@blackwall.org>
Cc: jiri@resnulli.us, sfeldma@gmail.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38201 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbJLMbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:31:06 -0400
Received: by wieq12 with SMTP id q12so18015916wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 05:31:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

VLANs 0 and 4095 are reserved and shouldn't be used, add checks to
switchdev similar to the bridge. Also make sure ids above 4095 cannot
be passed either.

Fixes: 47f8328bb1a4 ("switchdev: add new switchdev bridge setlink")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/switchdev/switchdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fda38f830a10..77f5d17e2612 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -16,6 +16,7 @@
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/if_vlan.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -634,6 +635,8 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 			return -EINVAL;
 		vinfo = nla_data(attr);
+		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
+			return -EINVAL;
 		vlan->flags = vinfo->flags;
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
 			if (vlan->vid_begin)
-- 
2.4.3
