From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:39:01 +0900
Message-ID: <20061124143901.0db589b8.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:63390 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934421AbWKXFn5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:57 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes mtu calculation of IPv4

ip_append_data should refer the mtu of "dst" not "path".
if "dst" is stacked, "path" is the actual dst_entry in
the routing table.
therefore the mtu of "path" equals link mtu which is
depends on the device so that it ignores the header length
and the trailer length
"dst" has mtu for creating packet.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/ipv4/ip_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1da3d32..f324449 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -806,7 +806,7 @@ int ip_append_data(struct sock *sk,
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
+		inet->cork.fragsize = mtu = dst_mtu(&rt->u.dst);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
