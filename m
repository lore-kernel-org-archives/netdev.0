From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Don't synchronize addresses while the vlan device is down
Date: Thu, 08 Nov 2007 18:19:53 +0100
Message-ID: <47334539.1010301@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010500020800010605030700"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65220 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761208AbXKHRTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 12:19:55 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010500020800010605030700
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010500020800010605030700
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[VLAN]: Don't synchronize addresses while the vlan device is down

While the VLAN device is down, the unicast addresses are not configured
on the underlying device, so we shouldn't attempt to sync them.

Noticed by Dmitry Butskoy <buc@odusz.so-cdu.ru>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f6d0e3b654d36bd87016b0626464990f3fc57ca7
tree 16ce232acdd1919e7ca42dc12b24f09f8d92f966
parent dbeeb816e805091e7cfc03baf36dc40b4adb2bbd
author Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 17:34:43 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 17:34:43 +0100

 net/8021q/vlan.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 3fe4fc8..d80afec 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -636,6 +636,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!vlandev)
 				continue;
 
+			flgs = vlandev->flags;
+			if (!(flgs & IFF_UP))
+				continue;
+
 			vlan_sync_address(dev, vlandev);
 		}
 		break;

--------------010500020800010605030700--
