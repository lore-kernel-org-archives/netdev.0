From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/4] selftests: add 'ip get' to rtnetlink.sh
Date: Tue, 15 Aug 2017 16:34:41 +0200
Message-ID: <20170815143444.17002-2-fw@strlen.de>
References: <20170815143444.17002-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41024 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752372AbdHOOe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:34:29 -0400
In-Reply-To: <20170815143444.17002-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

exercise ip/ip6 RTM_GETROUTE doit() callpath.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 tools/testing/selftests/net/rtnetlink.sh | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
index 5b04ad912525..84b4acf5baa9 100755
--- a/tools/testing/selftests/net/rtnetlink.sh
+++ b/tools/testing/selftests/net/rtnetlink.sh
@@ -164,6 +164,37 @@ kci_test_polrouting()
 	echo "PASS: policy routing"
 }
 
+kci_test_route_get()
+{
+	ret=0
+
+	ip route get 127.0.0.1 > /dev/null
+	check_err $?
+	ip route get 127.0.0.1 dev "$devdummy" > /dev/null
+	check_err $?
+	ip route get ::1 > /dev/null
+	check_err $?
+	ip route get fe80::1 dev "$devdummy" > /dev/null
+	check_err $?
+	ip route get 127.0.0.1 from 127.0.0.1 oif lo tos 0x1 mark 0x1 > /dev/null
+	check_err $?
+	ip route get ::1 from ::1 iif lo oif lo tos 0x1 mark 0x1 > /dev/null
+	check_err $?
+	ip addr add dev "$devdummy" 10.23.7.11/24
+	check_err $?
+	ip route get 10.23.7.11 from 10.23.7.12 iif "$devdummy" > /dev/null
+	check_err $?
+	ip addr del dev "$devdummy" 10.23.7.11/24
+	check_err $?
+
+	if [ $ret -ne 0 ];then
+		echo "FAIL: route get"
+		return 1
+	fi
+
+	echo "PASS: route get"
+}
+
 kci_test_rtnl()
 {
 	kci_add_dummy
@@ -173,6 +204,7 @@ kci_test_rtnl()
 	fi
 
 	kci_test_polrouting
+	kci_test_route_get
 	kci_test_tc
 	kci_test_gre
 	kci_test_bridge
-- 
2.13.0
