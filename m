From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/17 net-2.6.26] [IPV4]: Remove check for ifa->ifa_dev != NULL.
Date: Tue, 19 Feb 2008 10:31:22 +0300
Message-ID: <1203406297-32725-2-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:51142 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755451AbYBSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:16 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a callback registered to inet address notifier chain.
The check is useless as:
- ifa->ifa_dev is always != NULL
- similar checks are abscent in all other notifiers.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/atm/clip.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 86b885e..dd96440 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -648,10 +648,6 @@ static int clip_inet_event(struct notifier_block *this, unsigned long event,
 	struct in_device *in_dev;
 
 	in_dev = ((struct in_ifaddr *)ifa)->ifa_dev;
-	if (!in_dev || !in_dev->dev) {
-		printk(KERN_WARNING "clip_inet_event: no device\n");
-		return NOTIFY_DONE;
-	}
 	/*
 	 * Transitions are of the down-change-up type, so it's sufficient to
 	 * handle the change on up.
-- 
1.5.3.rc5

