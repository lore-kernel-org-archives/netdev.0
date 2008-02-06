From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 9/17] [NETNS]: DST cleanup routines should be called inside namespace.
Date: Wed,  6 Feb 2008 13:53:29 +0300
Message-ID: <1202295217-22769-9-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:52879 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758312AbYBFKxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:15 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device inside the namespace can be started and downed. So, active routing
cache should be cleaned up on device stop.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/dst.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 7deef48..3a01a81 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -295,9 +295,6 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event, void
 	struct net_device *dev = ptr;
 	struct dst_entry *dst, *last = NULL;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_UNREGISTER:
 	case NETDEV_DOWN:
-- 
1.5.3.rc5

