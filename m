From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] hp100: fix section references
Date: Sun, 27 Feb 2005 22:13:11 -0800
Message-ID: <20050227221311.4a163e80.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, perex@suse.cz, torvalds <torvalds@osdl.org>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hp100: references __init code that should be marked as __devinit;

Error: ./drivers/net/hp100.o .text refers to 0000000000000f7f R_X86_64_PC32     .init.text+0x00000000000000b8

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/hp100.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -Naurp ./drivers/net/hp100.c~hp100_sections ./drivers/net/hp100.c
--- ./drivers/net/hp100.c~hp100_sections	2005-02-27 12:54:05.731052192 -0800
+++ ./drivers/net/hp100.c	2005-02-27 22:07:52.561806128 -0800
@@ -306,7 +306,7 @@ static void wait(void)
  * Read board id and convert to string.
  * Effectively same code as decode_eisa_sig
  */
-static __init const char *hp100_read_id(int ioaddr)
+static __devinit const char *hp100_read_id(int ioaddr)
 {
 	int i;
 	static char str[HP100_SIG_LEN];
@@ -429,8 +429,8 @@ struct net_device * __init hp100_probe(i
 }
 #endif
 
-static int __init hp100_probe1(struct net_device *dev, int ioaddr,
-			       u_char bus, struct pci_dev *pci_dev)
+static int __devinit hp100_probe1(struct net_device *dev, int ioaddr,
+				  u_char bus, struct pci_dev *pci_dev)
 {
 	int i;
 	int err = -ENODEV;

---
