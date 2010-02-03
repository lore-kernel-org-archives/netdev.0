From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH] ssb: fix interrupt assignment
Date: Wed,  3 Feb 2010 21:28:11 +0100
Message-ID: <1265228891-3066-1-git-send-email-jochen@scram.de>
Reply-To: OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
List-Unsubscribe: <https://lists.openwrt.org/mailman/options/openwrt-devel>,
	<mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/mailman/listinfo/openwrt-devel>,
	<mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Sender: openwrt-devel-bounces@lists.openwrt.org
Errors-To: openwrt-devel-bounces@lists.openwrt.org
List-Id: netdev.vger.kernel.org

Explicitely enable shared interrupt 2 for any core that didn't get a dedicated IRQ
anymore (fallthrough case) and for EXTIF cores to make gpio interrupts work.
Also remove a bogus comment.

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---
 drivers/ssb/driver_mipscore.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/ssb/driver_mipscore.c b/drivers/ssb/driver_mipscore.c
index 3c6feed..97efce1 100644
--- a/drivers/ssb/driver_mipscore.c
+++ b/drivers/ssb/driver_mipscore.c
@@ -270,7 +270,6 @@ void ssb_mipscore_init(struct ssb_mipscore *mcore)
 				set_irq(dev, irq++);
 			}
 			break;
-			/* fallthrough */
 		case SSB_DEV_PCI:
 		case SSB_DEV_ETHERNET:
 		case SSB_DEV_ETHERNET_GBIT:
@@ -281,6 +280,10 @@ void ssb_mipscore_init(struct ssb_mipscore *mcore)
 				set_irq(dev, irq++);
 				break;
 			}
+			/* fallthrough */
+		case SSB_DEV_EXTIF:
+			set_irq(dev, 0);
+			break;
 		}
 	}
 	ssb_dprintk(KERN_INFO PFX "after irq reconfiguration\n");
-- 
1.6.6
