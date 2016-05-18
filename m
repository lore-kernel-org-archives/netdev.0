From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 v3 2/5] utils: make hexstring_a2n provide the number of hex digits parsed
Date: Wed, 18 May 2016 17:35:10 +0200
Message-ID: <60cf5980f01ca8cea749b63485d38ec65bd31980.1463585050.git.sd@queasysnail.net>
References: <cover.1463585050.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359AbcERPgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 11:36:15 -0400
In-Reply-To: <cover.1463585050.git.sd@queasysnail.net>
In-Reply-To: <cover.1463585050.git.sd@queasysnail.net>
References: <cover.1463585050.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h | 4 ++--
 lib/utils.c     | 8 ++++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index ef81d00f3d70..aef28ce732ab 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -114,8 +114,8 @@ int get_u8(__u8 *val, const char *arg, int base);
 int get_s8(__s8 *val, const char *arg, int base);
 int get_addr64(__u64 *ap, const char *cp);
 
-char* hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
-__u8* hexstring_a2n(const char *str, __u8 *buf, int blen);
+char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
+__u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len);
 #define ADDR64_BUF_SIZE sizeof("xxxx:xxxx:xxxx:xxxx")
 int addr64_n2a(__u64 addr, char *buff, size_t len);
 
diff --git a/lib/utils.c b/lib/utils.c
index b93b1dc84315..bd10c0d71718 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -866,9 +866,9 @@ char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 	return buf;
 }
 
-__u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
+__u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len)
 {
-	int cnt = 0;
+	unsigned int cnt = 0;
 	char *endptr;
 
 	if (strlen(str) % 2)
@@ -885,6 +885,10 @@ __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 		buf[cnt++] = tmp;
 		str += 2;
 	}
+
+	if (len)
+		*len = cnt;
+
 	return buf;
 }
 
-- 
2.8.2
