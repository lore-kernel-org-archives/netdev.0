From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/31] Staging: r8188eu: Various cleanups
Date: Sun, 22 Dec 2013 17:36:31 -0600
Message-ID: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
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

This set of patches removes a number of wrappers around standard routines,
cleans up some sparse warhings, and also removed a smatch warning.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (31):
  staging: r8188eu: Replace wrappers ODM_sleep_us and rtw_usleep_os
  staging: r8188eu: Replace wrapper rtw_yield_os
  staging: r8188eu: Remove wrapper code for rtw_suspend_lock_init,
    rtw_suspend_lock_uninit, rtw_lock_suspend, and rtw_unlock_suspend
  staging: r8188eu: Replace ATOMIC_T with atomic_t
  staging: r8188eu: Replace wrapper around atomic_set()
  staging: r8188eu: Remove unused atomic_xxx wrappers
  staging: r8188eu: Replace wrappers for atomic_inc and
    atomic_inc_return
  staging: r8188eu: Remove daemonize conditional
  staging: r8188eu: Replace wrapper around sema_init
  staging: r8188eu: Remove wrappers _rtw_free_sema, _rtw_up_sema, and
    _rtw_mutex_init
  staging: r8188eu: Remove wrapper around mutex_destroy
  staging: r8188eu: Remove macro ODM_SetBBReg
  staging: r8188eu: Remove macro ODM_GetBBReg
  staging: r8188eu: Remove macro ODM_SetRFReg
  staging: r8188eu: Remove macro ODM_GetRFReg
  staging: r8188eu: Remove macro ODM_SetMACReg
  staging: r8188eu: Remove macro ODM_GetMACReg
  staging: r8188eu: Remove - number of dummy and unused routines
  staging: r8188eu: Remove more empty routines
  staging: r8188eu: Remove even more empty routines
  staging: r8188eu: Simplify code concerning SupportPlatform
  staging: r8188eu: Simplify code related to SupportICType
  staging: r8188eu: Remove unneeded prototypes from include/odm.h
  staging: r8188eu: Additional cleanup of include/odm.h
  staging: r8188eu: Cleanup of include/hal_intf.h
  staging: r8188eu: Eliminate enum ODM_RADIO_PATH in favor of
    rf_radio_path
  staging: r8188eu: Fix sparse warning in core/rtw_sta_mgt.c
  staging: r8188eu: Fix sparse warning in core/rtw_pwrctrl.c
  staging: r8188eu: Fix sparce warning in core/rtw_xmit.c
  staging: r8188eu: Fix sparse warnings in core/rtw_br_ext.c
  staging: r8188eu: Fix smatch error

 drivers/staging/rtl8188eu/core/rtw_ap.c            |   2 +-
 drivers/staging/rtl8188eu/core/rtw_br_ext.c        |  43 +-
 drivers/staging/rtl8188eu/core/rtw_cmd.c           |  19 +-
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c      |  16 +-
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c       |  13 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c          |   2 +-
 drivers/staging/rtl8188eu/core/rtw_sreset.c        |   2 +-
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c       |   2 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c          |  20 +-
 .../staging/rtl8188eu/hal/Hal8188ERateAdaptive.c   |   4 +-
 drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c   |   4 +-
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 280 +++----
 drivers/staging/rtl8188eu/hal/odm.c                | 918 ++++-----------------
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c       | 361 +++-----
 drivers/staging/rtl8188eu/hal/odm_RTL8188E.c       | 163 ++--
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  20 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  82 --
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c       |   2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_dm.c        |   5 -
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c  |   6 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c        |  34 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c    |   4 +-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c      |   1 -
 drivers/staging/rtl8188eu/include/drv_types.h      |   4 +-
 drivers/staging/rtl8188eu/include/hal_intf.h       |  29 -
 drivers/staging/rtl8188eu/include/odm.h            |  88 +-
 drivers/staging/rtl8188eu/include/odm_HWConfig.h   |   4 +-
 .../staging/rtl8188eu/include/odm_RegConfig8188E.h |   2 +-
 drivers/staging/rtl8188eu/include/odm_debug.h      |  13 +-
 drivers/staging/rtl8188eu/include/odm_interface.h  |  44 +-
 drivers/staging/rtl8188eu/include/odm_precomp.h    |   7 -
 drivers/staging/rtl8188eu/include/osdep_service.h  |  31 -
 drivers/staging/rtl8188eu/include/rtw_cmd.h        |   2 +-
 drivers/staging/rtl8188eu/include/rtw_mlme_ext.h   |   2 +-
 drivers/staging/rtl8188eu/include/rtw_pwrctrl.h    |  10 +-
 drivers/staging/rtl8188eu/include/usb_ops.h        |   4 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c        |   4 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   | 103 ---
 drivers/staging/rtl8188eu/os_dep/rtw_android.c     |   2 -
 drivers/staging/rtl8188eu/os_dep/usb_intf.c        |  15 +-
 40 files changed, 609 insertions(+), 1758 deletions(-)

-- 
1.8.4
