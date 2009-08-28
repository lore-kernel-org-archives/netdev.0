From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] From: Petri Gynther <pgynther@google.com>
Date: Fri, 28 Aug 2009 14:57:52 -0700
Message-ID: <1251496672-14498-5-git-send-email-fubar@us.ibm.com>
References: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-2-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-3-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-4-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:37321 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbZH1V55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 17:57:57 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SLsA1D024341
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:54:10 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SLvt0T191396
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SLvsKG011669
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:55 -0600
In-Reply-To: <1251496672-14498-4-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>

bonding: Have bond_check_dev_link examine netif_running

	Some network devices do not call netif_carrier_off when they
are set administratively down.  Have the bonding link check function
also inspect the netif_running state.  Ignore netif_running if the
bond_check_dev_link function is called with "reporting" set, as in that
case it's inspecting the capabilities of the non-netif_carrier device
driver.

Signed-off-by: Petri Gynther <pgynther@google.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6b9f15b..7c0e0bd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -695,6 +695,9 @@ static int bond_check_dev_link(struct bonding *bond,
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 
+	if (!reporting && !netif_running(slave_dev))
+		return 0;
+
 	if (bond->params.use_carrier)
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
 
-- 
1.6.0.2

