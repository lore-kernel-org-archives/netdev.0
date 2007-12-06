From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][VLAN] Lost rtnl_unlock() in vlan_ioctl()
Date: Thu, 06 Dec 2007 16:52:00 +0300
Message-ID: <4757FE80.2080000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53389 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbXLFNwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 08:52:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SET_VLAN_NAME_TYPE_CMD command w/o CAP_NET_ADMIN capability
doesn't release the rtnl lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6567213..5b18315 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -776,7 +776,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 	case SET_VLAN_NAME_TYPE_CMD:
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
+			break;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
 			vlan_name_type = args.u.name_type;
