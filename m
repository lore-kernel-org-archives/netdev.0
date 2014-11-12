From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] amd-xgbe: fix ->rss_hash_type
Date: Wed, 12 Nov 2014 11:31:35 +0300
Message-ID: <20141112083135.GA12795@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45255 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbaKLIbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 03:31:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a missing break statement so we set everything to
PKT_HASH_TYPE_L3 even when we intended to use PKT_HASH_TYPE_L4.

Fixes: 5b9dfe299e55 ('amd-xgbe: Provide support for receive side scaling')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This driver has a lot of Sparse endian warnings.
http://lwn.net/Articles/205624/

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 7daa2cd..55ba1dc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1601,6 +1601,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		case RX_DESC3_L34T_IPV6_UDP:
 			packet->rss_hash_type = PKT_HASH_TYPE_L4;
 
+			break;
 		default:
 			packet->rss_hash_type = PKT_HASH_TYPE_L3;
 		}
