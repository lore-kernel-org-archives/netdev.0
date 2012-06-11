From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 1/4] drivers/net/ethernet/sfc: Add efx_ prefix to
 set_bit_le()
Date: Mon, 11 Jun 2012 21:29:01 +0900
Message-ID: <20120611212901.2b4d0a17.yoshikawa.takuya@oss.ntt.co.jp>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, arnd@arndb.de, avi@redhat.com,
	mtosatti@redhat.com, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	takuya.yoshikawa@gmail.com
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Needed to introduce generic set_bit_le().

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    4 ++--
 drivers/net/ethernet/sfc/net_driver.h |    4 ++--
 drivers/net/ethernet/sfc/nic.c        |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b95f2e1..de11449 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1976,14 +1976,14 @@ static void efx_set_rx_mode(struct net_device *net_dev)
 		netdev_for_each_mc_addr(ha, net_dev) {
 			crc = ether_crc_le(ETH_ALEN, ha->addr);
 			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
-			set_bit_le(bit, mc_hash->byte);
+			efx_set_bit_le(bit, mc_hash->byte);
 		}
 
 		/* Broadcast packets go through the multicast hash filter.
 		 * ether_crc_le() of the broadcast address is 0xbe2612ff
 		 * so we always add bit 0xff to the mask.
 		 */
-		set_bit_le(0xff, mc_hash->byte);
+		efx_set_bit_le(0xff, mc_hash->byte);
 	}
 
 	if (efx->port_enabled)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0e57535..5e084bf 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1081,13 +1081,13 @@ static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
 }
 
 /* Set bit in a little-endian bitfield */
-static inline void set_bit_le(unsigned nr, unsigned char *addr)
+static inline void efx_set_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] |= (1 << (nr % 8));
 }
 
 /* Clear bit in a little-endian bitfield */
-static inline void clear_bit_le(unsigned nr, unsigned char *addr)
+static inline void efx_clear_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] &= ~(1 << (nr % 8));
 }
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 4a9a5be..3abde7b 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -473,9 +473,9 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 
 		efx_reado(efx, &reg, FR_AA_TX_CHKSM_CFG);
 		if (tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD)
-			clear_bit_le(tx_queue->queue, (void *)&reg);
+			efx_clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
-			set_bit_le(tx_queue->queue, (void *)&reg);
+			efx_set_bit_le(tx_queue->queue, (void *)&reg);
 		efx_writeo(efx, &reg, FR_AA_TX_CHKSM_CFG);
 	}
 
-- 
1.7.5.4
