From: Doug Kehn <rdkehn@yahoo.com>
Subject: [PATCH v2] ksz884x: fix mtu for VLAN
Date: Wed, 11 Jan 2012 17:12:43 -0600
Message-ID: <20120111231243.GA14836@dkehn-Latitude-D830>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm23-vm0.bullet.mail.ne1.yahoo.com ([98.138.91.57]:45692 "HELO
	nm23-vm0.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751005Ab2AKXSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 18:18:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet header does not account for the addition of a VLAN header.
Full size Ethernet frames containing VLAN header are not processed
because the frame is larger than the resulting hw mtu.

Signed-off-by: Doug Kehn <rdkehn@yahoo.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 6ed09a8..e52cd31 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -746,7 +746,7 @@
 #define MAC_ADDR_ORDER(i)		(ETH_ALEN - 1 - (i))
 
 #define MAX_ETHERNET_BODY_SIZE		1500
-#define ETHERNET_HEADER_SIZE		14
+#define ETHERNET_HEADER_SIZE		(14 + VLAN_HLEN)
 
 #define MAX_ETHERNET_PACKET_SIZE	\
 	(MAX_ETHERNET_BODY_SIZE + ETHERNET_HEADER_SIZE)
-- 
1.7.4.1
