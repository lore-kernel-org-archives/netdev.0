From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix the list rx_done may be used without initialization
Date: Tue, 14 Mar 2017 14:15:20 +0800
Message-ID: <1394712342-15778-252-Taiwan-albertk@realtek.com>
References: <20170313215714.n2p6j4nxtpxbheaj@dell5510>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>, <petr.vorel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170313215714.n2p6j4nxtpxbheaj@dell5510>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The list rx_done would be initialized when the linking on occurs.
Therefore, if a napi is scheduled without any linking on before,
the following kernel panic would happen.

	BUG: unable to handle kernel NULL pointer dereference at 000000000000008
	IP: [<ffffffffc085efde>] r8152_poll+0xe1e/0x1210 [r8152]
	PGD 0
	Oops: 0002 [#1] SMP

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 986243c..bb3eedd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1362,6 +1362,7 @@ static int alloc_all_mem(struct r8152 *tp)
 	spin_lock_init(&tp->rx_lock);
 	spin_lock_init(&tp->tx_lock);
 	INIT_LIST_HEAD(&tp->tx_free);
+	INIT_LIST_HEAD(&tp->rx_done);
 	skb_queue_head_init(&tp->tx_queue);
 	skb_queue_head_init(&tp->rx_queue);
 
-- 
2.7.4
