From: Matej Kupljen <matej.kupljen@gmail.com>
Subject: HSO driver patch again [1/2]
Date: Fri, 7 Oct 2016 16:44:40 +0200
Message-ID: <CAHMF36EFRnkXmBgt=CEP4PN-RbN-nWw9jx4HPJgc705W6iKgRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33796 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755954AbcJGOom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 10:44:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using hso driver for my 3G modem (although different manufacturer
with different USB VID/PID) but I have some problems with it. It is
working fine, but if you disconnect the USB connection while the data
is transferring trough AT interface, we get a crash.

First patch
0001-Reverse-the-order-in-disconnect.patch
This patch first sets the interface to NULL and only then starts
removing the allocated resources. This is according to documentation and
it is also more similar to other drivers.

Thanks,
Matej

From: Matej Kupljen <matej.kupljen@norik.si>
Date: Wed, 28 Sep 2016 18:37:23 +0200
Subject: [PATCH] Reverse the order in disconnect

When the device is disconnected, we first need to set interface
data to NULL and then do the freeing of resources to avoid race
conditions.

Signed-off-by: Matej Kupljen <matej.kupljen@norik.si>
---
 drivers/net/usb/hso.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index b0df61f..16aef06 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -3013,10 +3013,10 @@ exit:
 /* device removed, cleaning up */
 static void hso_disconnect(struct usb_interface *interface)
 {
- hso_free_interface(interface);
-
  /* remove reference of our private data */
  usb_set_intfdata(interface, NULL);
+
+ hso_free_interface(interface);
 }

 static void async_get_intf(struct work_struct *data)
-- 
2.7.4
