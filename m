From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v3 4/4] checkpatch: Add multi-line handling for PREFER_ETHER_ADDR_COPY
Date: Sun, 26 Apr 2015 18:43:20 +0200
Message-ID: <1430066600-12210-5-git-send-email-mateusz.kulikowski@gmail.com>
References: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34457 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbbDZQnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 12:43:37 -0400
In-Reply-To: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle multi-line memcpy() properly.

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index c05befe..6311950 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5027,9 +5027,10 @@ sub process {
 
 # Check for memcpy(foo, bar, ETH_ALEN) that could be ether_addr_copy(foo, bar)
 		if ($^V && $^V ge 5.10.0 &&
-		    $line =~ /^\+(?:.*?)\bmemcpy\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
+		    defined $stat &&
+		    $stat =~ /^\+(?:.*?)\bmemcpy\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/) {
 			if (WARN("PREFER_ETHER_ADDR_COPY",
-				 "Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)\n" . $herecurr) &&
+				 "Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)\n" . "$here\n$stat\n") &&
 			    $fix) {
 				$fixed[$fixlinenr] =~ s/\bmemcpy\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/ether_addr_copy($2, $7)/;
 			}
-- 
1.8.4.1
