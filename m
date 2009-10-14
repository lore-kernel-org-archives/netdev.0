From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 2/9] venet: fix gso.hdr_len to report correct length
Date: Wed, 14 Oct 2009 11:58:56 -0400
Message-ID: <20091014155856.18864.83305.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761929AbZJNP74@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This seemed to have worked for TSO4/6 frames, but breaks for UFO.  In
either case, its just plain wrong, so lets get the header set properly.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index 91c47a9..3d61444 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -512,7 +512,7 @@ vbus_enet_tx_start(struct sk_buff *skb, struct net_device *dev)
 
 			vsg->flags |= VENET_SG_FLAG_GSO;
 
-			vsg->gso.hdrlen = skb_transport_header(skb) - skb->data;
+			vsg->gso.hdrlen = skb_headlen(skb);
 			vsg->gso.size = sinfo->gso_size;
 			if (sinfo->gso_type & SKB_GSO_TCPV4)
 				vsg->gso.type = VENET_GSO_TYPE_TCPV4;
