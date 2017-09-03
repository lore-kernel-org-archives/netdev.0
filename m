From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/47] netlink: Introduce nla_strdup()
Date: Mon,  4 Sep 2017 00:27:14 +0200
Message-ID: <1504477667-12130-5-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>

This is similar to strdup() for netlink string attributes.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netlink.h |  1 +
 lib/nlattr.c          | 24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index ef8e6c3a80a6..c8c2eb5ae55e 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -247,6 +247,7 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 int nla_policy_len(const struct nla_policy *, int);
 struct nlattr *nla_find(const struct nlattr *head, int len, int attrtype);
 size_t nla_strlcpy(char *dst, const struct nlattr *nla, size_t dstsize);
+char *nla_strdup(const struct nlattr *nla, gfp_t flags);
 int nla_memcpy(void *dest, const struct nlattr *src, int count);
 int nla_memcmp(const struct nlattr *nla, const void *data, size_t size);
 int nla_strcmp(const struct nlattr *nla, const char *str);
diff --git a/lib/nlattr.c b/lib/nlattr.c
index fb52435be42d..f13013f7e21a 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -272,6 +272,30 @@ size_t nla_strlcpy(char *dst, const struct nlattr *nla, size_t dstsize)
 EXPORT_SYMBOL(nla_strlcpy);
 
 /**
+ * nla_strdup - Copy string attribute payload into a newly allocated buffer
+ * @nla: attribute to copy the string from
+ * @flags: the type of memory to allocate (see kmalloc).
+ *
+ * Returns a pointer to the allocated buffer or NULL on error.
+ */
+char *nla_strdup(const struct nlattr *nla, gfp_t flags)
+{
+	size_t srclen = nla_len(nla);
+	char *src = nla_data(nla), *dst;
+
+	if (srclen > 0 && src[srclen - 1] == '\0')
+		srclen--;
+
+	dst = kmalloc(srclen + 1, flags);
+	if (dst != NULL) {
+		memcpy(dst, src, srclen);
+		dst[srclen] = '\0';
+	}
+	return dst;
+}
+EXPORT_SYMBOL(nla_strdup);
+
+/**
  * nla_memcpy - Copy a netlink attribute into another memory area
  * @dest: where to copy to memcpy
  * @src: netlink attribute to copy from
-- 
2.1.4


