From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] atm: horizon: Remove some unused functions
Date: Tue, 13 Jan 2015 19:50:21 +0100
Message-ID: <1421175021-6022-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
channel_to_vpivci() query_tx_channel_config() rx_disabled_handler()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/atm/horizon.c |   24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 1dc0519..527bbd5 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -458,12 +458,6 @@ static inline void update_tx_channel_config (hrz_dev * dev, short chan, u8 mode,
     return;
 }
 
-static inline u16 query_tx_channel_config (hrz_dev * dev, short chan, u8 mode) {
-  wr_regw (dev, TX_CHANNEL_CONFIG_COMMAND_OFF,
-	   chan * TX_CHANNEL_CONFIG_MULT | mode);
-    return rd_regw (dev, TX_CHANNEL_CONFIG_DATA_OFF);
-}
-
 /********** dump functions **********/
 
 static inline void dump_skb (char * prefix, unsigned int vc, struct sk_buff * skb) {
@@ -513,16 +507,6 @@ static inline void dump_framer (hrz_dev * dev) {
 
 /* RX channels are 10 bit integers, these fns are quite paranoid */
 
-static inline int channel_to_vpivci (const u16 channel, short * vpi, int * vci) {
-  unsigned short vci_bits = 10 - vpi_bits;
-  if ((channel & RX_CHANNEL_MASK) == channel) {
-    *vci = channel & ((~0)<<vci_bits);
-    *vpi = channel >> vci_bits;
-    return channel ? 0 : -EINVAL;
-  }
-  return -EINVAL;
-}
-
 static inline int vpivci_to_channel (u16 * channel, const short vpi, const int vci) {
   unsigned short vci_bits = 10 - vpi_bits;
   if (0 <= vpi && vpi < 1<<vpi_bits && 0 <= vci && vci < 1<<vci_bits) {
@@ -1260,14 +1244,6 @@ static u32 rx_queue_entry_next (hrz_dev * dev) {
   return rx_queue_entry;
 }
 
-/********** handle RX disabled by device **********/
-
-static inline void rx_disabled_handler (hrz_dev * dev) {
-  wr_regw (dev, RX_CONFIG_OFF, rd_regw (dev, RX_CONFIG_OFF) | RX_ENABLE);
-  // count me please
-  PRINTK (KERN_WARNING, "RX was disabled!");
-}
-
 /********** handle RX data received by device **********/
 
 // called from IRQ handler
-- 
1.7.10.4
