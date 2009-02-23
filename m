From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: [PATCH] hso: remove hso_free_device()
Date: Mon, 23 Feb 2009 17:58:27 +0200
Message-ID: <20090223155827.10185.48514.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is really no need for function just doing simple kfree()

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Cc: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---

 drivers/net/usb/hso.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a6bf488..f5e4912 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2364,12 +2364,6 @@ exit:
 	return -1;
 }
 
-/* Frees a general hso device */
-static void hso_free_device(struct hso_device *hso_dev)
-{
-	kfree(hso_dev);
-}
-
 /* Creates a general hso device */
 static struct hso_device *hso_create_device(struct usb_interface *intf,
 					    int port_spec)
@@ -2432,7 +2426,7 @@ static void hso_free_net_device(struct hso_device *hso_dev)
 		free_netdev(hso_net->net);
 	}
 
-	hso_free_device(hso_dev);
+	kfree(hso_dev);
 }
 
 /* initialize the network interface */
@@ -2646,7 +2640,7 @@ static void hso_free_serial_device(struct hso_device *hso_dev)
 	}
 	hso_free_tiomget(serial);
 	kfree(serial);
-	hso_free_device(hso_dev);
+	kfree(hso_dev);
 }
 
 /* Creates a bulk AT channel */
@@ -2727,7 +2721,7 @@ exit2:
 exit:
 	hso_free_tiomget(serial);
 	kfree(serial);
-	hso_free_device(hso_dev);
+	kfree(hso_dev);
 	return NULL;
 }
 
@@ -2786,7 +2780,7 @@ exit:
 		kfree(serial);
 	}
 	if (hso_dev)
-		hso_free_device(hso_dev);
+		kfree(hso_dev);
 	return NULL;
 
 }

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
