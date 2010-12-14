From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 06/12] cxgb4: allocate more space for MSI-X interrupt names
Date: Tue, 14 Dec 2010 12:18:10 -0800
Message-ID: <1292357896-14339-7-git-send-email-dm@chelsio.com>
References: <1292357896-14339-1-git-send-email-dm@chelsio.com>
 <1292357896-14339-2-git-send-email-dm@chelsio.com>
 <1292357896-14339-3-git-send-email-dm@chelsio.com>
 <1292357896-14339-4-git-send-email-dm@chelsio.com>
 <1292357896-14339-5-git-send-email-dm@chelsio.com>
 <1292357896-14339-6-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17693 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759822Ab0LNU0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 15:26:39 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBEKQcRG031245
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:26:38 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBEKIHqV014456
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:18:17 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBEKIHBQ014455
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 12:18:17 -0800
In-Reply-To: <1292357896-14339-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently MSI-X names for netdevs with long names are truncated in
/proc/interrupts due to insufficient space.  Use IFNAMSIZ to size the
needed space.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 3d4253d..f3d9f64 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -497,7 +497,7 @@ struct adapter {
 
 	struct {
 		unsigned short vec;
-		char desc[14];
+		char desc[IFNAMSIZ + 10];
 	} msix_info[MAX_INGQ + 1];
 
 	struct sge sge;
-- 
1.5.4

