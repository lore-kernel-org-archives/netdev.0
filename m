From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: [PATCH v3 5/6] staging: fsl-dpaa2/ethsw: Add README
Date: Thu, 5 Oct 2017 12:16:13 +0300
Message-ID: <1507194974-12050-6-git-send-email-razvan.stefanescu@nxp.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, arnd@arndb.de, netdev@vger.kernel.org,
 alexandru.marginean@nxp.com, linux-kernel@vger.kernel.org, agraf@suse.de,
 stuyoder@gmail.com, bogdan.purcareata@nxp.com, laurentiu.tudor@nxp.com
To: <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Add a README file describing the driver architecture, components and
interfaces.

Signed-off-by: Razvan Stefanescu <razvan.stefanescu@nxp.com>
---
Changelog:
 v2:
    - no changes
 v3:
    - no changes

 drivers/staging/fsl-dpaa2/ethsw/README | 106 +++++++++++++++++++++++++++++++++
 1 file changed, 106 insertions(+)
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/README

diff --git a/drivers/staging/fsl-dpaa2/ethsw/README b/drivers/staging/fsl-dpaa2/ethsw/README
new file mode 100644
index 0000000..f6fc07f
--- /dev/null
+++ b/drivers/staging/fsl-dpaa2/ethsw/README
@@ -0,0 +1,106 @@
+DPAA2 Ethernet Switch driver
+============================
+
+This file provides documentation for the DPAA2 Ethernet Switch driver
+
+
+Contents
+========
+	Supported Platforms
+	Architecture Overview
+	Creating an Ethernet Switch
+	Features
+
+
+	Supported Platforms
+===================
+This driver provides networking support for Freescale LS2085A, LS2088A
+DPAA2 SoCs.
+
+
+Architecture Overview
+=====================
+The Ethernet Switch in the DPAA2 architecture consists of several hardware
+resources that provide the functionality. These are allocated and
+configured via the Management Complex (MC) portals. MC abstracts most of
+these resources as DPAA2 objects and exposes ABIs through which they can
+be configured and controlled.
+
+For a more detailed description of the DPAA2 architecture and its object
+abstractions see:
+	drivers/staging/fsl-mc/README.txt
+
+The Ethernet Switch is built on top of a Datapath Switch (DPSW) object.
+
+Configuration interface:
+
+          ---------------------
+         | DPAA2 Switch driver |
+          ---------------------
+                   .
+                   .
+              ----------
+             | DPSW API |
+              ----------
+                   .           software
+ ================= . ==============
+                   .           hardware
+          ---------------------
+         | MC hardware portals |
+          ---------------------
+                   .
+                   .
+                 ------
+                | DPSW |
+                 ------
+
+Driver uses the switch device driver model and exposes each switch port as
+a network interface, which can be included in a bridge. Traffic switched
+between ports is offloaded into the hardware. Exposed network interfaces
+are not used for I/O, they are used just for configuration. This
+limitation is going to be addressed in the future.
+
+The DPSW can have ports connected to DPNIs or to PHYs via DPMACs.
+
+
+ [ethA]     [ethB]     [ethC]     [ethD]     [ethE]     [ethF]
+    :          :          :          :          :          :
+    :          :          :          :          :          :
+[eth drv]  [eth drv]  [                ethsw drv              ]
+    :          :          :          :          :          :        kernel
+========================================================================
+    :          :          :          :          :          :        hardware
+ [DPNI]      [DPNI]     [============= DPSW =================]
+    |          |          |          |          |          |
+    |           ----------           |       [DPMAC]    [DPMAC]
+     -------------------------------            |          |
+                                                |          |
+                                              [PHY]      [PHY]
+
+For a more detailed description of the Ethernet switch device driver model
+see:
+	Documentation/networking/switchdev.txt
+
+Creating an Ethernet Switch
+===========================
+A device is created for the switch objects probed on the MC bus. Each DPSW
+has a number of properties which determine the configuration options and
+associated hardware resources.
+
+A DPSW object (and the other DPAA2 objects needed for a DPAA2 switch) can
+be added to a container on the MC bus in one of two ways: statically,
+through a Datapath Layout Binary file (DPL) that is parsed by MC at boot
+time; or created dynamically at runtime, via the DPAA2 objects APIs.
+
+Features
+========
+Driver configures DPSW to perform hardware switching offload of
+unicast/multicast/broadcast (VLAN tagged or untagged) traffic between its
+ports.
+
+It allows configuration of hardware learning, flooding, multicast groups,
+port VLAN configuration and STP state.
+
+Static entries can be added/removed from the FDB.
+
+Hardware statistics for each port are provided through ethtool -S option.
-- 
1.9.1
