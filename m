From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-10-13
Date: Fri, 13 Oct 2017 10:25:14 +0300
Message-ID: <878tgfpl0l.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request to net tree, more info in the signed tag below.
Please let me know if there are any problems.

Kalle

The following changes since commit 3e747fa18202896b5be66b88478352d5880fb8eb:

  Merge ath-current from ath.git (2017-09-25 10:06:12 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-10-13

for you to fetch changes up to a6127b4440d1f74f26b64006b2f50c9dc6d66efc:

  Merge tag 'iwlwifi-for-kalle-2017-10-06' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2017-10-09 17:31:39 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.14

Nothing really special standing out, all of these are important fixes
which should go to 4.14.

iwlwifi

* fix support for 3168 device series

* fix a potential crash when using FW debugging recording;

* improve channel flags parsing to avoid warnings on too long traces

* return -ENODATA when the temperature is not available, since the
 -EIO we were returning was causing fatal errors in userspace

* avoid printing too many messages in dmesg when using monitor mode,
  since this can become very noisy and completely flood the logs

brcmsmac

* reduce stack usage to avoid frame size warnings with KASAN

brcmfmac

* add a check to avoid copying uninitialised memory

rtlwifi:

* fix a regression with rtl8821ae starting from v4.11 where
  connections was frequently lost

----------------------------------------------------------------
Arnd Bergmann (1):
      brcmsmac: make some local variables 'static const' to reduce stack size

Chaya Rachel Ivgi (1):
      iwlwifi: nvm: set the correct offsets to 3168 series

Golan Ben Ami (1):
      iwlwifi: stop dbgc recording before stopping DMA

Johannes Berg (1):
      iwlwifi: nvm-parse: unify channel flags printing

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-10-06' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Kevin Cernekee (1):
      brcmfmac: Add check for short event packets

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix connection lost problem

Luca Coelho (1):
      iwlwifi: mvm: return -ENODATA when reading the temperature with the FW down

Shaul Triebitz (1):
      iwlwifi: mvm: do not print security error in monitor mode

 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |   3 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        | 197 ++++++++++-----------
 drivers/net/wireless/intel/iwlwifi/cfg/7000.c      |   1 +
 drivers/net/wireless/intel/iwlwifi/cfg/8000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c      |   2 +-
 .../net/wireless/intel/iwlwifi/fw/api/nvm-reg.h    |   2 +
 drivers/net/wireless/intel/iwlwifi/fw/dbg.c        |   7 +-
 drivers/net/wireless/intel/iwlwifi/fw/dbg.h        |  15 ++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |  16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c | 137 +++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   7 +
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |  21 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   2 +-
 18 files changed, 232 insertions(+), 197 deletions(-)
