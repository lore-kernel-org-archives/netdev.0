From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/4] samples/pktgen: remove remaining old pktgen
 sample scripts
Date: Wed, 01 Nov 2017 11:41:24 +0100
Message-ID: <150953288445.29671.5235599066338592919.stgit@firesoul>
References: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.se>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        robert.hu@intel.com, pabeni@redhat.com, kafai@fb.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753637AbdKAKl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:41:28 -0400
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0f06a6787e05 ("samples: Add an IPv6 '-6' option to the
pktgen scripts") the newer pktgen_sampleXX script does show howto use
IPv6 with pktgen.

Thus, there is no longer a reason to keep the older sample scripts around.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/pktgen.conf-1-1-ip6      |   60 ---------------------------
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |   63 ----------------------------
 samples/pktgen/pktgen.conf-1-2          |   69 -------------------------------
 3 files changed, 192 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-ip6
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-ip6-rdos
 delete mode 100755 samples/pktgen/pktgen.conf-1-2

diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
deleted file mode 100755
index 0b9ffd47fd41..000000000000
--- a/samples/pktgen/pktgen.conf-1-1-ip6
+++ /dev/null
@@ -1,60 +0,0 @@
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
-# IPv6. Note increase in minimal packet length
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
-CLONE_SKB="clone_skb 1000000"
-# NIC adds 4 bytes CRC
-PKT_SIZE="pkt_size 66"
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
- pgset "dst6 fec0::1"
- pgset "src6 fec0::2"
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
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
deleted file mode 100755
index ad98e5f40776..000000000000
--- a/samples/pktgen/pktgen.conf-1-1-ip6-rdos
+++ /dev/null
@@ -1,63 +0,0 @@
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
-# IPv6. Note increase in minimal packet length
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-
-
-# device config
-# delay 0 means maximum speed.
-
-# We need to do alloc for every skb since we cannot clone here.
-CLONE_SKB="clone_skb 0"
-
-# NIC adds 4 bytes CRC
-PKT_SIZE="pkt_size 66"
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
- pgset "dst6_min fec0::1"
- pgset "dst6_max fec0::FFFF:FFFF"
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
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
deleted file mode 100755
index ba4eb26e168d..000000000000
--- a/samples/pktgen/pktgen.conf-1-2
+++ /dev/null
@@ -1,69 +0,0 @@
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
-# One CPU means one thread. One CPU example. We add eth1, eth2 respectivly.
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-  echo "Adding eth2"
- pgset "add_device eth2"
-
-
-# device config
-# delay 0 means maximum speed.
-
-CLONE_SKB="clone_skb 1000000"
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
- pgset "dst 10.10.11.2"
- pgset "dst_mac  00:04:23:08:91:dc"
-
-PGDEV=/proc/net/pktgen/eth2
-  echo "Configuring $PGDEV"
- pgset "$COUNT"
- pgset "$CLONE_SKB"
- pgset "$PKT_SIZE"
- pgset "$DELAY"
- pgset "dst 192.168.2.2"
- pgset "dst_mac  00:04:23:08:91:de"
-
-# Time to run
-PGDEV=/proc/net/pktgen/pgctrl
-
- echo "Running... ctrl^C to stop"
- trap true INT
- pgset "start"
- echo "Done"
- cat /proc/net/pktgen/eth1 /proc/net/pktgen/eth2
