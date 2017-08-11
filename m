From: William Tu <u9012063@gmail.com>
Subject: [PATCHv2 net-next] selftests: bpf: add check for ip XDP redirect
Date: Fri, 11 Aug 2017 06:46:39 -0700
Message-ID: <1502459199-6442-1-git-send-email-u9012063@gmail.com>
Cc: John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35360 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753196AbdHKNrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 09:47:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id j68so3540327pfc.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 06:47:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel test robot reports error when running test_xdp_redirect.sh.
Check if ip tool supports xdpgeneric, if not, skip the test.

Signed-off-by: William Tu <u9012063@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_xdp_redirect.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.sh b/tools/testing/selftests/bpf/test_xdp_redirect.sh
index d8c73ed6e040..344a3656dea6 100755
--- a/tools/testing/selftests/bpf/test_xdp_redirect.sh
+++ b/tools/testing/selftests/bpf/test_xdp_redirect.sh
@@ -23,6 +23,11 @@ cleanup()
 	ip netns del ns2 2> /dev/null
 }
 
+ip link set dev lo xdpgeneric off 2>/dev/null > /dev/null
+if [ $? -ne 0 ];then
+	echo "selftests: [SKIP] Could not run test without the ip xdpgeneric support"
+	exit 0
+fi
 set -e
 
 ip netns add ns1
-- 
2.7.4
