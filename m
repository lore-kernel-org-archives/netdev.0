From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: make cubic the default
Date: Wed, 20 Sep 2006 13:32:58 -0700
Message-ID: <20060920133258.36ff42ce@localhost.localdomain>
References: <20060919214304.GB13543@outpost.ds9a.nl>
	<20060919.154435.102044066.davem@davemloft.net>
	<20060919160202.23390471@localhost.localdomain>
	<20060919.160441.66322371.davem@davemloft.net>
	<20060919162355.3a22fec1@localhost.localdomain>
	<20060920081704.GA1812@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39894 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750882AbWITUdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 16:33:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060920081704.GA1812@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change default congestion control used from BIC to the newer CUBIC
which it the successor to BIC but has better properties over long delay links.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/ipv4/Kconfig |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- net-test.orig/net/ipv4/Kconfig	2006-09-20 12:22:06.000000000 -0700
+++ net-test/net/ipv4/Kconfig	2006-09-20 13:31:21.000000000 -0700
@@ -454,7 +454,7 @@
 	  modules.
 
 	  Nearly all users can safely say no here, and a safe default
-	  selection will be made (BIC-TCP with new Reno as a fallback).
+	  selection will be made (CUBIC with new Reno as a fallback).
 
 	  If unsure, say N.
 
@@ -462,7 +462,7 @@
 
 config TCP_CONG_BIC
 	tristate "Binary Increase Congestion (BIC) control"
-	default y
+	default m
 	---help---
 	BIC-TCP is a sender-side only change that ensures a linear RTT
 	fairness under large windows while offering both scalability and
@@ -476,7 +476,7 @@
 
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
-	default m
+	default y
 	---help---
 	This is version 2.0 of BIC-TCP which uses a cubic growth function
 	among other techniques.
@@ -573,7 +573,7 @@
 
 choice
 	prompt "Default TCP congestion control"
-	default DEFAULT_BIC
+	default DEFAULT_CUBIC
 	help
 	  Select the TCP congestion control that will be used by default
 	  for all connections.
@@ -600,7 +600,7 @@
 
 endif
 
-config TCP_CONG_BIC
+config TCP_CONG_CUBIC
 	tristate
 	depends on !TCP_CONG_ADVANCED
 	default y
@@ -613,7 +613,7 @@
 	default "vegas" if DEFAULT_VEGAS
 	default "westwood" if DEFAULT_WESTWOOD
 	default "reno" if DEFAULT_RENO
-	default "bic"
+	default "cubic"
 
 source "net/ipv4/ipvs/Kconfig"
 
