From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] selftests: correct define in msg_zerocopy.c
Date: Fri,  1 Sep 2017 12:31:51 -0400
Message-ID: <20170901163151.106867-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, ast@fb.com, dmm@fb.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35991 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdIAQby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:31:54 -0400
Received: by mail-qk0-f194.google.com with SMTP id l65so515349qkc.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:31:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The msg_zerocopy test defines SO_ZEROCOPY if necessary, but its value
is inconsistent with the one in asm-generic.h. Correct that.

Also convert one error to a warning. When the test is complete, report
throughput and close cleanly even if the process did not wait for all
completions.

Reported-by: Dan Melnic <dmm@fb.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/msg_zerocopy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/msg_zerocopy.c b/tools/testing/selftests/net/msg_zerocopy.c
index 448c69a8af74..40232af5b023 100644
--- a/tools/testing/selftests/net/msg_zerocopy.c
+++ b/tools/testing/selftests/net/msg_zerocopy.c
@@ -59,7 +59,7 @@
 #endif
 
 #ifndef SO_ZEROCOPY
-#define SO_ZEROCOPY	59
+#define SO_ZEROCOPY	60
 #endif
 
 #ifndef SO_EE_CODE_ZEROCOPY_COPIED
@@ -382,8 +382,8 @@ static void do_recv_remaining_completions(int fd)
 	}
 
 	if (completions < expected_completions)
-		error(1, 0, "missing notifications: %lu < %lu\n",
-		      completions, expected_completions);
+		fprintf(stderr, "missing notifications: %lu < %lu\n",
+			completions, expected_completions);
 }
 
 static void do_tx(int domain, int type, int protocol)
-- 
2.14.1.581.gf28d330327-goog
