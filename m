From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/11] staging: r8188eu: Clean up a number of pointless
 wrappers
Date: Thu, 19 Dec 2013 22:38:32 -0600
Message-ID: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Because the original driver was designed to build for Windows, FreeBSD, and Linux,
there are wrappers for many of the OS primitives. These patches remove a number of them.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (11):
  staging: r8188eu: Remove pointless thread_exit macro
  staging: r8188eu: Remove wrapper around spin_lock_bh
  staging: r8188eu: Remove wrapper around spin_unlock_bh
  staging: r8188eu: Remove wrappers for spin_lock_irqsave
  staging: r8188eu: Remove wrappers around spin_unlock_irqrestore
  staging: r8188eu: Remove wrapper around spin_lock_init
  staging: r8188eu: Remove calls to _rtw_spinlock_free
  staging: r8188eu: Replace rtw_get_current_time() with jiffies
  staging: r8188eu: Replace wrappers ODM_sleep_ms() and rtw_msleep_os()
    with a simple msleep
  staging: r8188eu: Replace wrappers ODM_delay_ms() and rtw_mdelay_os()
    with a simple mdelay
  staging: r8188eu: Replace wrappers ODM_StallExecution, ODM_delay_us,
    and rtw_udelay_os

 drivers/staging/rtl8188eu/core/rtw_ap.c            |  80 +++++-----
 drivers/staging/rtl8188eu/core/rtw_br_ext.c        |  44 +++---
 drivers/staging/rtl8188eu/core/rtw_cmd.c           |  48 +++---
 drivers/staging/rtl8188eu/core/rtw_debug.c         |   4 +-
 drivers/staging/rtl8188eu/core/rtw_efuse.c         |   2 +-
 drivers/staging/rtl8188eu/core/rtw_ioctl_set.c     |  36 ++---
 drivers/staging/rtl8188eu/core/rtw_mlme.c          | 163 +++++++++------------
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c      |  73 +++++----
 drivers/staging/rtl8188eu/core/rtw_mp.c            |  23 ++-
 drivers/staging/rtl8188eu/core/rtw_mp_ioctl.c      |   6 +-
 drivers/staging/rtl8188eu/core/rtw_p2p.c           |  23 +--
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c       |  20 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c          |  68 ++++-----
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c       | 116 ++++-----------
 drivers/staging/rtl8188eu/core/rtw_xmit.c          | 106 ++++++--------
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     |  12 +-
 drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c       |   6 +-
 drivers/staging/rtl8188eu/hal/odm.c                |  10 +-
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  42 +++---
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  20 ---
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c       |   2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c  |   8 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c        |   6 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c    |   6 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c    |   8 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_sreset.c    |   2 +-
 drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c     |   2 +-
 drivers/staging/rtl8188eu/hal/rtl8188eu_xmit.c     |  12 +-
 drivers/staging/rtl8188eu/hal/usb_halinit.c        |   6 +-
 drivers/staging/rtl8188eu/include/odm_interface.h  |   8 -
 drivers/staging/rtl8188eu/include/osdep_service.h  |  40 -----
 drivers/staging/rtl8188eu/include/rtw_mlme.h       |  30 ++--
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c     |  90 +++++-------
 drivers/staging/rtl8188eu/os_dep/os_intfs.c        |   9 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   |  34 +----
 drivers/staging/rtl8188eu/os_dep/recv_linux.c      |   6 +-
 drivers/staging/rtl8188eu/os_dep/usb_intf.c        |   4 +-
 drivers/staging/rtl8188eu/os_dep/usb_ops_linux.c   |   8 +-
 drivers/staging/rtl8188eu/os_dep/xmit_linux.c      |  12 +-
 39 files changed, 446 insertions(+), 749 deletions(-)

-- 
1.8.4
