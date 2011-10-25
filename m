From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH] linux-next: et131x: Fixups due to merge issues from staging
 tree
Date: Tue, 25 Oct 2011 13:15:52 +0100
Message-ID: <20111025121551.GA2108@marke.airties>
References: <20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au>
Reply-To: 20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Einon <mark.einon@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Manually merged changes from commits afc4b13df143, bf3f1a6081aa and 5d6bcdfe38ce into et131x.c as identified in email below.

Also removed dependency on NETDEV_1000 in Kconfig, which no longer exists.

Greg: This patch should also be good for the staging tree.

----------------------------------------------------------
Date: Tue, 25 Oct 2011 19:26:36 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Greg KH <greg@kroah.com>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Pirko
<jpirko@redhat.com>, Ian Campbell <Ian.Campbell@citrix.com>, David Miller
<davem@davemloft.net>, <netdev@vger.kernel.org>, Mark Einon
<mark.einon@gmail.com>
Subject: linux-next: manual merge of the staging tree with the net-next tree

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/et131x/et1310_tx.c drivers/staging/et131x/et131x_netdev.c
between commits afc4b13df143 ("net: remove use of ndo_set_multicast_list
in drivers"), bf3f1a6081aa ("et131x: convert to SKB paged frag API") and
5d6bcdfe38ce ("net: use DMA_x_DEVICE and dma_mapping_error with
skb_frag_dma_map") from the net-next tree and commit d2796743cba2
("staging: et131x: Put all .c files into one big file") from the staging
tree.

The latter removed these files, so I did that but more fixup is proably
needed.
-----------------------------------------------------------

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/Kconfig  |    2 +-
 drivers/staging/et131x/et131x.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/et131x/Kconfig b/drivers/staging/et131x/Kconfig
index f0ed08d..9e1864c 100644
--- a/drivers/staging/et131x/Kconfig
+++ b/drivers/staging/et131x/Kconfig
@@ -1,6 +1,6 @@
 config ET131X
 	tristate "Agere ET-1310 Gigabit Ethernet support"
-	depends on NETDEV_1000 && PCI
+	depends on PCI
 	default n
 	---help---
 	  This driver supports Agere ET-1310 ethernet adapters.
diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 45b88d4..32c805b 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -3403,12 +3403,12 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 			 * returned by dma_map_page() is always 32-bit
 			 * addressable (as defined by the pci/dma subsystem)
 			 */
-			desc[frag++].addr_lo =
-			    dma_map_page(&adapter->pdev->dev,
-					 frags[i - 1].page,
-					 frags[i - 1].page_offset,
-					 frags[i - 1].size,
-					 DMA_TO_DEVICE);
+			desc[frag++].addr_lo = skb_frag_dma_map(
+                                                       &adapter->pdev->dev,
+                                                       &frags[i - 1],
+                                                       0,
+                                                       frags[i - 1].size,
+                                                       DMA_TO_DEVICE);
 		}
 	}
 
@@ -5233,7 +5233,7 @@ static const struct net_device_ops et131x_netdev_ops = {
 	.ndo_open		= et131x_open,
 	.ndo_stop		= et131x_close,
 	.ndo_start_xmit		= et131x_tx,
-	.ndo_set_multicast_list	= et131x_multicast,
+	.ndo_set_rx_mode        = et131x_multicast,
 	.ndo_tx_timeout		= et131x_tx_timeout,
 	.ndo_change_mtu		= et131x_change_mtu,
 	.ndo_set_mac_address	= et131x_set_mac_addr,
-- 
1.7.6.4
