From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] ewrk3: silence GCC warning
Date: Sat, 24 Nov 2012 13:12:45 +0100
Message-ID: <1353759165.1420.33.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building ewrk3.o triggers this GCC warning:
    drivers/net/ethernet/dec/ewrk3.c: In function '__check_irq':
    drivers/net/ethernet/dec/ewrk3.c:1915:1: warning: return from incompatible pointer type [enabled by default]

This can be trivially fixed by changing the 'irq' parameter from int to
byte (which is the alias for unsigned char for module parameters).

While we're touching this code also drop an outdated comment, that
should have been dropped with the patch named "MODULE_PARM conversions"
from early 2005.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Compile tested only.

 drivers/net/ethernet/dec/ewrk3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 17ae8c6..9f992b9 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -1910,9 +1910,8 @@ static struct net_device *ewrk3_devs[MAX_NUM_EWRK3S];
 static int ndevs;
 static int io[MAX_NUM_EWRK3S+1] = { 0x300, 0, };
 
-/* '21' below should really be 'MAX_NUM_EWRK3S' */
 module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
+module_param_array(irq, byte, NULL, 0);
 MODULE_PARM_DESC(io, "EtherWORKS 3 I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherWORKS 3 IRQ number(s)");
 
-- 
1.7.7.6
