From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: [PATCH] devicetree: net: micrel-ksz90x1.txt: Properly explain skew settings
Date: Wed,  5 Oct 2016 16:03:08 +0200
Message-ID: <1475676188-10639-1-git-send-email-mike.looijmans@topic.nl>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com,
        andrew@lunn.ch, f.fainelli@gmail.com,
        Mike Looijmans <mike.looijmans@topic.nl>
To: devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atl4mhob07.myregisteredsite.com ([209.17.115.45]:38970 "EHLO
        atl4mhob07.myregisteredsite.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754323AbcJEODT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 10:03:19 -0400
Received: from mailpod.hostingplatform.com ([10.30.71.209])
        by atl4mhob07.myregisteredsite.com (8.14.4/8.14.4) with ESMTP id u95E3Ffb014865
        for <netdev@vger.kernel.org>; Wed, 5 Oct 2016 10:03:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The KSZ9031 skew registers contain an offset, the chip's default value
is "neutral" which does not add any skew. Programming a 0 into a skew
property will actually set it the maximal negative adjustment and not
to a neutral position as one would expect.

Explain this situation in the devicetree binding documentation and list
the settings that the chip considers neutral.

Changing the implementation to accept negative values would have been
a better solution, but would break existing configurations.

Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
---
 Documentation/devicetree/bindings/net/micrel-ksz90x1.txt | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
index f9c32ad..c35b5b4 100644
--- a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
+++ b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
@@ -34,16 +34,17 @@ KSZ9031:
 
   All skew control options are specified in picoseconds. The minimum
   value is 0, and the maximum is property-dependent. The increment
-  step is 60ps.
+  step is 60ps. The default value is the neutral setting, so setting
+  rxc-skew-ps=<0> actually results in -900 picoseconds adjustment.
 
   Optional properties:
 
-    Maximum value of 1860:
+    Maximum value of 1860, default value 900:
 
       - rxc-skew-ps : Skew control of RX clock pad
       - txc-skew-ps : Skew control of TX clock pad
 
-    Maximum value of 900:
+    Maximum value of 900, default value 420:
 
       - rxdv-skew-ps : Skew control of RX CTL pad
       - txen-skew-ps : Skew control of TX CTL pad
-- 
1.9.1
