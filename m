From: "Martin Schiller" <mschiller@tdt.de>
Subject: [PATCH 3/3] hso: Fix interface order/creation when disabled_net=1
Date: Thu, 19 Nov 2009 09:44:24 +0100
Message-ID: <FBC3AE2CA6DC458FAE6A54AE13793373@mschille2>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:54657 "EHLO ns.tdt.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284AbZKSIoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 03:44:32 -0500
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id nAJ8igD22159
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 09:44:42 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch stops the useless creation of an serial ttyHS<x> for the
Network Port, when disable_net=1 is set. By that, the order of the
ttyHS<x> is always the same, regardless if disable_net is set or not.

Signed-off-by: Martin Schiller <mschiller@tdt.de>
---

--- linux-2.6.32-rc7-git3/drivers/net/usb/hso.c.orig 2009-11-19 09:08:17.000000000 +0100
+++ linux-2.6.32-rc7-git3/drivers/net/usb/hso.c 2009-11-19 09:10:36.000000000 +0100
@@ -2984,9 +2984,10 @@ static int hso_probe(struct usb_interfac
 
  case HSO_INTF_BULK:
   /* It's a regular bulk interface */
-  if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
-      && !disable_net)
+  if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
+      if (!disable_net)
    hso_dev = hso_create_net_device(interface, port_spec);
+  }
   else
    hso_dev =
        hso_create_bulk_serial_device(interface, port_spec);


