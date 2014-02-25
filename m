From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] ipv6: log src and dst along with "udp checksum is 0"
Date: Tue, 25 Feb 2014 20:34:05 +0100
Message-ID: <1393356845-15287-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43525 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583AbaBYTeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 14:34:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These info messages are rather pointless without any means to identify
the source of the bogus packets.  Logging the src and dst addresses
may help a bit.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/ipv6/ip6_checksum.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 72d198b8e4d2..652716b06c2b 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -79,7 +79,8 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr=
 *uh, int proto)
 		/* RFC 2460 section 8.1 says that we SHOULD log
 		   this error. Well, it is reasonable.
 		 */
-		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
+		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 [%pI6c > %pI6c]\n"=
,
+			       &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr);
 		return 1;
 	}
 	if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE &&
--=20
1.9.0
