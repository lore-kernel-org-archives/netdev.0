From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 22 Nov 2016 11:58:18 +1100
Message-ID: <20161122115818.2872dfa2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c

between commit:

  ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")

from the net tree and commit:

  38ddc59d65b6 ("net: stmmac: replace all pr_xxx by their netdev_xxx counterpart")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1f9ec02fa7f8,fbd1cd79233d..000000000000
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@@ -2484,7 -2493,7 +2493,7 @@@ static int stmmac_rx(struct stmmac_pri
  	if (netif_msg_rx_status(priv)) {
  		void *rx_head;
  
- 		pr_info(">>>>>> %s: descriptor ring:\n", __func__);
 -		netdev_dbg(priv->dev, "%s: descriptor ring:\n", __func__);
++		netdev_info(priv->dev, ">>>>>> %s: descriptor ring:\n", __func__);
  		if (priv->extend_desc)
  			rx_head = (void *)priv->dma_erx;
  		else
@@@ -2571,11 -2577,11 +2580,11 @@@
  				frame_len -= ETH_FCS_LEN;
  
  			if (netif_msg_rx_status(priv)) {
- 				pr_info("\tdesc: %p [entry %d] buff=0x%x\n",
- 					p, entry, des);
 -				netdev_dbg(priv->dev, "\tdesc: %p [entry %d] buff=0x%x\n",
 -					   p, entry, des);
++				netdev_info(priv->dev, "\tdesc: %p [entry %d] buff=0x%x\n",
++					    p, entry, des);
  				if (frame_len > ETH_FRAME_LEN)
- 					pr_debug("\tframe size %d, COE: %d\n",
- 						 frame_len, status);
+ 					netdev_dbg(priv->dev, "frame size %d, COE: %d\n",
+ 						   frame_len, status);
  			}
  
  			/* The zero-copy is always used for all the sizes
@@@ -2628,8 -2635,11 +2638,9 @@@
  						 DMA_FROM_DEVICE);
  			}
  
 -			stmmac_get_rx_hwtstamp(priv, entry, skb);
 -
  			if (netif_msg_pktdata(priv)) {
- 				pr_debug("frame received (%dbytes)", frame_len);
+ 				netdev_dbg(priv->dev, "frame received (%dbytes)",
+ 					   frame_len);
  				print_pkt(skb->data, frame_len);
  			}
  
