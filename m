From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] ibmtr: fix init (devinit) section usage
Date: Wed, 4 Aug 2004 09:49:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804094905.667b3954.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(resend from 2.6.4 days)

Use __devinit on 2 functions so that section usage is valid.

Removes these problems when CONFIG_HOTPLUG=n:
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000b7 R_386_PC32        .init.text
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000c8 R_386_32          .init.data
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000cf R_386_PC32        .init.text
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000d5 R_386_32          .init.data
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000df R_386_32          .init.data
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000e6 R_386_PC32        .init.text
Error: ./drivers/net/tokenring/ibmtr.o .text refers to 000000f4 R_386_32          .init.data

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>


diffstat:=
 drivers/net/tokenring/ibmtr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -Naurp ./drivers/net/tokenring/ibmtr.c~ibmtr_init ./drivers/net/tokenring/ibmtr.c
--- ./drivers/net/tokenring/ibmtr.c~ibmtr_init	2004-03-06 20:57:06.000000000 -0800
+++ ./drivers/net/tokenring/ibmtr.c	2004-03-07 18:31:11.000000000 -0800
@@ -334,7 +334,7 @@ static void ibmtr_cleanup_card(struct ne
 #endif		
 }
 
-int ibmtr_probe_card(struct net_device *dev)
+int __devinit ibmtr_probe_card(struct net_device *dev)
 {
 	int err = ibmtr_probe(dev);
 	if (!err) {
@@ -357,7 +357,7 @@ int ibmtr_probe_card(struct net_device *
  *	which references it.
  ****************************************************************************/
 
-static int ibmtr_probe(struct net_device *dev)
+static int __devinit ibmtr_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;

--
