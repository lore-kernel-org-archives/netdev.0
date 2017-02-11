From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/7] staging: r8712u: Fix macros used to read/write the TX/RX
 descriptors
Date: Fri, 10 Feb 2017 21:30:26 -0600
Message-ID: <20170211033030.28827-4-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Although the driver works on big-endian hardware, Sparse generates a lot
of warnings. Many of these are the result of incorrect coding of these
macros.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/wifi.h | 109 ++++++++++++++++++++---------------------
 1 file changed, 52 insertions(+), 57 deletions(-)

diff --git a/drivers/staging/rtl8712/wifi.h b/drivers/staging/rtl8712/wifi.h
index 7ebf247..74dfc9b 100644
--- a/drivers/staging/rtl8712/wifi.h
+++ b/drivers/staging/rtl8712/wifi.h
@@ -151,92 +151,88 @@ enum WIFI_REG_DOMAIN {
 #define _ORDER_		BIT(15)
 
 #define SetToDs(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_TO_DS_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_TO_DS_); \
 })
 
-#define GetToDs(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_TO_DS_)) != 0)
+#define GetToDs(pbuf)	(((*(__le16 *)(pbuf)) & cpu_to_le16(_TO_DS_)) != 0)
 
 #define ClearToDs(pbuf)	({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_TO_DS_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_TO_DS_)); \
 })
 
 #define SetFrDs(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_FROM_DS_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_FROM_DS_); \
 })
 
-#define GetFrDs(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_FROM_DS_)) != 0)
+#define GetFrDs(pbuf)	(((*(__le16 *)(pbuf)) & cpu_to_le16(_FROM_DS_)) != 0)
 
 #define ClearFrDs(pbuf)	({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_FROM_DS_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_FROM_DS_)); \
 })
 
 #define get_tofr_ds(pframe)	((GetToDs(pframe) << 1) | GetFrDs(pframe))
 
 
 #define SetMFrag(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_MORE_FRAG_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_MORE_FRAG_); \
 })
 
-#define GetMFrag(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_MORE_FRAG_)) != 0)
+#define GetMFrag(pbuf)	(((*(__le16 *)(pbuf)) & cpu_to_le16(_MORE_FRAG_)) != 0)
 
 #define ClearMFrag(pbuf) ({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_MORE_FRAG_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_MORE_FRAG_)); \
 })
 
 #define SetRetry(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_RETRY_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_RETRY_); \
 })
 
-#define GetRetry(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_RETRY_)) != 0)
+#define GetRetry(pbuf)	(((*(__le16 *)(pbuf)) & cpu_to_le16(_RETRY_)) != 0)
 
 #define ClearRetry(pbuf) ({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_RETRY_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_RETRY_)); \
 })
 
 #define SetPwrMgt(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_PWRMGT_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_PWRMGT_); \
 })
 
-#define GetPwrMgt(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_PWRMGT_)) != 0)
+#define GetPwrMgt(pbuf)	(((*(__le16 *)(pbuf)) & \
+			cpu_to_le16(_PWRMGT_)) != 0)
 
 #define ClearPwrMgt(pbuf) ({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_PWRMGT_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_PWRMGT_)); \
 })
 
 #define SetMData(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_MORE_DATA_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_MORE_DATA_); \
 })
 
-#define GetMData(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_MORE_DATA_)) != 0)
+#define GetMData(pbuf)	(((*(__le16 *)(pbuf)) & \
+			cpu_to_le16(_MORE_DATA_)) != 0)
 
 #define ClearMData(pbuf) ({ \
-	*(unsigned short *)(pbuf) &= (~cpu_to_le16(_MORE_DATA_)); \
+	*(__le16 *)(pbuf) &= (~cpu_to_le16(_MORE_DATA_)); \
 })
 
 #define SetPrivacy(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_PRIVACY_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_PRIVACY_); \
 })
 
-#define GetPrivacy(pbuf)	(((*(unsigned short *)(pbuf)) & \
-				le16_to_cpu(_PRIVACY_)) != 0)
+#define GetPrivacy(pbuf)	(((*(__le16 *)(pbuf)) & \
+				cpu_to_le16(_PRIVACY_)) != 0)
 
-#define GetOrder(pbuf)	(((*(unsigned short *)(pbuf)) & \
-			le16_to_cpu(_ORDER_)) != 0)
+#define GetOrder(pbuf)	(((*(__le16 *)(pbuf)) & \
+			cpu_to_le16(_ORDER_)) != 0)
 
 #define GetFrameType(pbuf)	(le16_to_cpu(*(__le16 *)(pbuf)) & \
 				(BIT(3) | BIT(2)))
 
 #define SetFrameType(pbuf, type)	\
 	do {	\
-		*(unsigned short *)(pbuf) &= cpu_to_le16(~(BIT(3) | \
+		*(__le16 *)(pbuf) &= cpu_to_le16(~(BIT(3) | \
 		BIT(2))); \
-		*(unsigned short *)(pbuf) |= cpu_to_le16(type); \
+		*(__le16 *)(pbuf) |= cpu_to_le16(type); \
 	} while (0)
 
 #define GetFrameSubType(pbuf)	(le16_to_cpu(*(__le16 *)(pbuf)) & \
@@ -245,44 +241,43 @@ enum WIFI_REG_DOMAIN {
 
 #define SetFrameSubType(pbuf, type) \
 	do {    \
-		*(unsigned short *)(pbuf) &= cpu_to_le16(~(BIT(7) | BIT(6) | \
+		*(__le16 *)(pbuf) &= cpu_to_le16(~(BIT(7) | BIT(6) | \
 		BIT(5) | BIT(4) | BIT(3) | BIT(2))); \
-		*(unsigned short *)(pbuf) |= cpu_to_le16(type); \
+		*(__le16 *)(pbuf) |= cpu_to_le16(type); \
 	} while (0)
 
-#define GetSequence(pbuf)	(cpu_to_le16(*(unsigned short *)\
+#define GetSequence(pbuf)	(le16_to_cpu(*(__le16 *)\
 				((addr_t)(pbuf) + 22)) >> 4)
 
-#define GetFragNum(pbuf)	(cpu_to_le16(*(unsigned short *)((addr_t)\
+#define GetFragNum(pbuf)	(le16_to_cpu(*(__le16 *)((addr_t)\
 				(pbuf) + 22)) & 0x0f)
 
 #define SetSeqNum(pbuf, num) ({ \
-	*(unsigned short *)((addr_t)(pbuf) + 22) = \
-	((*(unsigned short *)((addr_t)(pbuf) + 22)) & \
-	le16_to_cpu((unsigned short)0x000f)) | \
-	le16_to_cpu((unsigned short)(0xfff0 & (num << 4))); \
+	*(__le16 *)((addr_t)(pbuf) + 22) = \
+	cpu_to_le16((le16_to_cpu(*(__le16 *)((addr_t)(pbuf) + 22)) & \
+	0x000f) | (0xfff0 & (num << 4))); \
 })
 
 #define SetDuration(pbuf, dur) ({ \
-	*(unsigned short *)((addr_t)(pbuf) + 2) |= \
+	*(__le16 *)((addr_t)(pbuf) + 2) |= \
 	cpu_to_le16(0xffff & (dur)); \
 })
 
 #define SetPriority(pbuf, tid) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(tid & 0xf); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(tid & 0xf); \
 })
 
-#define GetPriority(pbuf)	((le16_to_cpu(*(unsigned short *)(pbuf))) & 0xf)
+#define GetPriority(pbuf)	((le16_to_cpu(*(__le16 *)(pbuf))) & 0xf)
 
 #define SetAckpolicy(pbuf, ack) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16((ack & 3) << 5); \
+	*(__le16 *)(pbuf) |= cpu_to_le16((ack & 3) << 5); \
 })
 
-#define GetAckpolicy(pbuf) (((le16_to_cpu(*(unsigned short *)pbuf)) >> 5) & 0x3)
+#define GetAckpolicy(pbuf) (((le16_to_cpu(*(__le16 *)pbuf)) >> 5) & 0x3)
 
-#define GetAMsdu(pbuf) (((le16_to_cpu(*(unsigned short *)pbuf)) >> 7) & 0x1)
+#define GetAMsdu(pbuf) (((le16_to_cpu(*(__le16 *)pbuf)) >> 7) & 0x1)
 
-#define GetAid(pbuf)	(cpu_to_le16(*(unsigned short *)((addr_t)(pbuf) + 2)) \
+#define GetAid(pbuf)	(cpu_to_le16(*(__le16 *)((addr_t)(pbuf) + 2)) \
 			& 0x3fff)
 
 #define GetAddr1Ptr(pbuf)	((unsigned char *)((addr_t)(pbuf) + 4))
@@ -476,10 +471,10 @@ static inline unsigned char *get_hdr_bssid(unsigned char *pframe)
 #define IEEE80211_DELBA_PARAM_INITIATOR_MASK 0x0800
 
 #define SetOrderBit(pbuf) ({ \
-	*(unsigned short *)(pbuf) |= cpu_to_le16(_ORDER_); \
+	*(__le16 *)(pbuf) |= cpu_to_le16(_ORDER_); \
 })
 
-#define GetOrderBit(pbuf)	(((*(unsigned short *)(pbuf)) & \
+#define GetOrderBit(pbuf)	(((*(__le16 *)(pbuf)) & \
 				le16_to_cpu(_ORDER_)) != 0)
 
 
@@ -490,12 +485,12 @@ static inline unsigned char *get_hdr_bssid(unsigned char *pframe)
  * described in 802.11n draft section 7.2.1.7.1
  */
 struct ieee80211_bar {
-	unsigned short frame_control;
-	unsigned short duration;
+	__le16 frame_control;
+	__le16 duration;
 	unsigned char ra[6];
 	unsigned char ta[6];
-	unsigned short control;
-	unsigned short start_seq_num;
+	__le16 control;
+	__le16 start_seq_num;
 } __packed;
 
 /* 802.11 BAR control masks */
@@ -511,11 +506,11 @@ struct ieee80211_bar {
  */
 
 struct ieee80211_ht_cap {
-	unsigned short	cap_info;
+	__le16	cap_info;
 	unsigned char	ampdu_params_info;
 	unsigned char	supp_mcs_set[16];
-	unsigned short	extended_ht_cap_info;
-	unsigned int		tx_BF_cap_info;
+	__le16	extended_ht_cap_info;
+	__le32	tx_BF_cap_info;
 	unsigned char	       antenna_selection_info;
 } __packed;
 
@@ -528,8 +523,8 @@ struct ieee80211_ht_cap {
 struct ieee80211_ht_addt_info {
 	unsigned char	control_chan;
 	unsigned char		ht_param;
-	unsigned short	operation_mode;
-	unsigned short	stbc_param;
+	__le16	operation_mode;
+	__le16	stbc_param;
 	unsigned char		basic_set[16];
 } __packed;
 
-- 
2.10.2
