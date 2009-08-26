From: Petri Gynther <pgynther@google.com>
Subject: [PATCH] bonding: bond_check_dev_link() needs to check for netif_running()
Date: Wed, 26 Aug 2009 13:35:00 -0700 (PDT)
Message-ID: <20090826203500.9E54B254211@localhost>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:34812 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbZHZUfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 16:35:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_check_dev_link() needs to check for netif_running() before checking
the link status of a slave. This needs to be done because some interfaces
keep reporting netif_carrier_ok() == TRUE even after "ifconfig down".

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/bonding/bond_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index aa1be1f..0835cbe 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -695,6 +695,9 @@ static int bond_check_dev_link(struct bonding *bond,
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 
+	if (!netif_running(slave_dev))
+		return 0;
+
 	if (bond->params.use_carrier)
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
 
-- 
1.5.4.3

