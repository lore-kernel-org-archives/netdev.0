From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Wed, 3 Feb 2010 11:39:47 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1002031136560.15395@pobox.suse.cz>
References: <20100203133011.75aef1d3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org, Daniel Mack <daniel@caiaq.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100203133011.75aef1d3.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Feb 2010, Stephen Rothwell wrote:

> Today's linux-next merge of the trivial tree got a conflict in
> drivers/net/ppp_generic.c between commit
> fa44a73cc766c7f3bac71a66d564e0049b800325 ("ppp_generic.c severly
> whitespace damanged by 9c705260feea6ae329bc6b6d5f6d2ef0227eda0a") from
> the net tree and commit 09e1aa00f106a476f5b90d94fc0139544bbded75
> ("tree-wide: fix 'lenght' typo in comments and code") from the trivial
> tree.
> 
> I fixed it up (by using the trivial tree version) and can carry the fix
> as necessary.

Hi,

I think the best thing is me dropping the net/ and drivers/net hunks of 
this patch and taking it through Davem's tree ... I have already dropped 
those hunks from my tree. Dave, the patch is below, please consider 
applying.



From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] net: fix 'lenght' typo in comments and code

Some misspelled occurences of 'octet' and some comments were also fixed
as I was on it.

Signed-off-by: Daniel Mack <daniel@caiaq.de>
Cc: Jiri Kosina <trivial@kernel.org>
Cc: Joe Perches <joe@perches.com>
Cc: Junio C Hamano <gitster@pobox.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 2282e72..16cb124 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1436,17 +1436,16 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		}
 
 		/*
-		 *check	if we are on the last channel or
-		 *we exceded the lenght	of the data	to
-		 *fragment
+		 * check if we are on the last channel or we exceeded the length
+		 * of the data to fragment
 		 */
 		if ((nfree <= 0) || (flen > len))
 			flen = len;
 		/*
-		 *it is not worth to tx on slow channels:
-		 *in that case from the resulting flen according to the
-		 *above formula will be equal or less than zero.
-		 *Skip the channel in this case
+		 * it is not worth to tx on slow channels:
+		 * in that case from the resulting flen according to the above
+		 * formula will be equal or less than zero.
+		 * skip the channel in this case.
 		 */
 		if (flen <=	0) {
 			pch->avail = 2;
@@ -1466,7 +1465,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 			goto noskb;
 		q =	skb_put(frag, flen + hdrlen);
 
-		/* make	the	MP header */
+		/* make	the MP header */
 		q[0] = PPP_MP >> 8;
 		q[1] = PPP_MP;
 		if (ppp->flags & SC_MP_XSHORTSEQ) {
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index f03e2e4..a3f9c3f 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -578,7 +578,7 @@ static int r6040_rx(struct net_device *dev, int limit)
 			/* RX dribble */
 			if (err & DSC_RX_ERR_DRI)
 				dev->stats.rx_frame_errors++;
-			/* Buffer lenght exceeded */
+			/* Buffer length exceeded */
 			if (err & DSC_RX_ERR_BUF)
 				dev->stats.rx_length_errors++;
 			/* Packet too long */
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index 9f83a11..dab3ac7 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -65,7 +65,7 @@ static const int sb1000_debug = 1;
 
 static const int SB1000_IO_EXTENT = 8;
 /* SB1000 Maximum Receive Unit */
-static const int SB1000_MRU = 1500; /* octects */
+static const int SB1000_MRU = 1500; /* octets */
 
 #define NPIDS 4
 struct sb1000_private {
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index e49e518..81e5def 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -169,7 +169,7 @@ struct stmmac_extra_stats {
 	unsigned long rx_toolong;
 	unsigned long rx_collision;
 	unsigned long rx_crc;
-	unsigned long rx_lenght;
+	unsigned long rx_length;
 	unsigned long rx_mii;
 	unsigned long rx_multicast;
 	unsigned long rx_gmac_overflow;
diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
index 52586ee..620b204 100644
--- a/drivers/net/stmmac/gmac.c
+++ b/drivers/net/stmmac/gmac.c
@@ -257,7 +257,7 @@ static int gmac_coe_rdes0(int ipc_err, int type, int payload_err)
 
 	/* bits 5 7 0 | Frame status
 	 * ----------------------------------------------------------
-	 *      0 0 0 | IEEE 802.3 Type frame (lenght < 1536 octects)
+	 *      0 0 0 | IEEE 802.3 Type frame (length < 1536 octets)
 	 *      1 0 0 | IPv4/6 No CSUM errorS.
 	 *      1 0 1 | IPv4/6 CSUM PAYLOAD error
 	 *      1 1 0 | IPv4/6 CSUM IP HR error
@@ -358,7 +358,7 @@ static int gmac_get_rx_frame_status(void *data, struct stmmac_extra_stats *x,
 	}
 	if (unlikely(p->des01.erx.length_error)) {
 		DBG(KERN_ERR "GMAC RX: length_error error\n");
-		x->rx_lenght++;
+		x->rx_length++;
 		ret = discard_frame;
 	}
 #ifdef STMMAC_VLAN_TAG_USED
diff --git a/drivers/net/stmmac/mac100.c b/drivers/net/stmmac/mac100.c
index 625171b..1f6b608 100644
--- a/drivers/net/stmmac/mac100.c
+++ b/drivers/net/stmmac/mac100.c
@@ -262,7 +262,7 @@ static int mac100_get_rx_frame_status(void *data, struct stmmac_extra_stats *x,
 		ret = discard_frame;
 
 	if (unlikely(p->des01.rx.length_error)) {
-		x->rx_lenght++;
+		x->rx_length++;
 		ret = discard_frame;
 	}
 	if (unlikely(p->des01.rx.mii_error)) {
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 694ebe6..9edda5d 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -61,7 +61,7 @@ static const struct  stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(rx_toolong),
 	STMMAC_STAT(rx_collision),
 	STMMAC_STAT(rx_crc),
-	STMMAC_STAT(rx_lenght),
+	STMMAC_STAT(rx_length),
 	STMMAC_STAT(rx_mii),
 	STMMAC_STAT(rx_multicast),
 	STMMAC_STAT(rx_gmac_overflow),
diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 5cc0f27..9c61e5f 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -105,7 +105,7 @@ static inline void edc_init(struct edc *edc)
  *
  * @edc: pointer to error density counter.
  * @max_err: maximum number of errors we can accept over the timeframe
- * @timeframe: lenght of the timeframe (in jiffies).
+ * @timeframe: length of the timeframe (in jiffies).
  *
  * Returns: !0 1 if maximum acceptable errors per timeframe has been
  *     exceeded. 0 otherwise.
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index afd26bf..c4e4121 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -279,7 +279,7 @@ static void p54spi_power_on(struct p54s_priv *priv)
 	enable_irq(gpio_to_irq(p54spi_gpio_irq));
 
 	/*
-	 * need to wait a while before device can be accessed, the lenght
+	 * need to wait a while before device can be accessed, the length
 	 * is just a guess
 	 */
 	msleep(10);
diff --git a/drivers/net/wireless/wl12xx/wl1251_cmd.c b/drivers/net/wireless/wl12xx/wl1251_cmd.c
index 770f260..ff446a0 100644
--- a/drivers/net/wireless/wl12xx/wl1251_cmd.c
+++ b/drivers/net/wireless/wl12xx/wl1251_cmd.c
@@ -103,7 +103,7 @@ int wl1251_cmd_test(struct wl1251 *wl, void *buf, size_t buf_len, u8 answer)
  * @wl: wl struct
  * @id: acx id
  * @buf: buffer for the response, including all headers, must work with dma
- * @len: lenght of buf
+ * @len: length of buf
  */
 int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 {
diff --git a/drivers/net/wireless/wl12xx/wl1251_rx.c b/drivers/net/wireless/wl12xx/wl1251_rx.c
index f84cc89..0a45528 100644
--- a/drivers/net/wireless/wl12xx/wl1251_rx.c
+++ b/drivers/net/wireless/wl12xx/wl1251_rx.c
@@ -135,7 +135,7 @@ static void wl1251_rx_body(struct wl1251 *wl,
 	rx_buffer = skb_put(skb, length);
 	wl1251_mem_read(wl, rx_packet_ring_addr, rx_buffer, length);
 
-	/* The actual lenght doesn't include the target's alignment */
+	/* The actual length doesn't include the target's alignment */
 	skb->len = desc->length  - PLCP_HEADER_LENGTH;
 
 	fc = (u16 *)skb->data;
diff --git a/drivers/net/wireless/wl12xx/wl1271_cmd.c b/drivers/net/wireless/wl12xx/wl1271_cmd.c
index c3385b3..1e3d4b0 100644
--- a/drivers/net/wireless/wl12xx/wl1271_cmd.c
+++ b/drivers/net/wireless/wl12xx/wl1271_cmd.c
@@ -437,7 +437,7 @@ int wl1271_cmd_test(struct wl1271 *wl, void *buf, size_t buf_len, u8 answer)
  * @wl: wl struct
  * @id: acx id
  * @buf: buffer for the response, including all headers, must work with dma
- * @len: lenght of buf
+ * @len: length of buf
  */
 int wl1271_cmd_interrogate(struct wl1271 *wl, u16 id, void *buf, size_t len)
 {
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 7ea557b..fd278d8 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -73,7 +73,7 @@ struct dccp_ackvec {
  * @avr_ack_ackno - sequence number being acknowledged
  * @avr_ack_ptr - pointer into av_buf where this record starts
  * @avr_ack_nonce - av_ack_nonce at the time this record was sent
- * @avr_sent_len - lenght of the record in av_buf
+ * @avr_sent_len - length of the record in av_buf
  */
 struct dccp_ackvec_record {
 	struct list_head avr_node;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index eb6d097..cb4c91d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1206,7 +1206,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
 	 * Otherwise, we need to reserve fragment header and
-	 * fragment alignment (= 8-15 octects, in total).
+	 * fragment alignment (= 8-15 octets, in total).
 	 *
 	 * Note that we may need to "move" the data from the tail of
 	 * of the buffer to the new fragment when we split
-- 
1.6.4.2
