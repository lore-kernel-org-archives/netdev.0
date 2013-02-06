From: Tommi Rantala <tt.rantala@gmail.com>
Subject: [PATCH] ipv6/ip6_gre: fix error case handling in ip6gre_tunnel_xmit()
Date: Wed,  6 Feb 2013 15:24:02 +0200
Message-ID: <1360157042-16473-1-git-send-email-tt.rantala@gmail.com>
Cc: Tommi Rantala <tt.rantala@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dmitry Kozlov <xeb@mail.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:65000 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab3BFNYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 08:24:44 -0500
Received: by mail-la0-f41.google.com with SMTP id fo12so1359538lab.28
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 05:24:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6gre_tunnel_xmit() is leaking the skb when we hit this error branch,
and the -1 return value from this function is bogus. Use the error
handling we already have in place in ip6gre_tunnel_xmit() for this error
case to fix this.

Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
---
 net/ipv6/ip6_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c727e47..131dd09 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -960,7 +960,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff *skb,
 	int ret;
 
 	if (!ip6_tnl_xmit_ctl(t))
-		return -1;
+		goto tx_err;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-- 
1.8.1
