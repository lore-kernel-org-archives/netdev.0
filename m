From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/3] sh_eth: no need for *else* after *goto*
Date: Wed, 04 Jan 2017 15:10:50 +0300
Message-ID: <2432748.6uHGRc6GHQ@wasted.cogentembedded.com>
References: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:36739 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757003AbdADMLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:11:00 -0500
Received: by mail-lf0-f41.google.com with SMTP id x140so6183093lfa.3
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:10:59 -0800 (PST)
In-Reply-To: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, checkpatch.pl complains about *else* after *return* and *break* but
not after *goto*... and it probably should have complained about the code
in sh_eth_error().  Win couple LoCs by removing that *else*. :-)

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: renesas/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- renesas.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ renesas/drivers/net/ethernet/renesas/sh_eth.c
@@ -1542,13 +1542,11 @@ static void sh_eth_error(struct net_devi
 			ndev->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
 			/* Link Changed */
-			if (mdp->cd->no_psr || mdp->no_ether_link) {
+			if (mdp->cd->no_psr || mdp->no_ether_link)
 				goto ignore_link;
-			} else {
-				link_stat = (sh_eth_read(ndev, PSR));
-				if (mdp->ether_link_active_low)
-					link_stat = ~link_stat;
-			}
+			link_stat = sh_eth_read(ndev, PSR);
+			if (mdp->ether_link_active_low)
+				link_stat = ~link_stat;
 			if (!(link_stat & PHY_ST_LINK)) {
 				sh_eth_rcv_snd_disable(ndev);
 			} else {
