From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/3] vlan: Propagate NETDEV_NOTIFY_PEERS
 notifier
Date: Sat, 16 Apr 2011 00:46:49 +0100
Message-ID: <1302911209.2845.40.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6752 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab1DOXqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:46:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NETDEV_NOTIFY_PEERS notifier indicates that a device moved to a
different physical link; this also applies to any VLAN devices on top
of it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/8021q/vlan.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 14ef5ef..b2ff70f 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -499,6 +499,17 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
 		return NOTIFY_BAD;
+
+	case NETDEV_NOTIFY_PEERS:
+		/* Propagate to vlan devices */
+		for (i = 0; i < VLAN_N_VID; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, vlandev);
+		}
+		break;
 	}
 
 out:
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

