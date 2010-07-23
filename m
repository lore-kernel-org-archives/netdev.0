From: frank.blaschka@de.ibm.com
Subject: [patch 6/8] [PATCH] qeth: return zero from reply callback functions
Date: Fri, 23 Jul 2010 11:15:08 +0200
Message-ID: <20100723091550.425248000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:43304 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=617-qeth-reply-callback.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Reply callback functions in qeth should return zero if command
response consists of one part only, otherwise qeth continues
waiting for further parts of the command response.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:36.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:36.000000000 +0200
@@ -1996,7 +1996,7 @@ static int qeth_ulp_setup_cb(struct qeth
 		QETH_DBF_TEXT(SETUP, 2, "olmlimit");
 		dev_err(&card->gdev->dev, "A connection could not be "
 			"established because of an OLM limit\n");
-		rc = -EMLINK;
+		iob->rc = -EMLINK;
 	}
 	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return rc;
@@ -3423,7 +3423,6 @@ static int qeth_setadpparms_set_access_c
 {
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_set_access_ctrl *access_ctrl_req;
-	int rc;
 
 	QETH_CARD_TEXT(card, 4, "setaccb");
 
@@ -3450,7 +3449,6 @@ static int qeth_setadpparms_set_access_c
 			card->gdev->dev.kobj.name,
 			access_ctrl_req->subcmd_code,
 			cmd->data.setadapterparms.hdr.return_code);
-		rc = 0;
 		break;
 	}
 	case SET_ACCESS_CTRL_RC_NOT_SUPPORTED:
@@ -3464,7 +3462,6 @@ static int qeth_setadpparms_set_access_c
 
 		/* ensure isolation mode is "none" */
 		card->options.isolation = ISOLATION_MODE_NONE;
-		rc = -EOPNOTSUPP;
 		break;
 	}
 	case SET_ACCESS_CTRL_RC_NONE_SHARED_ADAPTER:
@@ -3479,7 +3476,6 @@ static int qeth_setadpparms_set_access_c
 
 		/* ensure isolation mode is "none" */
 		card->options.isolation = ISOLATION_MODE_NONE;
-		rc = -EOPNOTSUPP;
 		break;
 	}
 	case SET_ACCESS_CTRL_RC_ACTIVE_CHECKSUM_OFF:
@@ -3493,7 +3489,6 @@ static int qeth_setadpparms_set_access_c
 
 		/* ensure isolation mode is "none" */
 		card->options.isolation = ISOLATION_MODE_NONE;
-		rc = -EPERM;
 		break;
 	}
 	default:
@@ -3507,12 +3502,11 @@ static int qeth_setadpparms_set_access_c
 
 		/* ensure isolation mode is "none" */
 		card->options.isolation = ISOLATION_MODE_NONE;
-		rc = 0;
 		break;
 	}
 	}
 	qeth_default_setadapterparms_cb(card, reply, (unsigned long) cmd);
-	return rc;
+	return 0;
 }
 
 static int qeth_setadpparms_set_access_ctrl(struct qeth_card *card,

