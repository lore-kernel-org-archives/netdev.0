From: "Martin Schiller" <mschiller@tdt.de>
Subject: [PATCH 1/3] hso: memory leak in hso_serial_common_free()
Date: Thu, 19 Nov 2009 09:43:57 +0100
Message-ID: <1C487791B6A047B7A26F2B3C54BE0A70@mschille2>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:54647 "EHLO ns.tdt.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbZKSIoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 03:44:06 -0500
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id nAJ8iFX22110
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 09:44:15 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a memory leak in the hso_serial_common_free() function.
The tx_buffer of a serial device was never freed here.

Signed-off-by: Martin Schiller <mschiller@tdt.de>
---

--- linux-2.6.32-rc7-git3/drivers/net/usb/hso.c.orig 2009-11-19 08:54:08.000000000 +0100
+++ linux-2.6.32-rc7-git3/drivers/net/usb/hso.c 2009-11-19 09:04:29.000000000 +0100
@@ -2296,6 +2296,7 @@ static void hso_serial_common_free(struc
  /* unlink and free TX URB */
  usb_free_urb(serial->tx_urb);
  kfree(serial->tx_data);
+ kfree(serial->tx_buffer);
 }
 
 static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,


