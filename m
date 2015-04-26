From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v3 1/4] checkpatch: suggest using ether_addr_equal*()
Date: Sun, 26 Apr 2015 18:43:17 +0200
Message-ID: <1430066600-12210-2-git-send-email-mateusz.kulikowski@gmail.com>
References: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check if memcmp() is used to compare ethernet addresses and suggest
using ether_addr_equal() or ether_addr_equal_unaligned()

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 89b1df4..0a511b7 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5035,6 +5035,14 @@ sub process {
 			}
 		}
 
+# Check for memcmp(foo, bar, ETH_ALEN) that could be ether_addr_equal*(foo, bar)
+		if ($^V && $^V ge 5.10.0 &&
+		    defined $stat &&
+		    $stat =~ /^\+(?:.*?)\bmemcmp\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/) {
+			WARN("PREFER_ETHER_ADDR_EQUAL",
+			     "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . "$here\n$stat\n")
+		}
+
 # typecasts on min/max could be min_t/max_t
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
-- 
1.8.4.1
