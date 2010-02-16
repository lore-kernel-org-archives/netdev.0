From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Tue, 16 Feb 2010 14:50:54 +1100
Message-ID: <20100216145054.d1443653.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Daniel Mack <daniel@caiaq.de>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:49325 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541Ab0BPDu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 22:50:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflicts in
drivers/net/qlge/qlge_ethtool.c and drivers/net/qlge/qlge_main.c between
commit ae9540f75d5a69e7604cc5391cc0726b3aa82ff6 ("drivers/net/qlge: Use
netif_printk helpers") from the net tree and commit
3ad2f3fbb961429d2aa627465ae4829758bc7e07 ("tree-wide: Assorted spelling
fixes") from the trivial tree.

I fixed them up (see below) and can carry the fixes as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/qlge/qlge_ethtool.c
index 4f26afe,b8d21ab..0000000
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@@ -404,9 -401,9 +404,9 @@@ static int ql_set_wol(struct net_devic
  	if (!qdev->wol) {
  		u32 wol = 0;
  		status = ql_mb_wol_mode(qdev, wol);
 -		QPRINTK(qdev, DRV, ERR, "WOL %s (wol code 0x%x) on %s\n",
 -			(status == 0) ? "cleared successfully" : "clear failed",
 -			wol, qdev->ndev->name);
 +		netif_err(qdev, drv, qdev->ndev, "WOL %s (wol code 0x%x)\n",
- 			  status == 0 ? "cleared sucessfully" : "clear failed",
++			  status == 0 ? "cleared successfully" : "clear failed",
 +			  wol);
  	}
  
  	return 0;
diff --cc drivers/net/qlge/qlge_main.c
index 2c052ca,a35845b..0000000
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@@ -3863,10 -3516,9 +3863,10 @@@ int ql_wol(struct ql_adapter *qdev
  	if (qdev->wol) {
  		wol |= MB_WOL_MODE_ON;
  		status = ql_mb_wol_mode(qdev, wol);
 -		QPRINTK(qdev, DRV, ERR, "WOL %s (wol code 0x%x) on %s\n",
 -			(status == 0) ? "Successfully set" : "Failed", wol,
 -			qdev->ndev->name);
 +		netif_err(qdev, drv, qdev->ndev,
 +			  "WOL %s (wol code 0x%x) on %s\n",
- 			  (status == 0) ? "Sucessfully set" : "Failed",
++			  (status == 0) ? "Successfully set" : "Failed",
 +			  wol, qdev->ndev->name);
  	}
  
  	return status;
