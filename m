From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2 for 3.19 0/7] Fixes for rtl8192ee
Date: Tue, 20 Jan 2015 11:01:19 -0600
Message-ID: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle,

This is V2 of the patches for rtl8192ee to be applied to 3.19. They replace
all the patches submitted under the title '[PATCH for 3.19 0/3] rtlwifi:
Various updates/fixes". All are marked for backporting to 3.18.

The first of these removes a logging statement that is no longer needed.

Patches 1-6 are relatively small and should not be a problem for 3.19.
Patch 7 is quite a bit larger, and adds two new routines to detect
DMA stalls. I will understand if you want to defer that to -next; however,
it does fix a serious problem.

Larry
---
Larry Finger (2):
  rtlwifi: Remove logging statement that is no longer needed
  rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO

Troy Tan (5):
  rtlwifi: rtl8192ee: Fix handling of new style descriptors
  rtlwifi: rtl8192ee: Fix adhoc fail
  rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write
    point
  rtlwifi: rtl8192ee: Fix parsing of received packet
  rtlwifi: rtl8192ee: Fix DMA stalls

 drivers/net/wireless/rtlwifi/pci.c           |  36 ++++--
 drivers/net/wireless/rtlwifi/pci.h           |   7 ++
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c  |   6 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c  | 166 ++++++++++++++++++++++-----
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c  |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  36 +++---
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h |   4 +-
 drivers/net/wireless/rtlwifi/wifi.h          |   1 +
 9 files changed, 192 insertions(+), 69 deletions(-)

-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
