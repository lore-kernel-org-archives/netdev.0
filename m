From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Fri, 23 May 2008 13:57:19 +0800
Message-ID: <48365CBF.4080502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54556 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1764577AbYEWF7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 01:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. dma should be freed when dma2 request fail.
2. dma2 should be freed too when device close.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/irda/via-ircc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 58e1287..04ad357 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1546,6 +1546,7 @@ static int via_ircc_net_open(struct net_device *dev)
 			IRDA_WARNING("%s, unable to allocate dma2=%d\n",
 				     driver_name, self->io.dma2);
 			free_irq(self->io.irq, self);
+			free_dma(self->io.dma);
 			return -EAGAIN;
 		}
 	}
@@ -1606,6 +1607,8 @@ static int via_ircc_net_close(struct net_device *dev)
 	EnAllInt(iobase, OFF);
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
+	if (self->io.dma2 != self->io.dma)
+		free_dma(self->io.dma2);
 
 	return 0;
 }
-- 
1.5.4.rc3

