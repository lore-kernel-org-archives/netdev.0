From: Greg KH <gregkh@suse.de>
Subject: [patch 34/37] sky2: use dev_alloc_skb for receive buffers
Date: Wed, 6 Sep 2006 15:57:59 -0700
Message-ID: <20060906225759.GI15922@kroah.com>
References: <20060906224631.999046890@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965073AbWIFXFy@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename="sky2-dev-alloc.patch"
In-Reply-To: <20060906225444.GA15922@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@osdl.org>

Several code paths assume an additional 16 bytes of header padding
on the receive path. Use dev_alloc_skb to get that padding.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -949,14 +949,14 @@ static void sky2_vlan_rx_kill_vid(struct
 /*
  * It appears the hardware has a bug in the FIFO logic that
  * cause it to hang if the FIFO gets overrun and the receive buffer
- * is not aligned. ALso alloc_skb() won't align properly if slab
+ * is not aligned. Also dev_alloc_skb() won't align properly if slab
  * debugging is enabled.
  */
 static inline struct sk_buff *sky2_alloc_skb(unsigned int size, gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
+	skb = __dev_alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
 	if (likely(skb)) {
 		unsigned long p	= (unsigned long) skb->data;
 		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
@@ -1855,7 +1855,7 @@ static struct sk_buff *sky2_receive(stru
 		goto oversize;
 
 	if (length < copybreak) {
-		skb = alloc_skb(length + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(length + 2);
 		if (!skb)
 			goto resubmit;
 

--
