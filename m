From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 5/9][v2] mISDN: fix sparse warning: symbol 'nskb' shadows an earlier one
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a31.0aa1660a.486c.07b8@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759717AbYLKXBe@vger.kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: define first occurence of variable 'nskb' in inner most possible scope

Fix this sparse warning:

  drivers/isdn/mISDN/dsp_core.c:746:20: warning: symbol 'nskb' shadows an earlier one
  drivers/isdn/mISDN/dsp_core.c:634:19: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/mISDN/dsp_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 41af063..1dc21d8 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -631,7 +631,6 @@ dsp_function(struct mISDNchannel *ch,  struct sk_buff *skb)
 	int			ret = 0;
 	u8			*digits;
 	int			cont;
-	struct			sk_buff *nskb;
 	u_long			flags;
 
 	hh = mISDN_HEAD_P(skb);
@@ -690,6 +689,7 @@ dsp_function(struct mISDNchannel *ch,  struct sk_buff *skb)
 			digits = dsp_dtmf_goertzel_decode(dsp, skb->data,
 				skb->len, (dsp_options&DSP_OPT_ULAW)?1:0);
 			while (*digits) {
+				struct sk_buff *nskb;
 				if (dsp_debug & DEBUG_DSP_DTMF)
 					printk(KERN_DEBUG "%s: digit"
 					    "(%c) to layer %s\n",
-- 
1.5.6.3
