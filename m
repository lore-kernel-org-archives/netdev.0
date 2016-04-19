From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 00/18] wcn36xx fixes
Date: Mon, 18 Apr 2016 22:00:38 -0700
Message-ID: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bulk of the following patches have been sitting in Eugene's Github tree for
quite some time. They fix various issues existing in the mainline drivers, so
they should be merged there too.

Also included are two new fixes, of my own; the important one being the
reordering of deletion of the bss, as this crashes the firmware on the
Dragonbaord 410c (apq8016 with pronto & wcn3620).

Lastly is a patch that adds a bunch of new capabilities found in the downstream
driver.

Changes since v2:
- Restore BEACON_TEMPLATE_SIZE to not break UPDATE_PROBE_RSP_TEMPLATE_REQ
- Added patch to correct WCN36XX_HAL_RMV_BSSKEY_RSP decoder
- Added patch with missing capabilities from downstream

Changes since v1:
- Reorder patch 6 and 7 to not break the build temporarily
- Inline fix from Jason Mobarak in the TIM PVM padding

Bjorn Andersson (3):
  wcn36xx: Delete BSS before idling link
  wcn36xx: Correct remove bss key response encoding
  wcn36xx: Fill in capability list

Pontus Fuchs (15):
  wcn36xx: Clean up wcn36xx_smd_send_beacon
  wcn36xx: Pad TIM PVM if needed
  wcn36xx: Add helper macros to cast vif to private vif and vice versa
  wcn36xx: Use consistent name for private vif
  wcn36xx: Use define for invalid index and fix typo
  wcn36xx: Add helper macros to cast sta to priv
  wcn36xx: Fetch private sta data from sta entry instead of from vif
  wcn36xx: Remove sta pointer in private vif struct
  wcn36xx: Parse trigger_ba response properly
  wcn36xx: Copy all members in config_sta v1 conversion
  wcn36xx: Use allocated self sta index instead of hard coded
  wcn36xx: Clear encrypt_type when deleting bss key
  wcn36xx: Track association state
  wcn36xx: Implement multicast filtering
  wcn36xx: Use correct command struct for EXIT_BMPS_REQ

 drivers/net/wireless/ath/wcn36xx/debug.c   |  12 +-
 drivers/net/wireless/ath/wcn36xx/hal.h     |  55 ++++++-
 drivers/net/wireless/ath/wcn36xx/main.c    | 133 +++++++++++++----
 drivers/net/wireless/ath/wcn36xx/pmc.c     |   4 +-
 drivers/net/wireless/ath/wcn36xx/smd.c     | 224 +++++++++++++++++++----------
 drivers/net/wireless/ath/wcn36xx/smd.h     |  12 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c    |   8 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  20 ++-
 8 files changed, 336 insertions(+), 132 deletions(-)

-- 
2.5.0
