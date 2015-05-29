From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] configure: Check for libmnl
Date: Fri, 29 May 2015 13:27:41 +0300
Message-ID: <1432895261-11826-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:33026 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbbE2K2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:28:44 -0400
Received: by labpy14 with SMTP id py14so40613160lab.0
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 03:28:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Indicate existence of libmnl which is required by tipc.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 configure | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/configure b/configure
index f1325df..1605464 100755
--- a/configure
+++ b/configure
@@ -284,6 +284,17 @@ check_selinux()
 	fi
 }
 
+check_mnl()
+{
+	if ${PKG_CONFIG} libmnl --exists
+	then
+		echo "HAVE_MNL:=y" >>Config
+		echo -n "yes"
+	else
+		echo -n "no"
+	fi
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 check_toolchain
 
@@ -313,5 +324,10 @@ check_selinux
 echo -n "ELF support: "
 check_elf
 
+echo -n "libmnl support: "
+check_mnl
+echo " (required by tipc)"
+
 echo -e "\nDocs"
 check_docs
+echo ""
-- 
2.3.1
