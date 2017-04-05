From: David Howells <dhowells@redhat.com>
Subject: [PATCH 16/38] Annotate hardware config module parameters in
 drivers/net/appletalk/
Date: Wed, 05 Apr 2017 17:59:10 +0100
Message-ID: <149141155002.29162.9347070846007030789.stgit@warthog.procyon.org.uk>
References: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        keyrings@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        gregkh@linuxfoundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

This patch annotates drivers in drivers/net/appletalk/.

Suggested-by: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
cc: netdev@vger.kernel.org
---

 drivers/net/appletalk/cops.c |    6 +++---
 drivers/net/appletalk/ltpc.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 1b2e9217ec78..486e1e6997fc 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -986,9 +986,9 @@ static int cops_close(struct net_device *dev)
 static struct net_device *cops_dev;
 
 MODULE_LICENSE("GPL");
-module_param(io, int, 0);
-module_param(irq, int, 0);
-module_param(board_type, int, 0);
+module_param_hw(io, int, ioport, 0);
+module_param_hw(irq, int, irq, 0);
+module_param_hw(board_type, int, other, 0);
 
 static int __init cops_module_init(void)
 {
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 01e2ac55c137..ac755d2950a6 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1231,9 +1231,9 @@ static struct net_device *dev_ltpc;
 
 MODULE_LICENSE("GPL");
 module_param(debug, int, 0);
-module_param(io, int, 0);
-module_param(irq, int, 0);
-module_param(dma, int, 0);
+module_param_hw(io, int, ioport, 0);
+module_param_hw(irq, int, irq, 0);
+module_param_hw(dma, int, dma, 0);
 
 
 static int __init ltpc_module_init(void)
