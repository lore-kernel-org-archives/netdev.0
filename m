From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 1/2] orinoco_nortel: Fix incorrect PCI resource use
Date: Fri, 16 Dec 2005 18:49:53 -0500
Message-ID: <1134776993.2228.6.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tomas Novak <tap-SgvXgqTD8kc@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
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

orinoco_nortel was broken during conversion to iomem API.  Wrong PCI BAR
is used for chipset registers.  Reported by Tomas Novak <tap-SgvXgqTD8kc@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

---
Please push to 2.6.15 or 2.6.15.x.  We don't want broken drivers in the
kernel.

diff --git a/drivers/net/wireless/orinoco_nortel.c
b/drivers/net/wireless/orinoco_nortel.c
index d8afd51..d1a670b 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -165,7 +167,7 @@ static int nortel_pci_init_one(struct pc
 		goto fail_resources;
 	}
 
-	iomem = pci_iomap(pdev, 3, 0);
+	iomem = pci_iomap(pdev, 2, 0);
 	if (!iomem) {
 		err = -ENOMEM;
 		goto fail_map_io;


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
