From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] tulip/de2104x: don't mix __init & __devinit sections
Date: Wed, 2 Mar 2005 10:09:17 -0800
Message-ID: <20050302100917.4115855e.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds <torvalds@osdl.org>, akpm <akpm@osdl.org>
To: netdev <netdev@oss.sgi.com>, jgarzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(take 2, based on Jeff's comment)

tulip/de2104x: fix section usage, don't mix __init & __devinit:

Error: ./drivers/net/tulip/de2104x.o .text refers to 000000000000176d R_X86_64_PC32     .init.text+0xfffffffffffffffc
Error: ./drivers/net/tulip/de2104x.o .text refers to 0000000000001798 R_X86_64_PC32     .init.text+0xfffffffffffffffc

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/tulip/de2104x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/tulip/de2104x.c~de2104x_sections ./drivers/net/tulip/de2104x.c
--- ./drivers/net/tulip/de2104x.c~de2104x_sections	2005-02-27 12:54:05.830037144 -0800
+++ ./drivers/net/tulip/de2104x.c	2005-03-02 09:49:13.533933000 -0800
@@ -1927,7 +1927,7 @@ bad_srom:
 	goto fill_defaults;
 }
 
-static int __devinit de_init_one (struct pci_dev *pdev,
+static int __init de_init_one (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct net_device *dev;

---
