From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2 -next] amd-xgbe: fix ->rss_hash_type
Date: Thu, 13 Nov 2014 09:19:06 +0300
Message-ID: <20141113061905.GA1280@mwanda>
References: <20141112.150459.233340605780805877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40536 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaKMGTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 01:19:20 -0500
Content-Disposition: inline
In-Reply-To: <20141112.150459.233340605780805877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a missing break statement so we set everything to
PKT_HASH_TYPE_L3 even when we intended to use PKT_HASH_TYPE_L4.

Fixes: 5b9dfe299e55 ('amd-xgbe: Provide support for receive side scaling')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: remove blank line

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 7daa2cd..f6014d3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1600,7 +1600,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		case RX_DESC3_L34T_IPV6_TCP:
 		case RX_DESC3_L34T_IPV6_UDP:
 			packet->rss_hash_type = PKT_HASH_TYPE_L4;
-
+			break;
 		default:
 			packet->rss_hash_type = PKT_HASH_TYPE_L3;
 		}
