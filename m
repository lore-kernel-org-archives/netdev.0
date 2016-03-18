From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 16:35:55 +0000
Message-ID: <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix order of mac80211_rx_flags description to match the enum.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

I want ahead and fixed the order of the descriptions. checkpatch.pl was giving
a warning to my previous patch and I had a hunch it was because the wrong order
breaks the parser. Indeed it does and with this patch below checkpatch.pl does
not complain about this flag descriptions anymore.

Thanks,
Luis

 include/net/mac80211.h | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 42c8cde..4b215a3 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -992,17 +992,13 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  * @RX_FLAG_MMIC_ERROR: Michael MIC error was reported on this frame.
  *	Use together with %RX_FLAG_MMIC_STRIPPED.
  * @RX_FLAG_DECRYPTED: This frame was decrypted in hardware.
+ * @RX_FLAG_MACTIME_PLCP_START: The timestamp passed in the RX status (@mactime
+ *	field) is valid and contains the time the SYNC preamble was received.
  * @RX_FLAG_MMIC_STRIPPED: the Michael MIC is stripped off this frame,
  *	verification has been done by the hardware.
  * @RX_FLAG_IV_STRIPPED: The IV/ICV are stripped from this frame.
  *	If this flag is set, the stack cannot do any replay detection
  *	hence the driver or hardware will have to do that.
- * @RX_FLAG_PN_VALIDATED: Currently only valid for CCMP/GCMP frames, this
- *	flag indicates that the PN was verified for replay protection.
- *	Note that this flag is also currently only supported when a frame
- *	is also decrypted (ie. @RX_FLAG_DECRYPTED must be set)
- * @RX_FLAG_DUP_VALIDATED: Set this flag for the driver to check for packet
- *	duplication by itself.
  * @RX_FLAG_FAILED_FCS_CRC: Set this flag if the FCS check failed on
  *	the frame.
  * @RX_FLAG_FAILED_PLCP_CRC: Set this flag if the PCLP check failed on
@@ -1011,14 +1007,8 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  *	field) is valid and contains the time the first symbol of the MPDU
  *	was received. This is useful in monitor mode and for proper IBSS
  *	merging.
- * @RX_FLAG_MACTIME_END: The timestamp passed in the RX status (@mactime
- *	field) is valid and contains the time the last symbol of the MPDU
- *	(including FCS) was received.
- * @RX_FLAG_MACTIME_PLCP_START: The timestamp passed in the RX status (@mactime
- *	field) is valid and contains the time the SYNC preamble was received.
  * @RX_FLAG_SHORTPRE: Short preamble was used for this frame
  * @RX_FLAG_HT: HT MCS was used and rate_idx is MCS index
- * @RX_FLAG_VHT: VHT MCS was used and rate_index is MCS index
  * @RX_FLAG_40MHZ: HT40 (40 MHz) was used
  * @RX_FLAG_SHORT_GI: Short guard interval was used
  * @RX_FLAG_NO_SIGNAL_VAL: The signal strength value is not present.
@@ -1029,6 +1019,12 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  * @RX_FLAG_AMPDU_DETAILS: A-MPDU details are known, in particular the reference
  *	number (@ampdu_reference) must be populated and be a distinct number for
  *	each A-MPDU
+ * @RX_FLAG_PN_VALIDATED: Currently only valid for CCMP/GCMP frames, this
+ *	flag indicates that the PN was verified for replay protection.
+ *	Note that this flag is also currently only supported when a frame
+ *	is also decrypted (ie. @RX_FLAG_DECRYPTED must be set)
+ * @RX_FLAG_DUP_VALIDATED: Set this flag for the driver to check for packet
+ *	duplication by itself.
  * @RX_FLAG_AMPDU_LAST_KNOWN: last subframe is known, should be set on all
  *	subframes of a single A-MPDU
  * @RX_FLAG_AMPDU_IS_LAST: this subframe is the last subframe of the A-MPDU
@@ -1036,8 +1032,10 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  *	on this subframe
  * @RX_FLAG_AMPDU_DELIM_CRC_KNOWN: The delimiter CRC field is known (the CRC
  *	is stored in the @ampdu_delimiter_crc field)
- * @RX_FLAG_MIC_STRIPPED: The mic was stripped of this packet. Decryption was
- *	done by the hardware
+ * @RX_FLAG_MACTIME_END: The timestamp passed in the RX status (@mactime
+ *	field) is valid and contains the time the last symbol of the MPDU
+ *	(including FCS) was received.
+ * @RX_FLAG_VHT: VHT MCS was used and rate_index is MCS index
  * @RX_FLAG_LDPC: LDPC was used
  * @RX_FLAG_ONLY_MONITOR: Report frame only to monitor interfaces without
  *	processing it in any regular way.
@@ -1062,6 +1060,8 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
  * @RX_FLAG_RADIOTAP_VENDOR_DATA: This frame contains vendor-specific
  *	radiotap data in the skb->data (before the frame) as described by
  *	the &struct ieee80211_vendor_radiotap.
+ * @RX_FLAG_MIC_STRIPPED: The mic was stripped of this packet. Decryption was
+ *	done by the hardware
  */
 enum mac80211_rx_flags {
 	RX_FLAG_MMIC_ERROR		= BIT(0),
-- 
2.5.1
