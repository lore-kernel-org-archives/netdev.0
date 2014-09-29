From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Allow policer test to be ran
Date: Tue, 30 Sep 2014 01:22:22 +0300
Message-ID: <1412029342-9696-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35170 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbaI2Way (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 18:30:54 -0400
Received: by mail-la0-f48.google.com with SMTP id q1so7439567lam.35
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 15:30:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Renamed testsuite/tests/policer to testsuite/tests/policer.t

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/tests/policer   | 13 -------------
 testsuite/tests/policer.t | 13 +++++++++++++
 2 files changed, 13 insertions(+), 13 deletions(-)
 delete mode 100755 testsuite/tests/policer
 create mode 100755 testsuite/tests/policer.t

diff --git a/testsuite/tests/policer b/testsuite/tests/policer
deleted file mode 100755
index eaf16ac..0000000
--- a/testsuite/tests/policer
+++ /dev/null
@@ -1,13 +0,0 @@
-#!/bin/sh
-$TC qdisc del dev $DEV root >/dev/null 2>&1
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
-$TC qdisc list dev $DEV
-$TC filter list dev $DEV parent 10:0
-$TC qdisc del dev $DEV root
-$TC qdisc list dev $DEV
-$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
-$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
-$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
-$TC qdisc del dev $DEV root
diff --git a/testsuite/tests/policer.t b/testsuite/tests/policer.t
new file mode 100755
index 0000000..eaf16ac
--- /dev/null
+++ b/testsuite/tests/policer.t
@@ -0,0 +1,13 @@
+#!/bin/sh
+$TC qdisc del dev $DEV root >/dev/null 2>&1
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
+$TC qdisc list dev $DEV
+$TC filter list dev $DEV parent 10:0
+$TC qdisc del dev $DEV root
+$TC qdisc list dev $DEV
+$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
+$TC class add dev $DEV parent 10:0  classid 10:12   cbq bandwidth 100mbit rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
+$TC filter add dev $DEV parent 10:0 protocol ip prio 10 u32 match ip protocol 1 0xff police rate 2kbit buffer 10k drop flowid 10:12
+$TC qdisc del dev $DEV root
-- 
2.1.0
