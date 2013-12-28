From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 20/20] net: caif: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:18:56 +0800
Message-ID: <52BE6D50.9000308@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/caif/cfrfml.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 61d7617..c680414 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -79,7 +79,7 @@ static struct cfpkt *rfm_append(struct cfrfml *rfml, char *seghead,
 		return NULL;
 
 	/* Verify correct header */
-	if (memcmp(seghead, rfml->seghead, 6) != 0)
+	if (!ether_addr_equal(seghead, rfml->seghead))
 		return NULL;
 
 	tmppkt = cfpkt_append(rfml->incomplete_frm, pkt,
-- 
1.8.0
