From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 17:17:01 +1000
Message-ID: <20100825071701.GA14962@kryten>
References: <20100825071626.GA13681@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: miltonm@bga.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33276 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab0HYHRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 03:17:40 -0400
Content-Disposition: inline
In-Reply-To: <20100825071626.GA13681@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We were hard coding 4096 when sizing sysctl_tcp_max_orphans which
causes problems when PAGE_SIZE is not 4k. We calculate an order based on
PAGE_SHIFT so the count should be based on PAGE_SIZE

Signed-off-By: Milton Miller <miltonm@bga.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: powerpc.git/net/ipv4/tcp.c
===================================================================
--- powerpc.git.orig/net/ipv4/tcp.c	2010-08-25 17:04:51.190305401 +1000
+++ powerpc.git/net/ipv4/tcp.c	2010-08-25 17:05:15.463884764 +1000
@@ -3270,7 +3270,7 @@ void __init tcp_init(void)
 		;
 	if (order >= 4) {
 		tcp_death_row.sysctl_max_tw_buckets = 180000;
-		sysctl_tcp_max_orphans = 4096 << (order - 4);
+		sysctl_tcp_max_orphans = PAGE_SIZE << (order - 4);
 		sysctl_max_syn_backlog = 1024;
 	} else if (order < 3) {
 		tcp_death_row.sysctl_max_tw_buckets >>= (3 - order);
