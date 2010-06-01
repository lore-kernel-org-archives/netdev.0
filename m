From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: convert hdr.timeout in be_cmd_loopback_test() to
 le32
Date: Tue, 1 Jun 2010 12:31:22 +0530
Message-ID: <20100601070122.GA2608@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:51545 "EHLO
	ubuntu.ubuntu-domain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127Ab0FAHBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:01:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code fails on ppc as hdr.timeout is not being converted
to le32.

Pls apply to net-2.6.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 9e305d7..b9ad799 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1593,7 +1593,7 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
 			OPCODE_LOWLEVEL_LOOPBACK_TEST, sizeof(*req));
-	req->hdr.timeout = 4;
+	req->hdr.timeout = cpu_to_le32(4);
 
 	req->pattern = cpu_to_le64(pattern);
 	req->src_port = cpu_to_le32(port_num);
-- 
1.6.5.2

