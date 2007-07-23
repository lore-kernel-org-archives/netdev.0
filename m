From: Micah Gruber <micah.gruber@gmail.com>
Subject: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in write_bulk_callback()
 in drivers/net/usb/pegasus.c
Date: Mon, 23 Jul 2007 16:05:52 +0800
Message-ID: <46A46160.9080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: petkan@users.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:53675 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbXGWIBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 04:01:15 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1416351wxd
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 01:01:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a potential null dereference bug where we dereference 
pegasus before a null check. This patch simply moves the dereferencing 
after the null check.

Signed-off-by: Micah Gruber <micah.gruber@gmail.com>

---

--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -768,11 +768,13 @@
 static void write_bulk_callback(struct urb *urb)
 {
        pegasus_t *pegasus = urb->context;
-       struct net_device *net = pegasus->net;
+       struct net_device *net;

        if (!pegasus)
                return;

+       net = pegasus->net;
+
        if (!netif_device_present(net) || !netif_running(net))
                return;
