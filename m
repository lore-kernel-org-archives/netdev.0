From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v4] selftests: rtnetlink.sh: add rudimentary vrf test
Date: Tue, 26 Sep 2017 07:40:42 +0200
Message-ID: <20170926054042.2750-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57348 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965051AbdIZFk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 01:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1: indent all lines with tabs, not spaces

 detaching this from the series, I want to avoid needless v5.

 tools/testing/selftests/net/rtnetlink.sh | 42 ++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 4b48de565cae..a048f7a5f94c 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -291,6 +291,47 @@ kci_test_ifalias()
 	echo "PASS: set ifalias $namewant for $devdummy"
 }
 
+kci_test_vrf()
+{
+	vrfname="test-vrf"
+	ret=0
+
+	ip link show type vrf 2>/dev/null
+	if [ $? -ne 0 ]; then
+		echo "SKIP: vrf: iproute2 too old"
+		return 0
+	fi
+
+	ip link add "$vrfname" type vrf table 10
+	check_err $?
+	if [ $ret -ne 0 ];then
+		echo "FAIL: can't add vrf interface, skipping test"
+		return 0
+	fi
+
+	ip -br link show type vrf | grep -q "$vrfname"
+	check_err $?
+	if [ $ret -ne 0 ];then
+		echo "FAIL: created vrf device not found"
+		return 1
+	fi
+
+	ip link set dev "$vrfname" up
+	check_err $?
+
+	ip link set dev "$devdummy" master "$vrfname"
+	check_err $?
+	ip link del dev "$vrfname"
+	check_err $?
+
+	if [ $ret -ne 0 ];then
+		echo "FAIL: vrf"
+		return 1
+	fi
+
+	echo "PASS: vrf"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -306,6 +347,7 @@ kci_test_rtnl()
 	kci_test_bridge
 	kci_test_addrlabel
 	kci_test_ifalias
+	kci_test_vrf
 
 	kci_del_dummy
 }
-- 
2.13.5
