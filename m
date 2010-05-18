From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tcp_md5_hash_skb_data() frag_list handling
Date: Tue, 18 May 2010 08:40:51 +0200
Message-ID: <1274164851.2567.39.camel@edumazet-laptop>
References: <20100517.231403.148532542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34467 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0ERGky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 02:40:54 -0400
Received: by wwi17 with SMTP id 17so230377wwi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 23:40:52 -0700 (PDT)
In-Reply-To: <20100517.231403.148532542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 23:14 -0700, David Miller a =C3=A9crit :
> Eric, would you please formally submit that tcp md5 fraglist
> fix to net/ipv4/tcp.c with proper signoffs?

Here it is, thanks !


[PATCH] tcp: tcp_md5_hash_skb_data() frag_list handling

tcp_md5_hash_skb_data() should handle skb->frag_list, and eventually
recurse.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6596b4f..49d0d2b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2999,6 +2999,7 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool =
*hp,
 	const unsigned head_data_len =3D skb_headlen(skb) > header_len ?
 				       skb_headlen(skb) - header_len : 0;
 	const struct skb_shared_info *shi =3D skb_shinfo(skb);
+	struct sk_buff *frag_iter;
=20
 	sg_init_table(&sg, 1);
=20
@@ -3013,6 +3014,10 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool=
 *hp,
 			return 1;
 	}
=20
+	skb_walk_frags(skb, frag_iter)
+		if (tcp_md5_hash_skb_data(hp, frag_iter, 0))
+			return 1;
+
 	return 0;
 }
=20


