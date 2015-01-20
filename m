From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: pull-request: wireless-drivers 2015-01-20
Date: Tue, 20 Jan 2015 11:03:33 +0200
Message-ID: <87oapt3jtm.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

more fixes for 3.19, I hope these are still appropriate. Please let me
know if there are any issues.

Kalle

The following changes since commit 16dde0d6ac159531a5e03cd3f8bc8a401d9f3fb6:

  be2net: Allow GRE to work concurrently while a VxLAN tunnel is configured (2015-01-15 01:55:05 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-01-20

for you to fetch changes up to e3f31175a3eeb492a6ab788e4fa136c19b43aab4:

  ath9k: fix race condition in irq processing during hardware reset (2015-01-19 14:32:29 +0200)

----------------------------------------------------------------
ath9k:

* fix an IRQ storm caused by commit 872b5d814f99

iwlwifi:

* A fix for scan that fixes a firmware assertion

* A fix that improves roaming behavior. Same fix has been tested for
  a while in iwldvm. This is a bit of a work around, but the real fix
  should be in mac80211 and will come later.

* A fix for BARs that avoids a WARNING.

* one fix for rfkill while scheduled scan is running.
  Linus's system hit this issue. WiFi would be unavailable
  after this has happpened because of bad state in cfg80211.

----------------------------------------------------------------
David Spinadel (1):
      iwlwifi: mvm: fix EBS on single scan

Emmanuel Grumbach (2):
      iwlwifi: mvm: drop non VO frames when flushing
      iwlwifi: mvm: abort scheduled scan upon RFKILL

Eyal Shapira (1):
      iwlwifi: mvm: set the tx cmd tid for BAR frame correctly

Felix Fietkau (1):
      ath9k: fix race condition in irq processing during hardware reset

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2015-01-13' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-for-kalle-2015-01-15' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

 drivers/net/wireless/ath/ath9k/main.c          |    7 ++--
 drivers/net/wireless/iwlwifi/iwl-fw-file.h     |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h |    7 +++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c    |   20 ++++-----
 drivers/net/wireless/iwlwifi/mvm/scan.c        |   53 ++++++++++++++++++------
 drivers/net/wireless/iwlwifi/mvm/tx.c          |   11 ++++-
 6 files changed, 69 insertions(+), 31 deletions(-)

-- 
Kalle Valo
