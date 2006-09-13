From: bora.sahin@ttnet.net.tr
Subject: [PATCH 2/12] smc911x: Fix SMC_WRITE_EEPROM_CMD macro
Date: Wed, 13 Sep 2006 20:53:57 +0300
Message-ID: <200609132053.57258.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:21370 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751048AbWIMSes
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:34:48 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


SMC_WRITE_EEPROM_CMD macro is wrong

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.h
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.h	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.h	2006-08-24 12:23:10.000000000 +0300
@@ -827,9 +828,13 @@
 
 #define SMC_WRITE_EEPROM_CMD(cmd, addr)					\
 	do {								\
-		while (SMC_GET_E2P_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_R_NOT_W_ | a );		\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
+		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
+			cpu_relax();					\
+		SMC_SET_E2P_DATA((v) & 0xFF);				\
+		SMC_SET_E2P_CMD(E2P_CMD_EPC_BUSY_ | 			\
+				(cmd) << 28 | ((addr) & 0xFF));		\
+		while (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)		\
+			cpu_relax();					\
 	} while (0)
 
 #endif	 /* _SMC911X_H_ */
