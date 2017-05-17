From: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] r8152: Mark usb_ocp_read() as __maybe_unused
Date: Wed, 17 May 2017 15:20:56 -0700
Message-ID: <20170517222056.183636-1-mka@chromium.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function is not used, but is probably kept around for debugging and
symmetry with usb_ocp_write(). Adding the attribute fixes the following
clang warning:

drivers/net/usb/r8152.c:825:5: error: unused function 'usb_ocp_read'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ddc62cb69be8..12776230ab96 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -840,7 +840,7 @@ int pla_ocp_write(struct r8152 *tp, u16 index, u16 byteen, u16 size, void *data)
 	return generic_ocp_write(tp, index, byteen, size, data, MCU_TYPE_PLA);
 }
 
-static inline
+static inline __maybe_unused
 int usb_ocp_read(struct r8152 *tp, u16 index, u16 size, void *data)
 {
 	return generic_ocp_read(tp, index, size, data, MCU_TYPE_USB);
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
