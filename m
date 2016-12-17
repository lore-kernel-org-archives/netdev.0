From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] bna: use designated initializers
Date: Fri, 16 Dec 2016 17:00:54 -0800
Message-ID: <20161217010054.GA140360@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rasesh Mody <rasesh.mody@cavium.com>,
        Sudarsana Kalluru <sudarsana.kalluru@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35907 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762204AbcLQBA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 20:00:56 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so37553011pgc.3
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 17:00:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/brocade/bna/bna_enet.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 4e5c3874a50f..bba81735ce87 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1676,10 +1676,10 @@ bna_cb_ioceth_reset(void *arg)
 }
 
 static struct bfa_ioc_cbfn bna_ioceth_cbfn = {
-	bna_cb_ioceth_enable,
-	bna_cb_ioceth_disable,
-	bna_cb_ioceth_hbfail,
-	bna_cb_ioceth_reset
+	.enable_cbfn = bna_cb_ioceth_enable,
+	.disable_cbfn = bna_cb_ioceth_disable,
+	.hbfail_cbfn = bna_cb_ioceth_hbfail,
+	.reset_cbfn = bna_cb_ioceth_reset
 };
 
 static void bna_attr_init(struct bna_ioceth *ioceth)
-- 
2.7.4


-- 
Kees Cook
Nexus Security
