From: Ralf Baechle <ralf@linux-mips.org>
Subject: [IOC3] Fix section missmatch
Date: Sat, 8 Mar 2008 16:56:33 +0000
Message-ID: <20080308165633.GA13996@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jgarik@linux-mips.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

  LD      drivers/net/built-in.o
WARNING: drivers/net/built-in.o(.text+0x3468): Section mismatch in reference fro
m the function ioc3_probe() to the function .devinit.text:ioc3_serial_probe()
The function ioc3_probe() references
the function __devinit ioc3_serial_probe().
This is often because ioc3_probe lacks a __devinit 
annotation or the annotation of ioc3_serial_probe is wrong.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 373f72c..1f25263 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1221,7 +1221,8 @@ static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 }
 #endif
 
-static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int __devinit ioc3_probe(struct pci_dev *pdev,
+	const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;
