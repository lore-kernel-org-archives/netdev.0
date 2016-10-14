From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-10-14
Date: Fri, 14 Oct 2016 10:18:42 +0300
Message-ID: <87oa2nbdpp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55933 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbcJNHSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 03:18:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

first wireless-drivers pull request for 4.9 and this time we have
unusually many fixes even before -rc1 is released. Most important here
are the wlcore and rtlwifi commits which fix critical regressions,
otherwise smaller impact fixes and one new sdio id for ath6kl.

Please let me know if there are any problems.

Kalle

The following changes since commit 03a1eabc3f54469abd4f1784182851b2e29630cc:

  Merge branch 'mlxsw-fixes' (2016-10-04 20:28:10 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-10-14

for you to fetch changes up to 1ea2643961b0d1b8d0e4a11af5aa69b0f92d0533:

  ath6kl: add Dell OEM SDIO I/O for the Venue 8 Pro (2016-10-13 14:16:33 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.9

wlcore

* fix a double free regression causing hard to track crashes

rtl8xxxu

* fix driver reload issues, a memory leak and an endian bug

rtlwifi

* fix a major regression introduced in 4.9 with firmware loading on
  certain hardware

ath10k

* fix regression about broken cal_data debugfs file (since 4.7)

ath9k

* revert temperature compensation for AR9003+ devices, it was causing
  too much problems

ath6kl

* add Dell OEM SDIO I/O for the Venue 8 Pro

----------------------------------------------------------------
Adam Williamson (1):
      ath6kl: add Dell OEM SDIO I/O for the Venue 8 Pro

Felix Fietkau (1):
      Revert "ath9k_hw: implement temperature compensation support for AR9003+"

Jes Sorensen (4):
      rtl8xxxu: Fix memory leak in handling rxdesc16 packets
      rtl8xxxu: Fix big-endian problem reporting mactime
      rtl8xxxu: Fix rtl8723bu driver reload issue
      rtl8xxxu: Fix rtl8192eu driver reload issue

Larry Finger (1):
      rtlwifi: Fix regression caused by commit d86e64768859

Marty Faltesek (1):
      ath10k: cache calibration data when the core is stopped

Wei Yongjun (1):
      wlcore: sdio: drop kfree for memory allocated with devm_kzalloc

 drivers/net/wireless/ath/ath10k/core.h             |    1 +
 drivers/net/wireless/ath/ath10k/debug.c            |   75 ++++++++++----------
 drivers/net/wireless/ath/ath6kl/sdio.c             |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   25 +------
 drivers/net/wireless/ath/ath9k/hw.h                |    1 -
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |    4 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |    8 ++-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |    4 ++
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |   11 ++-
 drivers/net/wireless/realtek/rtlwifi/core.c        |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |    8 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |   13 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |   12 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |    8 +--
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    9 +--
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |   12 ++--
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   18 ++---
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |    2 -
 drivers/net/wireless/ti/wlcore/sdio.c              |    1 -
 21 files changed, 110 insertions(+), 117 deletions(-)
