From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] ipv6: Update ip-sysctl.txt documentation for recent changes
 to accept_ra and forwarding
Date: Fri, 3 Sep 2010 11:47:30 -0400
Message-ID: <20100903154729.GA27681@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, davem@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38003 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab0ICPrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 11:47:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation for recent changes to the tunables accept_ra and
forwarding.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-2.6/Documentation/networking/ip-sysctl.txt
===================================================================
--- net-2.6.orig/Documentation/networking/ip-sysctl.txt
+++ net-2.6/Documentation/networking/ip-sysctl.txt
@@ -1014,6 +1014,12 @@ conf/interface/*:
 accept_ra - BOOLEAN
 	Accept Router Advertisements; autoconfigure using them.
 
+	Possible values are:
+		0 Do not accept Router Advertisements.
+		1 Accept Router Advertisements if forwarding is disabled.
+		2 Overrule forwarding behaviour. Accept Router Advertisements
+		  even if forwarding is enabled.
+
 	Functional default: enabled if local forwarding is disabled.
 			    disabled if local forwarding is enabled.
 
@@ -1075,7 +1081,12 @@ forwarding - BOOLEAN
 	Note: It is recommended to have the same setting on all
 	interfaces; mixed router/host scenarios are rather uncommon.
 
-	FALSE:
+	Possible values are:
+		0 Forwarding disabled
+		1 Forwarding enabled
+		2 Forwarding enabled (Hybrid Mode)
+
+	FALSE (0):
 
 	By default, Host behaviour is assumed.  This means:
 
@@ -1085,18 +1096,24 @@ forwarding - BOOLEAN
 	   Advertisements (and do autoconfiguration).
 	4. If accept_redirects is TRUE (default), accept Redirects.
 
-	TRUE:
+	TRUE (1):
 
 	If local forwarding is enabled, Router behaviour is assumed.
 	This means exactly the reverse from the above:
 
 	1. IsRouter flag is set in Neighbour Advertisements.
 	2. Router Solicitations are not sent.
-	3. Router Advertisements are ignored.
+	3. Router Advertisements are ignored unless accept_ra is 2.
 	4. Redirects are ignored.
 
-	Default: FALSE if global forwarding is disabled (default),
-		 otherwise TRUE.
+	TRUE (2):
+
+	Hybrid mode. Same behaviour as TRUE, except for:
+
+	2. Router Solicitations are being sent when necessary.
+
+	Default: 0 (disabled) if global forwarding is disabled (default),
+		 otherwise 1 (enabled).
 
 hop_limit - INTEGER
 	Default Hop Limit to set.
