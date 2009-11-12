From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH] s2io: fixing a ethtool test that is broken
Date: Thu, 12 Nov 2009 13:59:53 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705E74E6F@nekter>
References: <1257882263-7507-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
To: <leitao@linux.vnet.ibm.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:6062 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbZKLTPC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 14:15:02 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1257882263-7507-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Siva] Reviewed the patch. Please accept it.

Acked-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of leitao@linux.vnet.ibm.com
Sent: Tuesday, November 10, 2009 11:44 AM
To: netdev@vger.kernel.org
Cc: Sreenivasa Honnur; Breno Leitao
Subject: [PATCH] s2io: fixing a ethtool test that is broken

Due commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, it is not more
possible to pci_restore_state() more than once without calling
pci_save_state() in the middle.

Actually running a ethtool test on s2io makes the card inactive, 
and it needs to unload/reload the module to fix. 

This patch just save the state just after it restore in order to
keep the old behaviour

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/s2io.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ddccf5f..0dd7839 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3494,6 +3494,7 @@ static void s2io_reset(struct s2io_nic *sp)
 
 		/* Restore the PCI state saved during initialization. */
 		pci_restore_state(sp->pdev);
+		pci_save_state(sp->pdev);
 		pci_read_config_word(sp->pdev, 0x2, &val16);
 		if (check_pci_device_id(val16) != (u16)PCI_ANY_ID)
 			break;
-- 
1.6.0.2

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
