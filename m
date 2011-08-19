From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 53/75] sunhme: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:25 +0100
Message-ID: <1313760467-8598-53-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	David Decotigny <decot@google.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: David Decotigny <decot@google.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---
 drivers/net/sunhme.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 856e05b..0f897a0 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2309,9 +2309,8 @@ static netdev_tx_t happy_meal_start_xmit(struct s=
k_buff *skb,
 			u32 len, mapping, this_txflags;
=20
 			len =3D this_frag->size;
-			mapping =3D dma_map_page(hp->dma_dev, this_frag->page,
-					       this_frag->page_offset, len,
-					       DMA_TO_DEVICE);
+			mapping =3D skb_frag_dma_map(hp->dma_dev, this_frag,
+						   0, len, DMA_TO_DEVICE);
 			this_txflags =3D tx_flags;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
 				this_txflags |=3D TXFLAG_EOP;
--=20
1.7.2.5
