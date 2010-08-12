From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/2] s2io: remove unused code
Date: Thu, 12 Aug 2010 10:03:03 -0500
Message-ID: <1281625384-26927-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org, Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:53355 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab0HLPCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 11:02:31 -0400
Received: by pxi10 with SMTP id 10so465376pxi.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 08:02:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usr_addrs is never referenced outside the initial struct population
during open, thus making it unnecessary.  Remove it, the code that
references it, and the struct that it is the only user of.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |    2 --
 drivers/net/s2io.h |    8 --------
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 18bc5b7..0124f12 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5124,8 +5124,6 @@ static void s2io_set_multicast(struct net_device *dev)
 		/* Create the new Rx filter list and update the same in H/W. */
 		i = 0;
 		netdev_for_each_mc_addr(ha, dev) {
-			memcpy(sp->usr_addrs[i].addr, ha->addr,
-			       ETH_ALEN);
 			mac_addr = 0;
 			for (j = 0; j < ETH_ALEN; j++) {
 				mac_addr |= ha->addr[j];
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 0af0335..924f618 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -816,12 +816,6 @@ struct mac_info {
 	struct stat_block *stats_info;	/* Logical address of the stat block */
 };
 
-/* structure representing the user defined MAC addresses */
-struct usr_addr {
-	char addr[ETH_ALEN];
-	int usage_cnt;
-};
-
 /* Default Tunable parameters of the NIC. */
 #define DEFAULT_FIFO_0_LEN 4096
 #define DEFAULT_FIFO_1_7_LEN 512
@@ -894,9 +888,7 @@ struct s2io_nic {
 #define ALL_MULTI   2
 
 #define MAX_ADDRS_SUPPORTED 64
-	u16 usr_addr_count;
 	u16 mc_addr_count;
-	struct usr_addr usr_addrs[256];
 
 	u16 m_cast_flg;
 	u16 all_multi_pos;
-- 
1.7.0.4

