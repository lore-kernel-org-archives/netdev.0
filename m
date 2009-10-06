From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net/hamradio: fix test in receive()
Date: Tue, 06 Oct 2009 13:20:08 +0200
Message-ID: <4ACB27E8.8060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:40848 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbZJFLME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 07:12:04 -0400
Received: by ewy17 with SMTP id 17so3760928ewy.39
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 04:11:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The negation makes it a bool before the comparison and hence it
will never evaluate to true.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Was this intended?

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 7bcaf7c..ee06a13 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -596,7 +596,8 @@ static int receive(struct net_device *dev, int cnt)
 						state = 0;
 
 					/* not flag received */
-					else if (!(bitstream & (0x1fe << j)) != (0x0fc << j)) {
+					else if ((bitstream & (0x1fe << j)) !=
+							(0x0fc << j)) {
 						if (state)
 							do_rxpacket(dev);
 						bc->hdlcrx.bufcnt = 0;
