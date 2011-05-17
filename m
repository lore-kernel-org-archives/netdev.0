From: greearb@candelatech.com
Subject: [PATCH] sk-filter:  Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 11:30:14 -0700
Message-ID: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49822 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067Ab1EQSa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:30:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

A mis-configured filter can spam the logs with
lots of stack traces.  Rate-limit the warnings
and add printout of the bogus filter information.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 afc5837... 8249745... M	net/core/filter.c
 net/core/filter.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index afc5837..8249745 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -409,7 +409,13 @@ load_b:
 			continue;
 		}
 		default:
-			WARN_ON(1);
+			if (net_ratelimit()) {
+				pr_err("filter: Unknown code: %hu jt: %u tf: %u"
+				       " k: %u\n",
+				       fentry->code, (unsigned int)(fentry->jt),
+				       (unsigned int)(fentry->jf), fentry->k);
+				WARN_ON(1);
+			}
 			return 0;
 		}
 	}
-- 
1.7.3.4

