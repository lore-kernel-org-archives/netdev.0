From: Ben Greear <greearb@candelatech.com>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 11:51:43 -0800
Message-ID: <47448C4F.3060107@candelatech.com>
References: <474387E4.7020802@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070706060804040006000706"
Cc: Patrick McHardy <kaber@trash.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:37714 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbXKUTvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 14:51:49 -0500
In-Reply-To: <474387E4.7020802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070706060804040006000706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

For consideration, this patch seems to work for me.  I'm not sure
why we ever listed to these events.  I've only tested on a NIC that
doesn't support hw-accel at the moment..will test with e1000 later.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------070706060804040006000706
Content-Type: text/x-patch;
 name="vlan.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan.patch"

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c4209c8..acbf0ff 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -615,6 +615,11 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		break;
 
+#if 0
+		/* Don't propagate management state from base dev to VLANs.  If you do this,
+		 * then if you 'ifconfig eth0 down; ifconfig eth0 up', you also lose all the
+		 * routes for eth0.* VLANs. --Ben
+		 */
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
@@ -644,6 +649,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			dev_change_flags(vlandev, flgs | IFF_UP);
 		}
 		break;
+#endif
 		
 	case NETDEV_UNREGISTER:
 		/* Delete all VLANs for this dev. */

--------------070706060804040006000706--
