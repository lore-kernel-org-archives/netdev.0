From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] irda: Add irda_skb_cb qdisc related padding
Date: Wed, 17 Dec 2008 23:49:06 +0100
Message-ID: <20081217224906.GA5783@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:42671 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750961AbYLQWqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 17:46:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

We need to pad irda_skb_cb in order to keep it safe accross dev_queue_xmit()
calls. This is some ugly and temporary hack triggered by recent qisc code
changes.
Even though it fixes bugzilla.kernel.org bug #11795, it will be replaced by a
proper fix before 2.6.29 is released.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda_device.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 3025ae1..94c852d 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -135,9 +135,11 @@ struct dongle_reg {
 
 /* 
  * Per-packet information we need to hide inside sk_buff 
- * (must not exceed 48 bytes, check with struct sk_buff) 
+ * (must not exceed 48 bytes, check with struct sk_buff)
+ * The default_qdisc_pad field is a temporary hack.
  */
 struct irda_skb_cb {
+	unsigned int default_qdisc_pad;
 	magic_t magic;       /* Be sure that we can trust the information */
 	__u32   next_speed;  /* The Speed to be set *after* this frame */
 	__u16   mtt;         /* Minimum turn around time */
-- 
1.6.0.4.766.g6fc4a.dirty

