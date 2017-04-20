From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] netdevice: Prefer NETIF_F_HW_CSUM when intersecting features
Date: Wed, 19 Apr 2017 21:12:23 -0400
Message-ID: <1492650743-28164-1-git-send-email-vyasevic@redhat.com>
Cc: tom@herbertland.com, mkubecek@suse.cz,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36357 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763356AbdDTBMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 21:12:34 -0400
Received: by mail-qt0-f194.google.com with SMTP id t52so5597164qtb.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 18:12:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
This results in an interesting situation when the software
device is configured on top of hw device using (IP|IPV6)_CSUM.
In this situation, the user can't turn off checksum offloading
features on the software device.

This patch resolves that by prefering the NETIF_F_HW_CSUM setting
when computing a feature intersect.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b25..3d811c1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4019,9 +4019,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 {
 	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
 		if (f1 & NETIF_F_HW_CSUM)
-			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
+			f2 |= NETIF_F_HW_CSUM;
 		else
-			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
+			f1 |= NETIF_F_HW_CSUM;
 	}
 
 	return f1 & f2;
-- 
2.7.4
