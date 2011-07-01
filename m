From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH 1/3 resend] ssb: PCI revision ID register is 8-bit wide
Date: Fri, 1 Jul 2011 22:35:28 +0400
Message-ID: <201107012235.28745.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: mb@bu3sch.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:35236 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751426Ab1GAShN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 14:37:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SSB code reads PCI revision ID register as 16-bit entity while the register
is actually 8-bit only (the next 8 bits are the programming interface register).
Fix the read and make the 'rev' field of 'struct ssb_boardinfo' 8-bit as well,
to match the register size.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.
Resending with proper tearline this time...

 drivers/ssb/pci.c       |    2 +-
 include/linux/ssb/ssb.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/ssb/pci.c
===================================================================
--- linux-2.6.orig/drivers/ssb/pci.c
+++ linux-2.6/drivers/ssb/pci.c
@@ -738,7 +738,7 @@ static void ssb_pci_get_boardinfo(struct
 			     &bi->vendor);
 	pci_read_config_word(bus->host_pci, PCI_SUBSYSTEM_ID,
 			     &bi->type);
-	pci_read_config_word(bus->host_pci, PCI_REVISION_ID,
+	pci_read_config_byte(bus->host_pci, PCI_REVISION_ID,
 			     &bi->rev);
 }
 
Index: linux-2.6/include/linux/ssb/ssb.h
===================================================================
--- linux-2.6.orig/include/linux/ssb/ssb.h
+++ linux-2.6/include/linux/ssb/ssb.h
@@ -99,7 +99,7 @@ struct ssb_sprom {
 struct ssb_boardinfo {
 	u16 vendor;
 	u16 type;
-	u16 rev;
+	u8  rev;
 };
 
 
