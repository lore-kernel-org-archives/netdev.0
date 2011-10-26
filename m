From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH V2 2/4] MIPS: Add board support for Loongson1B
Date: Wed, 26 Oct 2011 09:20:55 +0200
Message-ID: <4EA7B4D7.9000101@st.com>
References: <1319192888-21465-1-git-send-email-keguang.zhang@gmail.com> <1319192888-21465-2-git-send-email-keguang.zhang@gmail.com> <CAD+V5YKBkW52_md9rBeVZ1RXq2FGEXt=Ergsw+z8txMreZdNsA@mail.gmail.com> <4EA5117C.3000402@st.com> <CAJhJPsVSzXXmBOwLaGNtOsxhVEyC0fAJtiBvEWzcKcSDC8NEcA@mail.gmail.com> <4EA557B2.4020504@st.com> <CAJhJPsXxUAuF9HdivLd66MQC45mz-iYAuF1SdGdU=-duxJJ5bQ@mail.gmail.com> <4EA585B5.5030405@st.com> <CAJhJPsVu7hahhmUvPQ=s=AqvXGhU-05x=GqQ29Mo6PZ8cTtefA@mail.gmail.com> <4EA660C0.1020901@st.com> <4EA6716A.80307@st.com> <CAJhJPsU3KMNuGcKaKf3H4pUCeu1+vnEz4DgO_jbm+wDQb1G4OA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070509020002010306020205"
Cc: Wu Zhangjin <wuzhangjin@gmail.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	r0bertz@gentoo.org, netdev@vger.kernel.org
To: Kelvin Cheung <keguang.zhang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJhJPsU3KMNuGcKaKf3H4pUCeu1+vnEz4DgO_jbm+wDQb1G4OA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070509020002010306020205
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello Kelvin

On 10/26/2011 6:27 AM, Kelvin Cheung wrote:
> Hi Giuseppe,
> 
> This patch works well on Loongson1B platform except one thing.
> The rx checksum offload of normal descriptor is disabled by default.
> So, I enabled this functon. And one minor tweak is added to your patch.
> What about your opinion?

Yes, I had not enabled the rx coe. I'm resending your patch (v3) where I
fixed a problem. Old mac10/100 has no rx csum in HW. So I added an extra
check.
Let me consider it the final version. ;-)

Thanks a lot for you effort.
I'll send it for net-next now.

Regards
Peppe

> 
> BTW, tx checksum insertion works now.
> 
> 2011/10/25, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>> On 10/25/2011 9:09 AM, Giuseppe CAVALLARO wrote:
>>> On 10/25/2011 4:12 AM, Kelvin Cheung wrote:
>>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>>> On 10/24/2011 4:05 PM, Kelvin Cheung wrote:
>>>>>> 2011/10/24, Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>>>>> Hello Kelvin.
>>>>>>>
>>>>>>> On 10/24/2011 12:36 PM, Kelvin Cheung wrote:
>>>>>>>
>>>>>>> [snip]
>>>>>>>
>>>>>>>> According to datasheet of Loongson 1B, the buffer size in RX/TX
>>>>>>>> descriptor is only 2KB. So the Loongson1B's GMAC could not handle
>>>>>>>> jumbo frames. And the second buffer is useless in this case. Am I
>>>>>>>> right? Is there a better way than ifdef CONFIG_MACH_LOONGSON1 to
>>>>>>>> avoid duplicate code?
>>>>>>>
>>>>>>> Sorry for my misunderstanding.
>>>>>>>
>>>>>>> I think you have to use the normal descriptor and remove the enh_desc
>>>>>>> from the platform w/o modifying the driver at all.
>>>>>>>
>>>>>>> The driver will be able to select/configure all automatically (also
>>>>>>> jumbo).
>>>>>>>
>>>>>>> Let me know.
>>>>>>
>>>>>> That's the problem.
>>>>>> The bitfield definition of Loongson1B is also different from normal
>>>>>> descriptor.
>>>>>
>>>>> The problem is not in the Loongson1B gmac.
>>>>
>>>> I found that the bit checksum_insertion is not existed in normal
>>>> descriptor.
>>>>
>>>>> The normal descriptor fields in the stmmac refer to an old synopsys
>>>>> databook.
>>>>
>>>> Could you send me the new databook of Synopsys GMAC?
>>>>
>>>>> New chips have the same structure you have added; so we should fix this
>>>>> in the driver w/o breaking the compatibility for old chips.
>>>>
>>>> Agree.
>>>>
>>>>> I kindly ask you to confirm if the currently normal descriptor structure
>>>>> (w/o your changes) doesn't work on your platform.
>>>>> Did you test it?
>>>>
>>>> Well, the normal descriptor works on my platform except TX checksum
>>>> offload.
>>>
>>> ok! I suspected that.
>>>
>>>
>>>>>> Moreover, I want to enable the TX checksum offload function which is
>>>>>> not supported in normal descriptor.
>>>>>> Any suggestions?
>>>>>
>>>>> It is supported but you have to pass from the platform: tx_coe = 1.
>>>>
>>>> I noticed that the flag csum_insertion is passed to
>>>> ndesc_prepare_tx_desc() in stmmac_xmit(). But ndesc_prepare_tx_desc()
>>>> just ignores it.
>>>> In other words, the TX checksum offload function is disabled in normal
>>>> descriptor currently.
>>>>
>>>> Should we fix this problem for normal descriptor?
>>>
>>> Yes, we should. If you agree, I'll update the normal descriptor
>>> structure to yours. This is the normal descriptor used in newer GMAC.
>>> Tx csum will be done for normal descriptors in case of these GMAC
>>> devices and not for old MAC10/100. For the MAC10/100 some bits for
>>> normal descriptors are reserved and won't be used at all.
>>>
>>> I'll also verify that the patch doesn't break the back-compatibility
>>> with old MAC10/100. I have the HW where doing the tests.
>>>
>>> After that, I'll prepare the patch for net-next and for your kernel.
>>
>> Hello Kelvin
>>
>> attached the patch tested on my development kernel.
>> It runs fine on old and new mac devices.
>>
>> Can you try it on your side? Hmm, it is likely it won't apply fine on
>> your tree but you know the changes ;-).
>>
>> If ok, I'll rework it for net-next and send it to the mailing list.
>>
>> Thanks
>> Peppe
>>
>>>
>>>>
>>>>> Peppe
>>>>>>
>>>>>>> Note:
>>>>>>> IIRC, there is a bit difference in case of normal descriptors for
>>>>>>> Synopsys databook newer than the 1.91 (I used for testing this mode).
>>>>>>> In any case, I remember that, on some platforms, the normal
>>>>>>> descriptors
>>>>>>> have been used w/o problems also on these new chip generations.
>>>>>>>
>>>>>>> Peppe
>>>>>>>
>>>>>>>
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
> 
> 


--------------070509020002010306020205
Content-Type: text/x-patch;
 name="0001-stmmac-update-normal-descriptor-structure-v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-stmmac-update-normal-descriptor-structure-v3.patch"

>From 324c8e56e728046590bae14d14e8ff09978b71b4 Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 25 Oct 2011 09:46:41 +0200
Subject: [PATCH (sh-2.6.32.y)] stmmac: update normal descriptor structure
 (v3)

This patch updates the normal descriptor structure
to work fine on new GMAC Synopsys chips.

Normal descriptors were designed on the old MAC10/100
databook 1.91 where some bits were reserved: for example
the tx checksum insertion and rx checksum offload.

The patch maintains the back-compatibility with old
MAC devices (tested on STx7109 MAC10/100) and adds new
fields that actually new GMAC devices can use.

For example, STx7109 will pass from the platform
tx_coe = 0, enh_desc = 0, has_gmac = 0.
A platform like Loongson1B (Mips) will pass:
tx_coe = 1, enh_desc = 0, has_gmac = 1.

Thanks to Kelvin, he enhanced the normal descriptors for
GMAC on Loongson1B.

Signed-off-by: Kelvin Cheung <keguang.zhang@gmail.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |    8 +++---
 drivers/net/stmmac/descs.h          |   31 +++++++++++++++-----------
 drivers/net/stmmac/norm_desc.c      |   40 ++++++++++++++++++++--------------
 drivers/net/stmmac/stmmac_ethtool.c |    8 +++---
 drivers/net/stmmac/stmmac_main.c    |    4 +-
 5 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 9100c10..2cc1192 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -49,7 +49,7 @@ struct stmmac_extra_stats {
 	unsigned long tx_underflow ____cacheline_aligned;
 	unsigned long tx_carrier;
 	unsigned long tx_losscarrier;
-	unsigned long tx_heartbeat;
+	unsigned long vlan_tag;
 	unsigned long tx_deferred;
 	unsigned long tx_vlan;
 	unsigned long tx_jabber;
@@ -58,9 +58,9 @@ struct stmmac_extra_stats {
 	unsigned long tx_ip_header_error;
 	/* Receive errors */
 	unsigned long rx_desc;
-	unsigned long rx_partial;
-	unsigned long rx_runt;
-	unsigned long rx_toolong;
+	unsigned long sa_filter_fail;
+	unsigned long overflow_error;
+	unsigned long ipc_csum_error;
 	unsigned long rx_collision;
 	unsigned long rx_crc;
 	unsigned long rx_length;
diff --git a/drivers/net/stmmac/descs.h b/drivers/net/stmmac/descs.h
index 63a03e2..9820ec8 100644
--- a/drivers/net/stmmac/descs.h
+++ b/drivers/net/stmmac/descs.h
@@ -25,33 +25,34 @@ struct dma_desc {
 	union {
 		struct {
 			/* RDES0 */
-			u32 reserved1:1;
+			u32 payload_csum_error:1;
 			u32 crc_error:1;
 			u32 dribbling:1;
 			u32 mii_error:1;
 			u32 receive_watchdog:1;
 			u32 frame_type:1;
 			u32 collision:1;
-			u32 frame_too_long:1;
+			u32 ipc_csum_error:1;
 			u32 last_descriptor:1;
 			u32 first_descriptor:1;
-			u32 multicast_frame:1;
-			u32 run_frame:1;
+			u32 vlan_tag:1;
+			u32 overflow_error:1;
 			u32 length_error:1;
-			u32 partial_frame_error:1;
+			u32 sa_filter_fail:1;
 			u32 descriptor_error:1;
 			u32 error_summary:1;
 			u32 frame_length:14;
-			u32 filtering_fail:1;
+			u32 da_filter_fail:1;
 			u32 own:1;
 			/* RDES1 */
 			u32 buffer1_size:11;
 			u32 buffer2_size:11;
-			u32 reserved2:2;
+			u32 reserved1:2;
 			u32 second_address_chained:1;
 			u32 end_ring:1;
-			u32 reserved3:5;
+			u32 reserved2:5;
 			u32 disable_ic:1;
+
 		} rx;
 		struct {
 			/* RDES0 */
@@ -91,24 +92,28 @@ struct dma_desc {
 			u32 underflow_error:1;
 			u32 excessive_deferral:1;
 			u32 collision_count:4;
-			u32 heartbeat_fail:1;
+			u32 vlan_frame:1;
 			u32 excessive_collisions:1;
 			u32 late_collision:1;
 			u32 no_carrier:1;
 			u32 loss_carrier:1;
-			u32 reserved1:3;
+			u32 payload_error:1;
+			u32 frame_flushed:1;
+			u32 jabber_timeout:1;
 			u32 error_summary:1;
-			u32 reserved2:15;
+			u32 ip_header_error:1;
+			u32 time_stamp_status:1;
+			u32 reserved1:13;
 			u32 own:1;
 			/* TDES1 */
 			u32 buffer1_size:11;
 			u32 buffer2_size:11;
-			u32 reserved3:1;
+			u32 time_stamp_enable:1;
 			u32 disable_padding:1;
 			u32 second_address_chained:1;
 			u32 end_ring:1;
 			u32 crc_disable:1;
-			u32 reserved4:2;
+			u32 checksum_insertion:2;
 			u32 first_segment:1;
 			u32 last_segment:1;
 			u32 interrupt:1;
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/stmmac/norm_desc.c
index f7e8ba7..3955ae7 100644
--- a/drivers/net/stmmac/norm_desc.c
+++ b/drivers/net/stmmac/norm_desc.c
@@ -50,11 +50,12 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			stats->collisions += p->des01.tx.collision_count;
 		ret = -1;
 	}
-	if (unlikely(p->des01.tx.heartbeat_fail)) {
-		x->tx_heartbeat++;
-		stats->tx_heartbeat_errors++;
-		ret = -1;
-	}
+
+        if (p->des01.etx.vlan_frame) {
+                CHIP_DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+                x->tx_vlan++;
+        }
+
 	if (unlikely(p->des01.tx.deferred))
 		x->tx_deferred++;
 
@@ -68,12 +69,12 @@ static int ndesc_get_tx_len(struct dma_desc *p)
 
 /* This function verifies if each incoming frame has some errors
  * and, if required, updates the multicast statistics.
- * In case of success, it returns csum_none because the device
- * is not able to compute the csum in HW. */
+ * In case of success, it returns good_frame because the GMAC device
+ * is supposed to be able to compute the csum in HW. */
 static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 			       struct dma_desc *p)
 {
-	int ret = csum_none;
+	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
 	if (unlikely(p->des01.rx.last_descriptor == 0)) {
@@ -86,12 +87,12 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	if (unlikely(p->des01.rx.error_summary)) {
 		if (unlikely(p->des01.rx.descriptor_error))
 			x->rx_desc++;
-		if (unlikely(p->des01.rx.partial_frame_error))
-			x->rx_partial++;
-		if (unlikely(p->des01.rx.run_frame))
-			x->rx_runt++;
-		if (unlikely(p->des01.rx.frame_too_long))
-			x->rx_toolong++;
+		if (unlikely(p->des01.rx.sa_filter_fail))
+			x->sa_filter_fail++;
+		if (unlikely(p->des01.rx.overflow_error))
+			x->overflow_error++;
+		if (unlikely(p->des01.rx.ipc_csum_error))
+			x->ipc_csum_error++;
 		if (unlikely(p->des01.rx.collision)) {
 			x->rx_collision++;
 			stats->collisions++;
@@ -113,10 +114,12 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		x->rx_mii++;
 		ret = discard_frame;
 	}
-	if (p->des01.rx.multicast_frame) {
-		x->rx_multicast++;
-		stats->multicast++;
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.rx.vlan_tag) {
+		x->vlan_tag++;
+		stats->vlan_tag++;
 	}
+#endif
 	return ret;
 }
 
@@ -184,6 +187,9 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 {
 	p->des01.tx.first_segment = is_fs;
 	norm_set_tx_desc_len(p, len);
+
+	if (likely(csum_flag))
+		p->des01.tx.checksum_insertion = cic_full;
 }
 
 static void ndesc_clear_tx_ic(struct dma_desc *p)
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index d81cf20..6831cf2 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -48,7 +48,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_underflow),
 	STMMAC_STAT(tx_carrier),
 	STMMAC_STAT(tx_losscarrier),
-	STMMAC_STAT(tx_heartbeat),
+	STMMAC_STAT(vlan_tag),
 	STMMAC_STAT(tx_deferred),
 	STMMAC_STAT(tx_vlan),
 	STMMAC_STAT(rx_vlan),
@@ -57,9 +57,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_payload_error),
 	STMMAC_STAT(tx_ip_header_error),
 	STMMAC_STAT(rx_desc),
-	STMMAC_STAT(rx_partial),
-	STMMAC_STAT(rx_runt),
-	STMMAC_STAT(rx_toolong),
+	STMMAC_STAT(sa_filter_fail),
+	STMMAC_STAT(overflow_error),
+	STMMAC_STAT(ipc_csum_error),
 	STMMAC_STAT(rx_collision),
 	STMMAC_STAT(rx_crc),
 	STMMAC_STAT(rx_length),
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 3a3efb1..18e614b 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1318,8 +1318,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
-			if (unlikely(status == csum_none)) {
-				/* always for the old mac 10/100 */
+			if (unlikely(!priv->plat->has_gmac)) {
+				/* No csum for the old mac 10/100 devices */
 				skb->ip_summed = CHECKSUM_NONE;
 				netif_receive_skb(skb);
 			} else {
-- 
1.7.4.4


--------------070509020002010306020205--
