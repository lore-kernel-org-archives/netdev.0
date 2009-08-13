From: Davide Rizzo <elpa.rizzo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Pegasus: Bug / Correction (?)
Date: Thu, 13 Aug 2009 12:11:24 +0200
Message-ID: <8447d6730908130311vd6984e8t1dd5c1e32efbeb2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bug Correction
ADM8515 fails to read central 2 bytes of MAC address
This patch solves the problem, but I didn't understand it.

Signed-off-by: Davide Rizzo <elpa.rizzo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
diff -urNp linux-2.6.30.4/drivers/net/usb/pegasus.c
linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c
--- linux-2.6.30.4/drivers/net/usb/pegasus.c	2009-08-13 07:14:57.000000000 +0200
+++ linux-2.6.30.4.elpa/drivers/net/usb/pegasus.c	2009-08-13
08:39:01.000000000 +0200
@@ -425,7 +425,6 @@ fail:
 static inline void enable_eprom_write(pegasus_t * pegasus)
 {
 	__u8 tmp;
-	int ret;

 	get_registers(pegasus, EthCtrl2, 1, &tmp);
 	set_register(pegasus, EthCtrl2, tmp | EPROM_WR_ENABLE);
@@ -434,7 +433,6 @@ static inline void enable_eprom_write(pe
 static inline void disable_eprom_write(pegasus_t * pegasus)
 {
 	__u8 tmp;
-	int ret;

 	get_registers(pegasus, EthCtrl2, 1, &tmp);
 	set_register(pegasus, EpromCtrl, 0);
@@ -486,9 +525,9 @@ static void set_ethernet_addr(pegasus_t
 {
 	__u8 node_id[6];

-	if (pegasus->features & PEGASUS_II) {
+/*if (pegasus->features & PEGASUS_II) {
 		get_registers(pegasus, 0x10, sizeof(node_id), node_id);
-	} else {
+	} else*/ {
 		get_node_id(pegasus, node_id);
 		set_registers(pegasus, EthID, sizeof (node_id), node_id);
 	}
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
