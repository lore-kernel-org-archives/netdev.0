From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH] be2net: Fix a bug in preparation of mcc wrb which was
	causing flash operation to fail
Date: Mon, 5 Oct 2009 14:36:07 +0530
Message-ID: <20091005090555.GA12287@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.211.173]:40850 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757429AbZJEJHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:07:11 -0400
Received: by ywh3 with SMTP id 3so2755658ywh.22
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 02:06:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug that got introduced in commit 76998bc7.
During preparation of mcc wrb, req was being wrongly overwritten
and the flash operation was failing.
This patch is against the net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 79d35d1..89876ad 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1129,7 +1129,6 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
-	req = embedded_payload(wrb);
 	sge = nonembedded_sgl(wrb);
 
 	be_wrb_hdr_prepare(wrb, cmd->size, false, 1);
-- 
1.6.0.4

