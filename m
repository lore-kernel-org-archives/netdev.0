From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/3] selftests/net: cleanup unused parameter in psock_fanout
Date: Fri, 21 Apr 2017 10:56:10 -0400
Message-ID: <20170421145612.106869-2-willemdebruijn.kernel@gmail.com>
References: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Cc: maloneykernel@gmail.com, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35212 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424255AbdDUTCC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:02:02 -0400
Received: by mail-qt0-f193.google.com with SMTP id o36so13026623qtb.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:02:02 -0700 (PDT)
In-Reply-To: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

sock_fanout_open no longer sets the size of packet_socket ring, so stop
passing the parameter.

Signed-off-by: Mike Maloney <maloney@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>

---
 tools/testing/selftests/net/psock_fanout.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 412459369686..b475d87d3aa3 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -71,7 +71,7 @@
 
 /* Open a socket in a given fanout mode.
  * @return -1 if mode is bad, a valid socket otherwise */
-static int sock_fanout_open(uint16_t typeflags, int num_packets)
+static int sock_fanout_open(uint16_t typeflags)
 {
 	int fd, val;
 
@@ -210,7 +210,7 @@ static void test_control_single(void)
 	fprintf(stderr, "test: control single socket\n");
 
 	if (sock_fanout_open(PACKET_FANOUT_ROLLOVER |
-			       PACKET_FANOUT_FLAG_ROLLOVER, 0) != -1) {
+			       PACKET_FANOUT_FLAG_ROLLOVER) != -1) {
 		fprintf(stderr, "ERROR: opened socket with dual rollover\n");
 		exit(1);
 	}
@@ -223,26 +223,26 @@ static void test_control_group(void)
 
 	fprintf(stderr, "test: control multiple sockets\n");
 
-	fds[0] = sock_fanout_open(PACKET_FANOUT_HASH, 20);
+	fds[0] = sock_fanout_open(PACKET_FANOUT_HASH);
 	if (fds[0] == -1) {
 		fprintf(stderr, "ERROR: failed to open HASH socket\n");
 		exit(1);
 	}
 	if (sock_fanout_open(PACKET_FANOUT_HASH |
-			       PACKET_FANOUT_FLAG_DEFRAG, 10) != -1) {
+			       PACKET_FANOUT_FLAG_DEFRAG) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong flag defrag\n");
 		exit(1);
 	}
 	if (sock_fanout_open(PACKET_FANOUT_HASH |
-			       PACKET_FANOUT_FLAG_ROLLOVER, 10) != -1) {
+			       PACKET_FANOUT_FLAG_ROLLOVER) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong flag ro\n");
 		exit(1);
 	}
-	if (sock_fanout_open(PACKET_FANOUT_CPU, 10) != -1) {
+	if (sock_fanout_open(PACKET_FANOUT_CPU) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong mode\n");
 		exit(1);
 	}
-	fds[1] = sock_fanout_open(PACKET_FANOUT_HASH, 20);
+	fds[1] = sock_fanout_open(PACKET_FANOUT_HASH);
 	if (fds[1] == -1) {
 		fprintf(stderr, "ERROR: failed to join group\n");
 		exit(1);
@@ -263,8 +263,8 @@ static int test_datapath(uint16_t typeflags, int port_off,
 
 	fprintf(stderr, "test: datapath 0x%hx\n", typeflags);
 
-	fds[0] = sock_fanout_open(typeflags, 20);
-	fds[1] = sock_fanout_open(typeflags, 20);
+	fds[0] = sock_fanout_open(typeflags);
+	fds[1] = sock_fanout_open(typeflags);
 	if (fds[0] == -1 || fds[1] == -1) {
 		fprintf(stderr, "ERROR: failed open\n");
 		exit(1);
-- 
2.12.2.816.g2cccc81164-goog
