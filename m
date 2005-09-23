From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 5/8] orinoco: Remove unneeded forward declarations.
Date: Fri, 23 Sep 2005 04:18:06 -0400
Message-ID: <E1EIikw-0003ld-EB@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Remove unneeded forward declarations.

Also reorder struct pcmcia_driver initialization to keep attach and
detach together.

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -80,17 +80,8 @@ static dev_link_t *dev_list; /* = NULL *
 /* Function prototypes						    */
 /********************************************************************/
 
-/* device methods */
-static int orinoco_cs_hard_reset(struct orinoco_private *priv);
-
-/* PCMCIA gumpf */
-static void orinoco_cs_config(dev_link_t * link);
-static void orinoco_cs_release(dev_link_t * link);
-static int orinoco_cs_event(event_t event, int priority,
-			    event_callback_args_t * args);
-
-static dev_link_t *orinoco_cs_attach(void);
-static void orinoco_cs_detach(dev_link_t *);
+static void orinoco_cs_release(dev_link_t *link);
+static void orinoco_cs_detach(dev_link_t *link);
 
 /********************************************************************/
 /* Device methods     						    */
@@ -675,8 +666,8 @@ static struct pcmcia_driver orinoco_driv
 		.name	= DRIVER_NAME,
 	},
 	.attach		= orinoco_cs_attach,
-	.event		= orinoco_cs_event,
 	.detach		= orinoco_cs_detach,
+	.event		= orinoco_cs_event,
 	.id_table       = orinoco_cs_ids,
 };
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -89,17 +89,8 @@ static dev_link_t *dev_list; /* = NULL *
 /* Function prototypes						    */
 /********************************************************************/
 
-/* device methods */
-static int spectrum_cs_hard_reset(struct orinoco_private *priv);
-
-/* PCMCIA gumpf */
-static void spectrum_cs_config(dev_link_t * link);
-static void spectrum_cs_release(dev_link_t * link);
-static int spectrum_cs_event(event_t event, int priority,
-			    event_callback_args_t * args);
-
-static dev_link_t *spectrum_cs_attach(void);
-static void spectrum_cs_detach(dev_link_t *);
+static void spectrum_cs_release(dev_link_t *link);
+static void spectrum_cs_detach(dev_link_t *link);
 
 /********************************************************************/
 /* Firmware downloader						    */
@@ -1058,8 +1049,8 @@ static struct pcmcia_driver orinoco_driv
 		.name	= DRIVER_NAME,
 	},
 	.attach		= spectrum_cs_attach,
-	.event		= spectrum_cs_event,
 	.detach		= spectrum_cs_detach,
+	.event		= spectrum_cs_event,
 	.id_table       = spectrum_cs_ids,
 };
 



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
