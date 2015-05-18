From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] selftests/net: expect headroom in psock_fanout rollover
Date: Mon, 18 May 2015 15:42:11 -0400
Message-ID: <1431978131-30579-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35766 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbbERTmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 15:42:18 -0400
Received: by ykec202 with SMTP id c202so56700857yke.2
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 12:42:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

psock_fanout tests the various fanout modes. Change the test for
rollover mode to expect early rollover due to socket pressure
as implemented in 2ccdbaa6d55b ("packet: rollover lock contention
avoidance").

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/psock_fanout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 6f67333..08c2a36 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -272,7 +272,7 @@ int main(int argc, char **argv)
 	const int expect_hash[2][2]	= { { 15, 5 },  { 20, 5 } };
 	const int expect_hash_rb[2][2]	= { { 15, 5 },  { 20, 15 } };
 	const int expect_lb[2][2]	= { { 10, 10 }, { 18, 17 } };
-	const int expect_rb[2][2]	= { { 20, 0 },  { 20, 15 } };
+	const int expect_rb[2][2]	= { { 15, 5 },  { 20, 15 } };
 	const int expect_cpu0[2][2]	= { { 20, 0 },  { 20, 0 } };
 	const int expect_cpu1[2][2]	= { { 0, 20 },  { 0, 20 } };
 	int port_off = 2, tries = 5, ret;
-- 
2.2.0.rc0.207.ga3a616c
