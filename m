From: akpm@osdl.org
Subject: [patch 8/9] rfcomm endianness bug: param_mask is little-endian on the wire
Date: Wed, 08 Nov 2006 19:51:10 -0800
Message-ID: <200611090351.kA93pApj003699@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, viro@ftp.linux.org.uk,
	marcel@holtmann.org, viro@zeniv.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21679 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161209AbWKIDvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:23 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/bluetooth/rfcomm/core.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff -puN net/bluetooth/rfcomm/core.c~rfcomm-endianness-bug-param_mask-is-little-endian-on-the-wire net/bluetooth/rfcomm/core.c
--- a/net/bluetooth/rfcomm/core.c~rfcomm-endianness-bug-param_mask-is-little-endian-on-the-wire
+++ a/net/bluetooth/rfcomm/core.c
@@ -854,7 +854,7 @@ int rfcomm_send_rpn(struct rfcomm_sessio
 	rpn->flow_ctrl     = flow_ctrl_settings;
 	rpn->xon_char      = xon_char;
 	rpn->xoff_char     = xoff_char;
-	rpn->param_mask    = param_mask;
+	rpn->param_mask    = cpu_to_le16(param_mask);
 
 	*ptr = __fcs(buf); ptr++;
 
@@ -1343,7 +1343,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 	/* Check for sane values, ignore/accept bit_rate, 8 bits, 1 stop bit,
 	 * no parity, no flow control lines, normal XON/XOFF chars */
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_BITRATE) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_BITRATE)) {
 		bit_rate = rpn->bit_rate;
 		if (bit_rate != RFCOMM_RPN_BR_115200) {
 			BT_DBG("RPN bit rate mismatch 0x%x", bit_rate);
@@ -1352,7 +1352,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_DATA) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_DATA)) {
 		data_bits = __get_rpn_data_bits(rpn->line_settings);
 		if (data_bits != RFCOMM_RPN_DATA_8) {
 			BT_DBG("RPN data bits mismatch 0x%x", data_bits);
@@ -1361,7 +1361,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_STOP) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_STOP)) {
 		stop_bits = __get_rpn_stop_bits(rpn->line_settings);
 		if (stop_bits != RFCOMM_RPN_STOP_1) {
 			BT_DBG("RPN stop bits mismatch 0x%x", stop_bits);
@@ -1370,7 +1370,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_PARITY) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_PARITY)) {
 		parity = __get_rpn_parity(rpn->line_settings);
 		if (parity != RFCOMM_RPN_PARITY_NONE) {
 			BT_DBG("RPN parity mismatch 0x%x", parity);
@@ -1379,7 +1379,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_FLOW) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_FLOW)) {
 		flow_ctrl = rpn->flow_ctrl;
 		if (flow_ctrl != RFCOMM_RPN_FLOW_NONE) {
 			BT_DBG("RPN flow ctrl mismatch 0x%x", flow_ctrl);
@@ -1388,7 +1388,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_XON) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XON)) {
 		xon_char = rpn->xon_char;
 		if (xon_char != RFCOMM_RPN_XON_CHAR) {
 			BT_DBG("RPN XON char mismatch 0x%x", xon_char);
@@ -1397,7 +1397,7 @@ static int rfcomm_recv_rpn(struct rfcomm
 		}
 	}
 
-	if (rpn->param_mask & RFCOMM_RPN_PM_XOFF) {
+	if (rpn->param_mask & cpu_to_le16(RFCOMM_RPN_PM_XOFF)) {
 		xoff_char = rpn->xoff_char;
 		if (xoff_char != RFCOMM_RPN_XOFF_CHAR) {
 			BT_DBG("RPN XOFF char mismatch 0x%x", xoff_char);
_
