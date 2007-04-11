From: Greg KH <gregkh@suse.de>
Subject: [patch 04/31] skge: turn carrier off when down
Date: Wed, 11 Apr 2007 15:51:25 -0700
Message-ID: <20070411225125.GE24814@kroah.com>
References: <20070411224329.866978349@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161339AbXDKWym@vger.kernel.org>
Content-Disposition: inline; filename="skge-carrier.patch"
In-Reply-To: <20070411225100.GA24814@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Driver needs to turn off carrier when down, otherwise it can
confuse bonding and bridging and looks like carrier is on immediately
when it is brought back up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/skge.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2462,6 +2462,7 @@ static int skge_down(struct net_device *
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		cancel_rearming_delayed_work(&skge->link_thread);
 

-- 
