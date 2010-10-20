From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 2/5] enic: Make firmware cognizant of the user
	set mac address
Date: Wed, 20 Oct 2010 13:17:04 -0700
Message-ID: <20101020201704.26870.68966.stgit@savbu-pc100.cisco.com>
References: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:10398 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab0JTURE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:17:04 -0400
In-Reply-To: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Let the firmware know about the mac address set by the user using ndo_set_mac_address

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index dcfc541..622106d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -974,8 +974,19 @@ static int enic_set_mac_address_dynamic(struct net_device *netdev, void *p)
 static int enic_set_mac_address(struct net_device *netdev, void *p)
 {
 	struct sockaddr *saddr = p;
+	char *addr = saddr->sa_data;
+	struct enic *enic = netdev_priv(netdev);
+	int err;
+
+	err = enic_dev_del_station_addr(enic);
+	if (err)
+		return err;
+
+	err = enic_set_mac_addr(netdev, addr);
+	if (err)
+		return err;
 
-	return enic_set_mac_addr(netdev, (char *)saddr->sa_data);
+	return enic_dev_add_station_addr(enic);
 }
 
 static int enic_dev_packet_filter(struct enic *enic, int directed,

