From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETFILTER]: Ipv6-related xt_hashlimit compilation fix.
Date: Thu, 31 Jan 2008 18:11:37 +0300
Message-ID: <47A1E529.2030500@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53314 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786AbYAaPLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 10:11:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hashlimit_ipv6_mask() is called from under IP6_NF_IPTABLES
config option, but is not under it by itself.

gcc warns us about it :) :
net/netfilter/xt_hashlimit.c:473: warning: =91hashlimit_ipv6_mask=92 de=
fined but not used

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 54aaf5b..744c7f2 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -469,6 +469,7 @@ static inline __be32 maskl(__be32 a, unsigned int l=
)
 	return htonl(ntohl(a) & ~(~(u_int32_t)0 >> l));
 }
=20
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
 static void hashlimit_ipv6_mask(__be32 *i, unsigned int p)
 {
 	switch (p) {
@@ -503,6 +504,7 @@ static void hashlimit_ipv6_mask(__be32 *i, unsigned=
 int p)
 		break;
 	}
 }
+#endif
=20
 static int
 hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
