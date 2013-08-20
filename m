From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: ipv6: minor: *_start_timer: rather use unsigned long
Date: Tue, 20 Aug 2013 12:22:01 +0200
Message-ID: <1376994122-3022-3-git-send-email-dborkman@redhat.com>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab3HTKWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:22:09 -0400
In-Reply-To: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the functions mld_gq_start_timer(), mld_ifc_start_timer(),
and mld_dad_start_timer(), rather use unsigned long than int
as we operate only on unsigned values anyway. This seems more
appropriate as there is no good reason to do type conversions
to int, that could lead to future errors.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/mcast.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 57863e2..33f98d9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -996,24 +996,24 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 
 static void mld_gq_start_timer(struct inet6_dev *idev)
 {
-	int tv = net_random() % idev->mc_maxdelay;
+	unsigned long tv = net_random() % idev->mc_maxdelay;
 
 	idev->mc_gq_running = 1;
 	if (!mod_timer(&idev->mc_gq_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
 }
 
-static void mld_ifc_start_timer(struct inet6_dev *idev, int delay)
+static void mld_ifc_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
-	int tv = net_random() % delay;
+	unsigned long tv = net_random() % delay;
 
 	if (!mod_timer(&idev->mc_ifc_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
 }
 
-static void mld_dad_start_timer(struct inet6_dev *idev, int delay)
+static void mld_dad_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
-	int tv = net_random() % delay;
+	unsigned long tv = net_random() % delay;
 
 	if (!mod_timer(&idev->mc_dad_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
-- 
1.7.11.7
