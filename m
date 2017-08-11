From: William Tu <u9012063@gmail.com>
Subject: [PATCH] selftests: bpf: add check for ip XDP redirect
Date: Thu, 10 Aug 2017 17:02:33 -0700
Message-ID: <1502409753-27516-1-git-send-email-u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37922 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdHKAFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 20:05:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id h75so1956037pfh.5
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 17:05:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel test robot reports error when running test_xdp_redirect.sh.
Check if ip tool supports xdpgeneric, if not, skip the test.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_xdp_redirect.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.sh b/tools/testing/selftests/bpf/test_xdp_redirect.sh
index d8c73ed6e040..c5a8b7173c12 100755
--- a/tools/testing/selftests/bpf/test_xdp_redirect.sh
+++ b/tools/testing/selftests/bpf/test_xdp_redirect.sh
@@ -23,6 +23,11 @@ cleanup()
 	ip netns del ns2 2> /dev/null
 }
 
+ip link set dev lo xdpgeneric off 2>/dev/null > /dev/null
+if [ $? -ne 0 ];then
+        echo "selftests: [SKIP] Could not run test without the ip xdpgeneric support"
+        exit 0
+fi
 set -e
 
 ip netns add ns1
-- 
2.7.4
