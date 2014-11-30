From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] configure: Add check for the doc tools
Date: Sun, 30 Nov 2014 18:08:25 +0200
Message-ID: <1417363705-560-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34282 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaK3QSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 11:18:05 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so22329375wid.15
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 08:18:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added checking existence of the doc files converters.
If the XXX tool exists then HAVE_XXX:=y will be written
to the Config file. Example of the configure script output:

TC schedulers
 ATM	no
 IPT	using xtables
 IPSET  yes

iptables modules directory: /usr/lib/iptables
libc has setns: yes
SELinux support: no

Docs
 latex: no
 WARNING: no docs can be built from LaTeX files
 sgml2html: yes

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 configure | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index d5170f0..c3dacdb 100755
--- a/configure
+++ b/configure
@@ -7,6 +7,24 @@ INCLUDE=${1:-"$PWD/include"}
 TMPDIR=$(mktemp -d config.XXXXXX)
 trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
 
+check_prog()
+{
+    echo -n "$2"
+    command -v $1 >/dev/null 2>&1 && (echo "$3:=y" >> Config; echo "yes") || (echo "no"; return 1)
+}
+
+check_docs()
+{
+    if check_prog latex " latex: " HAVE_LATEX; then
+        check_prog pdflatex " pdflatex: " HAVE_PDFLATEX || echo " WARNING: no PDF docs can be built from LaTeX files"
+        check_prog sgml2latex " sgml2latex: " HAVE_SGML2LATEX || echo " WARNING: no LaTeX files can be build from SGML files"
+    else
+        echo " WARNING: no docs can be built from LaTeX files"
+    fi
+
+    check_prog sgml2html " sgml2html: " HAVE_SGML2HTML || echo " WARNING: no HTML docs can be built from SGML"
+}
+
 check_toolchain()
 {
     : ${PKG_CONFIG:=pkg-config}
@@ -260,7 +278,7 @@ check_ipt
 echo -n " IPSET  "
 check_ipset
 
-echo -n "iptables modules directory: "
+echo -n -e "\niptables modules directory: "
 check_ipt_lib_dir
 
 echo -n "libc has setns: "
@@ -268,3 +286,6 @@ check_setns
 
 echo -n "SELinux support: "
 check_selinux
+
+echo -e "\nDocs"
+check_docs
-- 
2.1.3
