From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] solos-pci: Fix debugging to include size, vpi/vci, but
 omit preamble
Date: Sun, 20 Mar 2011 00:47:58 -0700
Message-ID: <4D85B12E.5040005@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:58401 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab1CTHsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 03:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show the buffer length, vpi, and vci as we do on receive.  Use the word "port" instead of "device" consistently.

Don't display the "struct pkt_hdr" preamble on the sk_buff when doing hexdump of frame data.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---

--- a/drivers/atm/solos-pci.c.orig	2011-03-19 12:19:06.000000000 -0600
+++ b/drivers/atm/solos-pci.c	2011-03-19 12:45:18.000000000 -0600
@@ -697,7 +697,7 @@ void solos_bh(unsigned long card_arg)
  					      size);
  			}
  			if (atmdebug) {
-				dev_info(&card->dev->dev, "Received: device %d\n", port);
+				dev_info(&card->dev->dev, "Received: port %d\n", port);
  				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
  					 size, le16_to_cpu(header->vpi),
  					 le16_to_cpu(header->vci));
@@ -1025,8 +1025,15 @@ static uint32_t fpga_tx(struct solos_car

  			/* Clean up and free oldskb now it's gone */
  			if (atmdebug) {
+				struct pkt_hdr *header = (void *)oldskb->data;
+				int size = le16_to_cpu(header->size);
+
+				skb_pull(oldskb, sizeof(*header));
  				dev_info(&card->dev->dev, "Transmitted: port %d\n",
  					 port);
+				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
+					 size, le16_to_cpu(header->vpi),
+					 le16_to_cpu(header->vci));
  				print_buffer(oldskb);
  			}



