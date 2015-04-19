From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH 1/2] checkpatch: suggest using ether_addr_equal*()
Date: Sun, 19 Apr 2015 21:04:05 +0200
Message-ID: <1429470246-15988-2-git-send-email-mateusz.kulikowski@gmail.com>
References: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35788 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbDSTES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 15:04:18 -0400
In-Reply-To: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if memcmp() is used to compare ethernet addresses and suggest using
ether_addr_equal() or ether_addr_equal_unaligned()

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 89b1df4..3a1a01e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5035,6 +5035,13 @@ sub process {
 			}
 		}
 
+# Check for memcmp(foo, bar, ETH_ALEN) that could be ether_addr_equal*(foo, bar)
+		if ($^V && $^V ge 5.10.0 &&
+			$line =~ /^\+(?:.*?)\bmemcmp\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
+			WARN("PREFER_ETHER_ADDR_EQUAL",
+				 "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . $herecurr)
+		}
+
 # typecasts on min/max could be min_t/max_t
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
-- 
1.8.4.1
