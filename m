From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 1/2 net-next] caif_usb: remove redundant memory message
Date: Tue, 14 Oct 2014 19:00:55 +0200
Message-ID: <1413306055-8281-1-git-send-email-fabf@skynet.be>
Cc: Joe Perches <joe@perches.com>, Fabian Frederick <fabf@skynet.be>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let MM subsystem display out of memory messages.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: add second patch with memset fix

 net/caif/caif_usb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index ba02db0..0e487b0 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -87,10 +87,9 @@ static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
 {
 	struct cfusbl *this = kmalloc(sizeof(struct cfusbl), GFP_ATOMIC);
 
-	if (!this) {
-		pr_warn("Out of memory\n");
+	if (!this)
 		return NULL;
-	}
+
 	caif_assert(offsetof(struct cfusbl, layer) == 0);
 
 	memset(this, 0, sizeof(struct cflayer));
-- 
1.9.3
