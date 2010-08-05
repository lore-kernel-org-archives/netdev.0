From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 40/42] drivers/isdn: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:29:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052228590.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39105 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934386Ab0HEU3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:29:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In hisax/hfc_sx.c and mISDN/l1oip_core.c, the code after the if is
outdented so that it is not aligned with the if branch.

In mISDN/dsp_cmx.c, an else is added between the original if branch and the
following statement, in line with the code following it.  Without this
change, the first assignment to dsp->rx_W has no useful effect.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/isdn/hisax/hfc_sx.c     |   13 +++++++------
 drivers/isdn/mISDN/dsp_cmx.c    |    1 +
 drivers/isdn/mISDN/l1oip_core.c |    2 +-
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index be5faf4..5aa138e 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -234,13 +234,14 @@ read_fifo(struct IsdnCardState *cs, u_char fifo, int trans_max)
 	  count++;
 	  if (count > trans_max) 
 	    count = trans_max; /* limit length */
-	    if ((skb = dev_alloc_skb(count))) {
-	      dst = skb_put(skb, count);
-	      while (count--) 
+	  skb = dev_alloc_skb(count);
+	  if (skb) {
+	    dst = skb_put(skb, count);
+	    while (count--)
 		*dst++ = Read_hfc(cs, HFCSX_FIF_DRD);
-	      return(skb);
-	    }
-	    else return(NULL); /* no memory */
+	    return skb;
+	  } else
+		return NULL; /* no memory */
 	}
 
 	do {
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 713ef2b..76d9e67 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1237,6 +1237,7 @@ dsp_cmx_receive(struct dsp *dsp, struct sk_buff *skb)
 			if (dsp->cmx_delay)
 				dsp->rx_W = (dsp->rx_R + dsp->cmx_delay)
 					& CMX_BUFF_MASK;
+			else
 				dsp->rx_W = (dsp->rx_R + (dsp_poll >> 1))
 					& CMX_BUFF_MASK;
 		} else {
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 22f38e4..5b59796 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -972,7 +972,7 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 		if (debug & DEBUG_L1OIP_SOCKET)
 			printk(KERN_DEBUG "%s: got new ip address from user "
 				"space.\n", __func__);
-			l1oip_socket_open(hc);
+		l1oip_socket_open(hc);
 		break;
 	case MISDN_CTRL_UNSETPEER:
 		if (debug & DEBUG_L1OIP_SOCKET)
