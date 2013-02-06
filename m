From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH iproute2] Use pkg-config to obtain xtables.h path
Date: Wed,  6 Feb 2013 16:19:24 -0500
Message-ID: <1360185564-29094-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:60575 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758103Ab3BFV1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:27:22 -0500
Received: by mail-vb0-f48.google.com with SMTP id fc21so1175305vbb.35
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 13:27:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On openSUSE 12.2 (at least) xtables.h is not installed in the system-wide
include dir but in /usr/include/iptables-1.4.16.3/. This results in the
following build failure:
em_ipset.c:26:21: fatal error: xtables.h: No such file or directory

Other includers of xtables.h already call out to pkg-config
---
 tc/Makefile |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/tc/Makefile b/tc/Makefile
index 696f891..f26e764 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -140,6 +140,8 @@ m_xt.so: m_xt.c
 m_xt_old.so: m_xt_old.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$($(PKG_CONFIG) xtables --cflags --libs)
 
+em_ipset.o: CFLAGS += $$($(PKG_CONFIG) xtables --cflags)
+
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
 
-- 
1.7.10.4
