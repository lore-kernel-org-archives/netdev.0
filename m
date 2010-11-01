From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-2.6 2/3] cxgb4: remove call to stop TX queues at load time.
Date: Mon, 01 Nov 2010 13:59:46 -0700
Message-ID: <20101101205946.27716.59639.stgit@speedy5.asicdesigners.com>
References: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove racy queue stopping after device registration.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

---

 drivers/net/cxgb4/cxgb4_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index f17703f..f50bc98 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3736,7 +3736,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 			__set_bit(i, &adapter->registered_device_map);
 			adapter->chan_map[adap2pinfo(adapter, i)->tx_chan] = i;
-			netif_tx_stop_all_queues(adapter->port[i]);
 		}
 	}
 	if (!adapter->registered_device_map) {
