From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-2.6 PATCH 1/3] be2net: Bug fix to avoid soft lockup in
 loopback test.
Date: Wed, 23 Dec 2009 20:10:36 +0530
Message-ID: <20091223144026.GA23383@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:11196 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750986AbZLWOkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:40:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change ensures that loopback test command gives up after 4 seconds when 
the hardware is not responsive. This could happen if the ports are connected 
properly in loopback mode.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 1b68bd9..a27fdb3 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1501,6 +1501,7 @@ int be_cmd_loopback_test(struct be_adapt
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_LOWLEVEL,
 			OPCODE_LOWLEVEL_LOOPBACK_TEST, sizeof(*req));
+	req->hdr.timeout = 4;
 
 	req->pattern = cpu_to_le64(pattern);
 	req->src_port = cpu_to_le32(port_num);
-- 
1.4.0

