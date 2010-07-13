From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] eth16i: fix memory leak
Date: Tue, 13 Jul 2010 15:22:18 +0400
Message-ID: <1279020138-9398-1-git-send-email-segooon@gmail.com>
Cc: Mika Kuoppala <miku@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54679 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab0GMLWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 07:22:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free allocated netdev if no probe is expected.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/eth16i.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 874973f..2bdd394 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1442,8 +1442,10 @@ int __init init_module(void)
 		dev->if_port = eth16i_parse_mediatype(mediatype[this_dev]);
 
 		if(io[this_dev] == 0) {
-			if(this_dev != 0) /* Only autoprobe 1st one */
+			if (this_dev != 0) { /* Only autoprobe 1st one */
+				free_netdev(def);
 				break;
+			}
 
 			printk(KERN_NOTICE "eth16i.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-- 
1.7.0.4

