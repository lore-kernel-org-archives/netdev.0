From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Thu, 22 Sep 2011 15:16:16 +1000
Message-ID: <20110922151616.95d604bbc0c1a9bbec3dc7cb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kasper Pedersen <kernel@kasperkp.dk>,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/ethernet/broadcom/tg3.c between commit 5c1e688388f6 ("tg3:
fix VLAN tagging regression") from Linus' tree and commit 93a700a9d20b
("tg3: Code movement") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/tg3.c
index 4a1374d,1485013..0000000
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@@ -6234,15 -6734,17 +6734,15 @@@ static netdev_tx_t tg3_start_xmit(struc
  		}
  	}
  
+ 	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
+ 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
+ 		base_flags |= TXD_FLAG_JMB_PKT;
+ 
 -#ifdef BCM_KERNEL_SUPPORTS_8021Q
  	if (vlan_tx_tag_present(skb)) {
  		base_flags |= TXD_FLAG_VLAN;
  		vlan = vlan_tx_tag_get(skb);
  	}
 -#endif
  
- 	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
- 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
- 		base_flags |= TXD_FLAG_JMB_PKT;
- 
  	len = skb_headlen(skb);
  
  	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
