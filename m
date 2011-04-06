From: Simon Wood <simon@mungewell.org>
Subject: [PatchV2 : PL25A1 Support - 3/3] reset_debug
Date: Tue,  5 Apr 2011 22:16:46 -0600
Message-ID: <1302063406-13077-3-git-send-email-simon@mungewell.org>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Cc: David Brownell <david-b@pacbell.net>,
	Sergei Shtylyov <sshtylyov@mvista.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Simon Wood <simon@mungewell.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds some debug in the event that reseting chip fails for some reason

Signed-off-by: Simon Wood <simon@mungewell.org>
---
 drivers/net/usb/plusb.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index b9649e0..11ff297 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -94,11 +94,15 @@ pl_set_QuickLink_features(struct usbnet *dev, int val)
 
 static int pl_reset(struct usbnet *dev)
 {
+	int     status;
+
 	/* some units seem to need this reset, others reject it utterly.
 	 * FIXME be more like "naplink" or windows drivers.
 	 */
-	(void) pl_set_QuickLink_features(dev,
+	status = pl_set_QuickLink_features(dev,
 		PL_S_EN|PL_RESET_OUT|PL_RESET_IN|PL_PEER_E);
+	if (status != 0 && netif_msg_probe(dev))
+		netif_dbg(dev, link, dev->net, "pl_reset --> %d\n", status);
 	return 0;
 }
 
-- 
1.7.0.4
