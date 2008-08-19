From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] misdn: fix multistatement if block missing braces
Date: Tue, 19 Aug 2008 09:51:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808190946270.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1374640394-1219128699=:4551"
Cc: Jeff Garzik <jeff@garzik.org>, Netdev <netdev@vger.kernel.org>
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58966 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbYHSGvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 02:51:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1374640394-1219128699=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


...Once again these show up though not causing any harm in
this case (yet).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/isdn/mISDN/dsp_cmx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index e92b1ba..7fecad2 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1855,7 +1855,7 @@ dsp_cmx_hdlc(struct dsp *dsp, struct sk_buff *skb)
 		/* in case of hardware (echo) */
 		if (dsp->pcm_slot_tx >= 0)
 			return;
-		if (dsp->echo)
+		if (dsp->echo) {
 			nskb = skb_clone(skb, GFP_ATOMIC);
 			if (nskb) {
 				hh = mISDN_HEAD_P(nskb);
@@ -1864,6 +1864,7 @@ dsp_cmx_hdlc(struct dsp *dsp, struct sk_buff *skb)
 				skb_queue_tail(&dsp->sendq, nskb);
 				schedule_work(&dsp->workq);
 			}
+		}
 		return;
 	}
 	/* in case of hardware conference */
-- 
1.5.2.2

---696208474-1374640394-1219128699=:4551--
