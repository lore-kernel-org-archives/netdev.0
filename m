From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH] orinoco: fix setting power management parameters
Date: Tue, 29 Nov 2005 02:59:27 -0500
Message-ID: <1133251167.27750.93.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Power management parameters could not be set by iwconfig due to
incorrect error handling.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

---
This is a very simple bugfix, and the bug is serious enough, so I'll
appreciate if the patch gets priority handling and goes to 2.6.15.  I
have lots of other stuff that can wait until 2.6.16.

diff --git a/drivers/net/wireless/orinoco.c
b/drivers/net/wireless/orinoco.c
index 2032c56..708b146 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -3492,9 +3492,8 @@ static int orinoco_ioctl_setpower(struct
 			break;
 		default:
 			err = -EINVAL;
-		}
-		if (err)
 			goto out;
+		}
 		
 		if (prq->flags & IW_POWER_TIMEOUT) {
 			priv->pm_on = 1;



-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
