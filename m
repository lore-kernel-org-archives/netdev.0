From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] tc35815: handle ioremap() failure
Date: Sat, 24 Jan 2004 22:29:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124222930.3da1ce43.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.

Thanks,
--
~Randy


From: Leann Ogasawara <ogasawara@osdl.org>


Hi All,

Patch to check if ioremap() failed.  If so, handle error accordingly. 
Was unable to test so feedback appreciated.

diffed against 2.6.1

Leann

===== drivers/net/tc35815.c 1.15 vs edited =====

diff -puN drivers/net/tc35815.c~tc35815.c_iounmap drivers/net/tc35815.c

diff -puN drivers/net/tc35815.c~tc35815.c_iounmap drivers/net/tc35815.c


 linux-262-rc1-bk1-rddunlap/drivers/net/tc35815.c |    5 +++++
 1 files changed, 5 insertions(+)

diff -puN drivers/net/tc35815.c~tc35815.c_iounmap drivers/net/tc35815.c
--- linux-262-rc1-bk1/drivers/net/tc35815.c~tc35815.c_iounmap	2004-01-23 15:49:36.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/tc35815.c	2004-01-23 15:49:36.000000000 -0800
@@ -554,6 +554,11 @@ static int __devinit tc35815_probe1(stru
 	dev->irq = irq;
 	dev->base_addr = (unsigned long)ioremap(base_addr,
 						sizeof(struct tc35815_regs));
+	if (!dev->base_addr) {
+		unregister_netdev(dev);
+		free_netdev(dev);
+		return -ENOMEM;
+	}
 	tr = (struct tc35815_regs*)dev->base_addr;
 
 	tc35815_chip_reset(dev);

_
