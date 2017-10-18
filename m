From: Donald Sharp <sharpd@cumulusnetworks.com>
Subject: [PATCH] doc: Update VRF documentation metric
Date: Wed, 18 Oct 2017 10:24:28 -0400
Message-ID: <20171018142428.26398-1-sharpd@cumulusnetworks.com>
To: netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:46863 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdJROYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:24:37 -0400
Received: by mail-qk0-f195.google.com with SMTP id k123so6435258qke.3
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:24:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two things:

1) Update examples to show usage of metric
2) Discuss reasoning for using such a high metric.

Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
---
 Documentation/networking/vrf.txt | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
index 3918dae..8ff7b4c 100644
--- a/Documentation/networking/vrf.txt
+++ b/Documentation/networking/vrf.txt
@@ -71,7 +71,12 @@ Setup
        ip ru add iif vrf-blue table 10
 
 3. Set the default route for the table (and hence default route for the VRF).
-       ip route add table 10 unreachable default
+       ip route add table 10 unreachable default metric 4278198272
+
+   This high metric value ensures that the default unreachable route can
+   be overridden by a routing protocol suite.  FRRouting interprets
+   kernel metrics as a combined admin distance (upper byte) and priority
+   (lower 3 bytes).  Thus the above metric translates to [255/8192].
 
 4. Enslave L3 interfaces to a VRF device.
        ip link set dev eth1 master vrf-blue
@@ -256,7 +261,7 @@ older form without it.
 
    For example:
    $ ip route show vrf red
-   prohibit default
+   unreachable default  metric 4278198272
    broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
    10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
    local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
@@ -282,7 +287,7 @@ older form without it.
    ff00::/8 dev red  metric 256  pref medium
    ff00::/8 dev eth1  metric 256  pref medium
    ff00::/8 dev eth2  metric 256  pref medium
-
+   unreachable default dev lo  metric 4278198272  error -101 pref medium
 
 8. Route Lookup for a VRF
 
@@ -331,7 +336,7 @@ function vrf_create
     ip link add ${VRF} type vrf table ${TBID}
 
     if [ "${VRF}" != "mgmt" ]; then
-        ip route add table ${TBID} unreachable default
+        ip route add table ${TBID} unreachable default metric 4278198272
     fi
     ip link set dev ${VRF} up
 }
-- 
2.9.5
