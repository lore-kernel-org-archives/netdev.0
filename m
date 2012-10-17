From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] vlan: allow to change type when no vlan device is hooked on netdev
Date: Wed, 17 Oct 2012 13:37:36 +0200
Message-ID: <1350473856-29380-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, jstanley@rmrf.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:55685 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab2JQLho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 07:37:44 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so476483wib.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 04:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan_info might be present but still no vlan devices might be there.
That is in case of vlan0 automatically added.

So in that case, allow to change netdev type.

Reported-by: Jon Stanley <jstanley@rmrf.net>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/8021q/vlan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9096bcb..ee07072 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -463,7 +463,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
-		return NOTIFY_BAD;
+		if (vlan_uses_dev(dev))
+			return NOTIFY_BAD;
+		break;
 
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_BONDING_FAILOVER:
-- 
1.7.11.4
