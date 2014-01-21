From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Prefer ether_addr_copy to memcpy(foo, bar,
 ETH_ALEN)
Date: Tue, 21 Jan 2014 13:51:29 -0800
Message-ID: <1390341089.31946.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Andy Whitcroft <apw@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0234.hostedemail.com ([216.40.44.234]:39732 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754554AbaAUVve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 16:51:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether_addr_copy was added for kernel version 3.14.
It's slightly smaller/faster for some arches.
Encourage its use.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index be53ba7..0ea2a1e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4096,6 +4096,16 @@ sub process {
 			}
 		}
 
+# Check for memcpy(foo, bar, ETH_ALEN) that could be ether_addr_copy(foo, bar)
+		if ($^V && $^V ge 5.10.0 &&
+		    $line =~ /^\+(?:.*?)\bmemcpy\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
+			if (WARN("PREFER_ETHER_ADDR_COPY",
+				 "Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)\n" . $herecurr) &&
+			    $fix) {
+				$fixed[$linenr - 1] =~ s/\bmemcpy\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/ether_addr_copy($2, $7)/;
+			}
+		}
+
 # typecasts on min/max could be min_t/max_t
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
