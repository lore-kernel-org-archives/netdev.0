From: Arnd Bergmann <arnd@arndb.de>
Subject: net: export TSO helper functions
Date: Tue, 27 May 2014 12:16:03 +0200
Message-ID: <4514086.6xHrns0u2W@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: ezequiel.garcia@free-electrons.com,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:53269 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbaE0KQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 06:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The software TSO helper API was recently added but so far only
works for built-in device drivers. This adds appropriate exports
to let us build the drivers using it as loadable modules.

Found during randconfig testing.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
diff --git a/net/core/tso.c b/net/core/tso.c
index 097821d..c8caf5b 100644
--- a/net/core/tso.c
+++ b/net/core/tso.c
@@ -7,6 +7,7 @@ int tso_count_descs(struct sk_buff *skb)
 	/* The Marvell Way */
 	return skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
 }
+EXPORT_SYMBOL_GPL(tso_count_descs);
 
 void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 		   int size, bool is_last)
@@ -31,6 +32,7 @@ void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 		tcph->rst = 0;
 	}
 }
+EXPORT_SYMBOL_GPL(tso_build_hdr);
 
 void tso_build_data(struct sk_buff *skb, struct tso_t *tso, int size)
 {
@@ -48,6 +50,7 @@ void tso_build_data(struct sk_buff *skb, struct tso_t *tso, int size)
 		tso->next_frag_idx++;
 	}
 }
+EXPORT_SYMBOL_GPL(tso_build_data);
 
 void tso_start(struct sk_buff *skb, struct tso_t *tso)
 {
@@ -70,3 +73,4 @@ void tso_start(struct sk_buff *skb, struct tso_t *tso)
 		tso->next_frag_idx++;
 	}
 }
+EXPORT_SYMBOL_GPL(tso_start);
