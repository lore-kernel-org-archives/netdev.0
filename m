From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 12:26:21 +0100
Message-ID: <20080124122621.3248c651.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38178 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbYAXL00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 06:26:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/net/xfrm.h      |    8 ++++----
 net/ipv4/ah4.c          |    2 +-
 net/ipv4/esp4.c         |    2 +-
 net/ipv4/ipcomp.c       |    2 +-
 net/ipv4/xfrm4_tunnel.c |    2 +-
 net/ipv6/ah6.c          |    2 +-
 net/ipv6/esp6.c         |    2 +-
 net/ipv6/ipcomp6.c      |    2 +-
 net/ipv6/mip6.c         |    4 ++--
 net/ipv6/xfrm6_tunnel.c |    2 +-
 net/xfrm/xfrm_state.c   |   16 ++++++++--------
 11 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5ebb9ba..02d9b1e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -201,7 +201,7 @@ struct xfrm_state
 
 	/* Reference to data common to all the instances of this
 	 * transformer. */
-	struct xfrm_type	*type;
+	const struct xfrm_type	*type;
 	struct xfrm_mode	*inner_mode;
 	struct xfrm_mode	*outer_mode;
 
@@ -278,7 +278,7 @@ struct xfrm_state_afinfo {
 	unsigned int		proto;
 	unsigned int		eth_proto;
 	struct module		*owner;
-	struct xfrm_type	*type_map[IPPROTO_MAX];
+	const struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
@@ -321,8 +321,8 @@ struct xfrm_type
 	u32			(*get_mtu)(struct xfrm_state *, int size);
 };
 
-extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
-extern int xfrm_unregister_type(struct xfrm_type *type, unsigned short family);
+extern int xfrm_register_type(const struct xfrm_type *type, unsigned short family);
+extern int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family);
 
 struct xfrm_mode {
 	/*
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3003503..4463eeb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -216,10 +216,10 @@ static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
 	write_unlock_bh(&xfrm_state_afinfo_lock);
 }
 
-int xfrm_register_type(struct xfrm_type *type, unsigned short family)
+int xfrm_register_type(const struct xfrm_type *type, unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
-	struct xfrm_type **typemap;
+	const struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
@@ -235,10 +235,10 @@ int xfrm_register_type(struct xfrm_type *type, unsigned short family)
 }
 EXPORT_SYMBOL(xfrm_register_type);
 
-int xfrm_unregister_type(struct xfrm_type *type, unsigned short family)
+int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_lock_afinfo(family);
-	struct xfrm_type **typemap;
+	const struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
@@ -254,11 +254,11 @@ int xfrm_unregister_type(struct xfrm_type *type, unsigned short family)
 }
 EXPORT_SYMBOL(xfrm_unregister_type);
 
-static struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
+static const struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo;
-	struct xfrm_type **typemap;
-	struct xfrm_type *type;
+	const struct xfrm_type **typemap;
+	const struct xfrm_type *type;
 	int modload_attempted = 0;
 
 retry:
@@ -281,7 +281,7 @@ retry:
 	return type;
 }
 
-static void xfrm_put_type(struct xfrm_type *type)
+static void xfrm_put_type(const struct xfrm_type *type)
 {
 	module_put(type->owner);
 }
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index d76803a..9d4555e 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -300,7 +300,7 @@ static void ah_destroy(struct xfrm_state *x)
 }
 
 
-static struct xfrm_type ah_type =
+static const struct xfrm_type ah_type =
 {
 	.description	= "AH4",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 28ea5c7..602779d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -448,7 +448,7 @@ error:
 	return -EINVAL;
 }
 
-static struct xfrm_type esp_type =
+static const struct xfrm_type esp_type =
 {
 	.description	= "ESP4",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index f4af99a..b271f87 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -434,7 +434,7 @@ error:
 	goto out;
 }
 
-static struct xfrm_type ipcomp_type = {
+static const struct xfrm_type ipcomp_type = {
 	.description	= "IPCOMP4",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_COMP,
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 3268451..87f77e4 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -38,7 +38,7 @@ static void ipip_destroy(struct xfrm_state *x)
 {
 }
 
-static struct xfrm_type ipip_type = {
+static const struct xfrm_type ipip_type = {
 	.description	= "IPIP",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_IPIP,
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index fb0d07a..379c8e0 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -515,7 +515,7 @@ static void ah6_destroy(struct xfrm_state *x)
 	kfree(ahp);
 }
 
-static struct xfrm_type ah6_type =
+static const struct xfrm_type ah6_type =
 {
 	.description	= "AH6",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 5bd5292..e3fd9fe 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -395,7 +395,7 @@ error:
 	return -EINVAL;
 }
 
-static struct xfrm_type esp6_type =
+static const struct xfrm_type esp6_type =
 {
 	.description	= "ESP6",
 	.owner	     	= THIS_MODULE,
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index b276d04..c8f38e0 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -450,7 +450,7 @@ error:
 	goto out;
 }
 
-static struct xfrm_type ipcomp6_type =
+static const struct xfrm_type ipcomp6_type =
 {
 	.description	= "IPCOMP6",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 49d3966..cd8a5bd 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -330,7 +330,7 @@ static void mip6_destopt_destroy(struct xfrm_state *x)
 {
 }
 
-static struct xfrm_type mip6_destopt_type =
+static const struct xfrm_type mip6_destopt_type =
 {
 	.description	= "MIP6DESTOPT",
 	.owner		= THIS_MODULE,
@@ -462,7 +462,7 @@ static void mip6_rthdr_destroy(struct xfrm_state *x)
 {
 }
 
-static struct xfrm_type mip6_rthdr_type =
+static const struct xfrm_type mip6_rthdr_type =
 {
 	.description	= "MIP6RT",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index fae90ff..639fe8a 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -319,7 +319,7 @@ static void xfrm6_tunnel_destroy(struct xfrm_state *x)
 	xfrm6_tunnel_free_spi((xfrm_address_t *)&x->props.saddr);
 }
 
-static struct xfrm_type xfrm6_tunnel_type = {
+static const struct xfrm_type xfrm6_tunnel_type = {
 	.description	= "IP6IP6",
 	.owner          = THIS_MODULE,
 	.proto		= IPPROTO_IPV6,
