From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net-next] selftests: rtnetlink: try concurrent change of ifalias
Date: Wed,  4 Oct 2017 16:22:59 +0200
Message-ID: <20171004142259.13235-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53420 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751176AbdJDOWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 10:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to make sure this is serialized correctly.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 change since v1:
 Eric points out 'wait' blocks for all current children, so no need
 for another loop.

 tools/testing/selftests/net/rtnetlink.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 62c87da92770..e8c86c416ed0 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -278,6 +278,12 @@ kci_test_ifalias()
 	        ip link show "$devdummy" | grep -q "alias $namewant"
 		check_fail $?
 
+		for i in $(seq 1 100); do
+			uuidgen > "$syspathname" &
+		done
+
+		wait
+
 		# re-add the alias -- kernel should free mem when dummy dev is removed
 		ip link set dev "$devdummy" alias "$namewant"
 		check_err $?
-- 
2.13.6
