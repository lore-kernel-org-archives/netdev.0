From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] wireless: mwifiex: remove unreachable paths
Date: Thu, 20 Dec 2012 14:11:25 -0500
Message-ID: <1356030701-16284-17-git-send-email-sasha.levin@oracle.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
To: Bing Zhao <bzhao@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21542 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab2LTTNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 14:13:55 -0500
In-Reply-To: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We know 'firmware' is non-NULL from the beginning of mwifiex_prog_fw_w_helper,
remove all !firmware paths from the rest of the function.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/net/wireless/mwifiex/usb.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
index 63ac9f2..8bd7098 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -836,23 +836,14 @@ static int mwifiex_prog_fw_w_helper(struct mwifiex_adapter *adapter,
 			dlen = 0;
 		} else {
 			/* copy the header of the fw_data to get the length */
-			if (firmware)
-				memcpy(&fwdata->fw_hdr, &firmware[tlen],
-				       sizeof(struct fw_header));
-			else
-				mwifiex_get_fw_data(adapter, tlen,
-						    sizeof(struct fw_header),
-						    (u8 *)&fwdata->fw_hdr);
+			memcpy(&fwdata->fw_hdr, &firmware[tlen],
+			       sizeof(struct fw_header));
 
 			dlen = le32_to_cpu(fwdata->fw_hdr.data_len);
 			dnld_cmd = le32_to_cpu(fwdata->fw_hdr.dnld_cmd);
 			tlen += sizeof(struct fw_header);
 
-			if (firmware)
-				memcpy(fwdata->data, &firmware[tlen], dlen);
-			else
-				mwifiex_get_fw_data(adapter, tlen, dlen,
-						    (u8 *)fwdata->data);
+			memcpy(fwdata->data, &firmware[tlen], dlen);
 
 			fwdata->seq_num = cpu_to_le32(fw_seqnum);
 			tlen += dlen;
-- 
1.8.0
