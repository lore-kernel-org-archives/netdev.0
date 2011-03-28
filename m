From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 2/2] solos-pci:Don't include pseudo-header in dump of frame
Date: Sun, 27 Mar 2011 22:21:54 -0700
Message-ID: <4D901AF2.2040503@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54103 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752186Ab1C1FWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 01:22:00 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-146-59.ptldor.dsl-w.verizon.net [71.111.146.59])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2S5Ls3B019225
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 23:22:00 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Don't include pseudo-header as part of frame hex-dump on transmit.

Signed-off-by: Philip Prindeville<philipp@redfish-solutions.com>
---
  drivers/atm/solos-pci.c |    9 ++++++++-
  1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2c4146a..968f022 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -697,7 +697,7 @@ void solos_bh(unsigned long card_arg)
  					      size);
  			}
  			if (atmdebug) {
-				dev_info(&card->dev->dev, "Received: device %d\n", port);
+				dev_info(&card->dev->dev, "Received: port %d\n", port);
  				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
  					 size, le16_to_cpu(header->vpi),
  					 le16_to_cpu(header->vci));
@@ -1018,8 +1018,15 @@ static uint32_t fpga_tx(struct solos_card *card)

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



