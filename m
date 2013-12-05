From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/16] e1000e: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:54:08 +0000
Message-ID: <1386287648.1516.137.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6688 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756086Ab3LEXyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:54:11 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index f02816575369..03e6af736de4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5790,7 +5790,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
  * specified. Matching the kind of event packet is not supported, with the
  * exception of "all V2 events regardless of level 2 or 4".
  **/
-static int e1000e_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
+static int e1000e_hwtstamp_set(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct hwtstamp_config config;
@@ -5825,6 +5825,14 @@ static int e1000e_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 			    sizeof(config)) ? -EFAULT : 0;
 }
 
+static int e1000e_hwtstamp_get(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	return copy_to_user(ifr->ifr_data, &adapter->hwtstamp_config,
+			    sizeof(adapter->hwtstamp_config)) ? -EFAULT : 0;
+}
+
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -5833,7 +5841,9 @@ static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCSMIIREG:
 		return e1000_mii_ioctl(netdev, ifr, cmd);
 	case SIOCSHWTSTAMP:
-		return e1000e_hwtstamp_ioctl(netdev, ifr);
+		return e1000e_hwtstamp_set(netdev, ifr);
+	case SIOCGHWTSTAMP:
+		return e1000e_hwtstamp_get(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
