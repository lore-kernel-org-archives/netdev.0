From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for orinoco
Date: Tue, 29 Aug 2006 18:02:31 -0700
Message-ID: <20060830010231.GG8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:1472 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932143AbWH3BGM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:06:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for Orinoco driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/orinoco.20.c linux/drivers/net/wireless/orinoco.c
--- linux/drivers/net/wireless/orinoco.20.c	2006-08-28 17:37:19.000000000 -0700
+++ linux/drivers/net/wireless/orinoco.c	2006-08-28 17:37:26.000000000 -0700
@@ -3036,7 +3036,7 @@ static int orinoco_ioctl_getessid(struct
 	}
 
 	erq->flags = 1;
-	erq->length = strlen(essidbuf) + 1;
+	erq->length = strlen(essidbuf);
 
 	return 0;
 }
@@ -3077,7 +3077,7 @@ static int orinoco_ioctl_getnick(struct 
 	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
 	orinoco_unlock(priv, &flags);
 
-	nrq->length = strlen(nickbuf)+1;
+	nrq->length = strlen(nickbuf);
 
 	return 0;
 }
@@ -3574,14 +3574,14 @@ static int orinoco_ioctl_getretry(struct
 		rrq->value = lifetime * 1000;	/* ??? */
 	} else {
 		/* By default, display the min number */
-		if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = long_limit;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = short_limit;
 			if(short_limit != long_limit)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 
