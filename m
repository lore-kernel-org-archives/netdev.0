From: Luis Henriques <luis.henriques@canonical.com>
Subject: [PATCH 37/72] rt2x00: rt2x00pci_regbusy_read() - only print register access failure once
Date: Thu, 18 Apr 2013 10:16:22 +0100
Message-ID: <1366276617-3553-38-git-send-email-luis.henriques@canonical.com>
References: <1366276617-3553-1-git-send-email-luis.henriques@canonical.com>
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, Tim Gardner <tim.gardner@canonical.com>,
	Luis Henriques <luis.henriques@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366276617-3553-1-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.5.7.11 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Tim Gardner <tim.gardner@canonical.com>

commit 83589b30f1e1dc9898986293c9336b8ce1705dec upstream.

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
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 0a4653a..1ea98a8 100644
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
1.8.1.2
