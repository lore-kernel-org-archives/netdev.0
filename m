From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] ctcm: avoid crash in ctcm_remove_device
Date: Wed, 20 May 2009 09:38:38 +0200
Message-ID: <20090520073927.823275000@de.ibm.com>
References: <20090520073836.897878000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:57092 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbZETHj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:39:28 -0400
Content-Disposition: inline; filename=613-ctcm-remove-crash.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Channels are already removed when setting a ctcm-device offline.
Thus ctcm_remove_device must not refer to channel information.
Solution: delete channel information from the trace call in
ctcm_remove_device.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-05-20 08:56:25.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-05-20 08:56:42.000000000 +0200
@@ -1677,10 +1677,8 @@ static void ctcm_remove_device(struct cc
 	BUG_ON(priv == NULL);
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
-			"removing device %s, r/w = %s/%s, proto : %d",
-			priv->channel[READ]->netdev->name,
-			priv->channel[READ]->id, priv->channel[WRITE]->id,
-			priv->protocol);
+			"removing device %p, proto : %d",
+			cgdev, priv->protocol);
 
 	if (cgdev->state == CCWGROUP_ONLINE)
 		ctcm_shutdown_device(cgdev);

