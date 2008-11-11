From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-11-11
Date: Tue, 11 Nov 2008 13:18:35 -0500
Message-ID: <20081111181834.GA20151@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37876 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbYKKSbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 13:31:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another quick patch for 2.6.29 -- this fixes a build break for ath9k
when RFKILL is enabled.  Sorry for letting that slip through!

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit fb28ad35906af2f042c94e2f9c0f898ef9acfa37:
  Kay Sievers (1):
        net: struct device - replace bus_id with dev_name(), dev_set_name()

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Sujith (1):
      ath9k: Fix compilation failure when RFKILL is enabled

 drivers/net/wireless/ath9k/main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index fb50aa0..f830fe1 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -37,6 +37,8 @@ static struct pci_device_id ath_pci_id_table[] __devinitdata = {
 	{ 0 }
 };
 
+static void ath_detach(struct ath_softc *sc);
+
 static int ath_get_channel(struct ath_softc *sc,
 			   struct ieee80211_channel *chan)
 {
@@ -813,7 +815,7 @@ static int ath_start_rfkill_poll(struct ath_softc *sc)
 			pci_iounmap(sc->pdev, sc->mem);
 			pci_release_region(sc->pdev, 0);
 			pci_disable_device(sc->pdev);
-			ieee80211_free_hw(hw);
+			ieee80211_free_hw(sc->hw);
 			return -EIO;
 		} else {
 			sc->sc_flags |= SC_OP_RFKILL_REGISTERED;
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
