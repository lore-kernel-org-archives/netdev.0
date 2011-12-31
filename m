From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: proper detection of libxtables position and flags
Date: Sat, 31 Dec 2011 23:17:56 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:50002 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab1LaWR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 17:17:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: 2011-09-24 23:37:34.405739159 +0200
Upstream: not sent yet

Any tests involving iptables _MUST_ utilize pkg-config to find the
proper locations of the installation. 

---
 configure   |    2 +-
 tc/Makefile |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: iproute2-2.6.39/configure
===================================================================
--- iproute2-2.6.39.orig/configure
+++ iproute2-2.6.39/configure
@@ -49,7 +49,7 @@ int main(int argc, char **argv)
 
 EOF
 
-if gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl -lxtables >/dev/null 2>&1
+if gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL $(pkg-config xtables --cflags --libs) -ldl >/dev/null 2>&1
 then
 	echo "TC_CONFIG_XT:=y" >>Config
 	echo "using xtables"
Index: iproute2-2.6.39/tc/Makefile
===================================================================
--- iproute2-2.6.39.orig/tc/Makefile
+++ iproute2-2.6.39/tc/Makefile
@@ -124,10 +124,10 @@ q_atm.so: q_atm.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
 m_xt.so: m_xt.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c -lxtables
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c $$(pkg-config xtables --cflags --libs)
 
 m_xt_old.so: m_xt_old.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c -lxtables
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$(pkg-config xtables --cflags --libs)
 
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
