From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: use time_before() in br_fdb_cleanup()
Date: Tue, 18 Mar 2008 09:32:29 -0700
Message-ID: <20080318093229.306b27d6@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36875 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755132AbYCSUOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 16:14:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In br_fdb_cleanup() next_timer and this_timer are in jiffies, so they
should be compared using the time_after() macro.

Signed-off-by: Fabio Checconi <fabio@gandalf.sssup.it>
Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
---
 net/bridge/br_fdb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index bc40377..9326c37 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -136,7 +136,7 @@ void br_fdb_cleanup(unsigned long _data)
 			this_timer = f->ageing_timer + delay;
 			if (time_before_eq(this_timer, jiffies))
 				fdb_delete(f);
-			else if (this_timer < next_timer)
+			else if (time_before(this_timer, next_timer))
 				next_timer = this_timer;
 		}
 	}
-- 
1.5.4.3

