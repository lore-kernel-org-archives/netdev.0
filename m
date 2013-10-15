From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 11/18] net: hamradio: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:07 +0800
Message-ID: <1381837514-50660-12-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_XXX_ratelimited() is called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/hamradio/6pack.c    | 3 +--
 drivers/net/hamradio/bpqether.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 1450e33..9e97eba 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -237,8 +237,7 @@ static void sp_encaps(struct sixpack *sp, unsigned char *icp, int len)
 out_drop:
 	sp->dev->stats.tx_dropped++;
 	netif_start_queue(sp->dev);
-	if (net_ratelimit())
-		printk(KERN_DEBUG "%s: %s - dropped.\n", sp->dev->name, msg);
+	net_dbg_ratelimited("%s: %s - dropped.\n", sp->dev->name, msg);
 }
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index f91bf0d..1522b4a 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -269,8 +269,7 @@ static netdev_tx_t bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * space for the BPQ headers.
 	 */
 	if (skb_cow(skb, AX25_BPQ_HEADER_LEN)) {
-		if (net_ratelimit())
-			pr_err("bpqether: out of memory\n");
+		net_err_ratelimited("pqether: out of memory\n");
 		kfree_skb(skb);
 
 		return NETDEV_TX_OK;
-- 
1.8.2.1
