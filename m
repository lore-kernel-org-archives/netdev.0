From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH v2 net-next 3/6] bnx2x: add Big-Endian ethtool comment
Date: Thu, 26 Dec 2013 09:57:09 +0200
Message-ID: <1388044632-9172-4-git-send-email-yuvalmin@broadcom.com>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:47794 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab3LZH5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 02:57:19 -0500
In-Reply-To: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a known issue that using `ethtool -e' flips the endianity of the
written data, i.e., using `ethtool -E' to dump eeprom image and than using
`ethtool -e' to re-write that same image will result in an image where
the data has the opposite endianity. 
Sadly, this cannot be fixed as there are already various tools deployed
based on the endianity of the eeprom read/write.
Instead, a comment is added to the code to help explain why this is un-fixable.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 32d0f14..92a467f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1639,6 +1639,12 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 
 		memcpy(&val, data_buf, 4);
 
+		/* Notice unlike bnx2x_nvram_read_dword() this will not
+		 * change val using be32_to_cpu(), which causes data to flip
+		 * if the eeprom is read and then written back. This is due
+		 * to tools utilizing this functionality that would break
+		 * if this would be resolved.
+		 */
 		rc = bnx2x_nvram_write_dword(bp, offset, val, cmd_flags);
 
 		/* advance to the next dword */
-- 
1.8.1.227.g44fe835
