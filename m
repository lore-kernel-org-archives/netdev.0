From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 7/7] [NETDEV]: myri10ge Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 13:01:27 +0900
Message-ID: <002801c83c73$af10f990$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <help@myri.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755679AbXLLEB5@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETDEV]: myri10ge Fix possible causing oops of net_rx_action

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 8def865..57311ed 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1242,6 +1242,8 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget || !netif_running(netdev)) {
 		netif_rx_complete(netdev, napi);
 		put_be32(htonl(3), mgp->irq_claim);
+		if (unlikely(work_done == napi->weight))
+			return work_done - 1;
 	}
 	return work_done;
 }
---

