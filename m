From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/6] utils: Implement strlcpy() and strlcat()
Date: Fri,  1 Sep 2017 18:52:51 +0200
Message-ID: <20170901165256.21459-2-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41345 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751863AbdIAQxP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:15 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By making use of strncpy(), both implementations are really simple so
there is no need to add libbsd as additional dependency.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h |  3 +++
 lib/utils.c     | 19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/utils.h b/include/utils.h
index f665d9001806f..9c2f9fc257fba 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -252,4 +252,7 @@ int make_path(const char *path, mode_t mode);
 char *find_cgroup2_mount(void);
 int get_command_name(const char *pid, char *comm, size_t len);
 
+size_t strlcpy(char *dst, const char *src, size_t size);
+size_t strlcat(char *dst, const char *src, size_t size);
+
 #endif /* __UTILS_H__ */
diff --git a/lib/utils.c b/lib/utils.c
index 002063075fd61..c95780e725252 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1238,3 +1238,22 @@ int get_real_family(int rtm_type, int rtm_family)
 
 	return rtm_family;
 }
+
+size_t strlcpy(char *dst, const char *src, size_t size)
+{
+	if (size) {
+		strncpy(dst, src, size - 1);
+		dst[size - 1] = '\0';
+	}
+	return strlen(src);
+}
+
+size_t strlcat(char *dst, const char *src, size_t size)
+{
+	size_t dlen = strlen(dst);
+
+	if (dlen > size)
+		return dlen + strlen(src);
+
+	return dlen + strlcpy(dst + dlen, src, size - dlen);
+}
-- 
2.13.1
