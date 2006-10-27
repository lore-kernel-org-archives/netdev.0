From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 10:30:16 -0700
Message-ID: <20061027103016.3e8514d7@freekitty>
References: <4540F076.70801@psc.edu>
	<20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
	<20061026.170221.99202188.davem@davemloft.net>
	<20061027104311.GB3967@c3po.0xdef.net>
	<20061027074102.2a6fef4b@localhost.localdomain>
	<20061027152157.GB4632@c3po.0xdef.net>
	<45422A31.7070806@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, jheffner@psc.edu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2792 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752325AbWJ0Raw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 13:30:52 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <45422A31.7070806@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My proposed method restricting TCP choices to fair algorithms.
This a net wide, not system wide issue, it should not be done
by kernel policy choice (capability), but by a build choice.

--- sky2.orig/net/ipv4/Kconfig	2006-10-27 10:10:47.000000000 -0700
+++ sky2/net/ipv4/Kconfig	2006-10-27 10:15:56.000000000 -0700
@@ -470,6 +470,16 @@
 
 if TCP_CONG_ADVANCED
 
+config TCP_CONG_UNFAIR
+        bool "Allow unfair congestion control algorithms"
+	depends on EXPERIMENTAL
+        ---help---
+	  Some of the congestion control algorithms are for testing
+	  and research purposes and should not deployed on public
+	  networks because of the possiblity of unfair behavior.
+	  These algorithms may be useful for future development
+	  or comparison purposes.
+
 config TCP_CONG_BIC
 	tristate "Binary Increase Congestion (BIC) control"
 	default m
@@ -551,7 +561,7 @@
 
 config TCP_CONG_SCALABLE
 	tristate "Scalable TCP"
-	depends on EXPERIMENTAL
+	depends on TCP_CONG_UNFAIR
 	default n
 	---help---
 	Scalable TCP is a sender-side only change to TCP which uses a
