From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] net-2.6.24: old ax25 driver fix
Date: Mon, 1 Oct 2007 11:24:17 -0700
Message-ID: <20071001112417.10bf522d@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundatio.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34123 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbXJASXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 14:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent change in hard header broke build of these old drivers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/hamradio/dmascc.c |    2 +-
 drivers/net/hamradio/scc.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index b529e23..bc02e46 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -581,7 +581,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		dev->do_ioctl = scc_ioctl;
 		dev->hard_start_xmit = scc_send_packet;
 		dev->get_stats = scc_get_stats;
-		dev->header_ops = &ax25_hard_header_ops
+		dev->header_ops = &ax25_header_ops;
 		dev->set_mac_address = scc_set_mac_address;
 	}
 	if (register_netdev(info->dev[0])) {
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 56cc523..353d13e 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1551,7 +1551,7 @@ static void scc_net_setup(struct net_device *dev)
 	dev->stop	     = scc_net_close;
 
 	dev->hard_start_xmit = scc_net_tx;
-	dev->header_ops      = &ax25_hard_header_ops;
+	dev->header_ops      = &ax25_header_ops;
 
 	dev->set_mac_address = scc_net_set_mac_address;
 	dev->get_stats       = scc_net_get_stats;
-- 
1.5.2.5

