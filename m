From: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 0/7] net: wireless: wcn36xx: add basic wcn3620 support
Date: Sun, 18 Jan 2015 13:10:35 +0800
Message-ID: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following series adds some basic wcn3620 support to the
mainline wcn36xx driver.

 - modify the chip detection to be told which chip from
   platform ops, which can get it from Device Tree... the
   existing detection is just assume it's a wcn3680 if it
   has AC mode which is not enough

 - Adapt the DXE register selection to use 3680 mode for
   3620 as well

 - Add a couple of async "indication" messages which can
   appear down smd on 3620, just accept and ignore

 - Accept a modified form of trigger_ba response that is
   sent by the wcn3620 firmware, if device is a 3620

 - Disable powersaving mode if 3620

With these the 3620 can associate and work for a while
before needing to be forcibly reassociated again.

It's tested on an msm8916-QRD "phone" dev platform that
includes wcn3620.

---

Andy Green (7):
      net: wireless: wcn36xx: add wcn3620 chip type definition
      net: wireless: wcn36xx: get chip type from platform ops
      net: wireless: wcn36xx: use 3680 dxe regs for 3620
      net: wireless: wcn36xx: introduce WCN36XX_HAL_AVOID_FREQ_RANGE_IND
      net: wireless: wcn36xx: swallow two wcn3620 IND messages
      net: wireless: wcn36xx: remove powersaving for wcn3620
      net: wireless: wcn36xx: handle new trigger_ba format


 drivers/net/wireless/ath/wcn36xx/dxe.c     |    2 +-
 drivers/net/wireless/ath/wcn36xx/hal.h     |    2 ++
 drivers/net/wireless/ath/wcn36xx/main.c    |   22 +++++++-----------
 drivers/net/wireless/ath/wcn36xx/smd.c     |   34 ++++++++++++++++++++++++++--
 drivers/net/wireless/ath/wcn36xx/smd.h     |    9 +++++++
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |   13 +++++++----
 6 files changed, 62 insertions(+), 20 deletions(-)

--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
