From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/4] arm: mvebu: add Ethernet controllers using mvneta driver
 for Armada 370/XP
Date: Tue,  4 Sep 2012 15:06:43 +0200
Message-ID: <1346764004-16332-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 David Marlin <dmarlin@redhat.com>, Rami Rosen <rosenr@marvell.com>,
 Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
To: "David S. Miller" <davem@davemloft.net>,
 Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The Armada 370 SoC has two network units, while the Armada XP has four
network units. The first two network units are common to both the
Armada XP and Armada 370, so they are added to armada-370-xp.dtsi,
while the other two network units are specific to the Armada XP and
therefore added to armada-xp.dtsi.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-xp.dtsi |   16 ++++++++++++++++
 arch/arm/boot/dts/armada-xp.dtsi     |   16 ++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
index 6b6b932..52af710 100644
--- a/arch/arm/boot/dts/armada-370-xp.dtsi
+++ b/arch/arm/boot/dts/armada-370-xp.dtsi
@@ -63,6 +63,22 @@
 			       reg = <0xd0020300 0x30>;
 			       interrupts = <37>, <38>, <39>, <40>;
 		};
+
+                eth@d0070000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0070000 0x2500>;
+                               interrupts = <8>;
+                               device_type = "network";
+                               status = "disabled";
+                };
+
+                eth@d0074000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0074000 0x2500>;
+                               interrupts = <10>;
+                               device_type = "network";
+                               status = "disabled";
+                };
 	};
 };
 
diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
index 71d6b5d..59167dc 100644
--- a/arch/arm/boot/dts/armada-xp.dtsi
+++ b/arch/arm/boot/dts/armada-xp.dtsi
@@ -51,5 +51,21 @@
 				compatible = "marvell,armada-370-xp-system-controller";
 				reg = <0xd0018200 0x500>;
 		};
+
+                eth@d0030000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0030000 0x2500>;
+                               interrupts = <12>;
+                               device_type = "network";
+                               status = "disabled";
+                };
+
+                eth@d0034000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0034000 0x2500>;
+                               interrupts = <14>;
+                               device_type = "network";
+                               status = "disabled";
+                };
 	};
 };
-- 
1.7.9.5
