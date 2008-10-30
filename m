From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: mark BIC as experimental
Date: Thu, 30 Oct 2008 08:36:41 -0700
Message-ID: <20081030083641.55e936b0@extreme>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Injong Rhee" <rhee@eos.ncsu.edu>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45894 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbYJ3Pgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 11:36:47 -0400
In-Reply-To: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the configuration defaults to mark BIC as experimental.
BIC is too aggressive and was replaced by CUBIC. Debian was picking
BIC in their default config (should be fixed by now), but the configuration
documentation did not make it explicit that this was a bad idea.

Also update the URLs in the configuration documentation to current
locations.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/Kconfig	2008-10-29 14:58:40.000000000 -0700
+++ b/net/ipv4/Kconfig	2008-10-30 08:18:08.000000000 -0700
@@ -437,7 +437,8 @@ if TCP_CONG_ADVANCED
 
 config TCP_CONG_BIC
 	tristate "Binary Increase Congestion (BIC) control"
-	default m
+	depends on EXPERIMENTAL
+	default n
 	---help---
 	BIC-TCP is a sender-side only change that ensures a linear RTT
 	fairness under large windows while offering both scalability and
@@ -447,15 +448,24 @@ config TCP_CONG_BIC
 	increment ensures linear RTT fairness as well as good
 	scalability. Under small congestion windows, binary search
 	increase provides TCP friendliness.
-	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
+
+	BIC growth function is too aggressive and should not be used
+	except for testing and comparision, use CUBIC instead.
+
+	For further details see:
+           http://netsrv.csc.ncsu.edu/twiki/bin/view/Main/BIC
 
 config TCP_CONG_CUBIC
 	tristate "CUBIC TCP"
 	default y
 	---help---
-	This is version 2.0 of BIC-TCP which uses a cubic growth function
-	among other techniques.
-	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/cubic-paper.pdf
+	CUBIC TCP is an sender-side only modification to the congestion control
+	algothrim improved versions on the growth function of BIC and has an
+	improved slow start algoritm, called HyStart.
+
+	For further details see:
+           http://netsrv.csc.ncsu.edu/twiki/bin/view/Main/BIC
+
 
 config TCP_CONG_WESTWOOD
 	tristate "TCP Westwood+"
@@ -581,9 +591,6 @@ choice
 	  Select the TCP congestion control that will be used by default
 	  for all connections.
 
-	config DEFAULT_BIC
-		bool "Bic" if TCP_CONG_BIC=y
-
 	config DEFAULT_CUBIC
 		bool "Cubic" if TCP_CONG_CUBIC=y
 
@@ -610,7 +617,6 @@ config TCP_CONG_CUBIC
 
 config DEFAULT_TCP_CONG
 	string
-	default "bic" if DEFAULT_BIC
 	default "cubic" if DEFAULT_CUBIC
 	default "htcp" if DEFAULT_HTCP
 	default "vegas" if DEFAULT_VEGAS
