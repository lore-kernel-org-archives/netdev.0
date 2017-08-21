From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,4/4] hv_netvsc: Update netvsc Document for UDP hash level setting
Date: Mon, 21 Aug 2017 14:55:55 -0700
Message-ID: <1503352555-9256-4-git-send-email-haiyangz@exchange.microsoft.com>
References: <1503352555-9256-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503352555-9256-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Update Documentation/networking/netvsc.txt for UDP hash level setting
and related info.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 Documentation/networking/netvsc.txt |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/netvsc.txt b/Documentation/networking/netvsc.txt
index 4ddb4e4..fa8d863 100644
--- a/Documentation/networking/netvsc.txt
+++ b/Documentation/networking/netvsc.txt
@@ -21,11 +21,23 @@ Features
   --------------------
   Hyper-V supports receive side scaling. For TCP, packets are
   distributed among available queues based on IP address and port
-  number. Current versions of Hyper-V host, only distribute UDP
-  packets based on the IP source and destination address.
-  The port number is not used as part of the hash value for UDP.
-  Fragmented IP packets are not distributed between queues;
-  all fragmented packets arrive on the first channel.
+  number.
+
+  For UDP, we can switch UDP hash level between L3 and L4 by ethtool
+  command. UDP over IPv4 and v6 can be set differently. The default
+  hash level is L4. We currently only allow switching TX hash level
+  from within the guests.
+
+  On Azure, fragmented UDP packets have high loss rate with L4
+  hashing. Using L3 hashing is recommended in this case.
+
+  For example, for UDP over IPv4 on eth0:
+  To include UDP port numbers in hasing:
+        ethtool -N eth0 rx-flow-hash udp4 sdfn
+  To exclude UDP port numbers in hasing:
+        ethtool -N eth0 rx-flow-hash udp4 sd
+  To show UDP hash level:
+        ethtool -n eth0 rx-flow-hash udp4
 
   Generic Receive Offload, aka GRO
   --------------------------------
-- 
1.7.1
