From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201
Date: Mon, 10 Apr 2017 17:34:23 +0200
Message-ID: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Telit LE920A4 uses the same pid 0x1201 of LE920, but modem
implementation is different, since it requires DTR to be set for
answering to qmi messages.

This patch replaces QMI_FIXED_INTF with QMI_QUIRK_SET_DTR: tests on
LE920 have been performed in order to verify backward compatibility.

Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

Hi Bjørn,

as a side note in latest kernels I had troubles with qmi devices
(e.g. I/O error when using qmicli).

I found your suggestion in libqmi mailing list to revert commit

833415a3e781a26fe480a34d45086bdb4fe1e4c0
cdc-wdm: fix "out-of-sync" due to missing notifications

and this seems to work.

Regards,
Daniele

---
 drivers/net/usb/qmi_wwan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 156f7f8..2474618 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -908,7 +908,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
 	{QMI_QUIRK_SET_DTR(0x1bc7, 0x1040, 2)},	/* Telit LE922A */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
-	{QMI_FIXED_INTF(0x1bc7, 0x1201, 2)},	/* Telit LE920 */
+	{QMI_QUIRK_SET_DTR(0x1bc7, 0x1201, 2)},	/* Telit LE920, LE920A4 */
 	{QMI_FIXED_INTF(0x1c9e, 0x9b01, 3)},	/* XS Stick W100-2 from 4G Systems */
 	{QMI_FIXED_INTF(0x0b3c, 0xc000, 4)},	/* Olivetti Olicard 100 */
 	{QMI_FIXED_INTF(0x0b3c, 0xc001, 4)},	/* Olivetti Olicard 120 */
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
