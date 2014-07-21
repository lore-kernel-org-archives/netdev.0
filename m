From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH for stable 3.15 4/4 v2] xen-netback: Fix pointer incrementation to avoid incorrect logging
Date: Mon, 21 Jul 2014 11:41:02 +0100
Message-ID: <1405939262-7944-4-git-send-email-zoltan.kiss@citrix.com>
References: <1405939262-7944-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405939262-7944-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to this pointer is increased prematurely, the error log contains rubbish.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7a36ecf..36fb4ff 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1020,7 +1020,6 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 
 	/* Check status of header. */
 	err = (*gopp_copy)->status;
-	(*gopp_copy)++;
 	if (unlikely(err)) {
 		if (net_ratelimit())
 			netdev_dbg(vif->dev,
@@ -1030,6 +1029,7 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 				   (*gopp_copy)->source.u.ref);
 		xenvif_idx_release(vif, first_pending_idx, XEN_NETIF_RSP_ERROR);
 	}
+	(*gopp_copy)++;
 
 check_frags:
 	for (i = 0; i < nr_frags; i++, gop_map++) {
