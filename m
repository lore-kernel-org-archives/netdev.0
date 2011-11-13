From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Net, libertas: Resolve memory leak in
 if_spi_host_to_card()
Date: Sun, 13 Nov 2011 22:14:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1111132211580.3368@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrey Yurovsky <andrey@cozybit.com>,
	Colin McCabe <colin@cozybit.com>,
	Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we hit the default case in the switch in if_spi_host_to_card() we'll leak
the memory we allocated for 'packet'. This patch resolves the leak by freeing
the allocated memory in that case.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/libertas/if_spi.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

 Compile tested only due to lack of hardware.

diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index 11b69b3..728baa4 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -995,6 +995,7 @@ static int if_spi_host_to_card(struct lbs_private *priv,
 		spin_unlock_irqrestore(&card->buffer_lock, flags);
 		break;
 	default:
+		kfree(packet);
 		netdev_err(priv->dev, "can't transfer buffer of type %d\n",
 			   type);
 		err = -EINVAL;
-- 
1.7.7.3


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
