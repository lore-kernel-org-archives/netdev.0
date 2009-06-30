From: Frank Seidel <Frank.Seidel@sphairon.com>
Subject: [PATCH] linux-2.4: br2684: fix double freeing skb
Date: Tue, 30 Jun 2009 10:15:56 +0200
Message-ID: <4A49C9BC.6050908@sphairon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Seidel, Frank" <Frank.Seidel@sphairon.com>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Author: Peter Sieber <siep@sphairon.com>

Fix double freeing skb, see net/core/dev.c
dev_queue_xmit().

Signed-off-by: Peter Sieber <siep@sphairon.com>
Signed-off-by: Frank Seidel <Frank.Seidel@sphairon.com>
---
 net/atm/br2684.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -221,7 +221,7 @@ static int br2684_start_xmit(struct sk_b
 		/* netif_stop_queue(dev); */
 		dev_kfree_skb(skb);
 		read_unlock(&devs_lock);
-		return -EUNATCH;
+		return 0;
 	}
 	if (!br2684_xmit_vcc(skb, brdev, brvcc)) {
 		/*
