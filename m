From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/3] pktgen: remove sample script
 pktgen.conf-1-1-rdos
Date: Wed, 13 Jul 2016 22:06:15 +0200
Message-ID: <20160713200615.21875.23607.stgit@firesoul>
References: <20160713200525.21875.21960.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbcGMUGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:06:41 -0400
In-Reply-To: <20160713200525.21875.21960.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the pktgen sample script pktgen.conf-1-1-rdos, because
it does not contain anything that is not covered by the other and
newer style sample scripts.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/pktgen.conf-1-1-rdos |   64 -----------------------------------
 1 file changed, 64 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-rdos

diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
deleted file mode 100755
index c7553be49b80..000000000000
--- a/samples/pktgen/pktgen.conf-1-1-rdos
+++ /dev/null
@@ -1,64 +0,0 @@
-#!/bin/bash
-
-#modprobe pktgen
-
-
-function pgset() {
-    local result
-
-    echo $1 > $PGDEV
-
-    result=`cat $PGDEV | fgrep "Result: OK:"`
-    if [ "$result" = "" ]; then
-         cat $PGDEV | fgrep Result:
-    fi
-}
-
-# Config Start Here -----------------------------------------------------------
-
-
-# thread config
-# Each CPU has its own thread. One CPU example. We add eth1.
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-
-
-# device config
-# delay 0
-
-# We need to do alloc for every skb since we cannot clone here.
-
-CLONE_SKB="clone_skb 0"
-# NIC adds 4 bytes CRC
-PKT_SIZE="pkt_size 60"
-
-# COUNT 0 means forever
-#COUNT="count 0"
-COUNT="count 10000000"
-DELAY="delay 0"
-
-PGDEV=/proc/net/pktgen/eth1
-  echo "Configuring $PGDEV"
- pgset "$COUNT"
- pgset "$CLONE_SKB"
- pgset "$PKT_SIZE"
- pgset "$DELAY"
- # Random address with in the min-max range
- pgset "flag IPDST_RND"
- pgset "dst_min 10.0.0.0"
- pgset "dst_max 10.255.255.255"
-
- pgset "dst_mac  00:04:23:08:91:dc"
-
-# Time to run
-PGDEV=/proc/net/pktgen/pgctrl
-
- echo "Running... ctrl^C to stop"
- trap true INT
- pgset "start"
- echo "Done"
- cat /proc/net/pktgen/eth1
