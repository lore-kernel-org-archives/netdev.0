From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH RFC] net: dsa: remove unnecessary phy.h include
Date: Wed, 18 Jan 2017 00:14:03 +0000
Message-ID: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
unnecessary dependency for quite a large amount of the kernel.  There's
very little which actually requires definitions from phy.h in net/dsa.h
- the include itself only wants the declaration of a couple of
structures and IFNAMSIZ.

Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
and phy_fixed.h from net/dsa.h.

This patch reduces from around 800 files rebuilt to around 40 - even
with ccache, the time difference is noticable.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
I noticed when I touched linux/phy.h that a lot of the kernel ended up
being unexpectedly rebuilt, as linux/netdevice.h includes net/dsa.h,
which then then includes linux/phy.h.  I've tested this change on both
ARM and ARM64, but I'd suggest letting the 0-day builder have a bite
at this, and then only taking it if everyone is confident that there's
a slim chance of any problems.  Also, it may need some rework to apply
to davem's tree.  All of the above makes this RFC only.

 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
 include/net/dsa.h                     | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a319c06d82e3..d247b0639ed4 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -15,6 +15,7 @@
 #include <linux/if_vlan.h>
 #include <linux/irq.h>
 #include <linux/gpio/consumer.h>
+#include <linux/phy.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b122196d5a1f..887b2f98f9ea 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,15 +11,17 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
-#include <linux/phy.h>
-#include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
 
+struct phy_device;
+struct fixed_phy_status;
+
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
 	DSA_TAG_PROTO_DSA,

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
