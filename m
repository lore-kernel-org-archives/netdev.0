From: frank.blaschka@de.ibm.com
Subject: [patch 1/7] [PATCH] qeth: show new mac-address if its setting fails
Date: Tue, 01 Feb 2011 09:16:48 +0100
Message-ID: <20110201081723.256273806@de.ibm.com>
References: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:51884 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab1BAIRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:17:38 -0500
Content-Disposition: inline; filename=604-qeth-mac-address.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Setting of a MAC-address may fail because an already used MAC-address
is to bet set or because of authorization problems. In those cases
qeth issues a message, but the mentioned MAC-address is not the
new MAC-address to be set, but the actual MAC-address. This patch
chooses now the new MAC-address to be set for the error messages.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_l2_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -573,13 +573,13 @@ static int qeth_l2_send_setmac_cb(struct
 		case IPA_RC_L2_DUP_LAYER3_MAC:
 			dev_warn(&card->gdev->dev,
 				"MAC address %pM already exists\n",
-				card->dev->dev_addr);
+				cmd->data.setdelmac.mac);
 			break;
 		case IPA_RC_L2_MAC_NOT_AUTH_BY_HYP:
 		case IPA_RC_L2_MAC_NOT_AUTH_BY_ADP:
 			dev_warn(&card->gdev->dev,
 				"MAC address %pM is not authorized\n",
-				card->dev->dev_addr);
+				cmd->data.setdelmac.mac);
 			break;
 		default:
 			break;

