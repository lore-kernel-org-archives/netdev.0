From: greearb@candelatech.com
Subject: [PATCH] net:  rate-limit warn-bad-offload splats.
Date: Fri, 19 Apr 2013 13:45:52 -0700
Message-ID: <1366404352-14134-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59583 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab3DSUqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:46:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

If one does do something unfortunate and allow a
bad offload bug into the kernel, this the
skb_warn_bad_offload can effectively live-lock the
system, filling the logs with the same error over
and over.

Add rate limitation to this so that box remains otherwise
functional in this case.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 net/core/dev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2ae4e93..ff27b34 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2165,6 +2165,9 @@ static void skb_warn_bad_offload(const struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	const char *driver = "";
 
+	if (!net_ratelimit())
+		return;
+
 	if (dev && dev->dev.parent)
 		driver = dev_driver_string(dev->dev.parent);
 
-- 
1.7.3.4
