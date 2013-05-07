From: Steven Rostedt <rostedt@goodmis.org>
Subject: [041/126] rt2x00: rt2x00pci_regbusy_read() - only print register access
 failure once
Date: Mon, 06 May 2013 23:57:53 -0400
Message-ID: <20130507035847.818086055@goodmis.org>
References: <20130507035712.909872333@goodmis.org>
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <users@rt2x00.serialmonkey.com>,
	<netdev@vger.kernel.org>, Tim Gardner <tim.gardner@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0041-rt2x00-rt2x00pci_regbusy_read-only-print-register-ac.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.6.11.3 stable review patch.
If anyone has any objections, please let me know.

------------------

From: Tim Gardner <tim.gardner@canonical.com>

[ Upstream commit 83589b30f1e1dc9898986293c9336b8ce1705dec ]

BugLink: http://bugs.launchpad.net/bugs/1128840

It appears that when this register read fails it never recovers, so
I think there is no need to repeat the same error message ad infinitum.

Cc: Ivo van Doorn <IvDoorn@gmail.com>
Cc: Gertjan van Wingerde <gwingerde@gmail.com>
Cc: Helmut Schaa <helmut.schaa@googlemail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: users@rt2x00.serialmonkey.com
Cc: netdev@vger.kernel.org
Cc: stable@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index a0c8cae..b1c673e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -52,8 +52,8 @@ int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=0x%.08x, value=0x%.08x\n", offset, *reg);
+	printk_once(KERN_ERR "%s() Indirect register access failed: "
+	      "offset=0x%.08x, value=0x%.08x\n", __func__, offset, *reg);
 	*reg = ~0;
 
 	return 0;
-- 
1.7.10.4
