From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 14 Nov 2006 20:31:12 -0500
Message-ID: <20061115013112.GG3451@tuxdriver.com>
References: <20061115012921.GF3451@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:47116 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S966615AbWKOCBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 21:01:21 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061115012921.GF3451@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 4c5d3c72166676663c3917839a030b86fa758b23:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

John W. Linville:
      prism54: correct overly aggressive check of return from pci_set_mwi

Larry Finger:
      bcm43xx: correct "Move IV/ICV stripping into ieee80211_rx"

 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c   |    1 +
 drivers/net/wireless/prism54/islpci_hotplug.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index a957bc8..3e24626 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
 		break;
 	}
 
+	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
 	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
 	case IEEE80211_FTYPE_MGMT:
 		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index e0bca3a..58257b4 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -170,8 +170,8 @@ #endif
 	pci_set_master(pdev);
 
 	/* enable MWI */
-	if (pci_set_mwi(pdev))
-		goto do_pci_release_regions;
+	if (!pci_set_mwi(pdev))
+		printk(KERN_INFO "%s: pci_set_mwi(pdev) succeeded\n", DRV_NAME);
 
 	/* setup the network device interface and its structure */
 	if (!(ndev = islpci_setup(pdev))) {
-- 
John W. Linville
linville@tuxdriver.com
