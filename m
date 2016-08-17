From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] bpf: use skb_pkt_type_ok helper in bpf_skb_change_type
Date: Thu, 18 Aug 2016 01:00:38 +0200
Message-ID: <17720ed3d08bbf6bc3d6f569a636efc10c956acd.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34684 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbcHQXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:02:00 -0400
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have a skb_pkt_type_ok() helper for checking the type before
mangling, make use of it instead of open coding. Follow-up to commit
8b10cab64c13 ("net: simplify and make pkt_type_ok() available for other
users") that came in after d2485c4242a8 ("bpf: add bpf_skb_change_type
helper").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index cb06ace..58b5e6d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1976,8 +1976,8 @@ static u64 bpf_skb_change_type(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	u32 pkt_type = r2;
 
 	/* We only allow a restricted subset to be changed for now. */
-	if (unlikely(skb->pkt_type > PACKET_OTHERHOST ||
-		     pkt_type > PACKET_OTHERHOST))
+	if (unlikely(!skb_pkt_type_ok(skb->pkt_type) ||
+		     !skb_pkt_type_ok(pkt_type)))
 		return -EINVAL;
 
 	skb->pkt_type = pkt_type;
-- 
1.9.3
