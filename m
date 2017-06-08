From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the wireless-drivers-next
 tree
Date: Thu, 8 Jun 2017 12:27:59 +1000
Message-ID: <20170608122759.7ffda0c3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>,
        Dmitrii Lebed <dlebed@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Bindu Therthala <btherthala@quantenna.com>,
        Huizhao Wang <hwang@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>
To: Kalle Valo <kvalo@codeaurora.org>,
        Wireless <linux-wireless@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the wireless-drivers-next tree, today's linux-next build
(x86_64 allmodconfig) failed like this:

drivers/net/wireless/quantenna/qtnfmac/core.c: In function 'qtnf_core_net_attach':
drivers/net/wireless/quantenna/qtnfmac/core.c:319:5: error: 'struct net_device' has no member named 'destructor'
  dev->destructor = free_netdev;
     ^

Caused by commit

  98f44cb0655c ("qtnfmac: introduce new FullMAC driver for Quantenna chipsets")

interacting with commit

  cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")

from the net tree.

I applied this merge fix patch for today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Jun 2017 12:24:08 +1000
Subject: [PATCH] qtnfmac: fix up for "net: Fix inconsistent teardown and
 release of private netdev state."

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/quantenna/qtnfmac/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/quantenna/qtnfmac/core.c b/drivers/net/wireless/quantenna/qtnfmac/core.c
index c5ac252464f4..f053532c0e87 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/core.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/core.c
@@ -316,7 +316,7 @@ int qtnf_core_net_attach(struct qtnf_wmac *mac, struct qtnf_vif *vif,
 	vif->netdev = dev;
 
 	dev->netdev_ops = &qtnf_netdev_ops;
-	dev->destructor = free_netdev;
+	dev->needs_free_netdev = true;
 	dev_net_set(dev, wiphy_net(wiphy));
 	dev->ieee80211_ptr = &vif->wdev;
 	dev->ieee80211_ptr->iftype = iftype;
-- 
2.11.0

-- 
Cheers,
Stephen Rothwell
