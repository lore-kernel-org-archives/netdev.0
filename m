From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] allow pkg-config to be customized
Date: Thu,  8 Nov 2012 11:41:17 -0500
Message-ID: <1352392877-22300-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:52466 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756363Ab2KHQkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 11:40:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than hard coding `pkg-config`, use ${PKG_CONFIG} so people can
override it to their specific version (like when cross-compiling).

This is the same way the upstream pkg-config code works.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure   | 6 ++++--
 tc/Makefile | 4 ++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index 2c2d1c4..0bfedf9 100755
--- a/configure
+++ b/configure
@@ -2,6 +2,8 @@
 # This is not an autconf generated configure
 #
 INCLUDE=${1:-"$PWD/include"}
+: ${PKG_CONFIG:=pkg-config}
+echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
 
 # Make a temp directory in build tree.
 TMPDIR=$(mktemp -d config.XXXXXX)
@@ -51,7 +53,7 @@ int main(int argc, char **argv)
 
 EOF
 
-if gcc -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL $(pkg-config xtables --cflags --libs) -ldl >/dev/null 2>&1
+if gcc -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL $(${PKG_CONFIG} xtables --cflags --libs) -ldl >/dev/null 2>&1
 then
 	echo "TC_CONFIG_XT:=y" >>Config
 	echo "using xtables"
@@ -148,7 +150,7 @@ check_ipt()
 
 check_ipt_lib_dir()
 {
-	IPT_LIB_DIR=$(pkg-config --variable=xtlibdir xtables)
+	IPT_LIB_DIR=$(${PKG_CONFIG} --variable=xtlibdir xtables)
 	if [ -n "$IPT_LIB_DIR" ]; then
 		echo $IPT_LIB_DIR
 		echo "IPT_LIB_DIR:=$IPT_LIB_DIR" >> Config
diff --git a/tc/Makefile b/tc/Makefile
index 389029d..696f891 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -135,10 +135,10 @@ q_atm.so: q_atm.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
 m_xt.so: m_xt.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c $$(pkg-config xtables --cflags --libs)
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c $$($(PKG_CONFIG) xtables --cflags --libs)
 
 m_xt_old.so: m_xt_old.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$(pkg-config xtables --cflags --libs)
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$($(PKG_CONFIG) xtables --cflags --libs)
 
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
-- 
1.7.12.4
