From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/2] pktgen: Specify num packets per thread
Date: Tue, 13 Jun 2017 18:04:48 +0300
Message-ID: <1497366289-22255-2-git-send-email-tariqt@mellanox.com>
References: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34392 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753175AbdFMPFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:05:09 -0400
In-Reply-To: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use -n <num>, to specify the number of packets every
thread sends.
Zero means indefinitely.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/README.rst                              | 1 +
 samples/pktgen/parameters.sh                           | 7 ++++++-
 samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh | 2 +-
 samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh    | 2 +-
 samples/pktgen/pktgen_sample01_simple.sh               | 2 +-
 samples/pktgen/pktgen_sample02_multiqueue.sh           | 3 ++-
 samples/pktgen/pktgen_sample03_burst_single_flow.sh    | 2 +-
 samples/pktgen/pktgen_sample04_many_flows.sh           | 2 +-
 samples/pktgen/pktgen_sample05_flow_per_thread.sh      | 2 +-
 9 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/samples/pktgen/README.rst b/samples/pktgen/README.rst
index 8365c4e5c513..c018d67da1a1 100644
--- a/samples/pktgen/README.rst
+++ b/samples/pktgen/README.rst
@@ -22,6 +22,7 @@ across the sample scripts.  Usage example is printed on errors::
   -m : ($DST_MAC)   destination MAC-addr
   -t : ($THREADS)   threads to start
   -c : ($SKB_CLONE) SKB clones send before alloc new SKB
+  -n : ($COUNT)     num messages to send per thread, 0 means indefinitely
   -b : ($BURST)     HW level bursting of SKBs
   -v : ($VERBOSE)   verbose
   -x : ($DEBUG)     debug
diff --git a/samples/pktgen/parameters.sh b/samples/pktgen/parameters.sh
index f70ea7dd5660..036147594a20 100644
--- a/samples/pktgen/parameters.sh
+++ b/samples/pktgen/parameters.sh
@@ -11,6 +11,7 @@ function usage() {
     echo "  -m : (\$DST_MAC)   destination MAC-addr"
     echo "  -t : (\$THREADS)   threads to start"
     echo "  -c : (\$SKB_CLONE) SKB clones send before alloc new SKB"
+    echo "  -n : (\$COUNT)     num messages to send per thread, 0 means indefinitely"
     echo "  -b : (\$BURST)     HW level bursting of SKBs"
     echo "  -v : (\$VERBOSE)   verbose"
     echo "  -x : (\$DEBUG)     debug"
@@ -20,7 +21,7 @@ function usage() {
 
 ##  --- Parse command line arguments / parameters ---
 ## echo "Commandline options:"
-while getopts "s:i:d:m:t:c:b:vxh6" option; do
+while getopts "s:i:d:m:t:c:n:b:vxh6" option; do
     case $option in
         i) # interface
           export DEV=$OPTARG
@@ -48,6 +49,10 @@ while getopts "s:i:d:m:t:c:b:vxh6" option; do
 	  export CLONE_SKB=$OPTARG
 	  info "CLONE_SKB=$CLONE_SKB"
           ;;
+        n)
+	  export COUNT=$OPTARG
+	  info "COUNT=$COUNT"
+          ;;
         b)
 	  export BURST=$OPTARG
 	  info "SKB bursting: BURST=$BURST"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
index f3e1bedfd77f..d2694a12de61 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
@@ -39,10 +39,10 @@ if [ -z "$DEST_IP" ]; then
 fi
 [ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$BURST" ] && BURST=1024
+[ -z "$COUNT" ] && COUNT="10000000" # Zero means indefinitely
 
 # Base Config
 DELAY="0"        # Zero means max speed
-COUNT="10000000" # Zero means indefinitely
 
 # General cleanup everything since last run
 pg_ctrl "reset"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
index cc102e923241..43604c2db726 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
@@ -22,10 +22,10 @@ fi
 if [[ -n "$BURST" ]]; then
     err 1 "Bursting not supported for this mode"
 fi
+[ -z "$COUNT" ] && COUNT="10000000" # Zero means indefinitely
 
 # Base Config
 DELAY="0"        # Zero means max speed
-COUNT="10000000" # Zero means indefinitely
 
 # General cleanup everything since last run
 pg_ctrl "reset"
diff --git a/samples/pktgen/pktgen_sample01_simple.sh b/samples/pktgen/pktgen_sample01_simple.sh
index 29ef4ba50796..35b7fe34bda2 100755
--- a/samples/pktgen/pktgen_sample01_simple.sh
+++ b/samples/pktgen/pktgen_sample01_simple.sh
@@ -20,10 +20,10 @@ fi
 [ -z "$CLONE_SKB" ] && CLONE_SKB="0"
 # Example enforce param "-m" for dst_mac
 [ -z "$DST_MAC" ] && usage && err 2 "Must specify -m dst_mac"
+[ -z "$COUNT" ]   && COUNT="100000" # Zero means indefinitely
 
 # Base Config
 DELAY="0"        # Zero means max speed
-COUNT="100000"   # Zero means indefinitely
 
 # Flow variation random source port between min and max
 UDP_MIN=9
diff --git a/samples/pktgen/pktgen_sample02_multiqueue.sh b/samples/pktgen/pktgen_sample02_multiqueue.sh
index c88a161d3e6f..164194d1c79b 100755
--- a/samples/pktgen/pktgen_sample02_multiqueue.sh
+++ b/samples/pktgen/pktgen_sample02_multiqueue.sh
@@ -13,9 +13,10 @@ root_check_run_with_sudo "$@"
 # Required param: -i dev in $DEV
 source ${basedir}/parameters.sh
 
+[ -z "$COUNT" ] && COUNT="100000" # Zero means indefinitely
+
 # Base Config
 DELAY="0"        # Zero means max speed
-COUNT="100000"   # Zero means indefinitely
 [ -z "$CLONE_SKB" ] && CLONE_SKB="0"
 
 # Flow variation random source port between min and max
diff --git a/samples/pktgen/pktgen_sample03_burst_single_flow.sh b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
index 80cf8f5ba6b2..e03dd4cd05ce 100755
--- a/samples/pktgen/pktgen_sample03_burst_single_flow.sh
+++ b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
@@ -31,10 +31,10 @@ fi
 [ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$BURST" ]     && BURST=32
 [ -z "$CLONE_SKB" ] && CLONE_SKB="100000"
+[ -z "$COUNT" ]     && COUNT="0" # Zero means indefinitely
 
 # Base Config
 DELAY="0"  # Zero means max speed
-COUNT="0"  # Zero means indefinitely
 
 # General cleanup everything since last run
 pg_ctrl "reset"
diff --git a/samples/pktgen/pktgen_sample04_many_flows.sh b/samples/pktgen/pktgen_sample04_many_flows.sh
index f60412e445bb..0fc72d2bcd31 100755
--- a/samples/pktgen/pktgen_sample04_many_flows.sh
+++ b/samples/pktgen/pktgen_sample04_many_flows.sh
@@ -15,6 +15,7 @@ source ${basedir}/parameters.sh
 [ -z "$DEST_IP" ]   && DEST_IP="198.18.0.42"
 [ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$CLONE_SKB" ] && CLONE_SKB="0"
+[ -z "$COUNT" ]     && COUNT="0" # Zero means indefinitely
 
 # NOTICE:  Script specific settings
 # =======
@@ -26,7 +27,6 @@ source ${basedir}/parameters.sh
 
 # Base Config
 DELAY="0"  # Zero means max speed
-COUNT="0"  # Zero means indefinitely
 
 if [[ -n "$BURST" ]]; then
     err 1 "Bursting not supported for this mode"
diff --git a/samples/pktgen/pktgen_sample05_flow_per_thread.sh b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
index 32ad818e2829..f4fb79409fd0 100755
--- a/samples/pktgen/pktgen_sample05_flow_per_thread.sh
+++ b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
@@ -20,11 +20,11 @@ source ${basedir}/parameters.sh
 [ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$CLONE_SKB" ] && CLONE_SKB="0"
 [ -z "$BURST" ]     && BURST=32
+[ -z "$COUNT" ]     && COUNT="0" # Zero means indefinitely
 
 
 # Base Config
 DELAY="0"  # Zero means max speed
-COUNT="0"  # Zero means indefinitely
 
 # General cleanup everything since last run
 pg_ctrl "reset"
-- 
1.8.3.1
