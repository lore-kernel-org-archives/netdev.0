From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 10/10] net: thunderx: use GFP_KERNEL in thread context
Date: Tue, 2 Jun 2015 11:00:27 -0700
Message-ID: <1433268028-23992-11-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0058.outbound.protection.outlook.com ([207.46.100.58]:21760
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932162AbbFBSBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 14:01:31 -0400
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GFP_KERNEL should be used in the thread context

Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 2ed7d1b..d69d228 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -356,7 +356,7 @@ static int nicvf_init_snd_queue(struct nicvf *nic,
 		return err;
 
 	sq->desc = sq->dmem.base;
-	sq->skbuff = kcalloc(q_len, sizeof(u64), GFP_ATOMIC);
+	sq->skbuff = kcalloc(q_len, sizeof(u64), GFP_KERNEL);
 	if (!sq->skbuff)
 		return -ENOMEM;
 	sq->head = 0;
-- 
2.4.1
