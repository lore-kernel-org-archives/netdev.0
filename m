From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 19/22] staging: rtl8723bs: Fix white-space errors in core/rtw_recv.c
Date: Sat,  8 Apr 2017 11:07:42 -0500
Message-ID: <20170408160745.14328-20-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34880 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdDHQIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:19 -0400
Received: by mail-oi0-f68.google.com with SMTP id g204so6269170oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:18 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smart reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_recv.c
drivers/staging/rtl8723bs/core/rtw_recv.c:598 portctrl() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_recv.c:838 sta2sta_data_frame() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_recv.c:1547 validate_recv_frame() warn: inconsistent indenting

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_recv.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_recv.c b/drivers/staging/rtl8723bs/core/rtw_recv.c
index 864538e8299d..6e98a1bd3e77 100644
--- a/drivers/staging/rtl8723bs/core/rtw_recv.c
+++ b/drivers/staging/rtl8723bs/core/rtw_recv.c
@@ -595,7 +595,7 @@ union recv_frame *portctrl(struct adapter *adapter, union recv_frame *precv_fram
 			memcpy(&be_tmp, ptr, 2);
 			ether_type = ntohs(be_tmp);
 
-		  if (ether_type == eapol_type)
+			if (ether_type == eapol_type)
 				prtnframe = precv_frame;
 			else {
 				/* free this frame */
@@ -827,17 +827,14 @@ sint sta2sta_data_frame(
 		sta_addr = pattrib->src;
 
 	} else if (check_fwstate(pmlmepriv, WIFI_STATION_STATE) == true) {
-		{
-			/*  For Station mode, sa and bssid should always be BSSID, and DA is my mac-address */
-			if (memcmp(pattrib->bssid, pattrib->src, ETH_ALEN)) {
-				RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("bssid != TA under STATION_MODE; drop pkt\n"));
-				ret = _FAIL;
-				goto exit;
-			}
-
-		sta_addr = pattrib->bssid;
+		/*  For Station mode, sa and bssid should always be BSSID, and DA is my mac-address */
+		if (memcmp(pattrib->bssid, pattrib->src, ETH_ALEN)) {
+			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("bssid != TA under STATION_MODE; drop pkt\n"));
+			ret = _FAIL;
+			goto exit;
 		}
 
+		sta_addr = pattrib->bssid;
 	} else if (check_fwstate(pmlmepriv, WIFI_AP_STATE) == true) {
 		if (bmcast) {
 			/*  For AP mode, if DA == MCAST, then BSSID should be also MCAST */
@@ -1517,6 +1514,7 @@ sint validate_recv_frame(struct adapter *adapter, union recv_frame *precv_frame)
 	u8 type;
 	u8 subtype;
 	sint retval = _SUCCESS;
+	u8 bDumpRxPkt;
 
 	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
 
@@ -1544,8 +1542,6 @@ sint validate_recv_frame(struct adapter *adapter, union recv_frame *precv_frame)
 	pattrib->mdata = GetMData(ptr);
 	pattrib->privacy = GetPrivacy(ptr);
 	pattrib->order = GetOrder(ptr);
-{
-	u8 bDumpRxPkt;
 	rtw_hal_get_def_var(adapter, HAL_DEF_DBG_DUMP_RXPKT, &(bDumpRxPkt));
 	if (bDumpRxPkt == 1) /* dump all rx packets */
 		dump_rx_packet(ptr);
@@ -1553,7 +1549,6 @@ sint validate_recv_frame(struct adapter *adapter, union recv_frame *precv_frame)
 		dump_rx_packet(ptr);
 	else if ((bDumpRxPkt == 3) && (type == WIFI_DATA_TYPE))
 		dump_rx_packet(ptr);
-}
 
 	switch (type) {
 	case WIFI_MGT_TYPE: /* mgnt */
-- 
2.12.0
