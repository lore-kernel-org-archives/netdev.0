From: sfeldma@gmail.com
Subject: [PATCH net-next v4 1/2] switchdev: fix: erasing too much of vlan obj when handling multiple vlan specs
Date: Wed, 28 Oct 2015 23:17:30 -0700
Message-ID: <1446099451-62999-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34100 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbJ2GOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 02:14:24 -0400
Received: by padhk11 with SMTP id hk11so30630588pad.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 23:14:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

When adding vlans with multiple IFLA_BRIDGE_VLAN_INFO attrs set in AFSPEC,
we would wipe the vlan obj struct after the first IFLA_BRIDGE_VLAN_INFO.
Fix this by only clearing what's necessary on each IFLA_BRIDGE_VLAN_INFO
iteration.

Fixes: 9e8f4a54 ("switchdev: push object ID back to object structure")
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
v3->v4: rebase sync
v2->v3: no change
v1->v2: add Jiri's Acked-by

 net/switchdev/switchdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 1eb76956..8d3e6c3 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -866,7 +866,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(&vlan, 0, sizeof(vlan));
+			vlan.vid_begin = 0;
 		} else {
 			if (vlan.vid_begin)
 				return -EINVAL;
@@ -875,7 +875,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(&vlan, 0, sizeof(vlan));
+			vlan.vid_begin = 0;
 		}
 	}
 
-- 
1.7.10.4
