From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 10/37] drivers/net/wireless/libertas_tf: Use kmemdup
Date: Sat, 15 May 2010 23:16:03 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152315450.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/wireless/libertas_tf/if_usb.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -u -p a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -538,7 +538,8 @@ static void if_usb_receive_fwload(struct
 		return;
 	}
 
-	syncfwheader = kmalloc(sizeof(struct fwsyncheader), GFP_ATOMIC);
+	syncfwheader = kmemdup(skb->data, sizeof(struct fwsyncheader),
+			       GFP_ATOMIC);
 	if (!syncfwheader) {
 		lbtf_deb_usbd(&cardp->udev->dev, "Failure to allocate syncfwheader\n");
 		kfree_skb(skb);
@@ -546,8 +547,6 @@ static void if_usb_receive_fwload(struct
 		return;
 	}
 
-	memcpy(syncfwheader, skb->data, sizeof(struct fwsyncheader));
