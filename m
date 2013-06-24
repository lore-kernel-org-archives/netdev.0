From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] qeth: Increase default MTU for OSA devices
Date: Mon, 24 Jun 2013 13:21:49 +0200
Message-ID: <20130624112226.544988561@de.ibm.com>
References: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:51399 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab3FXLWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:31 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:17:38 +0100
Content-Disposition: inline; filename=601-qeth-default-mtu.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Increase the default MTU for real OSA devices in layer 2 mode
to 1500 Bytes for increased compatibility.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2198,11 +2198,11 @@ static inline int qeth_get_initial_mtu_f
 		case QETH_LINK_TYPE_LANE_TR:
 			return 2000;
 		default:
-			return 1492;
+			return card->options.layer2 ? 1500 : 1492;
 		}
 	case QETH_CARD_TYPE_OSM:
 	case QETH_CARD_TYPE_OSX:
-		return 1492;
+		return card->options.layer2 ? 1500 : 1492;
 	default:
 		return 1500;
 	}
@@ -2275,9 +2275,10 @@ static int qeth_ulp_enable_cb(struct qet
 		card->info.max_mtu = mtu;
 		card->qdio.in_buf_size = mtu + 2 * PAGE_SIZE;
 	} else {
-		card->info.initial_mtu = qeth_get_initial_mtu_for_card(card);
 		card->info.max_mtu = *(__u16 *)QETH_ULP_ENABLE_RESP_MAX_MTU(
 			iob->data);
+		card->info.initial_mtu = min(card->info.max_mtu,
+					qeth_get_initial_mtu_for_card(card));
 		card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
 	}
 
