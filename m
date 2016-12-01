From: David Howells <dhowells@redhat.com>
Subject: [PATCH 17/39] Annotate hardware config module parameters in
 drivers/net/arcnet/
Date: Thu, 01 Dec 2016 12:31:53 +0000
Message-ID: <148059551381.31612.3024451259648856834.stgit@warthog.procyon.org.uk>
References: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk,
        Michael Grzeschik <m.grzeschik@pengutronix.de>,
        minyard@acm.org, netdev@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
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

This patch annotates drivers in drivers/net/arcnet/.

Suggested-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Michael Grzeschik <m.grzeschik@pengutronix.de>
cc: netdev@vger.kernel.org
---

 drivers/net/arcnet/com20020-isa.c |    4 ++--
 drivers/net/arcnet/com90io.c      |    4 ++--
 drivers/net/arcnet/com90xx.c      |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index b9e9931353b2..38fa60ddaf2e 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -129,8 +129,8 @@ static int clockp = 0;
 static int clockm = 0;
 
 module_param(node, int, 0);
-module_param(io, int, 0);
-module_param(irq, int, 0);
+module_param_hw(io, int, ioport, 0);
+module_param_hw(irq, int, irq, 0);
 module_param_string(device, device, sizeof(device), 0);
 module_param(timeout, int, 0);
 module_param(backplane, int, 0);
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index b57863df5bf5..4e56aaf2b984 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -347,8 +347,8 @@ static int io;			/* use the insmod io= irq= shmem= options */
 static int irq;
 static char device[9];		/* use eg. device=arc1 to change name */
 
-module_param(io, int, 0);
-module_param(irq, int, 0);
+module_param_hw(io, int, ioport, 0);
+module_param_hw(irq, int, irq, 0);
 module_param_string(device, device, sizeof(device), 0);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 81f90c4703ae..ca4a57c30bf8 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -88,8 +88,8 @@ static int irq;
 static int shmem;
 static char device[9];		/* use eg. device=arc1 to change name */
 
-module_param(io, int, 0);
-module_param(irq, int, 0);
+module_param_hw(io, int, ioport, 0);
+module_param_hw(irq, int, irq, 0);
 module_param(shmem, int, 0);
 module_param_string(device, device, sizeof(device), 0);
 
