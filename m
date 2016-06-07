From: vidya@cumulusnetworks.com
Subject: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636 Memory map max sizes
Date: Mon,  6 Jun 2016 22:55:26 -0700
Message-ID: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com
To: bwh@kernel.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34861 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcFGFzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 01:55:33 -0400
Received: by mail-pa0-f50.google.com with SMTP id xk1so42649340pac.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 22:55:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch provides macro definitions for maximum possible
memory map size of QSFP+/QSFP28 EEPROMs as per SFF-8436/SFF-8636

According to SFF-8436/SFF-8636 specs, the common memory map for
managing external cable interfaces is arranged into a single
lower page address space of 128 bytes and multiple upper address pages
of 128 bytes each. The total size of memory map is up to 5 128 byte pages
defined by a "pages valid" register and switched via a "page select"
register for "optional pages". Memory of 256 bytes can be memory mapped
at a time and QSFP+/QSFP28  drivers can export upto 5*128 bytes of
eeprom dump.

QSFP+/QSFP28 Memory layout
           2-Wire Serial Address: 1010000x
           Lower Page 00h (128 bytes)
           ======================
           |Page Select Byte(127)|
           ======================
                    |
                    V
       ----------------------------------------
      |             |            |             |
      V             V            V             V
   ----------   ----------   ---------    ------------
  | Upper    | | Upper    | | Upper    | | Upper      |
  | Page 00h | | Page 01h | | Page 02h | | Page 03h   |
  |          | |(Optional)| |(Optional)| | (Optional) |
  |    ID    | |   AST    | |  User    | |  For       |
  |  Fields  | |  Table   | | EEPROM   | |  Cable     |
  -----------  -----------   ----------  --------------

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 include/uapi/linux/ethtool.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f030b4..ff6ccbd 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1584,9 +1584,15 @@ static inline int ethtool_validate_duplex(__u8 duplex)
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
 #define ETH_MODULE_SFF_8636		0x3
+/* min, without optional page */
 #define ETH_MODULE_SFF_8636_LEN		256
+/* max, with all optional pages */
+#define ETH_MODULE_SFF_8636_MAX_LEN		640
 #define ETH_MODULE_SFF_8436		0x4
+/* min, without optional page */
 #define ETH_MODULE_SFF_8436_LEN		256
+/* max, with all optional pages */
+#define ETH_MODULE_SFF_8436_MAX_LEN		640
 
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
-- 
2.1.4
