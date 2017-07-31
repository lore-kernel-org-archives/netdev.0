From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 2/3] netvsc: add documentation
Date: Mon, 31 Jul 2017 16:45:23 -0700
Message-ID: <20170731234524.30326-3-sthemmin@microsoft.com>
References: <20170731234524.30326-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
 corbet@lwn.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170731234524.30326-1-sthemmin@microsoft.com>
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

Add some background documentation on netvsc device options
and limitations.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 Documentation/networking/netvsc.txt | 63 +++++++++++++++++++++++++++++++++++++
 MAINTAINERS                         |  1 +
 2 files changed, 64 insertions(+)
 create mode 100644 Documentation/networking/netvsc.txt

diff --git a/Documentation/networking/netvsc.txt b/Documentation/networking/netvsc.txt
new file mode 100644
index 000000000000..4ddb4e4b0426
--- /dev/null
+++ b/Documentation/networking/netvsc.txt
@@ -0,0 +1,63 @@
+Hyper-V network driver
+======================
+
+Compatibility
+=============
+
+This driver is compatible with Windows Server 2012 R2, 2016 and
+Windows 10.
+
+Features
+========
+
+  Checksum offload
+  ----------------
+  The netvsc driver supports checksum offload as long as the
+  Hyper-V host version does. Windows Server 2016 and Azure
+  support checksum offload for TCP and UDP for both IPv4 and
+  IPv6. Windows Server 2012 only supports checksum offload for TCP.
+
+  Receive Side Scaling
+  --------------------
+  Hyper-V supports receive side scaling. For TCP, packets are
+  distributed among available queues based on IP address and port
+  number. Current versions of Hyper-V host, only distribute UDP
+  packets based on the IP source and destination address.
+  The port number is not used as part of the hash value for UDP.
+  Fragmented IP packets are not distributed between queues;
+  all fragmented packets arrive on the first channel.
+
+  Generic Receive Offload, aka GRO
+  --------------------------------
+  The driver supports GRO and it is enabled by default. GRO coalesces
+  like packets and significantly reduces CPU usage under heavy Rx
+  load.
+
+  SR-IOV support
+  --------------
+  Hyper-V supports SR-IOV as a hardware acceleration option. If SR-IOV
+  is enabled in both the vSwitch and the guest configuration, then the
+  Virtual Function (VF) device is passed to the guest as a PCI
+  device. In this case, both a synthetic (netvsc) and VF device are
+  visible in the guest OS and both NIC's have the same MAC address.
+
+  The VF is enslaved by netvsc device.  The netvsc driver will transparently
+  switch the data path to the VF when it is available and up.
+  Network state (addresses, firewall, etc) should be applied only to the
+  netvsc device; the slave device should not be accessed directly in
+  most cases.  The exceptions are if some special queue discipline or
+  flow direction is desired, these should be applied directly to the
+  VF slave device.
+
+  Receive Buffer
+  --------------
+  Packets are received into a receive area which is created when device
+  is probed. The receive area is broken into MTU sized chunks and each may
+  contain one or more packets. The number of receive sections may be changed
+  via ethtool Rx ring parameters.
+
+  There is a similar send buffer which is used to aggregate packets for sending.
+  The send area is broken into chunks of 6144 bytes, each of section may
+  contain one or more packets. The send buffer is an optimization, the driver
+  will use slower method to handle very large packets or if the send buffer
+  area is exhausted.
diff --git a/MAINTAINERS b/MAINTAINERS
index 297e610c9163..d30c17df1deb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6294,6 +6294,7 @@ M:	Haiyang Zhang <haiyangz@microsoft.com>
 M:	Stephen Hemminger <sthemmin@microsoft.com>
 L:	devel@linuxdriverproject.org
 S:	Maintained
+F:	Documentation/networking/netvsc.txt
 F:	arch/x86/include/asm/mshyperv.h
 F:	arch/x86/include/uapi/asm/hyperv.h
 F:	arch/x86/kernel/cpu/mshyperv.c
-- 
2.11.0
