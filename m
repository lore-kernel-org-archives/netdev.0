From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-09-24
Date: Wed, 24 Sep 2008 19:17:33 -0400
Message-ID: <20080924231720.GD3639@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

One more for 2.6.27 -- a fix for a possible interrupt storm.  There is
even a link in the commit log to a youtube video of the storm in
progress. :-)

Let me know if there are problems!

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 4c07ab0fe4b4eaa0fc31f640ca65da7c173f5043:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Luis R. Rodriguez (1):
      ath9k: disable MIB interrupts to fix interrupt storm

 drivers/net/wireless/ath9k/core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath9k/core.c b/drivers/net/wireless/ath9k/core.c
index c049593..87e37bc 100644
--- a/drivers/net/wireless/ath9k/core.c
+++ b/drivers/net/wireless/ath9k/core.c
@@ -795,6 +795,12 @@ int ath_open(struct ath_softc *sc, struct ath9k_channel *initial_chan)
 	if (ah->ah_caps.hw_caps & ATH9K_HW_CAP_HT)
 		sc->sc_imask |= ATH9K_INT_CST;
 
+	/* Note: We disable MIB interrupts for now as we don't yet
+	 * handle processing ANI, otherwise you will get an interrupt
+	 * storm after about 7 hours of usage making the system unusable
+	 * with huge latency. Once we do have ANI processing included
+	 * we can re-enable this interrupt. */
+#if 0
 	/*
 	 * Enable MIB interrupts when there are hardware phy counters.
 	 * Note we only do this (at the moment) for station mode.
@@ -802,6 +808,7 @@ int ath_open(struct ath_softc *sc, struct ath9k_channel *initial_chan)
 	if (ath9k_hw_phycounters(ah) &&
 	    ((sc->sc_opmode == ATH9K_M_STA) || (sc->sc_opmode == ATH9K_M_IBSS)))
 		sc->sc_imask |= ATH9K_INT_MIB;
+#endif
 	/*
 	 * Some hardware processes the TIM IE and fires an
 	 * interrupt when the TIM bit is set.  For hardware
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
