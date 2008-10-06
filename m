From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vlan: propogate MTU changes (v2)
Date: Mon, 6 Oct 2008 20:25:54 +0200
Message-ID: <20081006202554.11354b09@speedy>
References: <20081006173024.2741cc01@speedy>
	<48EA369F.3090306@trash.net>
	<20081006195446.1dc5a372@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59532 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbYJFS0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 14:26:01 -0400
In-Reply-To: <20081006195446.1dc5a372@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propogate MTU changes of underlying device to all VLAN's and
send vlan MTU change out to userspace.

see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlan.c	2008-10-06 17:03:58.000000000 +0200
+++ b/net/8021q/vlan.c	2008-10-06 19:55:43.000000000 +0200
@@ -477,6 +477,17 @@ static int vlan_device_event(struct noti
 
 		break;
 
+	case NETDEV_CHANGEMTU:
+		/* Propogate MTU of underlying device */
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			dev_set_mtu(vlandev, dev->mtu);
+		}
+		break;
+
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {

