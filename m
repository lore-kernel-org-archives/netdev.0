From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 02/10] pktgen: Fix grammar errors and some poor
 wording in documentation
Date: Tue, 24 Feb 2015 02:31:52 +0000
Message-ID: <1424745112.4443.3.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Rob Jones <rob.jones@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55276 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbbBXCbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:31:55 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to Rob Jones for suggesting some of the changes.

Cc: Rob Jones <rob.jones@codethink.co.uk>
Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 Documentation/networking/pktgen.txt |   56 +++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 26 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 560c84ba9abd..fa0ad87e6597 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -3,11 +3,11 @@
                   HOWTO for the linux packet generator 
                   ------------------------------------
 
-Enable CONFIG_NET_PKTGEN to compile and build pktgen.o either in kernel
-or as module. Module is preferred. insmod pktgen if needed. Once running
-pktgen creates a thread on each CPU where each thread has affinity to its CPU.
-Monitoring and controlling is done via /proc. Easiest to select a suitable 
-a sample script and configure.
+Enable CONFIG_NET_PKTGEN to compile and build pktgen.o either in-kernel
+or as a module.  A module is preferred; insmod pktgen if needed.  Once
+running, pktgen creates a thread for each CPU with affinity to that CPU.
+Monitoring and controlling is done via /proc.  It is easiest to select a
+suitable sample script and configure that.
 
 On a dual CPU:
 
@@ -25,7 +25,7 @@ For monitoring and control pktgen creates:
 Tuning NIC for max performance
 ==============================
 
-The default NIC setting are (likely) not tuned for pktgen's artificial
+The default NIC settings are (likely) not tuned for pktgen's artificial
 overload type of benchmarking, as this could hurt the normal use-case.
 
 Specifically increasing the TX ring buffer in the NIC:
@@ -33,20 +33,20 @@ Specifically increasing the TX ring buffer in the NIC:
 
 A larger TX ring can improve pktgen's performance, while it can hurt
 in the general case, 1) because the TX ring buffer might get larger
-than the CPUs L1/L2 cache, 2) because it allow more queueing in the
+than the CPU's L1/L2 cache, 2) because it allows more queueing in the
 NIC HW layer (which is bad for bufferbloat).
 
-One should be careful to conclude, that packets/descriptors in the HW
+One should hesitate to conclude that packets/descriptors in the HW
 TX ring cause delay.  Drivers usually delay cleaning up the
-ring-buffers (for various performance reasons), thus packets stalling
-the TX ring, might just be waiting for cleanup.
+ring-buffers for various performance reasons, and packets stalling
+the TX ring might just be waiting for cleanup.
 
-This cleanup issues is specifically the case, for the driver ixgbe
-(Intel 82599 chip).  This driver (ixgbe) combine TX+RX ring cleanups,
+This cleanup issue is specifically the case for the driver ixgbe
+(Intel 82599 chip).  This driver (ixgbe) combines TX+RX ring cleanups,
 and the cleanup interval is affected by the ethtool --coalesce setting
 of parameter "rx-usecs".
 
-For ixgbe use e.g "30" resulting in approx 33K interrupts/sec (1/30*10^6):
+For ixgbe use e.g. "30" resulting in approx 33K interrupts/sec (1/30*10^6):
  # ethtool -C ethX rx-usecs 30
 

@@ -58,15 +58,16 @@ Running:
 Stopped: eth1 
 Result: OK: max_before_softirq=10000
 
-Most important the devices assigned to thread. Note! A device can only belong 
-to one thread.
+Most important are the devices assigned to the thread.  Note that a
+device can only belong to one thread.
 

 Viewing devices
 ===============
 
-Parm section holds configured info. Current hold running stats. 
-Result is printed after run or after interruption. Example:
+The Params section holds configured information.  The Current section
+holds running statistics.  The Result is printed after a run or after
+interruption.  Example:
 
 /proc/net/pktgen/eth1       
 
@@ -91,7 +92,8 @@ Result: OK: 13101142(c12220741+d880401) usec, 10000000 (60byte,0frags)
 
 Configuring threads and devices
 ================================
-This is done via the /proc interface easiest done via pgset in the scripts
+This is done via the /proc interface, and most easily done via pgset in
+the scripts.
 
 Examples:
 
@@ -193,7 +195,8 @@ Examples:
 Example scripts
 ===============
 
-A collection of small tutorial scripts for pktgen is in examples dir.
+A collection of small tutorial scripts for pktgen is in the examples
+directory:
 
 pktgen.conf-1-1                  # 1 CPU 1 dev 
 pktgen.conf-1-2                  # 1 CPU 2 dev
@@ -204,25 +207,26 @@ pktgen.conf-1-1-ip6              # 1 CPU 1 dev ipv6
 pktgen.conf-1-1-ip6-rdos         # 1 CPU 1 dev ipv6  w. route DoS
 pktgen.conf-1-1-flows            # 1 CPU 1 dev multiple flows.
 
-Run in shell: ./pktgen.conf-X-Y It does all the setup including sending. 
+Run in shell: ./pktgen.conf-X-Y
+This does all the setup including sending.
 

 Interrupt affinity
 ===================
-Note when adding devices to a specific CPU there good idea to also assign 
-/proc/irq/XX/smp_affinity so the TX-interrupts gets bound to the same CPU.
-as this reduces cache bouncing when freeing skb's.
+Note that when adding devices to a specific CPU it is a good idea to
+also assign /proc/irq/XX/smp_affinity so that the TX interrupts are bound
+to the same CPU.  This reduces cache bouncing when freeing skbs.
 
 Enable IPsec
 ============
-Default IPsec transformation with ESP encapsulation plus Transport mode
-could be enabled by simply setting:
+Default IPsec transformation with ESP encapsulation plus transport mode
+can be enabled by simply setting:
 
 pgset "flag IPSEC"
 pgset "flows 1"
 
 To avoid breaking existing testbed scripts for using AH type and tunnel mode,
-user could use "pgset spi SPI_VALUE" to specify which formal of transformation
+you can use "pgset spi SPI_VALUE" to specify which transformation mode
 to employ.
 

-- 
1.7.10.4
