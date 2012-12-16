From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/3] configure: move toolchain init to a function
Date: Sun, 16 Dec 2012 17:09:15 -0500
Message-ID: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
Cc: jengelh@inai.de
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58772 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365Ab2LPWJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 17:09:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The layout of this file uses functions to update Config.  Move the
toolchain logic to the same style to fix setting the vars in Config.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 9912114..ea1038d 100755
--- a/configure
+++ b/configure
@@ -2,14 +2,19 @@
 # This is not an autconf generated configure
 #
 INCLUDE=${1:-"$PWD/include"}
-: ${PKG_CONFIG:=pkg-config}
-: ${CC=gcc}
-echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
 
 # Make a temp directory in build tree.
 TMPDIR=$(mktemp -d config.XXXXXX)
 trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
 
+check_toolchain()
+{
+: ${PKG_CONFIG:=pkg-config}
+: ${CC=gcc}
+echo "CC:=${CC}" >>Config
+echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
+}
+
 check_atm()
 {
 cat >$TMPDIR/atmtest.c <<EOF
@@ -224,6 +229,7 @@ rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
 }
 
 echo "# Generated config based on" $INCLUDE >Config
+check_toolchain
 
 echo "TC schedulers"
 
-- 
1.8.0
