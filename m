From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 02/14] net: axienet: Fix compilation warnings
Date: Wed, 12 Feb 2014 16:55:36 +0100
Message-ID: <74d9ca89c57b2467bc8b2c669ac09f7e5f74b1b7.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7192279073494987455=="
Cc: Michal Simek <monstr@monstr.eu>, linux-kernel@vger.kernel.org,
 Srikanth Thokala <sthokal@xilinx.com>, Anirudha Sarangi <anirudh@xilinx.com>,
 John Linn <John.Linn@xilinx.com>, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--===============7192279073494987455==
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2210-1392220577-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2210-1392220577-0001

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


--=_mimegpg-monstr-desktop-2210-1392220577-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7maEACgkQykllyylKDCG4hQCfanC3cN3IUvoF9TA/RDofkrif
7jYAnj39Z3rNPtz2oxKNwOHDHCf0i5Sn
=5TMU
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2210-1392220577-0001--


--===============7192279073494987455==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============7192279073494987455==--
