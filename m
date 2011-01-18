From: holger@eitzenberger.org
Subject: [patch 1/4] ipset: show correct line numbers in restore output
Date: Tue, 18 Jan 2011 15:21:55 +0100
Message-ID: <20110118142247.001984763@eitzenberger.org>
References: <20110118142154.697547841@eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:62466 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab1AROWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:22:50 -0500
Content-Disposition: inline; filename=ipset-show-correct-line-number.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When passing something like

  create foo6 hash:ip hashsize 64 family inet6
  add foo6 20a1:1234:5678::/64
  add foo6 20a1:1234:5679::/64

you get:

  ipset v5.2: Error in line 1: Syntax error: plain IP address must be supplied: 20a1:1234:5678::/64

Should be line 2 though.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: ipset/lib/session.c
===================================================================
--- ipset.orig/lib/session.c	2011-01-05 18:59:59.000000000 +0100
+++ ipset/lib/session.c	2011-01-07 13:11:33.000000000 +0100
@@ -194,7 +194,7 @@
 
 	if (session->lineno != 0 && type == IPSET_ERROR) {
 		sprintf(session->report, "Error in line %u: ",
-			session->lineno);
+			session->lineno + 1);
 	}
 	offset = strlen(session->report);
 	

-- 
