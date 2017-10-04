From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] selftests: rtnetlink: try concurrent change of ifalias
Date: Wed,  4 Oct 2017 13:52:58 +0200
Message-ID: <20171004115258.5878-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:52652 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751546AbdJDLwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 07:52:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to make sure this is serialized correctly.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 62c87da92770..13c29beb5769 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -278,6 +278,14 @@ kci_test_ifalias()
 	        ip link show "$devdummy" | grep -q "alias $namewant"
 		check_fail $?
 
+		for i in $(seq 1 100); do
+			uuidgen > "$syspathname" &
+		done
+
+		for i in $(seq 1 100); do
+			wait
+		done
+
 		# re-add the alias -- kernel should free mem when dummy dev is removed
 		ip link set dev "$devdummy" alias "$namewant"
 		check_err $?
-- 
2.13.6
