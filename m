From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Mark frame diverter for future removal.
Date: Thu, 14 Sep 2006 12:04:56 +0900
Message-ID: <20060914120456.4291a16d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benwa@club-internet.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13794 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751065AbWINDFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 23:05:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code for frame diverter is unmaintained and has bitrotted.
The number of users is very small and the code has lots of problems.
If anyone is using it, they maybe exposing themselves to bad packet attacks.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 Documentation/feature-removal-schedule.txt |   13 +++++++++++++
 net/Kconfig                                |    2 +-
 2 files changed, 14 insertions(+), 1 deletions(-)

3e7063a07247fa424ba225f09c6d9df1a39ac7ba
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 87851ef..d0ef166 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -274,3 +274,16 @@ Why:	The deferred output hooks are a lay
 Who:	Patrick McHardy <kaber@trash.net>
 
 ---------------------------
+
+What:	frame diverter
+When:	November 2006
+Why:	The frame diverter is included in most distribution kernels, but is
+	broken. It does not correctly handle many things:
+	- IPV6
+	- non-linear skb's
+	- network device RCU on removal
+	- input frames not correctly checked for protocol errors
+	It also adds allocation overhead even if not enabled.
+	It is not clear if anyone is still using it.
+Who:	Stephen Hemminger <shemminger@osdl.org>	
+
diff --git a/net/Kconfig b/net/Kconfig
index 246125c..6528a93 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -177,7 +177,7 @@ source "net/lapb/Kconfig"
 
 config NET_DIVERT
 	bool "Frame Diverter (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	depends on EXPERIMENTAL && BROKEN
 	---help---
 	  The Frame Diverter allows you to divert packets from the
 	  network, that are not aimed at the interface receiving it (in
-- 
1.1.3
