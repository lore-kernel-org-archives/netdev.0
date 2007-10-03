From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 3 Oct 2007 14:40:01 -0400
Message-ID: <20071003184001.GA28525@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758125AbXJCSkX@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


sky2 is really the only important fix, the others are trivial.


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/sky2.c                          |    3 ---
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |    2 +-
 net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

Joe Perches (1):
      bcm43xx: Correct printk with PFX before KERN_

Richard Knutsson (1):
      softmac: Fix compiler-warning

Stephen Hemminger (1):
      sky2: jumbo frame regression fix

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 162489b..ea117fc 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2163,9 +2163,6 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
-	if (length < ETH_ZLEN || length > sky2->rx_data_size)
-		goto len_error;
-
 	/* This chip has hardware problems that generates bogus status.
 	 * So do only marginal checking and expect higher level protocols
 	 * to handle crap frames.
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index d6d9413..6acfdc4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -444,7 +444,7 @@ static int bcm43xx_wx_set_xmitpower(struct net_device *net_dev,
 	u16 maxpower;
 
 	if ((data->txpower.flags & IW_TXPOW_TYPE) != IW_TXPOW_DBM) {
-		printk(PFX KERN_ERR "TX power not in dBm.\n");
+		printk(KERN_ERR PFX "TX power not in dBm.\n");
 		return -EOPNOTSUPP;
 	}
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 442b987..5742dc8 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -114,7 +114,7 @@ check_assoc_again:
 	sm->associnfo.associating = 1;
 	/* queue lower level code to do work (if necessary) */
 	schedule_delayed_work(&sm->associnfo.work, 0);
-out:
+
 	mutex_unlock(&sm->associnfo.mutex);
 
 	return 0;
