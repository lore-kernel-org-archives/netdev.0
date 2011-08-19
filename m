From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 38/75] niu: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:10 +0100
Message-ID: <1313760467-8598-38-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37564 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929Ab1HSN3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:29:08 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---
 drivers/net/niu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index ed47585..0191712 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3291,7 +3291,7 @@ static void niu_rx_skb_append(struct sk_buff *skb=
, struct page *page,
 	int i =3D skb_shinfo(skb)->nr_frags;
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-	frag->page =3D page;
+	__skb_frag_set_page(frag, page);
 	frag->page_offset =3D offset;
 	frag->size =3D size;
=20
@@ -6736,7 +6736,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff =
*skb,
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		len =3D frag->size;
-		mapping =3D np->ops->map_page(np->device, frag->page,
+		mapping =3D np->ops->map_page(np->device, skb_frag_page(frag),
 					    frag->page_offset, len,
 					    DMA_TO_DEVICE);
=20
--=20
1.7.2.5

