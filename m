From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] ep93xx_eth stopps receiving packets
Date: Mon, 03 May 2010 13:42:44 +0200
Message-ID: <20100503134244.42345pyaszhd9f8c@limpopo.deheime.ch>
References: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch>
	<20100502104350.GS4586@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.deheime.ch ([62.12.167.34]:34138 "EHLO limpopo.deheime.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757824Ab0ECLmq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 07:42:46 -0400
In-Reply-To: <20100502104350.GS4586@mail.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receiving small packet(s) in a fast pace leads to not receiving any
packets at all after some time.

After ethernet packet(s) arrived the receive descriptor is incremented
by the number of frames processed. If another packet arrives while
processing, this is processed in another call of ep93xx_rx. This
second call leads that too many receive descriptors getting released.

This fix increments, even in these case, the right number of processed
receive descriptors.

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
  drivers/net/arm/ep93xx_eth.c |   10 +++++-----
  1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 6995169..cd6cd3e 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -311,11 +311,6 @@ err:
  		processed++;
  	}

-	if (processed) {
-		wrw(ep, REG_RXDENQ, processed);
-		wrw(ep, REG_RXSTSENQ, processed);
-	}
-
  	return processed;
  }

@@ -350,6 +345,11 @@ poll_some_more:
  			goto poll_some_more;
  	}

+	if (rx) {
+                wrw(ep, REG_RXDENQ, rx);
+                wrw(ep, REG_RXSTSENQ, rx);
+        }
+
  	return rx;
  }

-- 
1.7.0


----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

