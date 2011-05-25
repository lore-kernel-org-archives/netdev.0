From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: isdn: netjet - blacklist Digium TDM400P
Date: Wed, 25 May 2011 08:12:23 -0400
Message-ID: <20110525121223.26439.57412.sendpatchset@prarit.bos.redhat.com>
Content-Type: text/plain; charset=us-ascii
Cc: Prarit Bhargava <prarit@redhat.com>
To: netdev@vger.kernel.org, isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756449Ab1EYMMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 08:12:25 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p4PCCO1L006667
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 25 May 2011 08:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2nd try ... 1st attempt didn't make it to netdev mailing list]

A quick google search reveals that people with this card are blacklisting it
in the initramfs and in the module blacklist based on a statement that it
is unsupported. Since the older Digium is also unsupported I'm pretty
confident that this newer card is also not supported.

lspci -xxx -vv shows

04:07.0 Communication controller: Tiger Jet Network Inc. Tiger3XX Modem/ISDN interface
        Subsystem: Device b100:0003
P.

----8<----
The Asterisk Voice Card, DIGIUM TDM400P is unsupported by the netjet driver.
Blacklist it like the Digium X100P/X101P card.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 54ae71a..db25b6b 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1072,6 +1072,12 @@ nj_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENODEV;
 	}
 
+	if (pdev->subsystem_vendor == 0xb100 &&
+	    pdev->subsystem_device == 0x0003 ) {
+		pr_notice("Netjet: Digium TDM400P not handled yet\n");
+		return -ENODEV;
+	}
+
 	card = kzalloc(sizeof(struct tiger_hw), GFP_ATOMIC);
 	if (!card) {
 		pr_info("No kmem for Netjet\n");
