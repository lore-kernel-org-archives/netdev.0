From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH net-next] net: fix two sparse warnings introduced by IGMP/MLD
 parsing exports
Date: Tue,  5 May 2015 00:19:35 +0200
Message-ID: <1430777976-4014-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:50585 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbbEDWTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 18:19:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> net/core/skbuff.c:4108:13: sparse: incorrect type in assignment (diff=
erent base types)
> net/ipv6/mcast_snoop.c:63 ipv6_mc_check_exthdrs() warn: unsigned 'off=
set' is never less than zero.

Introduced by 9afd85c9e4552b276e2f4cfefd622bdeeffbbf26
("net: Export IGMP/MLD message validation code")

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
 net/core/skbuff.c      |    2 +-
 net/ipv6/mcast_snoop.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e4278a..b9eb90b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4093,7 +4093,7 @@ struct sk_buff *skb_checksum_trimmed(struct sk_bu=
ff *skb,
 {
 	struct sk_buff *skb_chk;
 	unsigned int offset =3D skb_transport_offset(skb);
-	int ret;
+	__sum16 ret;
=20
 	skb_chk =3D skb_checksum_maybe_trim(skb, transport_len);
 	if (!skb_chk)
diff --git a/net/ipv6/mcast_snoop.c b/net/ipv6/mcast_snoop.c
index 1a2cbc1..df8afe5 100644
--- a/net/ipv6/mcast_snoop.c
+++ b/net/ipv6/mcast_snoop.c
@@ -47,7 +47,7 @@ static int ipv6_mc_check_ip6hdr(struct sk_buff *skb)
 static int ipv6_mc_check_exthdrs(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h;
-	unsigned int offset;
+	int offset;
 	u8 nexthdr;
 	__be16 frag_off;
=20
--=20
1.7.10.4
