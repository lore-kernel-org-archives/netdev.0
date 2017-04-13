From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH 4/4] net: macb: Add macb_ptp to compilation chain
Date: Thu, 13 Apr 2017 14:39:58 +0100
Message-ID: <1492090798-16253-1-git-send-email-rafalo@cadence.com>
References: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>,
 <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <devicetree@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
 <harinikatakamlinux@gmail.com>, <harini.katakam@xilinx.com>,
 <richardcochran@gmail.com>, <Andrei.Pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add macb_ptp.c to Makefile.
In case that macb is compiled as a module, it has been renamed to
cadence-macb.ko to avoid naming confusion in Makefile.

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 drivers/net/ethernet/cadence/Makefile | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 4ba7559..a7f6e04 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -1,6 +1,11 @@
 #
 # Makefile for the Atmel network device drivers.
 #
+cadence-macb-y	:= macb.o
 
-obj-$(CONFIG_MACB) += macb.o
+ifeq ($(CONFIG_MACB_USE_HWSTAMP),y)
+cadence-macb-y	+= macb_ptp.o
+endif
+
+obj-$(CONFIG_MACB) += cadence-macb.o
 obj-$(CONFIG_MACB_PCI) += macb_pci.o
-- 
2.4.5
