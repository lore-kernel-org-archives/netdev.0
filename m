From: David Howells <dhowells@redhat.com>
Subject: [PATCH 20/39] Annotate hardware config module parameters in
 drivers/net/hamradio/
Date: Thu, 01 Dec 2016 12:32:18 +0000
Message-ID: <148059553894.31612.991515699609880549.stgit@warthog.procyon.org.uk>
References: <148059537897.31612.9461043954611464597.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk, minyard@acm.org,
        netdev@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        linux-hams@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
        Thomas Sailer <t.sailer@alumni.ethz.ch>
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

This patch annotates drivers in drivers/net/hamradio/.

Suggested-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
cc: Joerg Reuter <jreuter@yaina.de>
cc: linux-hams@vger.kernel.org
cc: netdev@vger.kernel.org
---

 drivers/net/hamradio/baycom_epp.c     |    2 +-
 drivers/net/hamradio/baycom_par.c     |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c |    4 ++--
 drivers/net/hamradio/baycom_ser_hdx.c |    4 ++--
 drivers/net/hamradio/dmascc.c         |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 78dbc44540f6..a50b72144b93 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1172,7 +1172,7 @@ static int iobase[NR_PORTS] = { 0x378, };
 
 module_param_array(mode, charp, NULL, 0);
 MODULE_PARM_DESC(mode, "baycom operating mode");
-module_param_array(iobase, int, NULL, 0);
+module_param_hw_array(iobase, int, ioport, NULL, 0);
 MODULE_PARM_DESC(iobase, "baycom io base address");
 
 MODULE_AUTHOR("Thomas M. Sailer, sailer@ife.ee.ethz.ch, hb9jnx@hb9w.che.eu");
diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index 072cddce9264..cb7fe200f347 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -481,7 +481,7 @@ static int iobase[NR_PORTS] = { 0x378, };
 
 module_param_array(mode, charp, NULL, 0);
 MODULE_PARM_DESC(mode, "baycom operating mode; eg. par96 or picpar");
-module_param_array(iobase, int, NULL, 0);
+module_param_hw_array(iobase, int, ioport, NULL, 0);
 MODULE_PARM_DESC(iobase, "baycom io base address");
 
 MODULE_AUTHOR("Thomas M. Sailer, sailer@ife.ee.ethz.ch, hb9jnx@hb9w.che.eu");
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 7b916d5b14b9..36d49c89d601 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -614,9 +614,9 @@ static int baud[NR_PORTS] = { [0 ... NR_PORTS-1] = 1200 };
 
 module_param_array(mode, charp, NULL, 0);
 MODULE_PARM_DESC(mode, "baycom operating mode; * for software DCD");
-module_param_array(iobase, int, NULL, 0);
+module_param_hw_array(iobase, int, ioport, NULL, 0);
 MODULE_PARM_DESC(iobase, "baycom io base address");
-module_param_array(irq, int, NULL, 0);
+module_param_hw_array(irq, int, irq, NULL, 0);
 MODULE_PARM_DESC(irq, "baycom irq number");
 module_param_array(baud, int, NULL, 0);
 MODULE_PARM_DESC(baud, "baycom baud rate (300 to 4800)");
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index f9a8976195ba..1b310493ba8a 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -642,9 +642,9 @@ static int irq[NR_PORTS] = { 4, };
 
 module_param_array(mode, charp, NULL, 0);
 MODULE_PARM_DESC(mode, "baycom operating mode; * for software DCD");
-module_param_array(iobase, int, NULL, 0);
+module_param_hw_array(iobase, int, ioport, NULL, 0);
 MODULE_PARM_DESC(iobase, "baycom io base address");
-module_param_array(irq, int, NULL, 0);
+module_param_hw_array(irq, int, irq, NULL, 0);
 MODULE_PARM_DESC(irq, "baycom irq number");
 
 MODULE_AUTHOR("Thomas M. Sailer, sailer@ife.ee.ethz.ch, hb9jnx@hb9w.che.eu");
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index e4137c1b3df9..f94ca7b91899 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -274,7 +274,7 @@ static unsigned long rand;
 
 MODULE_AUTHOR("Klaus Kudielka");
 MODULE_DESCRIPTION("Driver for high-speed SCC boards");
-module_param_array(io, int, NULL, 0);
+module_param_hw_array(io, int, ioport, NULL, 0);
 MODULE_LICENSE("GPL");
 
 static void __exit dmascc_exit(void)
