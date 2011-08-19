From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 52/75] sungem: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:24 +0100
Message-ID: <1313760467-8598-52-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>,
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
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Joe Perches <joe@perches.com>
Cc: David Decotigny <decot@google.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---
 drivers/net/sungem.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ade35dd..39189bf 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1071,10 +1071,8 @@ static netdev_tx_t gem_start_xmit(struct sk_buff=
 *skb,
 			u64 this_ctrl;
=20
 			len =3D this_frag->size;
-			mapping =3D pci_map_page(gp->pdev,
-					       this_frag->page,
-					       this_frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+			mapping =3D skb_frag_dma_map(&gp->pdev->dev, this_frag,
+						   0, len, PCI_DMA_TODEVICE);
 			this_ctrl =3D ctrl;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
 				this_ctrl |=3D TXDCTRL_EOF;
--=20
1.7.2.5
