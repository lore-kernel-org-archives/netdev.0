From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net] fjes: fix off-by-one error at fjes_hw_update_zone_task()
Date: Thu, 17 Sep 2015 23:21:21 +0900
Message-ID: <1442499681-16712-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: dan.carpenter@oracle.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:52379 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbIQFSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 01:18:44 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 5C8C5AC010E
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 14:18:41 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter reported off-by-one error of fjes at
http://www.mail-archive.com/netdev@vger.kernel.org/msg77520.html

Actually this is a bug.
ep_shm_info[epidx].{es_status, zone} should be update
inside for loop.

This patch fixes this bug.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index b5f4a78..2d3848c 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -1011,11 +1011,11 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 					set_bit(epidx, &irq_bit);
 				break;
 			}
-		}
-
-		hw->ep_shm_info[epidx].es_status = info[epidx].es_status;
-		hw->ep_shm_info[epidx].zone = info[epidx].zone;
 
+			hw->ep_shm_info[epidx].es_status =
+				info[epidx].es_status;
+			hw->ep_shm_info[epidx].zone = info[epidx].zone;
+		}
 		break;
 	}
 
-- 
1.8.3.1
