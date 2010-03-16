From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netlink: fix unaligned access in nla_get_be64()
Date: Wed, 17 Mar 2010 00:30:44 +0100
Message-ID: <20100316233044.4185.69099.stgit@decadence>
References: <20100316232247.4185.19426.stgit@decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59069 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab0CPXa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 19:30:58 -0400
In-Reply-To: <20100316232247.4185.19426.stgit@decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a unaligned access in nla_get_be64() that was
introduced by myself in a17c859849402315613a0015ac8fbf101acf0cc1.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netlink.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index a63b219..668ad04 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -945,7 +945,11 @@ static inline u64 nla_get_u64(const struct nlattr *nla)
  */
 static inline __be64 nla_get_be64(const struct nlattr *nla)
 {
-	return *(__be64 *) nla_data(nla);
+	__be64 tmp;
+
+	nla_memcpy(&tmp, nla, sizeof(tmp));
+
+	return tmp;
 }
 
 /**

