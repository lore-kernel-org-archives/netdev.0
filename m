From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 2/2] net: axienet: Fix compilation warnings
Date: Thu, 13 Feb 2014 08:10:43 +0100
Message-ID: <9be652e995e74663de1df69e6ea101225cb670a2.1392275432.git.michal.simek@xilinx.com>
References: <cover.1392275432.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-8717-1392275455-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392275432.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392275432.git.michal.simek@xilinx.com>
References: <cover.1392275432.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-8717-1392275455-0001

Warning log:
xilinx_axienet_main.c: In function 'axienet_start_xmit_done':
xilinx_axienet_main.c:617:16: warning: operation on 'lp->tx_bd_ci' may be undefined [-Wsequence-point]
xilinx_axienet_main.c: In function 'axienet_start_xmit':
xilinx_axienet_main.c:703:18: warning: operation on 'lp->tx_bd_tail' may be undefined [-Wsequence-point]
xilinx_axienet_main.c:719:17: warning: operation on 'lp->tx_bd_tail' may be undefined [-Wsequence-point]
xilinx_axienet_main.c: In function 'axienet_recv':
xilinx_axienet_main.c:792:16: warning: operation on 'lp->rx_bd_ci' may be undefined [-Wsequence-point]
xilinx_axienet_main.c: In function 'axienet_of_probe':
xilinx_axienet_main.c:1501:21: warning: unused variable 'rc' [-Wunused-variable]

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

Changes in v2:
- Separate bug fixes from features and cleanups

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9fb8ab2..4bfdf8c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -601,7 +601,8 @@ static void axienet_start_xmit_done(struct net_device *ndev)
 		size += status & XAXIDMA_BD_STS_ACTUAL_LEN_MASK;
 		packets++;

-		lp->tx_bd_ci = ++lp->tx_bd_ci % TX_BD_NUM;
+		++lp->tx_bd_ci;
+		lp->tx_bd_ci %= TX_BD_NUM;
 		cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
 		status = cur_p->status;
 	}
@@ -687,7 +688,8 @@ static int axienet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				     skb_headlen(skb), DMA_TO_DEVICE);

 	for (ii = 0; ii < num_frag; ii++) {
-		lp->tx_bd_tail = ++lp->tx_bd_tail % TX_BD_NUM;
+		++lp->tx_bd_tail;
+		lp->tx_bd_tail %= TX_BD_NUM;
 		cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 		frag = &skb_shinfo(skb)->frags[ii];
 		cur_p->phys = dma_map_single(ndev->dev.parent,
@@ -703,7 +705,8 @@ static int axienet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	tail_p = lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx_bd_tail;
 	/* Start the transfer */
 	axienet_dma_out32(lp, XAXIDMA_TX_TDESC_OFFSET, tail_p);
-	lp->tx_bd_tail = ++lp->tx_bd_tail % TX_BD_NUM;
+	++lp->tx_bd_tail;
+	lp->tx_bd_tail %= TX_BD_NUM;

 	return NETDEV_TX_OK;
 }
@@ -775,7 +778,8 @@ static void axienet_recv(struct net_device *ndev)
 		cur_p->status = 0;
 		cur_p->sw_id_offset = (u32) new_skb;

-		lp->rx_bd_ci = ++lp->rx_bd_ci % RX_BD_NUM;
+		++lp->rx_bd_ci;
+		lp->rx_bd_ci %= RX_BD_NUM;
 		cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
 	}

--
1.8.2.3


--=_mimegpg-monstr-desktop-8717-1392275455-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL8b/8ACgkQykllyylKDCH+fQCgjcE7z+eIbRWIbtsCwb0o5++m
yHUAn2im9iGN64W3+14uOX4cZe5gcUV1
=niAh
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-8717-1392275455-0001--
