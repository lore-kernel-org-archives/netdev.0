From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 1/2] ewrk3: silence GCC warning
Date: Tue, 27 Nov 2012 10:47:17 +0100
Message-ID: <1354009637.1420.50.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	richard -rw- weinberger <richard.weinberger@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building ewrk3.o triggers this GCC warning:
    drivers/net/ethernet/dec/ewrk3.c: In function '__check_irq':
    drivers/net/ethernet/dec/ewrk3.c:1915:1: warning: return from incompatible pointer type [enabled by default]

This can be trivially fixed by changing the 'irq' parameter from int to
byte (which is an alias for unsigned char for module parameters).

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Only compile tested.

 drivers/net/ethernet/dec/ewrk3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 17ae8c6..2ee1c47 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -1912,7 +1912,7 @@ static int io[MAX_NUM_EWRK3S+1] = { 0x300, 0, };
 
 /* '21' below should really be 'MAX_NUM_EWRK3S' */
 module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
+module_param_array(irq, byte, NULL, 0);
 MODULE_PARM_DESC(io, "EtherWORKS 3 I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherWORKS 3 IRQ number(s)");
 
-- 
1.7.7.6
