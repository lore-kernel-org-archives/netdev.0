From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4vf: Fix off-by-one error checking for the end of the mailbox delay array
Date: Tue, 20 Jul 2010 08:58:52 -0700
Message-ID: <201007200858.52364.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32292 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab0GTQHM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 12:07:12 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6KG7CLg017820
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 09:07:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 1d32860335fad8c67e23254aec7c30750276f2b4 Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 19 Jul 2010 17:51:46 -0700
Subject: [PATCH net-next 1/3] cxgb4vf: Fix off-by-one error checking for the end of the mailbox delay array

Fix off-by-one error in checking for the end of the mailbox response delay
array.  We ended up walking off the end and, if we were unlucky, we'd end up
pulling in a 0 and never terminate the mailbox response delay loop ...

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/t4vf_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index 1ef2528..ea1c123 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -163,7 +163,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	for (i = 0; i < 500; i += ms) {
 		if (sleep_ok) {
 			ms = delay[delay_idx];
-			if (delay_idx < ARRAY_SIZE(delay))
+			if (delay_idx < ARRAY_SIZE(delay) - 1)
 				delay_idx++;
 			msleep(ms);
 		} else
-- 
1.7.0.4

