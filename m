From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 2/2][RESEND] ehea: fix last_rx update
Date: Fri, 7 Sep 2007 12:30:24 +0200
Message-ID: <200709071230.25008.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:58058 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965091AbXIGKad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 06:30:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update last_rx in registered device struct instead of
in the dummy device.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 1e9fd6f..717b129 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -471,7 +471,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 			else
 				netif_receive_skb(skb);
 
-			dev->last_rx = jiffies;
+			port->netdev->last_rx = jiffies;
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
-- 
1.5.2

