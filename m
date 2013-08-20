From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 2/3] net: vlan: handle NETDEV_CHANGEROOM events
Date: Tue, 20 Aug 2013 13:45:51 +0100
Message-ID: <1377002752-4622-3-git-send-email-f.fainelli@gmail.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, jiri@resnulli.us, stephen@networkplumber.org,
	kaber@trash.net, davem@davemloft.net, vyasevic@redhat.com,
	johannes@sipsolutions.net, eric.dumazet@gmail.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4027 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab3HTMqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 08:46:18 -0400
In-Reply-To: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever the parent device has needed_headroom/needed_tailroom
requirement changes, the VLAN devices should also be updated to the new
value. Handle the NETDEV_CHANGEROOM events and just set the new headroom
and tailroom requirements to the values of the parent device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/8021q/vlan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 61fc573..11a1faa 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -466,6 +466,13 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		vlan_group_for_each_dev(grp, i, vlandev)
 			call_netdevice_notifiers(event, vlandev);
 		break;
+
+	case NETDEV_CHANGEROOM:
+		vlan_group_for_each_dev(grp, i, vlandev) {
+			dev_set_headroom(vlandev, dev->needed_headroom);
+			dev_set_tailroom(vlandev, dev->needed_tailroom);
+		}
+		break;
 	}
 
 out:
-- 
1.8.1.2
