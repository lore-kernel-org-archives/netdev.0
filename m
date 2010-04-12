From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: clarify promiscuous cmd with a comment
Date: Mon, 12 Apr 2010 14:05:27 +0530
Message-ID: <20100412083527.GA27023@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pugs@cisco.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:61222 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753105Ab0DLIgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 04:36:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The promiscous cmd config code gives an impression that
setting a port to promisc mode will unset the other port.
This is not the case and is clarified with a comment.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index da87930..e79bf8b 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1113,6 +1113,10 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
 		OPCODE_ETH_PROMISCUOUS, sizeof(*req));
 
+	/* In FW versions X.102.149/X.101.487 and later,
+	 * the port setting associated only with the
+	 * issuing pci function will take effect
+	 */
 	if (port_num)
 		req->port1_promiscuous = en;
 	else
-- 
1.6.3.3

