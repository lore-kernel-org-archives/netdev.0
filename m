From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next] ipv6: log src and dst along with "udp checksum is 0"
Date: Tue, 25 Feb 2014 21:11:02 +0100
Message-ID: <1393359062-16844-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44086 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbaBYULT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 15:11:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These info messages are rather pointless without any means to identify
the source of the bogus packets.  Logging the src and dst addresses and
ports may help a bit.

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
v2: log port numbers too.  Suggested by Joe Perches

build tested only


 net/ipv6/ip6_checksum.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 72d198b8e4d2..ee7a97f510cb 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -79,7 +79,9 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr=
 *uh, int proto)
 		/* RFC 2460 section 8.1 says that we SHOULD log
 		   this error. Well, it is reasonable.
 		 */
-		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
+		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 for [%pI6c]:%u->[%=
pI6c]:%u\n",
+			       &ipv6_hdr(skb)->saddr, ntohs(uh->source),
+			       &ipv6_hdr(skb)->daddr, ntohs(uh->dest));
 		return 1;
 	}
 	if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE &&
--=20
1.9.0
