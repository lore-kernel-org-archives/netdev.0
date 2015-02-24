From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 03/10] samples/pktgen: Add sample scripts for
 pktgen facility
Date: Tue, 24 Feb 2015 02:32:07 +0000
Message-ID: <1424745127.4443.4.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Robert Olsson <robert@herjulf.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55297 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbBXCcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:32:11 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are Robert Olsson's samples which used to be available from
<ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/>
but currently are not.

Change the documentation to refer to these consistently as 'sample
scripts', matching the directory name used here.

Cc: Robert Olsson <robert@herjulf.se>
Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 Documentation/networking/pktgen.txt     |   12 ++---
 samples/pktgen/pktgen.conf-1-1          |   66 +++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-flows    |   74 ++++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-ip6      |   67 +++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |   70 ++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-rdos     |   71 ++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-2          |   76 ++++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-2-1          |   72 +++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-2-2          |   82 +++++++++++++++++++++++++++++++
 9 files changed, 584 insertions(+), 6 deletions(-)
 create mode 100755 samples/pktgen/pktgen.conf-1-1
 create mode 100755 samples/pktgen/pktgen.conf-1-1-flows
 create mode 100755 samples/pktgen/pktgen.conf-1-1-ip6
 create mode 100755 samples/pktgen/pktgen.conf-1-1-ip6-rdos
 create mode 100755 samples/pktgen/pktgen.conf-1-1-rdos
 create mode 100755 samples/pktgen/pktgen.conf-1-2
 create mode 100755 samples/pktgen/pktgen.conf-2-1
 create mode 100755 samples/pktgen/pktgen.conf-2-2

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index fa0ad87e6597..24c6dc100e02 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -92,8 +92,8 @@ Result: OK: 13101142(c12220741+d880401) usec, 10000000 (60byte,0frags)
 
 Configuring threads and devices
 ================================
-This is done via the /proc interface, and most easily done via pgset in
-the scripts.
+This is done via the /proc interface, and most easily done via pgset
+as defined in the sample scripts.
 
 Examples:
 
@@ -192,11 +192,11 @@ Examples:
  pgset "rate 300M"        set rate to 300 Mb/s
  pgset "ratep 1000000"    set rate to 1Mpps
 
-Example scripts
-===============
+Sample scripts
+==============
 
-A collection of small tutorial scripts for pktgen is in the examples
-directory:
+A collection of small tutorial scripts for pktgen is in the
+samples/pktgen directory:
 
 pktgen.conf-1-1                  # 1 CPU 1 dev 
 pktgen.conf-1-2                  # 1 CPU 2 dev
diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
new file mode 100755
index 000000000000..fb2a1e108690
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-1
@@ -0,0 +1,66 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0 means maximum speed.
+
+CLONE_SKB="clone_skb 1000000"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 10.10.11.2" 
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
new file mode 100755
index 000000000000..634a860a745c
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-1-flows
@@ -0,0 +1,74 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0
+# We need to do alloc for every skb since we cannot clone here.
+
+CLONE_SKB="clone_skb 0"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ # Random address with in the min-max range
+ pgset "flag IPDST_RND" 
+ pgset "dst_min 10.0.0.0" 
+ pgset "dst_max 10.255.255.255" 
+
+ # 8k Concurrent flows at 4 pkts
+ pgset "flows 8192" 
+ pgset "flowlen 4" 
+
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6 b/samples/pktgen/pktgen.conf-1-1-ip6
new file mode 100755
index 000000000000..05a59fea3b49
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-1-ip6
@@ -0,0 +1,67 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# IPv6. Note increase in minimal packet length
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0
+
+CLONE_SKB="clone_skb 1000000"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 66"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst6 fec0::1"
+ pgset "src6 fec0::2"
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-ip6-rdos b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
new file mode 100755
index 000000000000..15bf3fb724a2
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-1-ip6-rdos
@@ -0,0 +1,70 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+# IPv6. Note increase in minimal packet length
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0 means maximum speed.
+
+# We need to do alloc for every skb since we cannot clone here.
+CLONE_SKB="clone_skb 0"
+
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 66"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst6_min fec0::1"
+ pgset "dst6_max fec0::FFFF:FFFF"
+
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-1-rdos b/samples/pktgen/pktgen.conf-1-1-rdos
new file mode 100755
index 000000000000..d170b5374ae2
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-1-rdos
@@ -0,0 +1,71 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0
+
+# We need to do alloc for every skb since we cannot clone here.
+
+CLONE_SKB="clone_skb 0"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ # Random address with in the min-max range
+ pgset "flag IPDST_RND" 
+ pgset "dst_min 10.0.0.0" 
+ pgset "dst_max 10.255.255.255" 
+
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-1-2 b/samples/pktgen/pktgen.conf-1-2
new file mode 100755
index 000000000000..aab32737bf18
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-1-2
@@ -0,0 +1,76 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# One CPU means one thread. One CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Adding eth2"
+ pgset "add_device eth2" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0 means maximum speed.
+
+CLONE_SKB="clone_skb 1000000"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 10.10.11.2" 
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+PGDEV=/proc/net/pktgen/eth2
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 192.168.2.2"
+ pgset "dst_mac  00:04:23:08:91:de"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth[1,2]
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
new file mode 100755
index 000000000000..375bc1d2af53
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-2-1
@@ -0,0 +1,72 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+# We need to remove old config since we dont use this thread. We can only
+# one NIC on one CPU due to affinity reasons.
+
+PGDEV=/proc/net/pktgen/kpktgend_1
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+
+# device config
+# delay 0 means maximum speed.
+
+CLONE_SKB="clone_skb 1000000"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 10.10.11.2" 
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
new file mode 100755
index 000000000000..de800d1d8fbe
--- /dev/null
+++ b/samples/pktgen/pktgen.conf-2-2
@@ -0,0 +1,82 @@
+#! /bin/sh
+
+#modprobe pktgen
+
+
+function pgset() {
+    local result
+
+    echo $1 > $PGDEV
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [ "$result" = "" ]; then
+         cat $PGDEV | fgrep Result:
+    fi
+}
+
+function pg() {
+    echo inject > $PGDEV
+    cat $PGDEV
+}
+
+# Config Start Here -----------------------------------------------------------
+
+
+# thread config
+# Each CPU has own thread. Two CPU exammple. We add eth1, eth2 respectivly.
+
+PGDEV=/proc/net/pktgen/kpktgend_0
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth1"
+ pgset "add_device eth1" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+PGDEV=/proc/net/pktgen/kpktgend_1
+  echo "Removing all devices"
+ pgset "rem_device_all" 
+  echo "Adding eth2"
+ pgset "add_device eth2" 
+  echo "Setting max_before_softirq 10000"
+ pgset "max_before_softirq 10000"
+
+
+# device config
+# delay 0 means maximum speed.
+
+CLONE_SKB="clone_skb 1000000"
+# NIC adds 4 bytes CRC
+PKT_SIZE="pkt_size 60"
+
+# COUNT 0 means forever
+#COUNT="count 0"
+COUNT="count 10000000"
+DELAY="delay 0"
+
+PGDEV=/proc/net/pktgen/eth1
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 10.10.11.2" 
+ pgset "dst_mac  00:04:23:08:91:dc"
+
+PGDEV=/proc/net/pktgen/eth2
+  echo "Configuring $PGDEV"
+ pgset "$COUNT"
+ pgset "$CLONE_SKB"
+ pgset "$PKT_SIZE"
+ pgset "$DELAY"
+ pgset "dst 192.168.2.2"
+ pgset "dst_mac  00:04:23:08:91:de"
+
+# Time to run
+PGDEV=/proc/net/pktgen/pgctrl
+
+ echo "Running... ctrl^C to stop"
+ pgset "start" 
+ echo "Done"
+
+# Result can be vieved in /proc/net/pktgen/eth[1,2]
-- 
1.7.10.4
