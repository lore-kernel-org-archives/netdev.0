From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 1/37] drivers/net/wireless/libertas: Use kmemdup
Date: Sat, 15 May 2010 23:12:28 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152312060.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel@vge
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
 drivers/net/wireless/libertas/if_usb.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -u -p a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -618,16 +618,14 @@ static void if_usb_receive_fwload(struct
 		return;
 	}
 
-	syncfwheader = kmalloc(sizeof(struct fwsyncheader), GFP_ATOMIC);
+	syncfwheader = kmemdup(skb->data + IPFIELD_ALIGN_OFFSET,
+			       sizeof(struct fwsyncheader), GFP_ATOMIC);
 	if (!syncfwheader) {
 		lbs_deb_usbd(&cardp->udev->dev, "Failure to allocate syncfwheader\n");
 		kfree_skb(skb);
 		return;
 	}
 
-	memcpy(syncfwheader, skb->data + IPFIELD_ALIGN_OFFSET,
-	       sizeof(struct fwsyncheader));
