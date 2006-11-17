From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 3/10][NETLABEL]: Use kmemdup in cipso_ipv4.c
Date: Fri, 17 Nov 2006 13:17:11 -0200
Message-ID: <20061117151711.GD17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:26510 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755088AbWKQPRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:17:24 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/cipso_ipv4.o.before /tmp/cipso_ipv4.o.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/cipso_ipv4.c:
  cipso_v4_cache_add |  -46
 1 function changed, 46 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/cipso_ipv4.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index c3a61eb..095038a 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -377,12 +377,11 @@ int cipso_v4_cache_add(const struct sk_b
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
 		return -ENOMEM;
-	entry->key = kmalloc(cipso_ptr_len, GFP_ATOMIC);
+	entry->key = kmemdup(cipso_ptr, cipso_ptr_len, GFP_ATOMIC);
 	if (entry->key == NULL) {
 		ret_val = -ENOMEM;
 		goto cache_add_failure;
 	}
-	memcpy(entry->key, cipso_ptr, cipso_ptr_len);
 	entry->key_len = cipso_ptr_len;
 	entry->hash = cipso_v4_map_cache_hash(cipso_ptr, cipso_ptr_len);
 	atomic_inc(&secattr->cache->refcount);
-- 
1.4.2.1.g3d5c

