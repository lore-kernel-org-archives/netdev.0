From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix scaling error for 'iwlist freq' information
Date: Tue, 23 Jan 2007 16:43:26 -0600
Message-ID: <45b68f8e.m8+Bl9ZfRL/zvhGv%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The bcm43xx driver returns the available frequencies to 'iwlist freq' with the wrong scaling.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This is to be applied to wireless-2.6. It could also be sent upstream to 2.6.20,
but it is not very important.

Larry
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -286,7 +286,7 @@ static int bcm43xx_wx_get_rangeparams(st
 		if (j == IW_MAX_FREQUENCIES)
 			break;
 		range->freq[j].i = j + 1;
-		range->freq[j].m = geo->a[i].freq;//FIXME?
+		range->freq[j].m = geo->a[i].freq * 100000;
 		range->freq[j].e = 1;
 		j++;
 	}
@@ -294,7 +294,7 @@ static int bcm43xx_wx_get_rangeparams(st
 		if (j == IW_MAX_FREQUENCIES)
 			break;
 		range->freq[j].i = j + 1;
-		range->freq[j].m = geo->bg[i].freq;//FIXME?
+		range->freq[j].m = geo->bg[i].freq * 100000;
 		range->freq[j].e = 1;
 		j++;
 	}

---
