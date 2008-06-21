From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 6/8] netfilter: fix string extension for case insensitive pattern matching
Date: Sat, 21 Jun 2008 00:54:18 -0700
Message-ID: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:58005 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbYFUHyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 03:54:36 -0400
Received: by rv-out-0506.google.com with SMTP id k40so6015127rvb.1
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 00:54:36 -0700 (PDT)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

icase of xt_string_info indicates case [in]sensitive matching.
netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/netfilter/xt_string.h |    1 +
 net/netfilter/xt_string.c           |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
index bb21dd1..dfd347f 100644
--- a/include/linux/netfilter/xt_string.h
+++ b/include/linux/netfilter/xt_string.h
@@ -12,6 +12,7 @@ struct xt_string_info
 	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
 	u_int8_t  patlen;
 	u_int8_t  invert;
+	u_int8_t  icase;
 
 	/* Used internally by the kernel */
 	struct ts_config __attribute__((aligned(8))) *config;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 9508484..7c83431 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -55,7 +55,7 @@ string_mt_check(const char *tablename, const void *ip,
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
 		return false;
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
-				     0, GFP_KERNEL, TS_AUTOLOAD);
+				     conf->icase, GFP_KERNEL, TS_AUTOLOAD);
 	if (IS_ERR(ts_conf))
 		return false;
 
-- 
1.5.4.3

