From: "Randy.Dunlap" <randy.dunlap@verizon.net>
Subject: [PATCH] tulip: de2104x, fix init. sections
Date: Tue, 01 Mar 2005 21:44:38 -0800
Message-ID: <20050301214438.4653810e.randy.dunlap@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


tulip/de2104x: some __devinit functions were calling __init
  functions, made the latter __devinit also;

Error: ./drivers/net/tulip/de2104x.o .text refers to 000000000000176d R_X86_64_PC32     .init.text+0xfffffffffffffffc
Error: ./drivers/net/tulip/de2104x.o .text refers to 0000000000001798 R_X86_64_PC32     .init.text+0xfffffffffffffffc

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/tulip/de2104x.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -Naurp ./drivers/net/tulip/de2104x.c~de2104x_sections ./drivers/net/tulip/de2104x.c
--- ./drivers/net/tulip/de2104x.c~de2104x_sections	2005-02-27 12:54:05.830037144 -0800
+++ ./drivers/net/tulip/de2104x.c	2005-03-01 21:41:19.354417488 -0800
@@ -1691,7 +1691,7 @@ static struct ethtool_ops de_ethtool_ops
 	.get_regs		= de_get_regs,
 };
 
-static void __init de21040_get_mac_address (struct de_private *de)
+static void __devinit de21040_get_mac_address (struct de_private *de)
 {
 	unsigned i;
 
@@ -1709,7 +1709,7 @@ static void __init de21040_get_mac_addre
 	}
 }
 
-static void __init de21040_get_media_info(struct de_private *de)
+static void __devinit de21040_get_media_info(struct de_private *de)
 {
 	unsigned int i;
 
@@ -1736,7 +1736,7 @@ static void __init de21040_get_media_inf
 }
 
 /* Note: this routine returns extra data bits for size detection. */
-static unsigned __init tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
+static unsigned __devinit tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
@@ -1771,7 +1771,7 @@ static unsigned __init tulip_read_eeprom
 	return retval;
 }
 
-static void __init de21041_get_srom_info (struct de_private *de)
+static void __devinit de21041_get_srom_info (struct de_private *de)
 {
 	unsigned i, sa_offset = 0, ofs;
 	u8 ee_data[DE_EEPROM_SIZE + 6] = {};

---
