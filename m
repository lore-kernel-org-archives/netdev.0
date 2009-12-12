From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] be2net: fix error in rx completion processing.
Date: Sat, 12 Dec 2009 07:08:49 +0530
Message-ID: <20091212013847.GA10922@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:61781 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762665AbZLLBih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 20:38:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are certain skews of the NIC which have multiple bits set in adapter->cap.
Use & instead of == to process rx completions.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 957a0f7..8959bc7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -759,7 +759,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	/* vlanf could be wrongly set in some cards.
 	 * ignore if vtm is not set */
-	if ((adapter->cap == 0x400) && !vtm)
+	if ((adapter->cap & 0x400) && !vtm)
 		vlanf = 0;
 
 	skb = netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
@@ -816,7 +816,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 
 	/* vlanf could be wrongly set in some cards.
 	 * ignore if vtm is not set */
-	if ((adapter->cap == 0x400) && !vtm)
+	if ((adapter->cap & 0x400) && !vtm)
 		vlanf = 0;
 
 	skb = napi_get_frags(&eq_obj->napi);
-- 
1.6.3.3

