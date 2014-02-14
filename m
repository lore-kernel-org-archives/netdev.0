From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/13] Cleanups for r8188eu
Date: Fri, 14 Feb 2014 16:54:04 -0600
Message-ID: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
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

This set of patches removes a number of wrappers that only tend to obfuscate
the code. These do not cause any functional changes.

The one exception is the last patch. It changes the code to hold the firmware
image in memory until the device is closed. That way, it is no longer necessary
to reread the disk file every time the device reinits.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (12):
  staging: r8188eu: Remove unnecessary list_head entry from recv_frame
    union
  staging: r8188eu: Remove pointless "alignment" entry in recv_frame
  staging: r8188eu: Remove union wrapping of recv_frame
  staging: r8188eu: Remove pkt_to_recv{frame,data,mem} routines
  staging: r8188eu: Remove unused get_rxbuf_desc()
  staging: r8188eu: Remove get_recvframe_len()
  staging: r8188eu: Remove get_recvframe_data()
  staging: r8188eu: Remove unused union
  staging: r8188eu: Remove wrapper _exit_critical_mutex()
  staging: r8188eu: Remove wrapper _enter_critical_mutex()
  staging: r8188eu: Remove wrapper routine _init_workitem()
  staging: r8188eu: Remove wrapper routine _set_workitem()

Stas Sergeev (1):
  staging: r8188eu: Make firmware buffer persistent

 drivers/staging/rtl8188eu/core/rtw_cmd.c          |   2 +-
 drivers/staging/rtl8188eu/core/rtw_led.c          |   4 +-
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 148 ++++-----
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 352 ++++++++++++----------
 drivers/staging/rtl8188eu/core/rtw_security.c     |  18 +-
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      |  10 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |  80 ++---
 drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c   |  33 +-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c     |  48 +--
 drivers/staging/rtl8188eu/include/drv_types.h     |   6 +
 drivers/staging/rtl8188eu/include/osdep_service.h |  27 --
 drivers/staging/rtl8188eu/include/recv_osdep.h    |  10 +-
 drivers/staging/rtl8188eu/include/rtl8188e_hal.h  |  11 -
 drivers/staging/rtl8188eu/include/rtl8188e_recv.h |   7 +-
 drivers/staging/rtl8188eu/include/rtw_mlme_ext.h  |  49 +--
 drivers/staging/rtl8188eu/include/rtw_recv.h      | 139 +++------
 drivers/staging/rtl8188eu/include/rtw_xmit.h      |   5 -
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       |   9 +-
 drivers/staging/rtl8188eu/os_dep/recv_linux.c     |  36 +--
 19 files changed, 472 insertions(+), 522 deletions(-)

-- 
1.8.4.5
