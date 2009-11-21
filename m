From: Amit Kumar Salecha <amit@netxen.com>
Subject: [net-2.6 PATCH 1/3] netxen: fix memory initialization
Date: Fri, 20 Nov 2009 17:09:32 -0800
Message-ID: <1258765774-27068-2-git-send-email-amit@netxen.com>
References: <1258765774-27068-1-git-send-email-amit@netxen.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27775 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753336AbZKUBJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 20:09:28 -0500
In-Reply-To: <1258765774-27068-1-git-send-email-amit@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid resetting memory during initialization, skip this memory
block during driver probe.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index e40b914..8a09043 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -544,6 +544,8 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				continue;
 			if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
 				continue;
+			if ((off & 0x0ff00000) == NETXEN_CRB_DDR_NET)
+				continue;
 			if (off == (NETXEN_CRB_PEG_NET_1 + 0x18))
 				buf[i].data = 0x1020;
 			/* skip the function enable register */
-- 
1.6.0.2

