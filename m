From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 07/11] gigaset: correct debugging output selection
Date: Wed,  7 Oct 2009 00:18:56 +0200 (CEST)
Message-ID: <20091006-patch-gigaset-07.tilman@imap.cc>
References: <20091006-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: isdn4linux-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>,
        Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>, Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20091006-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Dump payload data consistently only when DEBUG_STREAM_DUMP debug bit
is set.

Impact: debugging aid
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---
 drivers/isdn/gigaset/isocdata.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index bed38fc..7fd32f0 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -429,7 +429,7 @@ static inline int hdlc_buildframe(struct isowbuf_t *iwb,
 		return -EAGAIN;
 	}
 
-	dump_bytes(DEBUG_STREAM, "snd data", in, count);
+	dump_bytes(DEBUG_STREAM_DUMP, "snd data", in, count);
 
 	/* bitstuff and checksum input data */
 	fcs = PPP_INITFCS;
@@ -448,7 +448,6 @@ static inline int hdlc_buildframe(struct isowbuf_t *iwb,
 	/* put closing flag and repeat byte for flag idle */
 	isowbuf_putflag(iwb);
 	end = isowbuf_donewrite(iwb);
-	dump_bytes(DEBUG_STREAM_DUMP, "isowbuf", iwb->data, end + 1);
 	return end;
 }
 
@@ -482,6 +481,8 @@ static inline int trans_buildframe(struct isowbuf_t *iwb,
 	}
 
 	gig_dbg(DEBUG_STREAM, "put %d bytes", count);
+	dump_bytes(DEBUG_STREAM_DUMP, "snd data", in, count);
+
 	write = iwb->write;
 	do {
 		c = bitrev8(*in++);
@@ -583,7 +584,7 @@ static inline void hdlc_done(struct bc_state *bcs)
 		procskb->tail -= 2;
 		gig_dbg(DEBUG_ISO, "%s: good frame (%d octets)",
 			__func__, procskb->len);
-		dump_bytes(DEBUG_STREAM,
+		dump_bytes(DEBUG_STREAM_DUMP,
 			   "rcv data", procskb->data, procskb->len);
 		bcs->hw.bas->goodbytes += procskb->len;
 		gigaset_rcv_skb(procskb, bcs->cs, bcs);
@@ -878,6 +879,8 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 			dobytes--;
 		}
 		if (dobytes == 0) {
+			dump_bytes(DEBUG_STREAM_DUMP,
+				   "rcv data", skb->data, skb->len);
 			gigaset_rcv_skb(skb, bcs->cs, bcs);
 			bcs->skb = skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN);
 			if (!skb) {
-- 
1.6.2.1.214.ge986c
