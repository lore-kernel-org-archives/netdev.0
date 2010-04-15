From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-04-15
Date: Thu, 15 Apr 2010 16:03:31 -0400
Message-ID: <20100415200331.GD3020@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Another fix intended for 2.6.34...without it some firmware wierdness can
induce the driver into hanging the box... :-(

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4eaa0e3c869acd5dbc7c2e3818a9ae9cbf221d27:
  Eric Dumazet (1):
        fib: suppress lockdep-RCU false positive in FIB trie.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      iwlwifi: work around bogus active chains detection

 drivers/net/wireless/iwlwifi/iwl-calib.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-calib.c b/drivers/net/wireless/iwlwifi/iwl-calib.c
index 845831a..64de42b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-calib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-calib.c
@@ -807,6 +807,18 @@ void iwl_chain_noise_calibration(struct iwl_priv *priv,
 		}
 	}
 
+	/*
+	 * The above algorithm sometimes fails when the ucode
+	 * reports 0 for all chains. It's not clear why that
+	 * happens to start with, but it is then causing trouble
+	 * because this can make us enable more chains than the
+	 * hardware really has.
+	 *
+	 * To be safe, simply mask out any chains that we know
+	 * are not on the device.
+	 */
+	active_chains &= priv->hw_params.valid_rx_ant;
+
 	num_tx_chains = 0;
 	for (i = 0; i < NUM_RX_CHAINS; i++) {
 		/* loops on all the bits of
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
