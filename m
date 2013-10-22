From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: r8188eu: Set device type to wlan
Date: Mon, 21 Oct 2013 22:15:05 -0500
Message-ID: <1382411705-5374-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:56889 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab3JVDPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 23:15:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latest version of NetworkManager does not recognize the device as wireless
without this change.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>a [3.12+]
---
 drivers/staging/rtl8188eu/os_dep/os_intfs.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index da9f0d5..17659bb 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -707,6 +707,10 @@ int rtw_init_netdev_name(struct net_device *pnetdev, const char *ifname)
 	return 0;
 }
 
+static const struct device_type wlan_type = {
+	.name = "wlan",
+};
+
 struct net_device *rtw_init_netdev(struct adapter *old_padapter)
 {
 	struct adapter *padapter;
@@ -722,6 +726,7 @@ struct net_device *rtw_init_netdev(struct adapter *old_padapter)
 	if (!pnetdev)
 		return NULL;
 
+	pnetdev->dev.type = &wlan_type;
 	padapter = rtw_netdev_priv(pnetdev);
 	padapter->pnetdev = pnetdev;
 	DBG_88E("register rtw_netdev_ops to netdev_ops\n");
-- 
1.8.4
