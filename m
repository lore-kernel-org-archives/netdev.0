From: Dan McGee <dan@archlinux.org>
Subject: [PATCH] Make iproute2 configure script more flexible
Date: Fri, 15 Jul 2011 13:52:24 -0500
Message-ID: <1310755944-2420-1-git-send-email-dan@archlinux.org>
Cc: Dan McGee <dan@archlinux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33999 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab1GOSw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 14:52:28 -0400
Received: by yxi11 with SMTP id 11so662767yxi.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 11:52:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Arch Linux, we still install the iptables shared libraries in
/usr/lib/iptables/, even though the main library is installed to
/usr/lib/libxtables.so. This change checks all available locations to
correctly find the iptables library directory.

Signed-off-by: Dan McGee <dan@archlinux.org>
---
 configure |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/configure b/configure
index 69797ab..0795df8 100755
--- a/configure
+++ b/configure
@@ -3,8 +3,6 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
-TABLES=
-
 check_atm()
 {
 cat >/tmp/atmtest.c <<EOF
@@ -141,9 +139,6 @@ check_ipt()
 	if ! grep TC_CONFIG_XT Config > /dev/null
 	then
 		echo "using iptables"
-		TABLES="iptables"
-	else
-		TABLES="xtables"
 	fi
 }
 
@@ -152,10 +147,10 @@ check_ipt_lib_dir()
 	IPT_LIB_DIR=""
 	for dir in /lib /usr/lib /usr/local/lib
 	do
-		for file in $dir/$TABLES/lib*t_*so ; do
+		for file in $dir/{xtables,iptables}/lib*t_*so ; do
 			if [ -f $file ]; then
-				echo $dir/$TABLES
-				echo "IPT_LIB_DIR:=$dir/$TABLES" >> Config
+				echo ${file%/*}
+				echo "IPT_LIB_DIR:=${file%/*}" >> Config
 				return
 			fi
 		done
-- 
1.7.6

