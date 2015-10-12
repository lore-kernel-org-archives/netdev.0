From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Mon, 12 Oct 2015 14:01:39 +0200
Message-ID: <1444651299-2813-1-git-send-email-razor@blackwall.org>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
Cc: sfeldma@gmail.com, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37671 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbJLMBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:01:49 -0400
Received: by wijq8 with SMTP id q8so54398532wij.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 05:01:48 -0700 (PDT)
In-Reply-To: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/switchdev/switchdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6e4a4f9ad927..256c596de896 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			if (vlan.vid_begin)
 				return -EINVAL;
 			vlan.vid_begin = vinfo->vid;
+			/* don't allow range of pvids */
+			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
+				return -EINVAL;
 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
 			if (!vlan.vid_begin)
 				return -EINVAL;
-- 
2.4.3
