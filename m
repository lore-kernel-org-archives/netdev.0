From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH v2] iproute2: configure: Add search path for 64bit library.
Date: Mon, 20 Aug 2012 09:41:47 +0800
Message-ID: <1345426907-4236-1-git-send-email-lw@cn.fujitsu.com>
References: <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43685 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752022Ab2HTBmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 21:42:55 -0400
In-Reply-To: <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pkg-config to tell us the library path and fallback to search
old paths if xtables.pc not exists.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---

Changes from v1:
- use pkg-config as Ben and Stephen suggested.

 configure |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index a1916de..db7cd6a 100755
--- a/configure
+++ b/configure
@@ -148,7 +148,13 @@ check_ipt()
 
 check_ipt_lib_dir()
 {
-	IPT_LIB_DIR=""
+	IPT_LIB_DIR=$(pkg-config --variable=xtlibdir xtables)
+	if [ -n "$IPT_LIB_DIR" ]; then
+		echo $IPT_LIB_DIR
+		echo "IPT_LIB_DIR:=$IPT_LIB_DIR" >> Config
+		return
+	fi
+
 	for dir in /lib /usr/lib /usr/local/lib
 	do
 		for file in $dir/{xtables,iptables}/lib*t_*so ; do
-- 
1.7.10.1
