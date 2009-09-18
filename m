From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 08/12] gigaset: correct debugging output selection
Date: Sat, 19 Sep 2009 01:57:43 +0200 (CEST)
Message-ID: <20090919-patch-gigaset-08.tilman@imap.cc>
References: <20090919-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755618AbZIRX7D@vger.kernel.org>
In-Reply-To: <20090919-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dump payload data consistently only when DEBUG_STREAM_DUMP debug bit
is set.

Impact: debugging aid
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
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
