From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: fix bpf_skb_set_tunnel_key() helper
Date: Wed, 26 Aug 2015 15:57:38 -0700
Message-ID: <1440629858-1847-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34979 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056AbbHZW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:57:47 -0400
Received: by pacdd16 with SMTP id dd16so2295214pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:57:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to indicate to tunnel driver that key.tun_id is set,
otherwise gre won't recognize the metadata.

Fixes: d3aa45ce6b94 ("bpf: add helpers to access tunnel metadata")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
With this fix both vxlan and gretap are working with tc+bpf.

 net/core/filter.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index b4adc961413f..66500d490995 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1528,6 +1528,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 
 	info = &md->u.tun_info;
 	info->mode = IP_TUNNEL_INFO_TX;
+	info->key.tun_flags = TUNNEL_KEY;
 	info->key.tun_id = cpu_to_be64(from->tunnel_id);
 	info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
 
-- 
1.7.9.5
