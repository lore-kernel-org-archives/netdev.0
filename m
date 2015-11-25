From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH v2 3/4] staging: rtl8712: Make error handling check for failure
Date: Wed, 25 Nov 2015 15:42:41 -0200
Message-ID: <1448473362-12524-4-git-send-email-mukadr@gmail.com>
References: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33189 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbKYRqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 12:46:50 -0500
Received: by qgea14 with SMTP id a14so37316076qge.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 09:46:49 -0800 (PST)
In-Reply-To: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make all error handling paths check for failure instead of success
in rtl871x_ioctl_rtl.c, reducing indentation and avoiding else
statements.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 239 +++++++++++++++-------------
 1 file changed, 124 insertions(+), 115 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
index 97596aa..3f1fa12 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
@@ -53,13 +53,14 @@ uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-				adapter->recvpriv.rx_smallpacket_crcerr;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf =
+		adapter->recvpriv.rx_smallpacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -69,13 +70,14 @@ uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-				adapter->recvpriv.rx_middlepacket_crcerr;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf =
+		adapter->recvpriv.rx_middlepacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -85,13 +87,14 @@ uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-				 adapter->recvpriv.rx_largepacket_crcerr;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf =
+		adapter->recvpriv.rx_largepacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -116,14 +119,14 @@ uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >=  sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-					 adapter->recvpriv.rx_pkts +
-					 adapter->recvpriv.rx_drop;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf =
+			adapter->recvpriv.rx_pkts + adapter->recvpriv.rx_drop;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -147,13 +150,13 @@ uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		*(uint *)poid_par_priv->information_buf =
-					 adapter->recvpriv.rx_icv_err;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(uint *)poid_par_priv->information_buf = adapter->recvpriv.rx_icv_err;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -172,18 +175,20 @@ uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		if (adapter->registrypriv.preamble == PREAMBLE_LONG)
-			preamblemode = 0;
-		else if (adapter->registrypriv.preamble == PREAMBLE_AUTO)
-			preamblemode = 1;
-		else if (adapter->registrypriv.preamble == PREAMBLE_SHORT)
-			preamblemode = 2;
-		*(u32 *)poid_par_priv->information_buf = preamblemode;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	if (adapter->registrypriv.preamble == PREAMBLE_LONG)
+		preamblemode = 0;
+	else if (adapter->registrypriv.preamble == PREAMBLE_AUTO)
+		preamblemode = 1;
+	else if (adapter->registrypriv.preamble == PREAMBLE_SHORT)
+		preamblemode = 2;
+
+	*(u32 *)poid_par_priv->information_buf = preamblemode;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -201,8 +206,10 @@ uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
+
 	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	*(u16 *)poid_par_priv->information_buf = peeprompriv->channel_plan;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -214,7 +221,9 @@ uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
+
 	peeprompriv->channel_plan = *(u16 *)poid_par_priv->information_buf;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -226,19 +235,21 @@ uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		preamblemode = *(u32 *)poid_par_priv->information_buf;
-		if (preamblemode == 0)
-			adapter->registrypriv.preamble = PREAMBLE_LONG;
-		else if (preamblemode == 1)
-			adapter->registrypriv.preamble = PREAMBLE_AUTO;
-		else if (preamblemode == 2)
-			adapter->registrypriv.preamble = PREAMBLE_SHORT;
-		*(u32 *)poid_par_priv->information_buf = preamblemode;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	preamblemode = *(u32 *)poid_par_priv->information_buf;
+	if (preamblemode == 0)
+		adapter->registrypriv.preamble = PREAMBLE_LONG;
+	else if (preamblemode == 1)
+		adapter->registrypriv.preamble = PREAMBLE_AUTO;
+	else if (preamblemode == 2)
+		adapter->registrypriv.preamble = PREAMBLE_SHORT;
+
+	*(u32 *)poid_par_priv->information_buf = preamblemode;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -262,13 +273,13 @@ uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-						 adapter->xmitpriv.tx_bytes;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf = adapter->xmitpriv.tx_bytes;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -279,14 +290,13 @@ uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		*(u32 *)poid_par_priv->information_buf =
-					   adapter->recvpriv.rx_bytes;
-		*poid_par_priv->bytes_rw = poid_par_priv->
-					   information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_bytes;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -355,15 +365,16 @@ uint oid_rt_supported_wireless_mode_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
-		ulInfo |= 0x0100; /* WIRELESS_MODE_B */
-		ulInfo |= 0x0200; /* WIRELESS_MODE_G */
-		ulInfo |= 0x0400; /* WIRELESS_MODE_A */
-		*(u32 *) poid_par_priv->information_buf = ulInfo;
-		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
-	} else {
+
+	if (poid_par_priv->information_buf_len < sizeof(u32))
 		return RNDIS_STATUS_INVALID_LENGTH;
-	}
+
+	ulInfo |= 0x0100; /* WIRELESS_MODE_B */
+	ulInfo |= 0x0200; /* WIRELESS_MODE_G */
+	ulInfo |= 0x0400; /* WIRELESS_MODE_A */
+	*(u32 *)poid_par_priv->information_buf = ulInfo;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -436,61 +447,57 @@ uint oid_rt_ap_set_passphrase_hdl(struct oid_par_priv *poid_par_priv)
 uint oid_rt_pro_rf_write_registry_hdl(struct oid_par_priv*
 					     poid_par_priv)
 {
-	uint status = RNDIS_STATUS_SUCCESS;
 	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len ==
-	   (sizeof(unsigned long) * 3)) {
-		if (!r8712_setrfreg_cmd(adapter,
+
+	if (poid_par_priv->information_buf_len != sizeof(unsigned long) * 3)
+		return RNDIS_STATUS_INVALID_LENGTH;
+
+	if (!r8712_setrfreg_cmd(adapter,
 			*(unsigned char *)poid_par_priv->information_buf,
 			(unsigned long)(*((unsigned long *)
 					poid_par_priv->information_buf + 2))))
-			status = RNDIS_STATUS_NOT_ACCEPTED;
-	} else {
-		status = RNDIS_STATUS_INVALID_LENGTH;
-	}
-	return status;
+		return RNDIS_STATUS_NOT_ACCEPTED;
+
+	return RNDIS_STATUS_SUCCESS;
 }
 
 uint oid_rt_pro_rf_read_registry_hdl(struct oid_par_priv *poid_par_priv)
 {
-	uint status = RNDIS_STATUS_SUCCESS;
 	struct _adapter *adapter = poid_par_priv->adapter_context;
 
 	if (poid_par_priv->type_of_oid != SET_OID) /* QUERY_OID */
 		return RNDIS_STATUS_NOT_ACCEPTED;
-	if (poid_par_priv->information_buf_len == (sizeof(unsigned long) *
-						   3)) {
-		if (adapter->mppriv.act_in_progress) {
-			status = RNDIS_STATUS_NOT_ACCEPTED;
-		} else {
-			/* init workparam */
-			adapter->mppriv.act_in_progress = true;
-			adapter->mppriv.workparam.bcompleted = false;
-			adapter->mppriv.workparam.act_type = MPT_READ_RF;
-			adapter->mppriv.workparam.io_offset = *(unsigned long *)
-						poid_par_priv->information_buf;
-			adapter->mppriv.workparam.io_value = 0xcccccccc;
-
-		/* RegOffsetValue	- The offset of RF register to read.
-		 * RegDataWidth	- The data width of RF register to read.
-		 * RegDataValue	- The value to read.
-		 * RegOffsetValue = *((unsigned long *)InformationBuffer);
-		 * RegDataWidth = *((unsigned long *)InformationBuffer+1);
-		 * RegDataValue =  *((unsigned long *)InformationBuffer+2);
-		 */
-			if (!r8712_getrfreg_cmd(adapter,
-			    *(unsigned char *)poid_par_priv->information_buf,
-			    (unsigned char *)&adapter->mppriv.workparam.
-			    io_value))
-				status = RNDIS_STATUS_NOT_ACCEPTED;
-		}
-	} else {
-		status = RNDIS_STATUS_INVALID_LENGTH;
-	}
-	return status;
+
+	if (poid_par_priv->information_buf_len != sizeof(unsigned long) * 3)
+		return RNDIS_STATUS_INVALID_LENGTH;
+
+	if (adapter->mppriv.act_in_progress)
+		return RNDIS_STATUS_NOT_ACCEPTED;
+
+	/* init workparam */
+	adapter->mppriv.act_in_progress = true;
+	adapter->mppriv.workparam.bcompleted = false;
+	adapter->mppriv.workparam.act_type = MPT_READ_RF;
+	adapter->mppriv.workparam.io_offset = *(unsigned long *)
+				poid_par_priv->information_buf;
+	adapter->mppriv.workparam.io_value = 0xcccccccc;
+
+	/* RegOffsetValue	- The offset of RF register to read.
+	 * RegDataWidth	- The data width of RF register to read.
+	 * RegDataValue	- The value to read.
+	 * RegOffsetValue = *((unsigned long *)InformationBuffer);
+	 * RegDataWidth = *((unsigned long *)InformationBuffer+1);
+	 * RegDataValue =  *((unsigned long *)InformationBuffer+2);
+	 */
+	if (!r8712_getrfreg_cmd(adapter,
+			*(unsigned char *)poid_par_priv->information_buf,
+			(unsigned char *)&adapter->mppriv.workparam.io_value))
+		return RNDIS_STATUS_NOT_ACCEPTED;
+
+	return RNDIS_STATUS_SUCCESS;
 }
 
 enum _CONNECT_STATE_ {
@@ -521,8 +528,10 @@ uint oid_rt_get_connect_state_hdl(struct oid_par_priv *poid_par_priv)
 		ulInfo = ADHOCMODE;
 	else
 		ulInfo = NOTASSOCIATED;
+
 	*(u32 *)poid_par_priv->information_buf = ulInfo;
 	*poid_par_priv->bytes_rw =  poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
-- 
2.6.3
