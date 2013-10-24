From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT 1/5] staging: r8188eu: Fix sparse warnings in ioctl_linux.c
Date: Wed, 23 Oct 2013 22:31:33 -0500
Message-ID: <1382585497-6787-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:62913 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab3JXDby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:31:54 -0400
Received: by mail-oa0-f45.google.com with SMTP id i4so1850034oah.32
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 20:31:53 -0700 (PDT)
In-Reply-To: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse checking results in the following warnings:

  CHECK   drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3932:17: warning: cast removes address space of expression
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3933:31: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3933:31:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3933:31:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3935:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3935:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3935:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3937:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3937:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3937:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3939:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3939:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3939:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3941:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3941:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3941:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3944:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3944:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3944:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3946:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3946:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3946:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3949:38: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3949:38:    expected void const *<noident>
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3949:38:    got void [noderef] <asn:1>*pointer
drivers/staging/rtl8188eu/os_dep/ioctl_linux.c:3963:9: warning: cast removes address space of expression

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index ae54587..5dc3fed 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -3929,24 +3929,24 @@ static int rtw_p2p_get(struct net_device *dev,
 	struct adapter *padapter = (struct adapter *)rtw_netdev_priv(dev);
 
 	if (padapter->bShowGetP2PState)
-		DBG_88E("[%s] extra = %s\n", __func__, (char *)wrqu->data.pointer);
-	if (!memcmp(wrqu->data.pointer, "status", 6)) {
+		DBG_88E("[%s] extra = %s\n", __func__, (__force char *)wrqu->data.pointer);
+	if (!memcmp((__force const char *)wrqu->data.pointer, "status", 6)) {
 		rtw_p2p_get_status(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "role", 4)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "role", 4)) {
 		rtw_p2p_get_role(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "peer_ifa", 8)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "peer_ifa", 8)) {
 		rtw_p2p_get_peer_ifaddr(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "req_cm", 6)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "req_cm", 6)) {
 		rtw_p2p_get_req_cm(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "peer_deva", 9)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "peer_deva", 9)) {
 		/*	Get the P2P device address when receiving the provision discovery request frame. */
 		rtw_p2p_get_peer_devaddr(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "group_id", 8)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "group_id", 8)) {
 		rtw_p2p_get_groupid(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "peer_deva_inv", 9)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "peer_deva_inv", 9)) {
 		/*	Get the P2P device address when receiving the P2P Invitation request frame. */
 		rtw_p2p_get_peer_devaddr_by_invitation(dev, info, wrqu, extra);
-	} else if (!memcmp(wrqu->data.pointer, "op_ch", 5)) {
+	} else if (!memcmp((__force const char *)wrqu->data.pointer, "op_ch", 5)) {
 		rtw_p2p_get_op_ch(dev, info, wrqu, extra);
 	}
 #endif /* CONFIG_88EU_P2P */
@@ -3960,7 +3960,7 @@ static int rtw_p2p_get2(struct net_device *dev,
 	int ret = 0;
 
 #ifdef CONFIG_88EU_P2P
-	DBG_88E("[%s] extra = %s\n", __func__, (char *)wrqu->data.pointer);
+	DBG_88E("[%s] extra = %s\n", __func__, (__force char *)wrqu->data.pointer);
 	if (!memcmp(extra, "wpsCM =", 6)) {
 		wrqu->data.length -= 6;
 		rtw_p2p_get_wps_configmethod(dev, info, wrqu,  &extra[6]);
-- 
1.8.4
