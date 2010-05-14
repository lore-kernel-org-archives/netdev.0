From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] e1000: fix WARN_ON with mac-vlan
Date: Thu, 13 May 2010 18:25:33 -0700
Message-ID: <20100514012425.30457.23799.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jiri Pirko <jpirko@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:48758
	"EHLO qmta01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753356Ab0ENBZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:25:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

When adding more than 14 mac-vlan adapters on e1000 the driver
would fire a WARN_ON when adding the 15th.  The WARN_ON in this
case is completely un-necessary, as the code below the WARN_ON is
directly handling the value the WARN_ON triggered on.

CC: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4dd2c23..e9b19f7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2161,8 +2161,6 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			e1000_rar_set(hw, ha->addr, i++);
 		}
 
-	WARN_ON(i == rar_entries);
-
 	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == rar_entries) {
 			/* load any remaining addresses into the hash table */

