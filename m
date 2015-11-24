From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH 3/4] staging: rtl8712: Make error handling check for failure
Date: Tue, 24 Nov 2015 10:19:41 -0200
Message-ID: <1448367582-8041-4-git-send-email-mukadr@gmail.com>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
 gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
 netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Some error handling paths are checking for success
instead of error on rtl871x_ioctl_rtl.c.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 239 ++++++++++++++--------------
 1 file changed, 121 insertions(+), 118 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
index 97596aa..9317370 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_rtl.c
@@ -53,13 +53,13 @@ uint oid_rt_get_small_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
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
+	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_smallpacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -69,13 +69,13 @@ uint oid_rt_get_middle_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
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
+	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_middlepacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -85,13 +85,13 @@ uint oid_rt_get_large_packet_crc_hdl(struct oid_par_priv *poid_par_priv)
 
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
+	*(u32 *)poid_par_priv->information_buf = adapter->recvpriv.rx_largepacket_crcerr;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -116,14 +116,14 @@ uint oid_rt_get_rx_total_packet_hdl(struct oid_par_priv *poid_par_priv)
 
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
 
@@ -147,13 +147,13 @@ uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
 
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
 
@@ -172,18 +172,20 @@ uint oid_rt_get_preamble_mode_hdl(struct oid_par_priv *poid_par_priv)
 
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
 
@@ -201,8 +203,10 @@ uint oid_rt_get_channelplan_hdl(struct oid_par_priv *poid_par_priv)
 
 	if (poid_par_priv->type_of_oid != QUERY_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
+
 	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
 	*(u16 *)poid_par_priv->information_buf = peeprompriv->channel_plan;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -214,7 +218,9 @@ uint oid_rt_set_channelplan_hdl(struct oid_par_priv
 
 	if (poid_par_priv->type_of_oid != SET_OID)
 		return RNDIS_STATUS_NOT_ACCEPTED;
+
 	peeprompriv->channel_plan = *(u16 *)poid_par_priv->information_buf;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -226,19 +232,21 @@ uint oid_rt_set_preamble_mode_hdl(struct oid_par_priv
 
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
 
@@ -262,13 +270,13 @@ uint oid_rt_get_total_tx_bytes_hdl(struct oid_par_priv
 
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
 
@@ -279,14 +287,13 @@ uint oid_rt_get_total_rx_bytes_hdl(struct oid_par_priv
 
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
 
@@ -355,15 +362,16 @@ uint oid_rt_supported_wireless_mode_hdl(struct oid_par_priv
 
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
+	*(u32 *) poid_par_priv->information_buf = ulInfo;
+	*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
+
 	return RNDIS_STATUS_SUCCESS;
 }
 
@@ -436,61 +444,56 @@ uint oid_rt_ap_set_passphrase_hdl(struct oid_par_priv *poid_par_priv)
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
-			*(unsigned char *)poid_par_priv->information_buf,
-			(unsigned long)(*((unsigned long *)
-					poid_par_priv->information_buf + 2))))
-			status = RNDIS_STATUS_NOT_ACCEPTED;
-	} else {
-		status = RNDIS_STATUS_INVALID_LENGTH;
-	}
-	return status;
+
+	if (poid_par_priv->information_buf_len != (sizeof(unsigned long) * 3))
+		return RNDIS_STATUS_INVALID_LENGTH;
+
+	if (!r8712_setrfreg_cmd(adapter,
+	    *(unsigned char *)poid_par_priv->information_buf,
+	    (unsigned long)(*((unsigned long *)poid_par_priv->information_buf + 2))))
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
+	if (poid_par_priv->information_buf_len != (sizeof(unsigned long) * 3))
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
+	    *(unsigned char *)poid_par_priv->information_buf,
+	    (unsigned char *)&adapter->mppriv.workparam.io_value))
+		return RNDIS_STATUS_NOT_ACCEPTED;
+
+	return RNDIS_STATUS_SUCCESS;
 }
 
 enum _CONNECT_STATE_ {
-- 
2.6.3
