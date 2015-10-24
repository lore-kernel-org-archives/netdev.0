From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] ipv6: icmp: include addresses in debug messages
Date: Sat, 24 Oct 2015 14:00:20 +0200
Message-ID: <1445688020-8510-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57802 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbbJXMA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2015 08:00:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Messages like "icmp6_send: no reply to icmp error" are close
to useless. Adding source and destination addresses to provide
some more clue.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I've had this laying around for much too long because I haven't been
convinced it's a good idea...  But keeping it around longer isn't going
to help, so it's better to leave that decision to you experts :)


Bj=C3=B8rn

 net/ipv6/icmp.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index efb1c00f2270..36c5a98b0472 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -453,7 +453,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type=
, u8 code, __u32 info)
 	 *	and anycast addresses will be checked later.
 	 */
 	if ((addr_type =3D=3D IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTIC=
AST)) {
-		net_dbg_ratelimited("icmp6_send: addr_any/mcast source\n");
+		net_dbg_ratelimited("icmp6_send: addr_any/mcast source [%pI6c > %pI6=
c]\n",
+				    &hdr->saddr, &hdr->daddr);
 		return;
 	}
=20
@@ -461,7 +462,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type=
, u8 code, __u32 info)
 	 *	Never answer to a ICMP packet.
 	 */
 	if (is_ineligible(skb)) {
-		net_dbg_ratelimited("icmp6_send: no reply to icmp error\n");
+		net_dbg_ratelimited("icmp6_send: no reply to icmp error [%pI6c > %pI=
6c]\n",
+				    &hdr->saddr, &hdr->daddr);
 		return;
 	}
=20
@@ -513,7 +515,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type=
, u8 code, __u32 info)
 	len =3D skb->len - msg.offset;
 	len =3D min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr=
) - sizeof(struct icmp6hdr));
 	if (len < 0) {
-		net_dbg_ratelimited("icmp: len problem\n");
+		net_dbg_ratelimited("icmp: len problem [%pI6c > %pI6c]\n",
+				    &hdr->saddr, &hdr->daddr);
 		goto out_dst_release;
 	}
=20
@@ -785,7 +788,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		if (type & ICMPV6_INFOMSG_MASK)
 			break;
=20
-		net_dbg_ratelimited("icmpv6: msg of unknown type\n");
+		net_dbg_ratelimited("icmpv6: msg of unknown type [%pI6c > %pI6c]\n",
+				    saddr, daddr);
=20
 		/*
 		 * error of unknown type.
--=20
2.1.4
