From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: wireless/ath: Fix compile error seen with W=1
Date: Sat, 26 Jan 2013 18:26:08 -0800
Message-ID: <1359253568-15762-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:58047 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128Ab3A0C0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2013 21:26:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make W=3D1 for x86_64 fails with

drivers/net/wireless/ath/wil6210/txrx.c: In function =E2=80=98wil_rx_fi=
ni=E2=80=99:
drivers/net/wireless/ath/wil6210/txrx.c:550:7: error: variable =E2=80=98=
rc=E2=80=99 set but not
used [-Werror=3Dunused-but-set-variable]

=46ix by dropping the variable.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/wireless/ath/wil6210/txrx.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/txrx.c b/drivers/net/wire=
less/ath/wil6210/txrx.c
index f29c294..b6e8042 100644
--- a/drivers/net/wireless/ath/wil6210/txrx.c
+++ b/drivers/net/wireless/ath/wil6210/txrx.c
@@ -547,7 +547,6 @@ void wil_rx_fini(struct wil6210_priv *wil)
 	struct vring *vring =3D &wil->vring_rx;
=20
 	if (vring->va) {
-		int rc;
 		struct wmi_cfg_rx_chain_cmd cmd =3D {
 			.action =3D cpu_to_le32(WMI_RX_CHAIN_DEL),
 			.rx_sw_ring =3D {
@@ -559,7 +558,7 @@ void wil_rx_fini(struct wil6210_priv *wil)
 			struct wmi_cfg_rx_chain_done_event cfg;
 		} __packed wmi_rx_cfg_reply;
=20
-		rc =3D wmi_call(wil, WMI_CFG_RX_CHAIN_CMDID, &cmd, sizeof(cmd),
+		(void)wmi_call(wil, WMI_CFG_RX_CHAIN_CMDID, &cmd, sizeof(cmd),
 			      WMI_CFG_RX_CHAIN_DONE_EVENTID,
 			      &wmi_rx_cfg_reply, sizeof(wmi_rx_cfg_reply),
 			      100);
--=20
1.7.9.7
