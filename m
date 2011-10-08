From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] vlan:make mtu of vlan equal to physical dev
Date: Sat,  8 Oct 2011 18:12:15 +0800
Message-ID: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50010 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab1JHKK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 06:10:56 -0400
Received: by wwf22 with SMTP id 22so7022435wwf.1
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 03:10:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default mtu of vlan device is the same with mtu of physical device,
for example 1500, but when change physics mtu to 1600,
VLAN device's mtu is still 1500.
Certainly, you can change vlan device's mtu to 1600 manually,
but I think when you change physics device's mtu, VLAN's mtu should be changed
automatically instead of by manually.

Steps to Reproduce:
1.vconfig add eth4 3
2.ifconfig eth4 mtu 1600
3.check mtu on eth4.3

And what's worse is that if you decrease mtu of pyhsical device,
and when you want to increase it, the mtu of vlan device won't be changed.

Steps to Reproduce:
1.vconfig add eth4 3
2.ifconfig eth4 mtu 100
3.ifconfig eth4 mtu 1500
4.the mtu of eth4.3 is still 100

This bug is reported by Liang Zheng(lzheng@redhat.com).

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/8021q/vlan.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8970ba1..f6072b4 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -417,9 +417,6 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!vlandev)
 				continue;
 
-			if (vlandev->mtu <= dev->mtu)
-				continue;
-
 			dev_set_mtu(vlandev, dev->mtu);
 		}
 		break;
-- 
1.7.4.4
