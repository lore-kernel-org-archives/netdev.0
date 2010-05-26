From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/3] xen: netfront: explicitly generate arp_notify event after migration.
Date: Wed, 26 May 2010 11:09:43 +0100
Message-ID: <1274868583-26291-3-git-send-email-ian.campbell@citrix.com>
References: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>,
	xen-devel@lists.xensource.com, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45651 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933936Ab0EZKI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:08:57 -0400
In-Reply-To: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use newly introduced netif_notify_peers() method to ensure a gratuitous ARP is
generated after a migration.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xensource.com
Cc: stable@kernel.org
---
 drivers/net/xen-netfront.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d504e2b..b50fedc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1621,6 +1621,7 @@ static void backend_changed(struct xenbus_device *dev,
 		if (xennet_connect(netdev) != 0)
 			break;
 		xenbus_switch_state(dev, XenbusStateConnected);
+		netif_notify_peers(netdev);
 		break;
 
 	case XenbusStateClosing:
-- 
1.5.6.5

