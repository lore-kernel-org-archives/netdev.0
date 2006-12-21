From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 20 Dec 2006 22:05:03 -0500
Message-ID: <20061221030503.GB9277@tuxdriver.com>
References: <20061221030340.GA9277@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3864 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422672AbWLUDzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 22:55:19 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061221030340.GA9277@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 0c234ae655a45ac3ee53a25b2e56e9bb6c27d71d:
  Ulrich Kunitz (1):
        ieee80211softmac: Fix mutex_lock at exit of ieee80211_softmac_get_genie

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Roy Marples (1):
      prism54: set carrier flags correctly

 drivers/net/wireless/prism54/isl_ioctl.c  |    5 ++++-
 drivers/net/wireless/prism54/islpci_dev.c |    4 +++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 838d510..25d42ac 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2093,8 +2093,11 @@ link_changed(struct net_device *ndev, u32 bitrate)
 		} else
 			send_simple_event(netdev_priv(ndev),
 					  "Link established");
-	} else
+		netif_carrier_on(ndev);
+	} else {
 		send_simple_event(netdev_priv(ndev), "Link lost");
+		netif_carrier_off(ndev);
+	}
 }
 
 /* Beacon/ProbeResp payload header */
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index f057fd9..9c8c6f2 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -386,7 +386,9 @@ islpci_open(struct net_device *ndev)
 	}
 
 	netif_start_queue(ndev);
-/*      netif_mark_up( ndev ); */
+
+	/* Turn off carrier unless we know we have associated */
+	netif_carrier_off(ndev);
 
 	return 0;
 }
-- 
John W. Linville
linville@tuxdriver.com
