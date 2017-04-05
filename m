From: David Howells <dhowells@redhat.com>
Subject: [PATCH 12/38] Annotate hardware config module parameters in
 drivers/isdn/
Date: Wed, 05 Apr 2017 17:58:33 +0100
Message-ID: <149141151320.29162.4938996321799823419.stgit@warthog.procyon.org.uk>
References: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk, Karsten Keil <isdn@linux-pingi.de>,
        netdev@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        gregkh@linuxfoundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43888 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753899AbdDEQ6g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 12:58:36 -0400
In-Reply-To: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the kernel is running in secure boot mode, we lock down the kernel to
prevent userspace from modifying the running kernel image.  Whilst this
includes prohibiting access to things like /dev/mem, it must also prevent
access by means of configuring driver modules in such a way as to cause a
device to access or modify the kernel image.

To this end, annotate module_param* statements that refer to hardware
configuration and indicate for future reference what type of parameter they
specify.  The parameter parser in the core sees this information and can
skip such parameters with an error message if the kernel is locked down.
The module initialisation then runs as normal, but just sees whatever the
default values for those parameters is.

Note that we do still need to do the module initialisation because some
drivers have viable defaults set in case parameters aren't specified and
some drivers support automatic configuration (e.g. PNP or PCI) in addition
to manually coded parameters.

This patch annotates drivers in drivers/isdn/.

Suggested-by: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Karsten Keil <isdn@linux-pingi.de>
cc: netdev@vger.kernel.org
---

 drivers/isdn/hardware/avm/b1isa.c |    4 ++--
 drivers/isdn/hardware/avm/t1isa.c |    4 ++--
 drivers/isdn/hisax/config.c       |   10 +++++-----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hardware/avm/b1isa.c b/drivers/isdn/hardware/avm/b1isa.c
index 31ef8130a87f..54e871a47387 100644
--- a/drivers/isdn/hardware/avm/b1isa.c
+++ b/drivers/isdn/hardware/avm/b1isa.c
@@ -169,8 +169,8 @@ static struct pci_dev isa_dev[MAX_CARDS];
 static int io[MAX_CARDS];
 static int irq[MAX_CARDS];
 
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
+module_param_hw_array(io, int, ioport, NULL, 0);
+module_param_hw_array(irq, int, irq, NULL, 0);
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
 
diff --git a/drivers/isdn/hardware/avm/t1isa.c b/drivers/isdn/hardware/avm/t1isa.c
index 72ef18853951..9516203c735f 100644
--- a/drivers/isdn/hardware/avm/t1isa.c
+++ b/drivers/isdn/hardware/avm/t1isa.c
@@ -516,8 +516,8 @@ static int io[MAX_CARDS];
 static int irq[MAX_CARDS];
 static int cardnr[MAX_CARDS];
 
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
+module_param_hw_array(io, int, ioport, NULL, 0);
+module_param_hw_array(irq, int, irq, NULL, 0);
 module_param_array(cardnr, int, NULL, 0);
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index 2d12c6ceeb89..c7d68675b028 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -350,13 +350,13 @@ MODULE_AUTHOR("Karsten Keil");
 MODULE_LICENSE("GPL");
 module_param_array(type, int, NULL, 0);
 module_param_array(protocol, int, NULL, 0);
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
-module_param_array(mem, int, NULL, 0);
+module_param_hw_array(io, int, ioport, NULL, 0);
+module_param_hw_array(irq, int, irq, NULL, 0);
+module_param_hw_array(mem, int, iomem, NULL, 0);
 module_param(id, charp, 0);
 #ifdef IO0_IO1
-module_param_array(io0, int, NULL, 0);
-module_param_array(io1, int, NULL, 0);
+module_param_hw_array(io0, int, ioport, NULL, 0);
+module_param_hw_array(io1, int, ioport, NULL, 0);
 #endif
 #endif /* MODULE */
 
