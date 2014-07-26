From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.15 078/109] xen-netback: Fix pointer incrementation to avoid incorrect logging
Date: Sat, 26 Jul 2014 12:02:40 -0700
Message-ID: <20140726190226.217751248@linuxfoundation.org>
References: <20140726190223.834037485@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Zoltan Kiss <zoltan.kiss@citrix.com>,
	Armin Zentai <armin.zentai@ezit.hu>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140726190223.834037485@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.15-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Zoltan Kiss <zoltan.kiss@citrix.com>

[ Upstream commit d8cfbfc4660054150ca1b7c501a8edc0771022f9 ]

Due to this pointer is increased prematurely, the error log contains rubbish.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1022,7 +1022,6 @@ static int xenvif_tx_check_gop(struct xe
 
 	/* Check status of header. */
 	err = (*gopp_copy)->status;
-	(*gopp_copy)++;
 	if (unlikely(err)) {
 		if (net_ratelimit())
 			netdev_dbg(vif->dev,
@@ -1035,6 +1034,7 @@ static int xenvif_tx_check_gop(struct xe
 			xenvif_idx_release(vif, pending_idx,
 					   XEN_NETIF_RSP_ERROR);
 	}
+	(*gopp_copy)++;
 
 check_frags:
 	for (i = 0; i < nr_frags; i++, gop_map++) {
