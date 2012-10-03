From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 4/20] drivers/net/can/sja1000/peak_pcmcia.c: fix error return code
Date: Wed,  3 Oct 2012 18:17:53 +0200
Message-ID: <1349281090-10013-3-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, mkl@pengutronix.de,
	linux@dominikbrodowski.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39029 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933019Ab2JCQS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/can/sja1000/peak_pcmcia.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index ec6bd9d..272a85f 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -686,8 +686,10 @@ static int __devinit pcan_probe(struct pcmcia_device *pdev)
 
 	/* detect available channels */
 	pcan_add_channels(card);
-	if (!card->chan_count)
+	if (!card->chan_count) {
+		err = -ENOMEM;
 		goto probe_err_4;
+	}
 
 	/* init the timer which controls the leds */
 	init_timer(&card->led_timer);
