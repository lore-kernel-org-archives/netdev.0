From: sfeldma@gmail.com
Subject: [PATCH net-next 1/3] switchdev: fix: erasing too much of vlan obj when handling multiple vlan specs
Date: Tue, 20 Oct 2015 12:36:37 -0700
Message-ID: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33887 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbJTTd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 15:33:57 -0400
Received: by padhk11 with SMTP id hk11so29994026pad.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 12:33:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

When adding vlans with multiple IFLA_BRIDGE_VLAN_INFO attrs set in AFSPEC,
we would wipe the vlan obj struct after the first IFLA_BRIDGE_VLAN_INFO.
Fix this by only clearing what's necessary on each IFLA_BRIDGE_VLAN_INFO
iteration.

Fixes: 9e8f4a54 ("switchdev: push object ID back to object structure")
Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 73e3895..56d8479 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -863,7 +863,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(&vlan, 0, sizeof(vlan));
+			vlan.vid_begin = 0;
 		} else {
 			if (vlan.vid_begin)
 				return -EINVAL;
@@ -872,7 +872,7 @@ static int switchdev_port_br_afspec(struct net_device *dev,
 			err = f(dev, &vlan.obj);
 			if (err)
 				return err;
-			memset(&vlan, 0, sizeof(vlan));
+			vlan.vid_begin = 0;
 		}
 	}
 
-- 
1.7.10.4
