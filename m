From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] Fix broken ip= parsing
Date: Sat, 29 Dec 2007 18:08:49 +0100 (CET)
Message-ID: <20071229170849.C2E68C2EEE@solo.franken.de>
Cc: horms@verge.net.au, davem@davemloft.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:47497 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbXL2RJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2007 12:09:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a6c05c3d064dbb83be88cba3189beb5db9d2dfc3 breaks ip= parsing
completly, because ic_enable is never set. The patch below puts
back the way ic_enable was set before.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 net/ipv4/ipconfig.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 420f56a..4266528 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1440,6 +1440,7 @@ static int __init ip_auto_config_setup(char *addrs)
 	int num = 0;
 
 	ic_set_manually = 1;
+	ic_enable = *addrs;
 
 	if (ic_proto_name(addrs))
 		return 1;
