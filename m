From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH net-next] selftests/net: Fix broken test case in psock_fanout
Date: Mon, 24 Apr 2017 21:29:11 -0400
Message-ID: <20170425012911.903-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36498 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965138AbdDYB3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:29:18 -0400
Received: by mail-yw0-f195.google.com with SMTP id s39so1337244ywa.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 18:29:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

The error return falue form sock_fanout_open is -1, not zero.  One test
case was checking for 0 instead of -1.

Tested: Built and tested in clean client.
Signed-off-by: Mike Maloney <maloney@google.com>
---
 tools/testing/selftests/net/psock_fanout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index b4b1d91fcea5..989f917068d1 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -305,7 +305,7 @@ static void test_unique_fanout_group_ids(void)
 		exit(1);
 	}
 
-	if (sock_fanout_open(PACKET_FANOUT_CPU, first_group_id)) {
+	if (sock_fanout_open(PACKET_FANOUT_CPU, first_group_id) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong type.\n");
 		exit(1);
 	}
-- 
2.13.0.rc0.306.g87b477812d-goog
