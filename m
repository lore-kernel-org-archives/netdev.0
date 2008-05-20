From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Correctly handle device notifications for layered VLAN devices
Date: Tue, 20 May 2008 15:23:34 +0200
Message-ID: <4832D0D6.3020503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060905010402080805050901"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39404 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbYETNXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 09:23:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060905010402080805050901
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060905010402080805050901
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit cf794e6af782a838252dfc9fc6f10f7a7f66f62a
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 20 15:12:49 2008 +0200

    [VLAN]: Correctly handle device notifications for layered VLAN devices

    Commit 30688a9 ([VLAN]: Handle vlan devices net namespace changing)
    changed the device notifier to special-case notifications for VLAN
    devices, effectively disabling state propagation to underlying VLAN
    devices. This is needed for layered VLANs though, so restore the
    original behaviour.

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2a739ad..b934159 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -410,10 +410,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	int i, flgs;
 	struct net_device *vlandev;
 
-	if (is_vlan_dev(dev)) {
+	if (is_vlan_dev(dev))
 		__vlan_device_event(dev, event);
-		goto out;
-	}
 
 	grp = __vlan_find_group(dev);
 	if (!grp)

--------------060905010402080805050901--
