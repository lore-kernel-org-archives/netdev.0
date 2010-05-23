From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH 2/2] enic: Use random mac addr when associating
	port-profile
Date: Sat, 22 May 2010 20:29:58 -0700
Message-ID: <20100523032957.20200.59700.stgit@savbu-pc100.cisco.com>
References: <20100523032952.20200.30148.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:4913 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab0EWD36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 23:29:58 -0400
In-Reply-To: <20100523032952.20200.30148.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Use random mac addr for interface when associating port-profile to 
dynamic enic device, in the case no mac addr was previous assigned.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 7e97323..6586b5c 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1132,6 +1132,14 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 	switch (request) {
 	case PORT_REQUEST_ASSOCIATE:
 
+		/* If the interface mac addr hasn't been assigned,
+		 * assign a random mac addr before setting port-
+		 * profile.
+		 */
+
+		if (is_zero_ether_addr(netdev->dev_addr))
+			random_ether_addr(netdev->dev_addr);
+
 		if (port[IFLA_PORT_PROFILE])
 			name = nla_data(port[IFLA_PORT_PROFILE]);
 

