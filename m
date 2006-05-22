From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Mon, 22 May 2006 15:18:03 -0400
Message-ID: <20060522191759.GD13964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:16147 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751138AbWEVTSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 15:18:24 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 353b28bafd1b962359a866ff263a7fad833d29a1:
  David S. Miller:
        [SPARC]: Add robust futex syscall entries.

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Florin Malita:
      orinoco: possible null pointer dereference in orinoco_rx_monitor()

 drivers/net/wireless/orinoco.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 06523e2..c2d0b09 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -812,7 +812,6 @@ static void orinoco_rx_monitor(struct ne
 	if (datalen > IEEE80211_DATA_LEN + 12) {
 		printk(KERN_DEBUG "%s: oversized monitor frame, "
 		       "data length = %d\n", dev->name, datalen);
-		err = -EIO;
 		stats->rx_length_errors++;
 		goto update_stats;
 	}
@@ -821,8 +820,7 @@ static void orinoco_rx_monitor(struct ne
 	if (!skb) {
 		printk(KERN_WARNING "%s: Cannot allocate skb for monitor frame\n",
 		       dev->name);
-		err = -ENOMEM;
-		goto drop;
+		goto update_stats;
 	}
 
 	/* Copy the 802.11 header to the skb */
-- 
John W. Linville
linville@tuxdriver.com
