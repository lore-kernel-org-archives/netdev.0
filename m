From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 03/15] fcoe: Use CHECKSUM_PARTIAL to indicate CRC offload
Date: Thu, 19 Nov 2015 11:55:49 -0800
Message-ID: <1447962961-2106059-4-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:10359 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759162AbbKST4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:14 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJsvn9016186
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:13 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6vxd7a-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:13 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 95d8016e8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:12 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting up CRC offload set ip_summed to CHECKSUM_PARTIAL
instead of CHECKSUM_UNNECESSARY. This is consistent with the
definition of CHECKSUM_PARTIAL.

The only driver that seems to be advertising NETIF_F_FCOE_CRC is
ixgbe. AFICT the driver does not look at ip_summed for FCOE and
just assumes that CRC is being offloaded.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/scsi/fcoe/fcoe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index f442406..0efe711 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1625,7 +1625,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 
 	/* crc offload */
 	if (likely(lport->crc_offload)) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_headroom(skb);
 		skb->csum_offset = skb->len;
 		crc = 0;
-- 
2.4.6
