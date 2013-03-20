From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add socket() system call self test.
Date: Wed, 20 Mar 2013 15:10:55 -0400 (EDT)
Message-ID: <20130320.151055.2179062291630664090.davem@davemloft.net>
References: <20130319.145258.1891905092469394685.davem@davemloft.net>
	<CAEnQRZDOwE592qXK0h-u1B7R-9oWP1CZ2rbt197QTn4oagdwgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: daniel.baluta@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3CTTK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:10:58 -0400
In-Reply-To: <CAEnQRZDOwE592qXK0h-u1B7R-9oWP1CZ2rbt197QTn4oagdwgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <daniel.baluta@gmail.com>
Date: Wed, 20 Mar 2013 00:14:05 +0200

> I think it's better to have a selftests/net directory dedicated for
> networking tests. Over time
> the number of net-{x} directories may become very large.

Good idea, here's what I've done for now:

====================
net: Move selftests to common net/ subdirectory.

Suggested-by: Daniel Baluta <daniel.baluta@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/Makefile                         |  3 +--
 tools/testing/selftests/net-socket/Makefile              | 16 ----------------
 tools/testing/selftests/{net-afpacket => net}/Makefile   |  9 +++++----
 .../selftests/{net-afpacket => net}/psock_fanout.c       |  0
 .../selftests/{net-afpacket => net}/run_afpackettests    |  0
 .../selftests/{net-socket => net}/run_netsocktests       |  0
 tools/testing/selftests/{net-socket => net}/socket.c     |  0
 7 files changed, 6 insertions(+), 22 deletions(-)
 delete mode 100644 tools/testing/selftests/net-socket/Makefile
 rename tools/testing/selftests/{net-afpacket => net}/Makefile (55%)
 rename tools/testing/selftests/{net-afpacket => net}/psock_fanout.c (100%)
 rename tools/testing/selftests/{net-afpacket => net}/run_afpackettests (100%)
 rename tools/testing/selftests/{net-socket => net}/run_netsocktests (100%)
 rename tools/testing/selftests/{net-socket => net}/socket.c (100%)

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 7f50078..a480593 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -5,8 +5,7 @@ TARGETS += vm
 TARGETS += cpu-hotplug
 TARGETS += memory-hotplug
 TARGETS += efivarfs
-TARGETS += net-socket
-TARGETS += net-afpacket
+TARGETS += net
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git a/tools/testing/selftests/net-socket/Makefile b/tools/testing/selftests/net-socket/Makefile
deleted file mode 100644
index 2450fd8..0000000
--- a/tools/testing/selftests/net-socket/Makefile
+++ /dev/null
@@ -1,16 +0,0 @@
-# Makefile for net-socket selftests
-
-CC = $(CROSS_COMPILE)gcc
-CFLAGS = -Wall
-
-NET_SOCK_PROGS = socket
-
-all: $(NET_SOCK_PROGS)
-%: %.c
-	$(CC) $(CFLAGS) -o $@ $^
-
-run_tests: all
-	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
-
-clean:
-	$(RM) $(NET_SOCK_PROGS)
diff --git a/tools/testing/selftests/net-afpacket/Makefile b/tools/testing/selftests/net/Makefile
similarity index 55%
rename from tools/testing/selftests/net-afpacket/Makefile
rename to tools/testing/selftests/net/Makefile
index 45f2ffb..bd6e272 100644
--- a/tools/testing/selftests/net-afpacket/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -1,18 +1,19 @@
-# Makefile for net-socket selftests
+# Makefile for net selftests
 
 CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 
 CFLAGS += -I../../../../usr/include/
 
-AF_PACKET_PROGS = psock_fanout
+NET_PROGS = socket psock_fanout
 
-all: $(AF_PACKET_PROGS)
+all: $(NET_PROGS)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
 run_tests: all
+	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
 	@/bin/sh ./run_afpackettests || echo "afpackettests: [FAIL]"
 
 clean:
-	$(RM) $(AF_PACKET_PROGS)
+	$(RM) $(NET_PROGS)
diff --git a/tools/testing/selftests/net-afpacket/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
similarity index 100%
rename from tools/testing/selftests/net-afpacket/psock_fanout.c
rename to tools/testing/selftests/net/psock_fanout.c
diff --git a/tools/testing/selftests/net-afpacket/run_afpackettests b/tools/testing/selftests/net/run_afpackettests
similarity index 100%
rename from tools/testing/selftests/net-afpacket/run_afpackettests
rename to tools/testing/selftests/net/run_afpackettests
diff --git a/tools/testing/selftests/net-socket/run_netsocktests b/tools/testing/selftests/net/run_netsocktests
similarity index 100%
rename from tools/testing/selftests/net-socket/run_netsocktests
rename to tools/testing/selftests/net/run_netsocktests
diff --git a/tools/testing/selftests/net-socket/socket.c b/tools/testing/selftests/net/socket.c
similarity index 100%
rename from tools/testing/selftests/net-socket/socket.c
rename to tools/testing/selftests/net/socket.c
-- 
1.7.11.7
