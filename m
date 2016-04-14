From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 1/4] utils: make hexstring_a2n provide the number of hex digits parsed
Date: Thu, 14 Apr 2016 15:01:07 +0200
Message-ID: <fa57a9769170dab751eaa718e6c1ba19d6eef7f6.1460622809.git.sd@queasysnail.net>
References: <cover.1460622809.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbcDNNBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 09:01:15 -0400
In-Reply-To: <cover.1460622809.git.sd@queasysnail.net>
In-Reply-To: <cover.1460622809.git.sd@queasysnail.net>
References: <cover.1460622809.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/utils.h | 4 ++--
 lib/utils.c     | 5 +++--
 2 files changed, 5 insertions(+), 4 deletions(-)

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
index b93b1dc84315..9337f57a5bde 100644
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
@@ -885,6 +885,7 @@ __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 		buf[cnt++] = tmp;
 		str += 2;
 	}
+	*len = cnt;
 	return buf;
 }
 
-- 
2.8.0
