From: Alan Ott <alan@signal11.us>
Subject: [PATCH beta 1] 3/3] mrf24j40: Use level-triggered interrupts
Date: Tue, 21 May 2013 22:01:20 -0400
Message-ID: <1369188080-8904-4-git-send-email-alan@signal11.us>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com>
 <1369188080-8904-1-git-send-email-alan@signal11.us>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>
To: david@hauweele.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369188080-8904-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mrf24j40 generates level interrupts. There are rare cases where it
appears that the interrupt line never gets de-asserted between interrupts,
causing interrupts to be lost, and causing a hung device from the driver's
perspective.  Switching the driver to interpret these interrupts as
level-triggered fixes this issue.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 drivers/net/ieee802154/mrf24j40.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index a55ab8d..d59dbff 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -685,7 +685,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	ret = request_threaded_irq(spi->irq,
 				   NULL,
 				   mrf24j40_isr,
-				   IRQF_TRIGGER_FALLING|IRQF_ONESHOT,
+				   IRQF_TRIGGER_LOW|IRQF_ONESHOT,
 				   dev_name(&spi->dev),
 				   devrec);
 
-- 
1.7.11.2
