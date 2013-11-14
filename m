From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdnloop: use strlcpy() instead of strcpy()
Date: Thu, 14 Nov 2013 11:21:10 +0300
Message-ID: <20131114082110.GD8150@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These strings come from a copy_from_user() and there is no way to be
sure they are NUL terminated.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index baf2686..02125e6 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -1083,8 +1083,10 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
 			spin_unlock_irqrestore(&card->isdnloop_lock, flags);
 			return -ENOMEM;
 		}
-		for (i = 0; i < 3; i++)
-			strcpy(card->s0num[i], sdef.num[i]);
+		for (i = 0; i < 3; i++) {
+			strlcpy(card->s0num[i], sdef.num[i],
+				sizeof(card->s0num[0]));
+		}
 		break;
 	case ISDN_PTYPE_1TR6:
 		if (isdnloop_fake(card, "DRV1.04TC-1TR6-CAPI-CNS-BASIS-29.11.95",
@@ -1097,7 +1099,7 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
 			spin_unlock_irqrestore(&card->isdnloop_lock, flags);
 			return -ENOMEM;
 		}
-		strcpy(card->s0num[0], sdef.num[0]);
+		strlcpy(card->s0num[0], sdef.num[0], sizeof(card->s0num[0]));
 		card->s0num[1][0] = '\0';
 		card->s0num[2][0] = '\0';
 		break;
