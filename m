From: akpm@osdl.org
Subject: [patch 11/18] gcc-3.5: ne2k-pci.c
Date: Sun, 25 Jan 2004 03:07:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7ko25097@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



drivers/net/ne2k-pci.c: In function `ne2k_pci_block_input':
drivers/net/ne2k-pci.c:539: error: invalid lvalue in increment
drivers/net/ne2k-pci.c: In function `ne2k_pci_block_output':
drivers/net/ne2k-pci.c:600: error: invalid lvalue in increment



---

 drivers/net/ne2k-pci.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff -puN drivers/net/ne2k-pci.c~gcc-35-ne2k-pci drivers/net/ne2k-pci.c
--- 25/drivers/net/ne2k-pci.c~gcc-35-ne2k-pci	2004-01-25 03:01:38.000000000 -0800
+++ 25-akpm/drivers/net/ne2k-pci.c	2004-01-25 03:01:38.000000000 -0800
@@ -532,8 +532,12 @@ static void ne2k_pci_block_input(struct 
 		insl(NE_BASE + NE_DATAPORT, buf, count>>2);
 		if (count & 3) {
 			buf += count & ~3;
-			if (count & 2)
-				*((u16*)buf)++ = le16_to_cpu(inw(NE_BASE + NE_DATAPORT));
+			if (count & 2) {
+				u16 *b = (u16 *)buf;
+
+				*b++ = le16_to_cpu(inw(NE_BASE + NE_DATAPORT));
+				buf = (char *)b;
+			}
 			if (count & 1)
 				*buf = inb(NE_BASE + NE_DATAPORT);
 		}
@@ -593,8 +597,12 @@ static void ne2k_pci_block_output(struct
 		outsl(NE_BASE + NE_DATAPORT, buf, count>>2);
 		if (count & 3) {
 			buf += count & ~3;
-			if (count & 2)
-				outw(cpu_to_le16(*((u16*)buf)++), NE_BASE + NE_DATAPORT);
+			if (count & 2) {
+				u16 *b = (u16 *)buf;
+
+				outw(cpu_to_le16(*b++), NE_BASE + NE_DATAPORT);
+				buf = (char *)b;
+			}
 		}
 	}
 

_
