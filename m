From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] sky2: avoid using uninitialized variable
Date: Mon, 13 Jun 2011 14:21:59 -0700
Message-ID: <xr93vcw9s9zc.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58778 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1FMVWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 17:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not sure if 0 or ~0 would be a better choice in the gm_phy_read()
error case.  I used 0.  A more complete solution might be to plumb up
error handling to the callers of gm_phy_read().

==
>From 37486219a3d93881f3b2619a4b2bb21be62db7d4 Mon Sep 17 00:00:00 2001
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Jun 2011 14:09:07 -0700
Subject: [PATCH] sky2: avoid using uninitialized variable

Prior to this change gm_phy_read() could return an uninitialized
variable if __gm_phy_read() failed.

This change returns zero in the failure case.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 drivers/net/sky2.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3ee41da..eba1ac4 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -206,7 +206,8 @@ io_error:
 static inline u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
 {
 	u16 v;
-	__gm_phy_read(hw, port, reg, &v);
+	if (__gm_phy_read(hw, port, reg, &v) < 0)
+		return 0;
 	return v;
 }
 
-- 
1.7.3.1

