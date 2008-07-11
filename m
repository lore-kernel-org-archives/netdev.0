From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Fri, 11 Jul 2008 01:27:59 -0400
Message-ID: <20080711052759.GA646@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56239 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572AbYGKF2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:28:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git dave=
m-next

to receive the following updates:

 Documentation/networking/ixgb.txt  |  419 ++++++++++----
 drivers/net/Kconfig                |   59 +--
 drivers/net/Makefile               |    1 -
 drivers/net/chelsio/cxgb2.c        |    2 -
 drivers/net/chelsio/sge.c          |   70 +--
 drivers/net/cxgb3/cxgb3_ctl_defs.h |    5 +-
 drivers/net/cxgb3/cxgb3_offload.c  |   11 +
 drivers/net/cxgb3/regs.h           |   10 +-
 drivers/net/cxgb3/t3_cpl.h         |   40 ++
 drivers/net/cxgb3/t3cdev.h         |    1 +
 drivers/net/gianfar.c              |   76 +---
 drivers/net/gianfar.h              |   11 -
 drivers/net/igb/e1000_82575.c      |  208 ++++++-
 drivers/net/igb/e1000_82575.h      |   22 +
 drivers/net/igb/e1000_defines.h    |   10 +
 drivers/net/igb/e1000_hw.h         |    8 +
 drivers/net/igb/e1000_mac.c        |    3 +-
 drivers/net/igb/e1000_mac.h        |    1 +
 drivers/net/igb/e1000_regs.h       |    9 +-
 drivers/net/igb/igb.h              |   47 ++-
 drivers/net/igb/igb_ethtool.c      |  203 +++++--
 drivers/net/igb/igb_main.c         | 1032 ++++++++++++++++++++++++----=
-----
 drivers/net/ixgb/Makefile          |    2 +-
 drivers/net/ixgb/ixgb.h            |   21 +-
 drivers/net/ixgb/ixgb_ee.c         |   28 +-
 drivers/net/ixgb/ixgb_ee.h         |   12 +-
 drivers/net/ixgb/ixgb_ethtool.c    |  120 ++--
 drivers/net/ixgb/ixgb_hw.c         |   40 +-
 drivers/net/ixgb/ixgb_hw.h         |    2 +-
 drivers/net/ixgb/ixgb_ids.h        |   10 +-
 drivers/net/ixgb/ixgb_main.c       |  480 +++++++---------
 drivers/net/ixgb/ixgb_osdep.h      |    4 +-
 drivers/net/ixgb/ixgb_param.c      |   44 +-
 drivers/net/phy/mdio-bitbang.c     |    2 +
 drivers/net/s2io.c                 |   90 ++--
 drivers/net/s2io.h                 |    1 +
 drivers/net/saa9730.c              | 1139 ----------------------------=
--------
 drivers/net/saa9730.h              |  384 ------------
 drivers/net/ucc_geth.c             |   29 +-
 drivers/net/via-rhine.c            |   27 +-
 drivers/net/via-velocity.c         |  158 ++---
 drivers/net/via-velocity.h         |    5 -
 drivers/net/virtio_net.c           |    3 +-
 include/linux/netdevice.h          |   13 +
 44 files changed, 2071 insertions(+), 2791 deletions(-)
 delete mode 100644 drivers/net/saa9730.c
 delete mode 100644 drivers/net/saa9730.h

Alexander Duyck (9):
      igb: update ethtool stats to support multiqueue
      igb: add 82576 MAC support
      igb: Add support for quad port WOL and feature flags
      igb: add page recycling support
      igb: add support for in kernel LRO
      net: add netif_napi_del function to allow for removal of napistru=
cts
      igb: update suspend resume
      igb: unused variable warning in igb remove
      igb: Improve multiqueue AIM support

Auke Kok (2):
      igb: reenable CRC stripping in hardware
      igb: Increment driver version

=46rancois Romieu (8):
      via-velocity: remove the bounce buffers
      via-velocity: lean and clean velocity_init_rings
      via-velocity: move residual free rx descriptors count register up=
date
      via-velocity: add velocity_set_rxbufsize helper
      cxgb: delete non NAPI code from the driver.
      via-rhine: delete non NAPI code from the driver.
      gianfar: delete non NAPI code from the driver.
      ucc_geth: delete non NAPI code from the driver.

Jeb Cramer (1):
      igb: add DCA support

Jesse Brandeburg (25):
      ixgb: maybe stop tx port missed a piece
      ixgb: repeat 32 bit ioremap cleanup
      ixgb: fix bug in descriptor ring due to prefetch corruption
      ixgb: leave room for extra hardware memory usage
      ixgb: check down state before enable irq
      ixgb: don't allow too small MTU
      ixgb: move time stamp set before setting dma pointer
      ixgb: fix race on rx_buffer_len in mtu change
      ixgb: fix unload race with timers
      ixgb: remove lltx support and update tx routine
      ixgb: update readme text
      ixgb: add copybreak parameter
      ixgb: clean up un-necessary declarations
      ixgb: format all if( to be if (
      ixgb: cleanup space after while
      ixgb: whitespace fixups
      ixgb: fix spelling errors
      ixgb: trivial fix space after for
      ixgb: cleanup checkpatch suggestions that are relevant
      ixgb: rx cleanup performance improvements
      ixgb: clean up assignments inside if statements
      ixgb: audit use of dev_kfree_skb_any
      ixgb: cleanup header
      ixgb: make NAPI the only option and the default
      ixgb: update copyright dates and versions

Karen Xie (1):
      cxgb3 - Add iscsi support

Mark McLoughlin (1):
      virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature

Peter P Waskiewicz Jr (1):
      igb: Introduce multiple TX queues with infrastructure

Ralf Baechle (1):
      SAA9730: Remove driver

Sreenivasa Honnur (3):
      S2io: Fix IOMMU overflow checking.
      S2io: Enable msi-x link interrupts.
      S2io: Version update for IOMMU overflow checking and enable msi-x=
 link interrupts patches.

Takashi Iwai (1):
      Fix missing exports for net/phy/mdio-bitbang.c

diff --git a/Documentation/networking/ixgb.txt b/Documentation/networki=
ng/ixgb.txt
index 7c98277..a0d0ffb 100644
--- a/Documentation/networking/ixgb.txt
+++ b/Documentation/networking/ixgb.txt
@@ -1,7 +1,7 @@
-Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+Linux Base Driver for 10 Gigabit Intel(R) Network Connection
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-November 17, 2004
+October 9, 2007
=20
=20
 Contents
@@ -9,94 +9,151 @@ Contents
=20
 - In This Release
 - Identifying Your Adapter
+- Building and Installation
 - Command Line Parameters
 - Improving Performance
+- Additional Configurations
+- Known Issues/Troubleshooting
 - Support
=20
=20
+
 In This Release
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE =
=46amily=20
-of Adapters, version 1.0.x. =20
+This file describes the ixgb Linux Base Driver for the 10 Gigabit Inte=
l(R)
+Network Connection.  This driver includes support for Itanium(R)2-base=
d
+systems.
+
+For questions related to hardware requirements, refer to the documenta=
tion
+supplied with your 10 Gigabit adapter.  All hardware requirements list=
ed apply
+to use with Linux.
+
+The following features are available in this kernel:
+ - Native VLANs
+ - Channel Bonding (teaming)
+ - SNMP
+
+Channel Bonding documentation can be found in the Linux kernel source:
+/Documentation/networking/bonding.txt
+
+The driver information previously displayed in the /proc filesystem is=
 not
+supported in this release.  Alternatively, you can use ethtool (versio=
n 1.6
+or later), lspci, and ifconfig to obtain the same information.
+
+Instructions on updating ethtool can be found in the section "Addition=
al
+Configurations" later in this document.
=20
-For questions related to hardware requirements, refer to the documenta=
tion=20
-supplied with your Intel PRO/10GbE adapter. All hardware requirements =
listed=20
-apply to use with Linux.
=20
 Identifying Your Adapter
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-To verify your Intel adapter is supported, find the board ID number on=
 the=20
-adapter. Look for a label that has a barcode and a number in the forma=
t =20
-A12345-001.=20
+The following Intel network adapters are compatible with the drivers i=
n this
+release:
+
+Controller  Adapter Name                 Physical Layer
+----------  ------------                 --------------
+82597EX     Intel(R) PRO/10GbE LR/SR/CX4 10G Base-LR (1310 nm optical =
fiber)
+            Server Adapters              10G Base-SR (850 nm optical f=
iber)
+                                         10G Base-CX4(twin-axial coppe=
r cabling)
+
+For more information on how to identify your adapter, go to the Adapte=
r &
+Driver ID Guide at:
+
+    http://support.intel.com/support/network/sb/CS-012904.htm
+
+
+Building and Installation
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
+
+select m for "Intel(R) PRO/10GbE support" located at:
+      Location:
+        -> Device Drivers
+          -> Network device support (NETDEVICES [=3Dy])
+            -> Ethernet (10000 Mbit) (NETDEV_10000 [=3Dy])
+1. make modules && make modules_install
+
+2. Load the module:
+
+=A0=A0=A0=A0modprobe ixgb <parameter>=3D<value>
+
+   The insmod command can be used if the full
+   path to the driver module is specified.  For example:
+
+     insmod /lib/modules/<KERNEL VERSION>/kernel/drivers/net/ixgb/ixgb=
=2Eko
+
+   With 2.6 based kernels also make sure that older ixgb drivers are
+   removed from the kernel, before loading the new module:
=20
-Use the above information and the Adapter & Driver ID Guide at:
+     rmmod ixgb; modprobe ixgb
=20
-  http://support.intel.com/support/network/adapter/pro100/21397.htm
+3. Assign an IP address to the interface by entering the following, wh=
ere
+   x is the interface number:
=20
-For the latest Intel network drivers for Linux, go to:
+     ifconfig ethx <IP_address>
+
+4. Verify that the interface works. Enter the following, where <IP_add=
ress>
+   is the IP address for another machine on the same subnet as the int=
erface
+   that is being tested:
+
+     ping  <IP_address>
=20
-    http://downloadfinder.intel.com/scripts-df/support_intel.asp
=20
 Command Line Parameters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-If the driver is built as a module, the  following optional parameters=
 are=20
-used by entering them on the command line with the modprobe or insmod =
command
-using this syntax:
+If the driver is built as a module, the  following optional parameters=
 are
+used by entering them on the command line with the modprobe command us=
ing
+this syntax:
=20
      modprobe ixgb [<option>=3D<VAL1>,<VAL2>,...]
=20
-     insmod ixgb [<option>=3D<VAL1>,<VAL2>,...]
+For example, with two 10GbE PCI adapters, entering:
=20
-For example, with two PRO/10GbE PCI adapters, entering:
+     modprobe ixgb TxDescriptors=3D80,128
=20
-    insmod ixgb TxDescriptors=3D80,128
-
-loads the ixgb driver with 80 TX resources for the first adapter and 1=
28 TX=20
+loads the ixgb driver with 80 TX resources for the first adapter and 1=
28 TX
 resources for the second adapter.
=20
 The default value for each parameter is generally the recommended sett=
ing,
-unless otherwise noted. Also, if the driver is statically built into t=
he
-kernel, the driver is loaded with the default values for all the param=
eters.
-Ethtool can be used to change some of the parameters at runtime.
+unless otherwise noted.
=20
 FlowControl
 Valid Range: 0-3 (0=3Dnone, 1=3DRx only, 2=3DTx only, 3=3DRx&Tx)
 Default: Read from the EEPROM
-         If EEPROM is not detected, default is 3
-    This parameter controls the automatic generation(Tx) and response(=
Rx) to=20
-    Ethernet PAUSE frames.
+         If EEPROM is not detected, default is 1
+    This parameter controls the automatic generation(Tx) and response(=
Rx) to
+    Ethernet PAUSE frames.  There are hardware bugs associated with en=
abling
+    Tx flow control so beware.
=20
 RxDescriptors
 Valid Range: 64-512
 Default Value: 512
-    This value is the number of receive descriptors allocated by the d=
river.=20
-    Increasing this value allows the driver to buffer more incoming pa=
ckets.=20
-    Each descriptor is 16 bytes.  A receive buffer is also allocated f=
or=20
-    each descriptor and can be either 2048, 4056, 8192, or 16384 bytes=
,=20
-    depending on the MTU setting. When the MTU size is 1500 or less, t=
he=20
+    This value is the number of receive descriptors allocated by the d=
river.
+    Increasing this value allows the driver to buffer more incoming pa=
ckets.
+    Each descriptor is 16 bytes.  A receive buffer is also allocated f=
or
+    each descriptor and can be either 2048, 4056, 8192, or 16384 bytes=
,
+    depending on the MTU setting.  When the MTU size is 1500 or less, =
the
     receive buffer size is 2048 bytes. When the MTU is greater than 15=
00 the
-    receive buffer size will be either 4056, 8192, or 16384 bytes. The=
=20
+    receive buffer size will be either 4056, 8192, or 16384 bytes.  Th=
e
     maximum MTU size is 16114.
=20
 RxIntDelay
 Valid Range: 0-65535 (0=3Doff)
-Default Value: 6
-    This value delays the generation of receive interrupts in units of=
=20
-    0.8192 microseconds.  Receive interrupt reduction can improve CPU=20
-    efficiency if properly tuned for specific network traffic. Increas=
ing=20
-    this value adds extra latency to frame reception and can end up=20
-    decreasing the throughput of TCP traffic. If the system is reporti=
ng=20
-    dropped receives, this value may be set too high, causing the driv=
er to=20
+Default Value: 72
+    This value delays the generation of receive interrupts in units of
+    0.8192 microseconds.  Receive interrupt reduction can improve CPU
+    efficiency if properly tuned for specific network traffic.  Increa=
sing
+    this value adds extra latency to frame reception and can end up
+    decreasing the throughput of TCP traffic.  If the system is report=
ing
+    dropped receives, this value may be set too high, causing the driv=
er to
     run out of available receive descriptors.
=20
 TxDescriptors
 Valid Range: 64-4096
 Default Value: 256
     This value is the number of transmit descriptors allocated by the =
driver.
-    Increasing this value allows the driver to queue more transmits. E=
ach=20
+    Increasing this value allows the driver to queue more transmits.  =
Each
     descriptor is 16 bytes.
=20
 XsumRX
@@ -105,51 +162,49 @@ Default Value: 1
     A value of '1' indicates that the driver should enable IP checksum
     offload for received packets (both UDP and TCP) to the adapter har=
dware.
=20
-XsumTX
-Valid Range: 0-1
-Default Value: 1
-    A value of '1' indicates that the driver should enable IP checksum
-    offload for transmitted packets (both UDP and TCP) to the adapter=20
-    hardware.
=20
 Improving Performance
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-With the Intel PRO/10 GbE adapter, the default Linux configuration wil=
l very=20
-likely limit the total available throughput artificially.  There is a =
set of=20
-things that when applied together increase the ability of Linux to tra=
nsmit=20
-and receive data.  The following enhancements were originally acquired=
 from
-settings published at http://www.spec.org/web99 for various submitted =
results=20
-using Linux.
+With the 10 Gigabit server adapters, the default Linux configuration w=
ill
+very likely limit the total available throughput artificially.  There =
is a set
+of configuration changes that, when applied together, will increase th=
e ability
+of Linux to transmit and receive data.  The following enhancements wer=
e
+originally acquired from settings published at http://www.spec.org/web=
99/ for
+various submitted results using Linux.
=20
-NOTE: These changes are only suggestions, and serve as a starting poin=
t for=20
-tuning your network performance.
+NOTE: These changes are only suggestions, and serve as a starting poin=
t for
+      tuning your network performance.
=20
 The changes are made in three major ways, listed in order of greatest =
effect:
-- Use ifconfig to modify the mtu (maximum transmission unit) and the t=
xqueuelen=20
+- Use ifconfig to modify the mtu (maximum transmission unit) and the t=
xqueuelen
   parameter.
 - Use sysctl to modify /proc parameters (essentially kernel tuning)
-- Use setpci to modify the MMRBC field in PCI-X configuration space to=
 increase=20
+- Use setpci to modify the MMRBC field in PCI-X configuration space to=
 increase
   transmit burst lengths on the bus.
=20
-NOTE: setpci modifies the adapter's configuration registers to allow i=
t to read=20
-up to 4k bytes at a time (for transmits).  However, for some systems t=
he=20
-behavior after modifying this register may be undefined (possibly erro=
rs of some=20
-kind). A power-cycle, hard reset or explicitly setting the e6 register=
 back to=20
-22 (setpci -d 8086:1048 e6.b=3D22) may be required to get back to a st=
able=20
-configuration.
+NOTE: setpci modifies the adapter's configuration registers to allow i=
t to read
+up to 4k bytes at a time (for transmits).  However, for some systems t=
he
+behavior after modifying this register may be undefined (possibly erro=
rs of
+some kind).  A power-cycle, hard reset or explicitly setting the e6 re=
gister
+back to 22 (setpci -d 8086:1a48 e6.b=3D22) may be required to get back=
 to a
+stable configuration.
=20
 - COPY these lines and paste them into ixgb_perf.sh:
 #!/bin/bash
-echo "configuring network performance , edit this file to change the i=
nterface"
+echo "configuring network performance , edit this file to change the i=
nterface
+or device ID of 10GbE card"
 # set mmrbc to 4k reads, modify only Intel 10GbE device IDs
-setpci -d 8086:1048 e6.b=3D2e
-# set the MTU (max transmission unit) - it requires your switch and cl=
ients to change too!
+# replace 1a48 with appropriate 10GbE device's ID installed on the sys=
tem,
+# if needed.
+setpci -d 8086:1a48 e6.b=3D2e
+# set the MTU (max transmission unit) - it requires your switch and cl=
ients
+# to change as well.
 # set the txqueuelen
 # your ixgb adapter should be loaded as eth1 for this to work, change =
if needed
 ifconfig eth1 mtu 9000 txqueuelen 1000 up
-# call the sysctl utility to modify /proc/sys entries=20
-sysctl -p ./sysctl_ixgb.conf=20
+# call the sysctl utility to modify /proc/sys entries
+sysctl -p ./sysctl_ixgb.conf
 - END ixgb_perf.sh
=20
 - COPY these lines and paste them into sysctl_ixgb.conf:
@@ -159,54 +214,220 @@ sysctl -p ./sysctl_ixgb.conf
 # several network benchmark tests, your mileage may vary
=20
 ### IPV4 specific settings
-net.ipv4.tcp_timestamps =3D 0 # turns TCP timestamp support off, defau=
lt 1, reduces CPU use
-net.ipv4.tcp_sack =3D 0 # turn SACK support off, default on
-# on systems with a VERY fast bus -> memory interface this is the big =
gainer=20
-net.ipv4.tcp_rmem =3D 10000000 10000000 10000000 # sets min/default/ma=
x TCP read buffer, default 4096 87380 174760
-net.ipv4.tcp_wmem =3D 10000000 10000000 10000000 # sets min/pressure/m=
ax TCP write buffer, default 4096 16384 131072
-net.ipv4.tcp_mem =3D 10000000 10000000 10000000 # sets min/pressure/ma=
x TCP buffer space, default 31744 32256 32768
+# turn TCP timestamp support off, default 1, reduces CPU use
+net.ipv4.tcp_timestamps =3D 0
+# turn SACK support off, default on
+# on systems with a VERY fast bus -> memory interface this is the big =
gainer
+net.ipv4.tcp_sack =3D 0
+# set min/default/max TCP read buffer, default 4096 87380 174760
+net.ipv4.tcp_rmem =3D 10000000 10000000 10000000
+# set min/pressure/max TCP write buffer, default 4096 16384 131072
+net.ipv4.tcp_wmem =3D 10000000 10000000 10000000
+# set min/pressure/max TCP buffer space, default 31744 32256 32768
+net.ipv4.tcp_mem =3D 10000000 10000000 10000000
=20
 ### CORE settings (mostly for socket and UDP effect)
-net.core.rmem_max =3D 524287 # maximum receive socket buffer size, def=
ault 131071
-net.core.wmem_max =3D 524287 # maximum send socket buffer size, defaul=
t 131071
-net.core.rmem_default =3D 524287 # default receive socket buffer size,=
 default 65535
-net.core.wmem_default =3D 524287 # default send socket buffer size, de=
fault 65535
-net.core.optmem_max =3D 524287 # maximum amount of option memory buffe=
rs, default 10240
-net.core.netdev_max_backlog =3D 300000 # number of unprocessed input p=
ackets before kernel starts dropping them, default 300
+# set maximum receive socket buffer size, default 131071
+net.core.rmem_max =3D 524287
+# set maximum send socket buffer size, default 131071
+net.core.wmem_max =3D 524287
+# set default receive socket buffer size, default 65535
+net.core.rmem_default =3D 524287
+# set default send socket buffer size, default 65535
+net.core.wmem_default =3D 524287
+# set maximum amount of option memory buffers, default 10240
+net.core.optmem_max =3D 524287
+# set number of unprocessed input packets before kernel starts droppin=
g them; default 300
+net.core.netdev_max_backlog =3D 300000
 - END sysctl_ixgb.conf
=20
-Edit the ixgb_perf.sh script if necessary to change eth1 to whatever i=
nterface=20
-your ixgb driver is using.
+Edit the ixgb_perf.sh script if necessary to change eth1 to whatever i=
nterface
+your ixgb driver is using and/or replace '1a48' with appropriate 10GbE=
 device's
+ID installed on the system.
=20
-NOTE: Unless these scripts are added to the boot process, these change=
s will=20
-only last only until the next system reboot.
+NOTE: Unless these scripts are added to the boot process, these change=
s will
+      only last only until the next system reboot.
=20
=20
 Resolving Slow UDP Traffic
 --------------------------
+If your server does not seem to be able to receive UDP traffic as fast=
 as it
+can receive TCP traffic, it could be because Linux, by default, does n=
ot set
+the network stack buffers as large as they need to be to support high =
UDP
+transfer rates.  One way to alleviate this problem is to allow more me=
mory to
+be used by the IP stack to store incoming data.
=20
-If your server does not seem to be able to receive UDP traffic as fast=
 as it=20
-can receive TCP traffic, it could be because Linux, by default, does n=
ot set=20
-the network stack buffers as large as they need to be to support high =
UDP=20
-transfer rates. One way to alleviate this problem is to allow more mem=
ory to=20
-be used by the IP stack to store incoming data.=20
-
-For instance, use the commands:=20
+For instance, use the commands:
     sysctl -w net.core.rmem_max=3D262143
 and
     sysctl -w net.core.rmem_default=3D262143
-to increase the read buffer memory max and default to 262143 (256k - 1=
) from=20
-defaults of max=3D131071 (128k - 1) and default=3D65535 (64k - 1). The=
se variables=20
-will increase the amount of memory used by the network stack for recei=
ves, and=20
+to increase the read buffer memory max and default to 262143 (256k - 1=
) from
+defaults of max=3D131071 (128k - 1) and default=3D65535 (64k - 1).  Th=
ese variables
+will increase the amount of memory used by the network stack for recei=
ves, and
 can be increased significantly more if necessary for your application.
=20
+
+Additional Configurations
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
+
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+  Configuring a network driver to load properly when the system is sta=
rted is
+  distribution dependent. Typically, the configuration process involve=
s adding
+  an alias line to /etc/modprobe.conf as well as editing other system =
startup
+  scripts and/or configuration files.  Many popular Linux distribution=
s ship
+  with tools to make these changes for you.  To learn the proper way t=
o
+  configure a network device for your system, refer to your distributi=
on
+  documentation.  If during this process you are asked for the driver =
or module
+  name, the name for the Linux Base Driver for the Intel 10GbE Family =
of
+  Adapters is ixgb.
+
+  Viewing Link Messages
+  ---------------------
+  Link messages will not be displayed to the console if the distributi=
on is
+  restricting system messages. In order to see network driver link mes=
sages on
+  your console, set dmesg to eight by entering the following:
+
+       dmesg -n 8
+
+  NOTE: This setting is not saved across reboots.
+
+
+  Jumbo Frames
+  ------------
+  The driver supports Jumbo Frames for all adapters. Jumbo Frames supp=
ort is
+  enabled by changing the MTU to a value larger than the default of 15=
00.
+  The maximum value for the MTU is 16114.  Use the ifconfig command to
+  increase the MTU size.  For example:
+
+        ifconfig ethx mtu 9000 up
+
+  The maximum MTU setting for Jumbo Frames is 16114.  This value coinc=
ides
+  with the maximum Jumbo Frames size of 16128.
+
+
+  Ethtool
+  -------
+  The driver utilizes the ethtool interface for driver configuration a=
nd
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found from
+  http://sourceforge.net/projects/gkernel
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Su=
pport
+        for a more complete ethtool feature set can be enabled by upgr=
ading
+        to the latest version.
+
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the ixgb driver.  NAPI is ena=
bled
+  or disabled based on the configuration of the kernel.  see CONFIG_IX=
GB_NAPI
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NA=
PI.
+
+
+Known Issues/Troubleshooting
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+  NOTE: After installing the driver, if your Intel Network Connection =
is not
+  working, verify in the "In This Release" section of the readme that =
you have
+  installed the correct driver.
+
+  Intel(R) PRO/10GbE CX4 Server Adapter Cable Interoperability Issue w=
ith
+  Fujitsu XENPAK Module in SmartBits Chassis
+  --------------------------------------------------------------------=
-
+  Excessive CRC errors may be observed if the Intel(R) PRO/10GbE CX4
+  Server adapter is connected to a Fujitsu XENPAK CX4 module in a Smar=
tBits
+  chassis using 15 m/24AWG cable assemblies manufactured by Fujitsu or=
 Leoni.
+  The CRC errors may be received either by the Intel(R) PRO/10GbE CX4
+  Server adapter or the SmartBits. If this situation occurs using a di=
fferent
+  cable assembly may resolve the issue.
+
+  CX4 Server Adapter Cable Interoperability Issues with HP Procurve 34=
00cl
+  Switch Port
+  --------------------------------------------------------------------=
----
+  Excessive CRC errors may be observed if the Intel(R) PRO/10GbE CX4 S=
erver
+  adapter is connected to an HP Procurve 3400cl switch port using shor=
t cables
+  (1 m or shorter). If this situation occurs, using a longer cable may=
 resolve
+  the issue.
+
+  Excessive CRC errors may be observed using Fujitsu 24AWG cable assem=
blies that
+  Are 10 m or longer or where using a Leoni 15 m/24AWG cable assembly.=
 The CRC
+  errors may be received either by the CX4 Server adapter or at the sw=
itch. If
+  this situation occurs, using a different cable assembly may resolve =
the issue.
+
+
+  Jumbo Frames System Requirement
+  -------------------------------
+  Memory allocation failures have been observed on Linux systems with =
64 MB
+  of RAM or less that are running Jumbo Frames.  If you are using Jumb=
o
+  Frames, your system may require more than the advertised minimum
+  requirement of 64 MB of system memory.
+
+
+  Performance Degradation with Jumbo Frames
+  -----------------------------------------
+  Degradation in throughput performance may be observed in some Jumbo =
frames
+  environments.  If this is observed, increasing the application's soc=
ket buffer
+  size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry values =
may help.
+  See the specific application manual and /usr/src/linux*/Documentatio=
n/
+  networking/ip-sysctl.txt for more details.
+
+
+  Allocating Rx Buffers when Using Jumbo Frames
+  ---------------------------------------------
+  Allocating Rx buffers when using Jumbo Frames on 2.6.x kernels may f=
ail if
+  the available memory is heavily fragmented. This issue may be seen w=
ith PCI-X
+  adapters or with packet split disabled. This can be reduced or elimi=
nated
+  by changing the amount of available memory for receive buffer alloca=
tion, by
+  increasing /proc/sys/vm/min_free_kbytes.
+
+
+  Multiple Interfaces on Same Ethernet Broadcast Network
+  ------------------------------------------------------
+  Due to the default ARP behavior on Linux, it is not possible to have
+  one system on two IP networks in the same Ethernet broadcast domain
+  (non-partitioned switch) behave as expected.  All Ethernet interface=
s
+  will respond to IP traffic for any IP address assigned to the system=
=2E
+  This results in unbalanced receive traffic.
+
+  If you have multiple interfaces in a server, do either of the follow=
ing:
+
+  - Turn on ARP filtering by entering:
+      echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
+
+  - Install the interfaces in separate broadcast domains - either in
+    different switches or in a switch partitioned to VLANs.
+
+
+  UDP Stress Test Dropped Packet Issue
+  --------------------------------------
+  Under small packets UDP stress test with 10GbE driver, the Linux sys=
tem
+  may drop UDP packets due to the fullness of socket buffers. You may =
want
+  to change the driver's Flow Control variables to the minimum value f=
or
+  controlling packet reception.
+
+
+  Tx Hangs Possible Under Stress
+  ------------------------------
+  Under stress conditions, if TX hangs occur, turning off TSO
+  "ethtool -K eth0 tso off" may resolve the problem.
+
+
 Support
 =3D=3D=3D=3D=3D=3D=3D
=20
-For general information and support, go to the Intel support website a=
t:
+For general information, go to the Intel support website at:
=20
     http://support.intel.com
=20
+or the Intel Wired Networking project hosted by Sourceforge at:
+
+    http://sourceforge.net/projects/e1000
+
 If an issue is identified with the released source code on the support=
ed
-kernel with a supported adapter, email the specific information relate=
d to=20
-the issue to linux.nics@intel.com.
+kernel with a supported adapter, email the specific information relate=
d
+to the issue to e1000-devel@lists.sf.net
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4675c1b..9490cb1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1694,26 +1694,6 @@ config VIA_RHINE_MMIO
=20
 	  If unsure, say Y.
=20
-config VIA_RHINE_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on VIA_RHINE
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-config LAN_SAA9730
-	bool "Philips SAA9730 Ethernet support"
-	depends on NET_PCI && PCI && MIPS_ATLAS
-	help
-	  The SAA9730 is a combined multimedia and peripheral controller used
-	  in thin clients, Internet access terminals, and diskless
-	  workstations.
-	  See <http://www.semiconductors.philips.com/pip/SAA9730_flyer_1>.
-
 config SC92031
 	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTA=
L)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
@@ -2029,6 +2009,15 @@ config IGB
          To compile this driver as a module, choose M here. The module
          will be called igb.
=20
+config IGB_LRO=20
+	bool "Use software LRO"
+	depends on IGB && INET
+	select INET_LRO
+	---help---
+	  Say Y here if you want to use large receive offload.=20
+
+	  If in doubt, say N.
+
 source "drivers/net/ixp2000/Kconfig"
=20
 config MYRI_SBUS
@@ -2273,10 +2262,6 @@ config GIANFAR
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
 	  and MPC86xx family of chips, and the FEC on the 8540.
=20
-config GFAR_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on GIANFAR
-
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
@@ -2285,10 +2270,6 @@ config UCC_GETH
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
 	  which is available on some Freescale SOCs.
=20
-config UGETH_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on UCC_GETH
-
 config UGETH_MAGIC_PACKET
 	bool "Magic Packet detection support"
 	depends on UCC_GETH
@@ -2378,14 +2359,6 @@ config CHELSIO_T1_1G
           Enables support for Chelsio's gigabit Ethernet PCI cards.  I=
f you
           are using only 10G cards say 'N' here.
=20
-config CHELSIO_T1_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on CHELSIO_T1
-	default y
-	help
-	  NAPI is a driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card.
-
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on PCI && INET
@@ -2457,20 +2430,6 @@ config IXGB
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgb.
=20
-config IXGB_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on IXGB && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4beb043..3292d0a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -166,7 +166,6 @@ obj-$(CONFIG_EEXPRESS_PRO) +=3D eepro.o
 obj-$(CONFIG_8139CP) +=3D 8139cp.o
 obj-$(CONFIG_8139TOO) +=3D 8139too.o
 obj-$(CONFIG_ZNET) +=3D znet.o
-obj-$(CONFIG_LAN_SAA9730) +=3D saa9730.o
 obj-$(CONFIG_CPMAC) +=3D cpmac.o
 obj-$(CONFIG_DEPCA) +=3D depca.o
 obj-$(CONFIG_EWRK3) +=3D ewrk3.o
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index a509337..638c9a2 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1153,9 +1153,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller =3D t1_netpoll;
 #endif
-#ifdef CONFIG_CHELSIO_T1_NAPI
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
-#endif
=20
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 8a7efd3..d6c7d2a 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1396,20 +1396,10 @@ static void sge_rx(struct sge *sge, struct free=
lQ *fl, unsigned int len)
=20
 	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
 		st->vlan_xtract++;
-#ifdef CONFIG_CHELSIO_T1_NAPI
-			vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
-						 ntohs(p->vlan));
-#else
-			vlan_hwaccel_rx(skb, adapter->vlan_grp,
-					ntohs(p->vlan));
-#endif
-	} else {
-#ifdef CONFIG_CHELSIO_T1_NAPI
+		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
+					 ntohs(p->vlan));
+	} else
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
-	}
 }
=20
 /*
@@ -1568,7 +1558,6 @@ static inline int responses_pending(const struct =
adapter *adapter)
 	return (e->GenerationBit =3D=3D Q->genbit);
 }
=20
-#ifdef CONFIG_CHELSIO_T1_NAPI
 /*
  * A simpler version of process_responses() that handles only pure (i.=
e.,
  * non data-carrying) responses.  Such respones are too light-weight t=
o justify
@@ -1636,9 +1625,6 @@ int t1_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
=20
-/*
- * NAPI version of the main interrupt handler.
- */
 irqreturn_t t1_interrupt(int irq, void *data)
 {
 	struct adapter *adapter =3D data;
@@ -1656,7 +1642,8 @@ irqreturn_t t1_interrupt(int irq, void *data)
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-				napi_enable(&adapter->napi);	/* undo schedule_prep */
+				/* undo schedule_prep */
+				napi_enable(&adapter->napi);
 			}
 		}
 		return IRQ_HANDLED;
@@ -1672,53 +1659,6 @@ irqreturn_t t1_interrupt(int irq, void *data)
 	return IRQ_RETVAL(handled !=3D 0);
 }
=20
-#else
-/*
- * Main interrupt handler, optimized assuming that we took a 'DATA'
- * interrupt.
- *
- * 1. Clear the interrupt
- * 2. Loop while we find valid descriptors and process them; accumulat=
e
- *      information that can be processed after the loop
- * 3. Tell the SGE at which index we stopped processing descriptors
- * 4. Bookkeeping; free TX buffers, ring doorbell if there are any
- *      outstanding TX buffers waiting, replenish RX buffers, potentia=
lly
- *      reenable upper layers if they were turned off due to lack of T=
X
- *      resources which are available again.
- * 5. If we took an interrupt, but no valid respQ descriptors was foun=
d we
- *      let the slow_intr_handler run and do error handling.
- */
-irqreturn_t t1_interrupt(int irq, void *cookie)
-{
-	int work_done;
-	struct adapter *adapter =3D cookie;
-	struct respQ *Q =3D &adapter->sge->respQ;
-
-	spin_lock(&adapter->async_lock);
-
-	writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
-
-	if (likely(responses_pending(adapter)))
-		work_done =3D process_responses(adapter, -1);
-	else
-		work_done =3D t1_slow_intr_handler(adapter);
-
-	/*
-	 * The unconditional clearing of the PL_CAUSE above may have raced
-	 * with DMA completion and the corresponding generation of a response
-	 * to cause us to miss the resulting data interrupt.  The next write
-	 * is also unconditional to recover the missed interrupt and render
-	 * this race harmless.
-	 */
-	writel(Q->cidx, adapter->regs + A_SG_SLEEPING);
-
-	if (!work_done)
-		adapter->sge->stats.unhandled_irqs++;
-	spin_unlock(&adapter->async_lock);
-	return IRQ_RETVAL(work_done !=3D 0);
-}
-#endif
-
 /*
  * Enqueues the sk_buff onto the cmdQ[qid] and has hardware fetch it.
  *
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxg=
b3_ctl_defs.h
index 6c4f320..d38e6cc 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -110,10 +110,7 @@ struct ulp_iscsi_info {
 	unsigned int llimit;
 	unsigned int ulimit;
 	unsigned int tagmask;
-	unsigned int pgsz3;
-	unsigned int pgsz2;
-	unsigned int pgsz1;
-	unsigned int pgsz0;
+	u8 pgsz_factor[4];
 	unsigned int max_rxsz;
 	unsigned int max_txsz;
 	struct pci_dev *pdev;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb=
3_offload.c
index ae6ff5d..c69f4c0 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -207,6 +207,17 @@ static int cxgb_ulp_iscsi_ctl(struct adapter *adap=
ter, unsigned int req,
 		break;
 	case ULP_ISCSI_SET_PARAMS:
 		t3_write_reg(adapter, A_ULPRX_ISCSI_TAGMASK, uiip->tagmask);
+		/* set MaxRxData and MaxCoalesceSize to 16224 */
+		t3_write_reg(adapter, A_TP_PARA_REG2, 0x3f603f60);
+		/* program the ddp page sizes */
+		{
+			int i;
+			unsigned int val =3D 0;
+			for (i =3D 0; i < 4; i++)
+				val |=3D (uiip->pgsz_factor[i] & 0xF) << (8 * i);
+			if (val)
+				t3_write_reg(adapter, A_ULPRX_ISCSI_PSZ, val);
+		}
 		break;
 	default:
 		ret =3D -EOPNOTSUPP;
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 5671788..4bda27c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1517,16 +1517,18 @@
=20
 #define A_ULPRX_ISCSI_TAGMASK 0x514
=20
-#define S_HPZ0    0
-#define M_HPZ0    0xf
-#define V_HPZ0(x) ((x) << S_HPZ0)
-#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+#define A_ULPRX_ISCSI_PSZ 0x518
=20
 #define A_ULPRX_TDDP_LLIMIT 0x51c
=20
 #define A_ULPRX_TDDP_ULIMIT 0x520
 #define A_ULPRX_TDDP_PSZ 0x528
=20
+#define S_HPZ0    0
+#define M_HPZ0    0xf
+#define V_HPZ0(x) ((x) << S_HPZ0)
+#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+
 #define A_ULPRX_STAG_LLIMIT 0x52c
=20
 #define A_ULPRX_STAG_ULIMIT 0x530
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index a666c5d..917970e 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -191,6 +191,9 @@ union opcode_tid {
 #define G_OPCODE(x) (((x) >> S_OPCODE) & 0xFF)
 #define G_TID(x)    ((x) & 0xFFFFFF)
=20
+#define S_QNUM 0
+#define G_QNUM(x) (((x) >> S_QNUM) & 0xFFFF)
+
 #define S_HASHTYPE 22
 #define M_HASHTYPE 0x3
 #define G_HASHTYPE(x) (((x) >> S_HASHTYPE) & M_HASHTYPE)
@@ -779,6 +782,12 @@ struct tx_data_wr {
 	__be32 param;
 };
=20
+/* tx_data_wr.flags fields */
+#define S_TX_ACK_PAGES	21
+#define M_TX_ACK_PAGES	0x7
+#define V_TX_ACK_PAGES(x) ((x) << S_TX_ACK_PAGES)
+#define G_TX_ACK_PAGES(x) (((x) >> S_TX_ACK_PAGES) & M_TX_ACK_PAGES)
+
 /* tx_data_wr.param fields */
 #define S_TX_PORT    0
 #define M_TX_PORT    0x7
@@ -1452,4 +1461,35 @@ struct cpl_rdma_terminate {
 #define M_TERM_TID    0xFFFFF
 #define V_TERM_TID(x) ((x) << S_TERM_TID)
 #define G_TERM_TID(x) (((x) >> S_TERM_TID) & M_TERM_TID)
+
+/* ULP_TX opcodes */
+enum { ULP_MEM_READ =3D 2, ULP_MEM_WRITE =3D 3, ULP_TXPKT =3D 4 };
+
+#define S_ULPTX_CMD	28
+#define M_ULPTX_CMD	0xF
+#define V_ULPTX_CMD(x)	((x) << S_ULPTX_CMD)
+
+#define S_ULPTX_NFLITS	0
+#define M_ULPTX_NFLITS	0xFF
+#define V_ULPTX_NFLITS(x) ((x) << S_ULPTX_NFLITS)
+
+struct ulp_mem_io {
+	WR_HDR;
+	__be32 cmd_lock_addr;
+	__be32 len;
+};
+
+/* ulp_mem_io.cmd_lock_addr fields */
+#define S_ULP_MEMIO_ADDR	0
+#define M_ULP_MEMIO_ADDR	0x7FFFFFF
+#define V_ULP_MEMIO_ADDR(x)	((x) << S_ULP_MEMIO_ADDR)
+#define S_ULP_MEMIO_LOCK	27
+#define V_ULP_MEMIO_LOCK(x)	((x) << S_ULP_MEMIO_LOCK)
+#define F_ULP_MEMIO_LOCK	V_ULP_MEMIO_LOCK(1U)
+
+/* ulp_mem_io.len fields */
+#define S_ULP_MEMIO_DATA_LEN	28
+#define M_ULP_MEMIO_DATA_LEN	0xF
+#define V_ULP_MEMIO_DATA_LEN(x)	((x) << S_ULP_MEMIO_DATA_LEN)
+
 #endif				/* T3_CPL_H */
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index 8556628..0a21cfb 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -64,6 +64,7 @@ struct t3cdev {
 	void *l3opt;		/* optional layer 3 data */
 	void *l4opt;		/* optional layer 4 data */
 	void *ulp;		/* ulp stuff */
+	void *ulp_iscsi;	/* ulp iscsi */
 };
=20
 #endif				/* _T3CDEV_H_ */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 393a0f1..fa78d68 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -44,8 +44,7 @@
  *  happen immediately, but will wait until either a set number
  *  of frames or amount of time have passed).  In NAPI, the
  *  interrupt handler will signal there is work to be done, and
- *  exit.  Without NAPI, the packet(s) will be handled
- *  immediately.  Both methods will start at the last known empty
+ *  exit. This method will start at the last known empty
  *  descriptor, and process every subsequent descriptor until there
  *  are none left with data (NAPI will stop after a set number of
  *  packets to give time to other tasks, but will eventually
@@ -101,12 +100,6 @@
 #undef BRIEF_GFAR_ERRORS
 #undef VERBOSE_GFAR_ERRORS
=20
-#ifdef CONFIG_GFAR_NAPI
-#define RECEIVE(x) netif_receive_skb(x)
-#else
-#define RECEIVE(x) netif_rx(x)
-#endif
-
 const char gfar_driver_name[] =3D "Gianfar Ethernet";
 const char gfar_driver_version[] =3D "1.3";
=20
@@ -131,9 +124,7 @@ static void free_skb_resources(struct gfar_private =
*priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gfar_netpoll(struct net_device *dev);
 #endif
@@ -260,9 +251,7 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->hard_start_xmit =3D gfar_start_xmit;
 	dev->tx_timeout =3D gfar_timeout;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
-#ifdef CONFIG_GFAR_NAPI
 	netif_napi_add(dev, &priv->napi, gfar_poll, GFAR_DEV_WEIGHT);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D gfar_netpoll;
 #endif
@@ -363,11 +352,7 @@ static int gfar_probe(struct platform_device *pdev=
)
=20
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
-#ifdef CONFIG_GFAR_NAPI
 	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
-#else
-	printk(KERN_INFO "%s: Running with NAPI disabled\n", dev->name);
-#endif
 	printk(KERN_INFO "%s: %d/%d RX/TX BD ring size\n",
 	       dev->name, priv->rx_ring_size, priv->tx_ring_size);
=20
@@ -945,14 +930,10 @@ tx_skb_fail:
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
 {
-#ifdef CONFIG_GFAR_NAPI
 	struct gfar_private *priv =3D netdev_priv(dev);
-#endif
 	int err;
=20
-#ifdef CONFIG_GFAR_NAPI
 	napi_enable(&priv->napi);
-#endif
=20
 	/* Initialize a bunch of registers */
 	init_registers(dev);
@@ -962,17 +943,13 @@ static int gfar_enet_open(struct net_device *dev)
 	err =3D init_phy(dev);
=20
 	if(err) {
-#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
-#endif
 		return err;
 	}
=20
 	err =3D startup_gfar(dev);
 	if (err) {
-#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
-#endif
 		return err;
 	}
=20
@@ -1128,9 +1105,7 @@ static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
=20
-#ifdef CONFIG_GFAR_NAPI
 	napi_disable(&priv->napi);
-#endif
=20
 	stop_gfar(dev);
=20
@@ -1427,14 +1402,9 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 {
 	struct net_device *dev =3D (struct net_device *) dev_id;
 	struct gfar_private *priv =3D netdev_priv(dev);
-#ifdef CONFIG_GFAR_NAPI
 	u32 tempval;
-#else
-	unsigned long flags;
-#endif
=20
 	/* support NAPI */
-#ifdef CONFIG_GFAR_NAPI
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived */
 	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
@@ -1451,38 +1421,10 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 				dev->name, gfar_read(&priv->regs->ievent),
 				gfar_read(&priv->regs->imask));
 	}
-#else
-	/* Clear IEVENT, so rx interrupt isn't called again
-	 * because of this interrupt */
-	gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
-
-	spin_lock_irqsave(&priv->rxlock, flags);
-	gfar_clean_rx_ring(dev, priv->rx_ring_size);
-
-	/* If we are coalescing interrupts, update the timer */
-	/* Otherwise, clear it */
-	if (likely(priv->rxcoalescing)) {
-		gfar_write(&priv->regs->rxic, 0);
-		gfar_write(&priv->regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	}
-
-	spin_unlock_irqrestore(&priv->rxlock, flags);
-#endif
=20
 	return IRQ_HANDLED;
 }
=20
-static inline int gfar_rx_vlan(struct sk_buff *skb,
-		struct vlan_group *vlgrp, unsigned short vlctl)
-{
-#ifdef CONFIG_GFAR_NAPI
-	return vlan_hwaccel_receive_skb(skb, vlgrp, vlctl);
-#else
-	return vlan_hwaccel_rx(skb, vlgrp, vlctl);
-#endif
-}
-
 static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb =
*fcb)
 {
 	/* If valid headers were found, and valid sums
@@ -1539,10 +1481,11 @@ static int gfar_process_frame(struct net_device=
 *dev, struct sk_buff *skb,
 		skb->protocol =3D eth_type_trans(skb, dev);
=20
 		/* Send the packet up the stack */
-		if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN)))
-			ret =3D gfar_rx_vlan(skb, priv->vlgrp, fcb->vlctl);
-		else
-			ret =3D RECEIVE(skb);
+		if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN))) {
+			ret =3D vlan_hwaccel_receive_skb(skb, priv->vlgrp,
+						       fcb->vlctl);
+		} else
+			ret =3D netif_receive_skb(skb);
=20
 		if (NET_RX_DROP =3D=3D ret)
 			priv->extra_stats.kernel_dropped++;
@@ -1629,7 +1572,6 @@ int gfar_clean_rx_ring(struct net_device *dev, in=
t rx_work_limit)
 	return howmany;
 }
=20
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_private *priv =3D container_of(napi, struct gfar_private,=
 napi);
@@ -1664,7 +1606,6 @@ static int gfar_poll(struct napi_struct *napi, in=
t budget)
=20
 	return howmany;
 }
-#endif
=20
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
@@ -2003,11 +1944,6 @@ static irqreturn_t gfar_error(int irq, void *dev=
_id)
=20
 		gfar_receive(irq, dev_id);
=20
-#ifndef CONFIG_GFAR_NAPI
-		/* Clear the halt bit in RSTAT */
-		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
-#endif
-
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: busy error (rstat: %x)\n",
 			       dev->name, gfar_read(&priv->regs->rstat));
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 27f37c8..bead71c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -77,13 +77,8 @@ extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
=20
 /* These need to be powers of 2 for this driver */
-#ifdef CONFIG_GFAR_NAPI
 #define DEFAULT_TX_RING_SIZE	256
 #define DEFAULT_RX_RING_SIZE	256
-#else
-#define DEFAULT_TX_RING_SIZE    64
-#define DEFAULT_RX_RING_SIZE    64
-#endif
=20
 #define GFAR_RX_MAX_RING_SIZE   256
 #define GFAR_TX_MAX_RING_SIZE   256
@@ -128,14 +123,8 @@ extern const char gfar_driver_version[];
=20
 #define DEFAULT_RXTIME	21
=20
-/* Non NAPI Case */
-#ifndef CONFIG_GFAR_NAPI
-#define DEFAULT_RX_COALESCE 1
-#define DEFAULT_RXCOUNT	16
-#else
 #define DEFAULT_RX_COALESCE 0
 #define DEFAULT_RXCOUNT	0
-#endif /* CONFIG_GFAR_NAPI */
=20
 #define MIIMCFG_INIT_VALUE	0x00000007
 #define MIIMCFG_RESET           0x80000000
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_8257=
5.c
index 2c8b910..e098f23 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -31,6 +31,7 @@
=20
 #include <linux/types.h>
 #include <linux/slab.h>
+#include <linux/if_ether.h>
=20
 #include "e1000_mac.h"
 #include "e1000_82575.h"
@@ -45,7 +46,6 @@ static s32  igb_get_cfg_done_82575(struct e1000_hw *)=
;
 static s32  igb_init_hw_82575(struct e1000_hw *);
 static s32  igb_phy_hw_reset_sgmii_82575(struct e1000_hw *);
 static s32  igb_read_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16 *=
);
-static void igb_rar_set_82575(struct e1000_hw *, u8 *, u32);
 static s32  igb_reset_hw_82575(struct e1000_hw *);
 static s32  igb_set_d0_lplu_state_82575(struct e1000_hw *, bool);
 static s32  igb_setup_copper_link_82575(struct e1000_hw *);
@@ -84,6 +84,12 @@ static s32 igb_get_invariants_82575(struct e1000_hw =
*hw)
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
 		mac->type =3D e1000_82575;
 		break;
+	case E1000_DEV_ID_82576:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		mac->type =3D e1000_82576;
+		break;
 	default:
 		return -E1000_ERR_MAC_INIT;
 		break;
@@ -128,6 +134,8 @@ static s32 igb_get_invariants_82575(struct e1000_hw=
 *hw)
 	mac->mta_reg_count =3D 128;
 	/* Set rar entry count */
 	mac->rar_entry_count =3D E1000_RAR_ENTRIES_82575;
+	if (mac->type =3D=3D e1000_82576)
+		mac->rar_entry_count =3D E1000_RAR_ENTRIES_82576;
 	/* Set if part includes ASF firmware */
 	mac->asf_firmware_present =3D true;
 	/* Set if manageability features are enabled. */
@@ -694,13 +702,12 @@ static s32 igb_check_for_link_82575(struct e1000_=
hw *hw)
 	if ((hw->phy.media_type !=3D e1000_media_type_copper) ||
 	    (igb_sgmii_active_82575(hw)))
 		ret_val =3D igb_get_pcs_speed_and_duplex_82575(hw, &speed,
-							       &duplex);
+		                                             &duplex);
 	else
 		ret_val =3D igb_check_for_copper_link(hw);
=20
 	return ret_val;
 }
-
 /**
  *  igb_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
@@ -757,18 +764,129 @@ static s32 igb_get_pcs_speed_and_duplex_82575(st=
ruct e1000_hw *hw, u16 *speed,
 }
=20
 /**
- *  igb_rar_set_82575 - Set receive address register
+ *  igb_init_rx_addrs_82575 - Initialize receive address's
+ *  @hw: pointer to the HW structure
+ *  @rar_count: receive address registers
+ *
+ *  Setups the receive address registers by setting the base receive a=
ddress
+ *  register to the devices MAC address and clearing all the other rec=
eive
+ *  address registers to 0.
+ **/
+static void igb_init_rx_addrs_82575(struct e1000_hw *hw, u16 rar_count=
)
+{
+	u32 i;
+	u8 addr[6] =3D {0,0,0,0,0,0};
+	/*
+	 * This function is essentially the same as that of
+	 * e1000_init_rx_addrs_generic. However it also takes care
+	 * of the special case where the register offset of the
+	 * second set of RARs begins elsewhere. This is implicitly taken care=
 by
+	 * function e1000_rar_set_generic.
+	 */
+
+	hw_dbg("e1000_init_rx_addrs_82575");
+
+	/* Setup the receive address */
+	hw_dbg("Programming MAC Address into RAR[0]\n");
+	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
+
+	/* Zero out the other (rar_entry_count - 1) receive addresses */
+	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	for (i =3D 1; i < rar_count; i++)
+	    hw->mac.ops.rar_set(hw, addr, i);
+}
+
+/**
+ *  igb_update_mc_addr_list_82575 - Update Multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @mc_addr_list: array of multicast addresses to program
+ *  @mc_addr_count: number of multicast addresses to program
+ *  @rar_used_count: the first RAR register free to program
+ *  @rar_count: total number of supported Receive Address Registers
+ *
+ *  Updates the Receive Address Registers and Multicast Table Array.
+ *  The caller must have a packed mc_addr_list of multicast addresses.
+ *  The parameter rar_count will usually be hw->mac.rar_entry_count
+ *  unless there are workarounds that change this.
+ **/
+void igb_update_mc_addr_list_82575(struct e1000_hw *hw,
+                                   u8 *mc_addr_list, u32 mc_addr_count=
,
+                                   u32 rar_used_count, u32 rar_count)
+{
+	u32 hash_value;
+	u32 i;
+	u8 addr[6] =3D {0,0,0,0,0,0};
+	/*
+	 * This function is essentially the same as that of=20
+	 * igb_update_mc_addr_list_generic. However it also takes care=20
+	 * of the special case where the register offset of the=20
+	 * second set of RARs begins elsewhere. This is implicitly taken care=
 by=20
+	 * function e1000_rar_set_generic.
+	 */
+
+	/*
+	 * Load the first set of multicast addresses into the exact
+	 * filters (RAR).  If there are not enough to fill the RAR
+	 * array, clear the filters.
+	 */
+	for (i =3D rar_used_count; i < rar_count; i++) {
+		if (mc_addr_count) {
+			igb_rar_set(hw, mc_addr_list, i);
+			mc_addr_count--;
+			mc_addr_list +=3D ETH_ALEN;
+		} else {
+			igb_rar_set(hw, addr, i);
+		}
+	}
+
+	/* Clear the old settings from the MTA */
+	hw_dbg("Clearing MTA\n");
+	for (i =3D 0; i < hw->mac.mta_reg_count; i++) {
+		array_wr32(E1000_MTA, i, 0);
+		wrfl();
+	}
+
+	/* Load any remaining multicast addresses into the hash table. */
+	for (; mc_addr_count > 0; mc_addr_count--) {
+		hash_value =3D igb_hash_mc_addr(hw, mc_addr_list);
+		hw_dbg("Hash value =3D 0x%03X\n", hash_value);
+		hw->mac.ops.mta_set(hw, hash_value);
+		mc_addr_list +=3D ETH_ALEN;
+	}
+}
+
+/**
+ *  igb_shutdown_fiber_serdes_link_82575 - Remove link during power do=
wn
  *  @hw: pointer to the HW structure
- *  @addr: pointer to the receive address
- *  @index: receive address array register
  *
- *  Sets the receive address array register at index to the address pa=
ssed
- *  in by addr.
+ *  In the case of fiber serdes, shut down optics and PCS on driver un=
load
+ *  when management pass thru is not enabled.
  **/
-static void igb_rar_set_82575(struct e1000_hw *hw, u8 *addr, u32 index=
)
+void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
 {
-	if (index < E1000_RAR_ENTRIES_82575)
-		igb_rar_set(hw, addr, index);
+	u32 reg;
+
+	if (hw->mac.type !=3D e1000_82576 ||
+	    (hw->phy.media_type !=3D e1000_media_type_fiber &&
+	     hw->phy.media_type !=3D e1000_media_type_internal_serdes))
+		return;
+
+	/* if the management interface is not enabled, then power down */
+	if (!igb_enable_mng_pass_thru(hw)) {
+		/* Disable PCS to turn off link */
+		reg =3D rd32(E1000_PCS_CFG0);
+		reg &=3D ~E1000_PCS_CFG_PCS_EN;
+		wr32(E1000_PCS_CFG0, reg);
+
+		/* shutdown the laser */
+		reg =3D rd32(E1000_CTRL_EXT);
+		reg |=3D E1000_CTRL_EXT_SDP7_DATA;
+		wr32(E1000_CTRL_EXT, reg);
+
+		/* flush the write to verify completion */
+		wrfl();
+		msleep(1);
+	}
=20
 	return;
 }
@@ -854,7 +972,7 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	igb_clear_vfta(hw);
=20
 	/* Setup the receive address */
-	igb_init_rx_addrs(hw, rar_count);
+	igb_init_rx_addrs_82575(hw, rar_count);
 	/* Zero out the Multicast HASH table */
 	hw_dbg("Zeroing the MTA\n");
 	for (i =3D 0; i < mac->mta_reg_count; i++)
@@ -1114,6 +1232,70 @@ out:
 }
=20
 /**
+ *  igb_translate_register_82576 - Translate the proper register offse=
t
+ *  @reg: e1000 register to be read
+ *
+ *  Registers in 82576 are located in different offsets than other ada=
pters
+ *  even though they function in the same manner.  This function takes=
 in
+ *  the name of the register to read and returns the correct offset fo=
r
+ *  82576 silicon.
+ **/
+u32 igb_translate_register_82576(u32 reg)
+{
+	/*
+	 * Some of the Kawela registers are located at different
+	 * offsets than they are in older adapters.
+	 * Despite the difference in location, the registers
+	 * function in the same manner.
+	 */
+	switch (reg) {
+	case E1000_TDBAL(0):
+		reg =3D 0x0E000;
+		break;
+	case E1000_TDBAH(0):
+		reg =3D 0x0E004;
+		break;
+	case E1000_TDLEN(0):
+		reg =3D 0x0E008;
+		break;
+	case E1000_TDH(0):
+		reg =3D 0x0E010;
+		break;
+	case E1000_TDT(0):
+		reg =3D 0x0E018;
+		break;
+	case E1000_TXDCTL(0):
+		reg =3D 0x0E028;
+		break;
+	case E1000_RDBAL(0):
+		reg =3D 0x0C000;
+		break;
+	case E1000_RDBAH(0):
+		reg =3D 0x0C004;
+		break;
+	case E1000_RDLEN(0):
+		reg =3D 0x0C008;
+		break;
+	case E1000_RDH(0):
+		reg =3D 0x0C010;
+		break;
+	case E1000_RDT(0):
+		reg =3D 0x0C018;
+		break;
+	case E1000_RXDCTL(0):
+		reg =3D 0x0C028;
+		break;
+	case E1000_SRRCTL(0):
+		reg =3D 0x0C00C;
+		break;
+	default:
+		break;
+	}
+
+	return reg;
+}
+
+/**
  *  igb_reset_init_script_82575 - Inits HW defaults after reset
  *  @hw: pointer to the HW structure
  *
@@ -1304,7 +1486,7 @@ static struct e1000_mac_operations e1000_mac_ops_=
82575 =3D {
 	.reset_hw             =3D igb_reset_hw_82575,
 	.init_hw              =3D igb_init_hw_82575,
 	.check_for_link       =3D igb_check_for_link_82575,
-	.rar_set              =3D igb_rar_set_82575,
+	.rar_set              =3D igb_rar_set,
 	.read_mac_addr        =3D igb_read_mac_addr_82575,
 	.get_speed_and_duplex =3D igb_get_speed_and_duplex_copper,
 };
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_8257=
5.h
index d78ad33..2f848e5 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -28,9 +28,13 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
=20
+u32 igb_translate_register_82576(u32 reg);
+void igb_update_mc_addr_list_82575(struct e1000_hw*, u8*, u32, u32, u3=
2);
+extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
=20
 #define E1000_RAR_ENTRIES_82575   16
+#define E1000_RAR_ENTRIES_82576   24
=20
 /* SRRCTL bit definitions */
 #define E1000_SRRCTL_BSIZEPKT_SHIFT                     10 /* Shift _r=
ight_ */
@@ -95,6 +99,8 @@ union e1000_adv_rx_desc {
 /* RSS Hash results */
=20
 /* RSS Packet Types as indicated in the receive descriptor */
+#define E1000_RXDADV_PKTTYPE_IPV4        0x00000010 /* IPV4 hdr presen=
t */
+#define E1000_RXDADV_PKTTYPE_TCP         0x00000100 /* TCP hdr present=
 */
=20
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
@@ -144,9 +150,25 @@ struct e1000_adv_tx_context_desc {
 #define E1000_RXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Rx Qu=
eue */
=20
 /* Direct Cache Access (DCA) definitions */
+#define E1000_DCA_CTRL_DCA_ENABLE  0x00000000 /* DCA Enable */
+#define E1000_DCA_CTRL_DCA_DISABLE 0x00000001 /* DCA Disable */
=20
+#define E1000_DCA_CTRL_DCA_MODE_CB1 0x00 /* DCA Mode CB1 */
+#define E1000_DCA_CTRL_DCA_MODE_CB2 0x02 /* DCA Mode CB2 */
=20
+#define E1000_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
+#define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
+#define E1000_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header en=
able */
+#define E1000_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload e=
nable */
=20
+#define E1000_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
+#define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
 #define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO=
 bit */
=20
+/* Additional DCA related definitions, note change in position of CPUI=
D */
+#define E1000_DCA_TXCTRL_CPUID_MASK_82576 0xFF000000 /* Tx CPUID Mask =
*/
+#define E1000_DCA_RXCTRL_CPUID_MASK_82576 0xFF000000 /* Rx CPUID Mask =
*/
+#define E1000_DCA_TXCTRL_CPUID_SHIFT 24 /* Tx CPUID now in the last by=
te */
+#define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last by=
te */
+
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_de=
fines.h
index ed748dc..afdba3c 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -90,6 +90,11 @@
 #define E1000_I2CCMD_ERROR            0x80000000
 #define E1000_MAX_SGMII_PHY_REG_ADDR  255
 #define E1000_I2CCMD_PHY_TIMEOUT      200
+#define E1000_IVAR_VALID              0x80
+#define E1000_GPIE_NSICR              0x00000001
+#define E1000_GPIE_MSIX_MODE          0x00000010
+#define E1000_GPIE_EIAME              0x40000000
+#define E1000_GPIE_PBA                0x80000000
=20
 /* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
@@ -213,6 +218,7 @@
 /* Device Control */
 #define E1000_CTRL_FD       0x00000001  /* Full duplex.0=3Dhalf; 1=3Df=
ull */
 #define E1000_CTRL_GIO_MASTER_DISABLE 0x00000004 /*Blocks new Master r=
equests */
+#define E1000_CTRL_LRST     0x00000008  /* Link reset. 0=3Dnormal,1=3D=
reset */
 #define E1000_CTRL_ASDE     0x00000020  /* Auto-speed detect enable */
 #define E1000_CTRL_SLU      0x00000040  /* Set link up (Force Link) */
 #define E1000_CTRL_ILOS     0x00000080  /* Invert Loss-Of Signal */
@@ -244,6 +250,7 @@
  */
=20
 #define E1000_CONNSW_ENRGSRC             0x4
+#define E1000_PCS_CFG_PCS_EN             8
 #define E1000_PCS_LCTL_FLV_LINK_UP       1
 #define E1000_PCS_LCTL_FSV_100           2
 #define E1000_PCS_LCTL_FSV_1000          4
@@ -253,6 +260,7 @@
 #define E1000_PCS_LCTL_AN_ENABLE         0x10000
 #define E1000_PCS_LCTL_AN_RESTART        0x20000
 #define E1000_PCS_LCTL_AN_TIMEOUT        0x40000
+#define E1000_ENABLE_SERDES_LOOPBACK     0x0410
=20
 #define E1000_PCS_LSTS_LINK_OK           1
 #define E1000_PCS_LSTS_SPEED_100         2
@@ -360,6 +368,7 @@
 #define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
 #define E1000_PBA_24K 0x0018
 #define E1000_PBA_34K 0x0022
+#define E1000_PBA_64K 0x0040    /* 64KB */
=20
 #define IFS_MAX       80
 #define IFS_MIN       40
@@ -528,6 +537,7 @@
 /* PHY Control Register */
 #define MII_CR_FULL_DUPLEX      0x0100  /* FDX =3D1, half duplex =3D0 =
*/
 #define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
+#define MII_CR_POWER_DOWN       0x0800  /* Power down */
 #define MII_CR_AUTO_NEG_EN      0x1000  /* Auto Neg Enable */
 #define MII_CR_LOOPBACK         0x4000  /* 0 =3D normal, 1 =3D loopbac=
k */
 #define MII_CR_RESET            0x8000  /* 0 =3D normal, 1 =3D PHY res=
et */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 746c3ea..19fa4ee 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -38,6 +38,10 @@
=20
 struct e1000_hw;
=20
+#define E1000_DEV_ID_82576                    0x10C9
+#define E1000_DEV_ID_82576_FIBER              0x10E6
+#define E1000_DEV_ID_82576_SERDES             0x10E7
+#define E1000_DEV_ID_82576_QUAD_COPPER        0x10E8
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
 #define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
@@ -50,6 +54,7 @@ struct e1000_hw;
 enum e1000_mac_type {
 	e1000_undefined =3D 0,
 	e1000_82575,
+	e1000_82576,
 	e1000_num_macs  /* List is 1-based, so subtract 1 for true count. */
 };
=20
@@ -410,14 +415,17 @@ struct e1000_mac_operations {
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*reset_hw)(struct e1000_hw *);
 	s32  (*init_hw)(struct e1000_hw *);
+	bool (*check_mng_mode)(struct e1000_hw *);
 	s32  (*setup_physical_interface)(struct e1000_hw *);
 	void (*rar_set)(struct e1000_hw *, u8 *, u32);
 	s32  (*read_mac_addr)(struct e1000_hw *);
 	s32  (*get_speed_and_duplex)(struct e1000_hw *, u16 *, u16 *);
+	void (*mta_set)(struct e1000_hw *, u32);
 };
=20
 struct e1000_phy_operations {
 	s32  (*acquire_phy)(struct e1000_hw *);
+	s32  (*check_reset_block)(struct e1000_hw *);
 	s32  (*force_speed_duplex)(struct e1000_hw *);
 	s32  (*get_cfg_done)(struct e1000_hw *hw);
 	s32  (*get_cable_length)(struct e1000_hw *);
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 47ad2c4..20408aa 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -36,7 +36,6 @@
=20
 static s32 igb_set_default_fc(struct e1000_hw *hw);
 static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
-static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
=20
 /**
  *  igb_remove_device - Free device specific structure
@@ -360,7 +359,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
  *  the multicast filter table array address and new table value.  See
  *  igb_mta_set()
  **/
-static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
+u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 {
 	u32 hash_value, hash_mask;
 	u8 bit_shift =3D 0;
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index 326b659..dc2f8cc 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -94,5 +94,6 @@ enum e1000_mng_mode {
 #define E1000_HICR_C               0x02
=20
 extern void e1000_init_function_pointers_82575(struct e1000_hw *hw);
+extern u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
=20
 #endif
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.=
h
index ff187b7..b95093d 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -56,6 +56,9 @@
 #define E1000_EIMC     0x01528  /* Ext. Interrupt Mask Clear - WO */
 #define E1000_EIAC     0x0152C  /* Ext. Interrupt Auto Clear - RW */
 #define E1000_EIAM     0x01530  /* Ext. Interrupt Ack Auto Clear Mask =
- RW */
+#define E1000_GPIE     0x01514  /* General Purpose Interrupt Enable - =
RW */
+#define E1000_IVAR0    0x01700  /* Interrupt Vector Allocation (array)=
 - RW */
+#define E1000_IVAR_MISC 0x01740 /* IVAR for "other" causes - RW */
 #define E1000_TCTL     0x00400  /* TX Control - RW */
 #define E1000_TCTL_EXT 0x00404  /* Extended TX Control - RW */
 #define E1000_TIPG     0x00410  /* TX Inter-packet gap -RW */
@@ -217,6 +220,7 @@
 #define E1000_RFCTL    0x05008  /* Receive Filter Control*/
 #define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
 #define E1000_RA       0x05400  /* Receive Address - RW Array */
+#define E1000_RA2      0x054E0  /* 2nd half of receive address array -=
 RW Array */
 #define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array =
*/
 #define E1000_VMD_CTL  0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
@@ -235,6 +239,8 @@
 #define E1000_FACTPS    0x05B30 /* Function Active and Power State to =
MNG */
 #define E1000_SWSM      0x05B50 /* SW Semaphore */
 #define E1000_FWSM      0x05B54 /* FW Semaphore */
+#define E1000_DCA_ID    0x05B70 /* DCA Requester ID Information - RO *=
/
+#define E1000_DCA_CTRL  0x05B74 /* DCA Control - RW */
 #define E1000_HICR      0x08F00 /* Host Inteface Control */
=20
 /* RSS registers */
@@ -256,7 +262,8 @@
 #define E1000_RETA(_i)  (0x05C00 + ((_i) * 4))
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW =
Array */
=20
-#define E1000_REGISTER(a, reg) reg
+#define E1000_REGISTER(a, reg) (((a)->mac.type < e1000_82576) \
+                               ? reg : e1000_translate_register_82576(=
reg))
=20
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 2c48eec..56de7ec 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -36,12 +36,20 @@
=20
 struct igb_adapter;
=20
+#ifdef CONFIG_IGB_LRO
+#include <linux/inet_lro.h>
+#define MAX_LRO_AGGR                      32
+#define MAX_LRO_DESCRIPTORS                8
+#endif
+
 /* Interrupt defines */
 #define IGB_MAX_TX_CLEAN 72
=20
 #define IGB_MIN_DYN_ITR 3000
 #define IGB_MAX_DYN_ITR 96000
-#define IGB_START_ITR 6000
+
+/* ((1000000000ns / (6000ints/s * 1024ns)) << 2 =3D 648 */
+#define IGB_START_ITR 648
=20
 #define IGB_DYN_ITR_PACKET_THRESHOLD 2
 #define IGB_DYN_ITR_LENGTH_LOW 200
@@ -62,6 +70,7 @@ struct igb_adapter;
=20
 /* Transmit and receive queues */
 #define IGB_MAX_RX_QUEUES                  4
+#define IGB_MAX_TX_QUEUES                  4
=20
 /* RX descriptor control thresholds.
  * PTHRESH - MAC will consider prefetch if it has fewer than this numb=
er of
@@ -124,6 +133,7 @@ struct igb_buffer {
 		struct {
 			struct page *page;
 			u64 page_dma;
+			unsigned int page_offset;
 		};
 	};
 };
@@ -157,18 +167,19 @@ struct igb_ring {
 	union {
 		/* TX */
 		struct {
-			spinlock_t tx_clean_lock;
-			spinlock_t tx_lock;
+			struct igb_queue_stats tx_stats;
 			bool detect_tx_hung;
 		};
 		/* RX */
 		struct {
-			/* arrays of page information for packet split */
-			struct sk_buff *pending_skb;
-			int pending_skb_page;
-			int no_itr_adjust;
 			struct igb_queue_stats rx_stats;
 			struct napi_struct napi;
+			int set_itr;
+			struct igb_ring *buddy;
+#ifdef CONFIG_IGB_LRO
+			struct net_lro_mgr lro_mgr;
+			bool lro_used;
+#endif
 		};
 	};
=20
@@ -211,7 +222,6 @@ struct igb_adapter {
 	u32 itr_setting;
 	u16 tx_itr;
 	u16 rx_itr;
-	int set_itr;
=20
 	struct work_struct reset_task;
 	struct work_struct watchdog_task;
@@ -270,15 +280,32 @@ struct igb_adapter {
=20
 	/* to not mess up cache alignment, always add to the bottom */
 	unsigned long state;
-	unsigned int msi_enabled;
-
+	unsigned int flags;
 	u32 eeprom_wol;
=20
 	/* for ioport free */
 	int bars;
 	int need_ioport;
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
+#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
+#ifdef CONFIG_IGB_LRO
+	unsigned int lro_max_aggr;
+	unsigned int lro_aggregated;
+	unsigned int lro_flushed;
+	unsigned int lro_no_desc;
+#endif
 };
=20
+#define IGB_FLAG_HAS_MSI           (1 << 0)
+#define IGB_FLAG_MSI_ENABLE        (1 << 1)
+#define IGB_FLAG_HAS_DCA           (1 << 2)
+#define IGB_FLAG_DCA_ENABLED       (1 << 3)
+#define IGB_FLAG_IN_NETPOLL        (1 << 5)
+#define IGB_FLAG_QUAD_PORT_A       (1 << 6)
+#define IGB_FLAG_NEED_CTX_IDX      (1 << 7)
+
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index 0447f9b..11aee13 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -93,13 +93,16 @@ static const struct igb_stats igb_gstrings_stats[] =
=3D {
 	{ "tx_smbus", IGB_STAT(stats.mgptc) },
 	{ "rx_smbus", IGB_STAT(stats.mgprc) },
 	{ "dropped_smbus", IGB_STAT(stats.mgpdc) },
+#ifdef CONFIG_IGB_LRO
+	{ "lro_aggregated", IGB_STAT(lro_aggregated) },
+	{ "lro_flushed", IGB_STAT(lro_flushed) },
+	{ "lro_no_desc", IGB_STAT(lro_no_desc) },
+#endif
 };
=20
 #define IGB_QUEUE_STATS_LEN \
-	((((((struct igb_adapter *)netdev->priv)->num_rx_queues > 1) ? \
-	  ((struct igb_adapter *)netdev->priv)->num_rx_queues : 0) + \
-	 (((((struct igb_adapter *)netdev->priv)->num_tx_queues > 1) ? \
-	  ((struct igb_adapter *)netdev->priv)->num_tx_queues : 0))) * \
+	((((struct igb_adapter *)netdev->priv)->num_rx_queues + \
+	 ((struct igb_adapter *)netdev->priv)->num_tx_queues) * \
 	(sizeof(struct igb_queue_stats) / sizeof(u64)))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
@@ -829,8 +832,9 @@ err_setup:
 /* ethtool register test data */
 struct igb_reg_test {
 	u16 reg;
-	u8  array_len;
-	u8  test_type;
+	u16 reg_offset;
+	u16 array_len;
+	u16 test_type;
 	u32 mask;
 	u32 write;
 };
@@ -852,34 +856,72 @@ struct igb_reg_test {
 #define TABLE64_TEST_LO	5
 #define TABLE64_TEST_HI	6
=20
-/* default register test */
+/* 82576 reg test */
+static struct igb_reg_test reg_test_82576[] =3D {
+	{ E1000_FCAL,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_FCAH,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_FCT,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_VET,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RDBAL(4),  0x40,  8, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(4),  0x40,  8, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(4),  0x40,  8, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	/* Enable all four RX queues before testing. */
+	{ E1000_RXDCTL(0), 0x100, 1,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_EN=
ABLE },
+	/* RDH is read-only for 82576, only test RDT. */
+	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, 0 },
+	{ E1000_FCRTH,	   0x100, 1,  PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
+	{ E1000_FCTTV,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TIPG,	   0x100, 1,  PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
+	{ E1000_TDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDBAL(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(4),  0x40, 8,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0x003FFFFB },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0xFFFFFFFF },
+	{ E1000_TCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_HI, 0x83FFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 8, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 8, TABLE64_TEST_HI, 0x83FFFFFF, 0xFFFFFFFF },
+	{ E1000_MTA,	   0, 128,TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ 0, 0, 0, 0 }
+};
+
+/* 82575 register test */
 static struct igb_reg_test reg_test_82575[] =3D {
-	{ E1000_FCAL, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_FCAH, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
-	{ E1000_FCT, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
-	{ E1000_VET, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_RDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ E1000_FCAL,      0x100, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_FCAH,      0x100, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_FCT,       0x100, 1, PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_VET,       0x100, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
 	/* Enable all four RX queues before testing. */
-	{ E1000_RXDCTL(0), 4, WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENA=
BLE },
 	/* RDH is read-only for 82575, only test RDT. */
-	{ E1000_RDT(0), 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
-	{ E1000_RXDCTL(0), 4, WRITE_NO_TEST, 0, 0 },
-	{ E1000_FCRTH, 1, PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
-	{ E1000_FCTTV, 1, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
-	{ E1000_TIPG, 1, PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
-	{ E1000_TDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_TDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_TDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0x04CFB3FE, 0x003FFFFB },
-	{ E1000_RCTL, 1, SET_READ_TEST, 0x04CFB3FE, 0xFFFFFFFF },
-	{ E1000_TCTL, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
-	{ E1000_TXCW, 1, PATTERN_TEST, 0xC000FFFF, 0x0000FFFF },
-	{ E1000_RA, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RA, 16, TABLE64_TEST_HI, 0x800FFFFF, 0xFFFFFFFF },
-	{ E1000_MTA, 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDT(0),    0x100, 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0, 0 },
+	{ E1000_FCRTH,     0x100, 1, PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
+	{ E1000_FCTTV,     0x100, 1, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TIPG,      0x100, 1, PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
+	{ E1000_TDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0x04CFB3FE, 0x003FFFFB },
+	{ E1000_RCTL,      0x100, 1, SET_READ_TEST, 0x04CFB3FE, 0xFFFFFFFF },
+	{ E1000_TCTL,      0x100, 1, SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_TXCW,      0x100, 1, PATTERN_TEST, 0xC000FFFF, 0x0000FFFF },
+	{ E1000_RA,        0, 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA,        0, 16, TABLE64_TEST_HI, 0x800FFFFF, 0xFFFFFFFF },
+	{ E1000_MTA,       0, 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ 0, 0, 0, 0 }
 };
=20
@@ -939,7 +981,15 @@ static int igb_reg_test(struct igb_adapter *adapte=
r, u64 *data)
 	u32 i, toggle;
=20
 	toggle =3D 0x7FFFF3FF;
-	test =3D reg_test_82575;
+
+	switch (adapter->hw.mac.type) {
+	case e1000_82576:
+		test =3D reg_test_82576;
+		break;
+	default:
+		test =3D reg_test_82575;
+		break;
+	}
=20
 	/* Because the status register is such a special case,
 	 * we handle it separately from the rest of the register
@@ -966,19 +1016,19 @@ static int igb_reg_test(struct igb_adapter *adap=
ter, u64 *data)
 		for (i =3D 0; i < test->array_len; i++) {
 			switch (test->test_type) {
 			case PATTERN_TEST:
-				REG_PATTERN_TEST(test->reg + (i * 0x100),
+				REG_PATTERN_TEST(test->reg + (i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
 			case SET_READ_TEST:
-				REG_SET_AND_CHECK(test->reg + (i * 0x100),
+				REG_SET_AND_CHECK(test->reg + (i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
 			case WRITE_NO_TEST:
 				writel(test->write,
 				    (adapter->hw.hw_addr + test->reg)
-					+ (i * 0x100));
+					+ (i * test->reg_offset));
 				break;
 			case TABLE32_TEST:
 				REG_PATTERN_TEST(test->reg + (i * 4),
@@ -1052,7 +1102,7 @@ static int igb_intr_test(struct igb_adapter *adap=
ter, u64 *data)
 	if (adapter->msix_entries) {
 		/* NOTE: we don't test MSI-X interrupts here, yet */
 		return 0;
-	} else if (adapter->msi_enabled) {
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int =3D false;
 		if (request_irq(irq, &igb_test_intr, 0, netdev->name, netdev)) {
 			*data =3D 1;
@@ -1394,13 +1444,39 @@ static int igb_set_phy_loopback(struct igb_adap=
ter *adapter)
 static int igb_setup_loopback_test(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw =3D &adapter->hw;
-	u32 rctl;
+	u32 reg;
=20
 	if (hw->phy.media_type =3D=3D e1000_media_type_fiber ||
 	    hw->phy.media_type =3D=3D e1000_media_type_internal_serdes) {
-		rctl =3D rd32(E1000_RCTL);
-		rctl |=3D E1000_RCTL_LBM_TCVR;
-		wr32(E1000_RCTL, rctl);
+		reg =3D rd32(E1000_RCTL);
+		reg |=3D E1000_RCTL_LBM_TCVR;
+		wr32(E1000_RCTL, reg);
+
+		wr32(E1000_SCTL, E1000_ENABLE_SERDES_LOOPBACK);
+
+		reg =3D rd32(E1000_CTRL);
+		reg &=3D ~(E1000_CTRL_RFCE |
+			 E1000_CTRL_TFCE |
+			 E1000_CTRL_LRST);
+		reg |=3D E1000_CTRL_SLU |
+		       E1000_CTRL_FD;=20
+		wr32(E1000_CTRL, reg);
+
+		/* Unset switch control to serdes energy detect */
+		reg =3D rd32(E1000_CONNSW);
+		reg &=3D ~E1000_CONNSW_ENRGSRC;
+		wr32(E1000_CONNSW, reg);
+
+		/* Set PCS register for forced speed */
+		reg =3D rd32(E1000_PCS_LCTL);
+		reg &=3D ~E1000_PCS_LCTL_AN_ENABLE;     /* Disable Autoneg*/
+		reg |=3D E1000_PCS_LCTL_FLV_LINK_UP |   /* Force link up */
+		       E1000_PCS_LCTL_FSV_1000 |      /* Force 1000    */
+		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
+		       E1000_PCS_LCTL_FSD |           /* Force Speed */
+		       E1000_PCS_LCTL_FORCE_LINK;     /* Force Link */
+		wr32(E1000_PCS_LCTL, reg);
+
 		return 0;
 	} else if (hw->phy.media_type =3D=3D e1000_media_type_copper) {
 		return igb_set_phy_loopback(adapter);
@@ -1660,6 +1736,8 @@ static int igb_wol_exclusion(struct igb_adapter *=
adapter,
 		wol->supported =3D 0;
 		break;
 	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
 		/* Wake events not supported on port B */
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported =3D 0;
@@ -1668,6 +1746,15 @@ static int igb_wol_exclusion(struct igb_adapter =
*adapter,
 		/* return success for non excluded adapter ports */
 		retval =3D 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* quad port adapters only support WoL on port A */
+		if (!(adapter->flags & IGB_FLAG_QUAD_PORT_A)) {
+			wol->supported =3D 0;
+			break;
+		}
+		/* return success for non excluded adapter ports */
+		retval =3D 0;
+		break;
 	default:
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
@@ -1774,6 +1861,8 @@ static int igb_set_coalesce(struct net_device *ne=
tdev,
 			    struct ethtool_coalesce *ec)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	int i;
=20
 	if ((ec->rx_coalesce_usecs > IGB_MAX_ITR_USECS) ||
 	    ((ec->rx_coalesce_usecs > 3) &&
@@ -1782,13 +1871,16 @@ static int igb_set_coalesce(struct net_device *=
netdev,
 		return -EINVAL;
=20
 	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs <=3D 3)
+	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <=3D 3) {
 		adapter->itr_setting =3D ec->rx_coalesce_usecs;
-	else
-		adapter->itr_setting =3D (1000000 / ec->rx_coalesce_usecs);
+		adapter->itr =3D IGB_START_ITR;
+	} else {
+		adapter->itr_setting =3D ec->rx_coalesce_usecs << 2;
+		adapter->itr =3D adapter->itr_setting;
+	}
=20
-	if (netif_running(netdev))
-		igb_reinit_locked(adapter);
+	for (i =3D 0; i < adapter->num_rx_queues; i++)
+		wr32(adapter->rx_ring[i].itr_register, adapter->itr);
=20
 	return 0;
 }
@@ -1801,7 +1893,7 @@ static int igb_get_coalesce(struct net_device *ne=
tdev,
 	if (adapter->itr_setting <=3D 3)
 		ec->rx_coalesce_usecs =3D adapter->itr_setting;
 	else
-		ec->rx_coalesce_usecs =3D 1000000 / adapter->itr_setting;
+		ec->rx_coalesce_usecs =3D adapter->itr_setting >> 2;
=20
 	return 0;
 }
@@ -1835,6 +1927,18 @@ static void igb_get_ethtool_stats(struct net_dev=
ice *netdev,
 	int stat_count =3D sizeof(struct igb_queue_stats) / sizeof(u64);
 	int j;
 	int i;
+#ifdef CONFIG_IGB_LRO
+	int aggregated =3D 0, flushed =3D 0, no_desc =3D 0;
+
+	for (i =3D 0; i < adapter->num_rx_queues; i++) {
+		aggregated +=3D adapter->rx_ring[i].lro_mgr.stats.aggregated;
+		flushed +=3D adapter->rx_ring[i].lro_mgr.stats.flushed;
+		no_desc +=3D adapter->rx_ring[i].lro_mgr.stats.no_desc;
+	}
+	adapter->lro_aggregated =3D aggregated;
+	adapter->lro_flushed =3D flushed;
+	adapter->lro_no_desc =3D no_desc;
+#endif
=20
 	igb_update_stats(adapter);
 	for (i =3D 0; i < IGB_GLOBAL_STATS_LEN; i++) {
@@ -1842,6 +1946,13 @@ static void igb_get_ethtool_stats(struct net_dev=
ice *netdev,
 		data[i] =3D (igb_gstrings_stats[i].sizeof_stat =3D=3D
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
+	for (j =3D 0; j < adapter->num_tx_queues; j++) {
+		int k;
+		queue_stat =3D (u64 *)&adapter->tx_ring[j].tx_stats;
+		for (k =3D 0; k < stat_count; k++)
+			data[i + k] =3D queue_stat[k];
+		i +=3D k;
+	}
 	for (j =3D 0; j < adapter->num_rx_queues; j++) {
 		int k;
 		queue_stat =3D (u64 *)&adapter->rx_ring[j].rx_stats;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index afd4ce3..aaed129 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -41,22 +41,27 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
-
+#ifdef CONFIG_DCA
+#include <linux/dca.h>
+#endif
 #include "igb.h"
=20
-#define DRV_VERSION "1.0.8-k2"
+#define DRV_VERSION "1.2.45-k2"
 char igb_driver_name[] =3D "igb";
 char igb_driver_version[] =3D DRV_VERSION;
 static const char igb_driver_string[] =3D
 				"Intel(R) Gigabit Ethernet Network Driver";
-static const char igb_copyright[] =3D "Copyright (c) 2007 Intel Corpor=
ation.";
-
+static const char igb_copyright[] =3D "Copyright (c) 2008 Intel Corpor=
ation.";
=20
 static const struct e1000_info *igb_info_tbl[] =3D {
 	[board_82575] =3D &e1000_82575_info,
 };
=20
 static struct pci_device_id igb_pci_tbl[] =3D {
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_QUAD_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_FIBER_SERDES), board_82575 =
},
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575GB_QUAD_COPPER), board_82575 }=
,
@@ -102,10 +107,18 @@ static irqreturn_t igb_msix_other(int irq, void *=
);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
+#ifdef CONFIG_DCA
+static void igb_update_rx_dca(struct igb_ring *);
+static void igb_update_tx_dca(struct igb_ring *);
+static void igb_setup_dca(struct igb_adapter *);
+#endif /* CONFIG_DCA */
 static bool igb_clean_tx_irq(struct igb_ring *);
-static int igb_clean(struct napi_struct *, int);
+static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
 static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
+#ifdef CONFIG_IGB_LRO
+static int igb_get_skb_hdr(struct sk_buff *skb, void **, void **, u64 =
*, void *);
+#endif
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -119,6 +132,14 @@ static int igb_suspend(struct pci_dev *, pm_messag=
e_t);
 static int igb_resume(struct pci_dev *);
 #endif
 static void igb_shutdown(struct pci_dev *);
+#ifdef CONFIG_DCA
+static int igb_notify_dca(struct notifier_block *, unsigned long, void=
 *);
+static struct notifier_block dca_notifier =3D {
+	.notifier_call	=3D igb_notify_dca,
+	.next		=3D NULL,
+	.priority	=3D 0
+};
+#endif
=20
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
@@ -151,6 +172,8 @@ static struct pci_driver igb_driver =3D {
 	.err_handler =3D &igb_err_handler
 };
=20
+static int global_quad_port_a; /* global quad port a indication */
+
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>"=
);
 MODULE_DESCRIPTION("Intel(R) Gigabit Ethernet Network Driver");
 MODULE_LICENSE("GPL");
@@ -182,7 +205,12 @@ static int __init igb_init_module(void)
=20
 	printk(KERN_INFO "%s\n", igb_copyright);
=20
+	global_quad_port_a =3D 0;
+
 	ret =3D pci_register_driver(&igb_driver);
+#ifdef CONFIG_DCA
+	dca_register_notify(&dca_notifier);
+#endif
 	return ret;
 }
=20
@@ -196,6 +224,9 @@ module_init(igb_init_module);
  **/
 static void __exit igb_exit_module(void)
 {
+#ifdef CONFIG_DCA
+	dca_unregister_notify(&dca_notifier);
+#endif
 	pci_unregister_driver(&igb_driver);
 }
=20
@@ -224,6 +255,13 @@ static int igb_alloc_queues(struct igb_adapter *ad=
apter)
 		return -ENOMEM;
 	}
=20
+	adapter->rx_ring->buddy =3D adapter->tx_ring;
+
+	for (i =3D 0; i < adapter->num_tx_queues; i++) {
+		struct igb_ring *ring =3D &(adapter->tx_ring[i]);
+		ring->adapter =3D adapter;
+		ring->queue_index =3D i;
+	}
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring =3D &(adapter->rx_ring[i]);
 		ring->adapter =3D adapter;
@@ -231,17 +269,32 @@ static int igb_alloc_queues(struct igb_adapter *a=
dapter)
 		ring->itr_register =3D E1000_ITR;
=20
 		/* set a default napi handler for each rx_ring */
-		netif_napi_add(adapter->netdev, &ring->napi, igb_clean, 64);
+		netif_napi_add(adapter->netdev, &ring->napi, igb_poll, 64);
 	}
 	return 0;
 }
=20
+static void igb_free_queues(struct igb_adapter *adapter)
+{
+	int i;
+
+	for (i =3D 0; i < adapter->num_rx_queues; i++)
+		netif_napi_del(&adapter->rx_ring[i].napi);
+
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+}
+
 #define IGB_N0_QUEUE -1
 static void igb_assign_vector(struct igb_adapter *adapter, int rx_queu=
e,
 			      int tx_queue, int msix_vector)
 {
 	u32 msixbm =3D 0;
 	struct e1000_hw *hw =3D &adapter->hw;
+	u32 ivar, index;
+
+	switch (hw->mac.type) {
+	case e1000_82575:
 		/* The 82575 assigns vectors using a bitmask, which matches the
 		   bitmask for the EICR/EIMS/EIMC registers.  To assign one
 		   or more queues to a vector, we write the appropriate bits
@@ -256,6 +309,47 @@ static void igb_assign_vector(struct igb_adapter *=
adapter, int rx_queue,
 				  E1000_EICR_TX_QUEUE0 << tx_queue;
 		}
 		array_wr32(E1000_MSIXBM(0), msix_vector, msixbm);
+		break;
+	case e1000_82576:
+		/* Kawela uses a table-based method for assigning vectors.
+		   Each queue has a single entry in the table to which we write
+		   a vector number along with a "valid" bit.  Sadly, the layout
+		   of the table is somewhat counterintuitive. */
+		if (rx_queue > IGB_N0_QUEUE) {
+			index =3D (rx_queue & 0x7);
+			ivar =3D array_rd32(E1000_IVAR0, index);
+			if (rx_queue < 8) {
+				/* vector goes into low byte of register */
+				ivar =3D ivar & 0xFFFFFF00;
+				ivar |=3D msix_vector | E1000_IVAR_VALID;
+			} else {
+				/* vector goes into third byte of register */
+				ivar =3D ivar & 0xFF00FFFF;
+				ivar |=3D (msix_vector | E1000_IVAR_VALID) << 16;
+			}
+			adapter->rx_ring[rx_queue].eims_value=3D 1 << msix_vector;
+			array_wr32(E1000_IVAR0, index, ivar);
+		}
+		if (tx_queue > IGB_N0_QUEUE) {
+			index =3D (tx_queue & 0x7);
+			ivar =3D array_rd32(E1000_IVAR0, index);
+			if (tx_queue < 8) {
+				/* vector goes into second byte of register */
+				ivar =3D ivar & 0xFFFF00FF;
+				ivar |=3D (msix_vector | E1000_IVAR_VALID) << 8;
+			} else {
+				/* vector goes into high byte of register */
+				ivar =3D ivar & 0x00FFFFFF;
+				ivar |=3D (msix_vector | E1000_IVAR_VALID) << 24;
+			}
+			adapter->tx_ring[tx_queue].eims_value=3D 1 << msix_vector;
+			array_wr32(E1000_IVAR0, index, ivar);
+		}
+		break;
+	default:
+		BUG();
+		break;
+	}
 }
=20
 /**
@@ -271,13 +365,19 @@ static void igb_configure_msix(struct igb_adapter=
 *adapter)
 	struct e1000_hw *hw =3D &adapter->hw;
=20
 	adapter->eims_enable_mask =3D 0;
+	if (hw->mac.type =3D=3D e1000_82576)
+		/* Turn on MSI-X capability first, or our settings
+		 * won't stick.  And it will take days to debug. */
+		wr32(E1000_GPIE, E1000_GPIE_MSIX_MODE |
+				   E1000_GPIE_PBA | E1000_GPIE_EIAME |=20
+ 				   E1000_GPIE_NSICR);
=20
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *tx_ring =3D &adapter->tx_ring[i];
 		igb_assign_vector(adapter, IGB_N0_QUEUE, i, vector++);
 		adapter->eims_enable_mask |=3D tx_ring->eims_value;
 		if (tx_ring->itr_val)
-			writel(1000000000 / (tx_ring->itr_val * 256),
+			writel(tx_ring->itr_val,
 			       hw->hw_addr + tx_ring->itr_register);
 		else
 			writel(1, hw->hw_addr + tx_ring->itr_register);
@@ -285,10 +385,11 @@ static void igb_configure_msix(struct igb_adapter=
 *adapter)
=20
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *rx_ring =3D &adapter->rx_ring[i];
+		rx_ring->buddy =3D 0;
 		igb_assign_vector(adapter, i, IGB_N0_QUEUE, vector++);
 		adapter->eims_enable_mask |=3D rx_ring->eims_value;
 		if (rx_ring->itr_val)
-			writel(1000000000 / (rx_ring->itr_val * 256),
+			writel(rx_ring->itr_val,
 			       hw->hw_addr + rx_ring->itr_register);
 		else
 			writel(1, hw->hw_addr + rx_ring->itr_register);
@@ -296,6 +397,8 @@ static void igb_configure_msix(struct igb_adapter *=
adapter)
=20
=20
 	/* set vector for other causes, i.e. link changes */
+	switch (hw->mac.type) {
+	case e1000_82575:
 		array_wr32(E1000_MSIXBM(0), vector++,
 				      E1000_EIMS_OTHER);
=20
@@ -311,6 +414,19 @@ static void igb_configure_msix(struct igb_adapter =
*adapter)
 		adapter->eims_enable_mask |=3D E1000_EIMS_OTHER;
 		adapter->eims_other =3D E1000_EIMS_OTHER;
=20
+		break;
+
+	case e1000_82576:
+		tmp =3D (vector++ | E1000_IVAR_VALID) << 8;
+		wr32(E1000_IVAR_MISC, tmp);
+
+		adapter->eims_enable_mask =3D (1 << (vector)) - 1;
+		adapter->eims_other =3D 1 << (vector - 1);
+		break;
+	default:
+		/* do nothing, since nothing else supports MSI-X */
+		break;
+	} /* switch (hw->mac.type) */
 	wrfl();
 }
=20
@@ -336,7 +452,7 @@ static int igb_request_msix(struct igb_adapter *ada=
pter)
 		if (err)
 			goto out;
 		ring->itr_register =3D E1000_EITR(0) + (vector << 2);
-		ring->itr_val =3D adapter->itr;
+		ring->itr_val =3D 976; /* ~4000 ints/sec */
 		vector++;
 	}
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
@@ -375,7 +491,7 @@ static void igb_reset_interrupt_capability(struct i=
gb_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 		kfree(adapter->msix_entries);
 		adapter->msix_entries =3D NULL;
-	} else if (adapter->msi_enabled)
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI)
 		pci_disable_msi(adapter->pdev);
 	return;
 }
@@ -412,8 +528,14 @@ static void igb_set_interrupt_capability(struct ig=
b_adapter *adapter)
 	/* If we can't do MSI-X, try MSI */
 msi_only:
 	adapter->num_rx_queues =3D 1;
+	adapter->num_tx_queues =3D 1;
 	if (!pci_enable_msi(adapter->pdev))
-		adapter->msi_enabled =3D 1;
+		adapter->flags |=3D IGB_FLAG_HAS_MSI;
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	adapter->netdev->egress_subqueue_count =3D adapter->num_tx_queues;
+#endif
 	return;
 }
=20
@@ -436,24 +558,33 @@ static int igb_request_irq(struct igb_adapter *ad=
apter)
 		/* fall back to MSI */
 		igb_reset_interrupt_capability(adapter);
 		if (!pci_enable_msi(adapter->pdev))
-			adapter->msi_enabled =3D 1;
+			adapter->flags |=3D IGB_FLAG_HAS_MSI;
 		igb_free_all_tx_resources(adapter);
 		igb_free_all_rx_resources(adapter);
 		adapter->num_rx_queues =3D 1;
 		igb_alloc_queues(adapter);
 	} else {
-		wr32(E1000_MSIXBM(0), (E1000_EICR_RX_QUEUE0 |
-		                       E1000_EIMS_OTHER));
+		switch (hw->mac.type) {
+		case e1000_82575:
+			wr32(E1000_MSIXBM(0),
+			     (E1000_EICR_RX_QUEUE0 | E1000_EIMS_OTHER));
+			break;
+		case e1000_82576:
+			wr32(E1000_IVAR0, E1000_IVAR_VALID);
+			break;
+		default:
+			break;
+		}
 	}
=20
-	if (adapter->msi_enabled) {
+	if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		err =3D request_irq(adapter->pdev->irq, &igb_intr_msi, 0,
 				  netdev->name, netdev);
 		if (!err)
 			goto request_done;
 		/* fall back to legacy interrupts */
 		igb_reset_interrupt_capability(adapter);
-		adapter->msi_enabled =3D 0;
+		adapter->flags &=3D ~IGB_FLAG_HAS_MSI;
 	}
=20
 	err =3D request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
@@ -693,6 +824,10 @@ void igb_down(struct igb_adapter *adapter)
 	/* flush and sleep below */
=20
 	netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i =3D 0; i < adapter->num_tx_queues; i++)
+		netif_stop_subqueue(netdev, i);
+#endif
=20
 	/* disable transmits in the hardware */
 	tctl =3D rd32(E1000_TCTL);
@@ -734,16 +869,23 @@ void igb_reinit_locked(struct igb_adapter *adapte=
r)
 void igb_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw =3D &adapter->hw;
-	struct e1000_fc_info *fc =3D &adapter->hw.fc;
+	struct e1000_mac_info *mac =3D &hw->mac;
+	struct e1000_fc_info *fc =3D &hw->fc;
 	u32 pba =3D 0, tx_space, min_tx_space, min_rx_space;
 	u16 hwm;
=20
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
+	if (mac->type !=3D e1000_82576) {
 	pba =3D E1000_PBA_34K;
+	}
+	else {
+		pba =3D E1000_PBA_64K;
+	}
=20
-	if (adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) {
+	if ((adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) &&
+	    (mac->type < e1000_82576)) {
 		/* adjust PBA for jumbo frames */
 		wr32(E1000_PBA, pba);
=20
@@ -782,8 +924,8 @@ void igb_reset(struct igb_adapter *adapter)
 			if (pba < min_rx_space)
 				pba =3D min_rx_space;
 		}
+		wr32(E1000_PBA, pba);
 	}
-	wr32(E1000_PBA, pba);
=20
 	/* flow control settings */
 	/* The high water mark must be low enough to fit one full frame
@@ -792,10 +934,15 @@ void igb_reset(struct igb_adapter *adapter)
 	 * - 90% of the Rx FIFO size, or
 	 * - the full Rx FIFO size minus one full frame */
 	hwm =3D min(((pba << 10) * 9 / 10),
-		  ((pba << 10) - adapter->max_frame_size));
+			((pba << 10) - 2 * adapter->max_frame_size));
=20
-	fc->high_water =3D hwm & 0xFFF8;	/* 8-byte granularity */
-	fc->low_water =3D fc->high_water - 8;
+	if (mac->type < e1000_82576) {
+		fc->high_water =3D hwm & 0xFFF8;	/* 8-byte granularity */
+		fc->low_water =3D fc->high_water - 8;
+	} else {
+		fc->high_water =3D hwm & 0xFFF0;	/* 16-byte granularity */
+		fc->low_water =3D fc->high_water - 16;
+	}
 	fc->pause_time =3D 0xFFFF;
 	fc->send_xon =3D 1;
 	fc->type =3D fc->original_type;
@@ -895,7 +1042,11 @@ static int __devinit igb_probe(struct pci_dev *pd=
ev,
 	pci_save_state(pdev);
=20
 	err =3D -ENOMEM;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev =3D alloc_etherdev_mq(sizeof(struct igb_adapter), IGB_MAX_TX_Q=
UEUES);
+#else
 	netdev =3D alloc_etherdev(sizeof(struct igb_adapter));
+#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 	if (!netdev)
 		goto err_alloc_etherdev;
=20
@@ -966,6 +1117,17 @@ static int __devinit igb_probe(struct pci_dev *pd=
ev,
=20
 	igb_get_bus_info_pcie(hw);
=20
+	/* set flags */
+	switch (hw->mac.type) {
+	case e1000_82576:
+	case e1000_82575:
+		adapter->flags |=3D IGB_FLAG_HAS_DCA;
+		adapter->flags |=3D IGB_FLAG_NEED_CTX_IDX;
+		break;
+	default:
+		break;
+	}
+
 	hw->phy.autoneg_wait_to_complete =3D false;
 	hw->mac.adaptive_ifs =3D true;
=20
@@ -989,6 +1151,10 @@ static int __devinit igb_probe(struct pci_dev *pd=
ev,
 	netdev->features |=3D NETIF_F_TSO;
 	netdev->features |=3D NETIF_F_TSO6;
=20
+#ifdef CONFIG_IGB_LRO
+	netdev->features |=3D NETIF_F_LRO;
+#endif
+
 	netdev->vlan_features |=3D NETIF_F_TSO;
 	netdev->vlan_features |=3D NETIF_F_TSO6;
 	netdev->vlan_features |=3D NETIF_F_HW_CSUM;
@@ -997,6 +1163,10 @@ static int __devinit igb_probe(struct pci_dev *pd=
ev,
 	if (pci_using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev->features |=3D NETIF_F_MULTI_QUEUE;
+#endif
+
 	netdev->features |=3D NETIF_F_LLTX;
 	adapter->en_mng_pt =3D igb_enable_mng_pass_thru(&adapter->hw);
=20
@@ -1077,11 +1247,23 @@ static int __devinit igb_probe(struct pci_dev *=
pdev,
 		adapter->eeprom_wol =3D 0;
 		break;
 	case E1000_DEV_ID_82575EB_FIBER_SERDES:
+	case E1000_DEV_ID_82576_FIBER:
+	case E1000_DEV_ID_82576_SERDES:
 		/* Wake events only supported on port A for dual fiber
 		 * regardless of eeprom setting */
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol =3D 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* if quad port adapter, disable WoL on all but port A */
+		if (global_quad_port_a !=3D 0)
+			adapter->eeprom_wol =3D 0;
+		else
+			adapter->flags |=3D IGB_FLAG_QUAD_PORT_A;
+		/* Reset for multiple quad port adapters */
+		if (++global_quad_port_a =3D=3D 4)
+			global_quad_port_a =3D 0;
+		break;
 	}
=20
 	/* initialize the wol settings based on the eeprom settings */
@@ -1097,12 +1279,28 @@ static int __devinit igb_probe(struct pci_dev *=
pdev,
 	/* tell the stack to leave us alone until igb_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i =3D 0; i < adapter->num_tx_queues; i++)
+		netif_stop_subqueue(netdev, i);
+#endif
=20
 	strcpy(netdev->name, "eth%d");
 	err =3D register_netdev(netdev);
 	if (err)
 		goto err_register;
=20
+#ifdef CONFIG_DCA
+	if ((adapter->flags & IGB_FLAG_HAS_DCA) &&
+	    (dca_add_requester(&pdev->dev) =3D=3D 0)) {
+		adapter->flags |=3D IGB_FLAG_DCA_ENABLED;
+		dev_info(&pdev->dev, "DCA enabled\n");
+		/* Always use CB2 mode, difference is masked
+		 * in the CB driver. */
+		wr32(E1000_DCA_CTRL, 2);
+		igb_setup_dca(adapter);
+	}
+#endif
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n"=
);
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev,
@@ -1123,7 +1321,7 @@ static int __devinit igb_probe(struct pci_dev *pd=
ev,
 	dev_info(&pdev->dev,
 		"Using %s interrupts. %d rx queue(s), %d tx queue(s)\n",
 		adapter->msix_entries ? "MSI-X" :
-		adapter->msi_enabled ? "MSI" : "legacy",
+		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
=20
 	return 0;
@@ -1138,8 +1336,7 @@ err_eeprom:
 		iounmap(hw->flash_address);
=20
 	igb_remove_device(hw);
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	igb_free_queues(adapter);
 err_sw_init:
 err_hw_init:
 	iounmap(hw->hw_addr);
@@ -1166,6 +1363,9 @@ static void __devexit igb_remove(struct pci_dev *=
pdev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
+#ifdef CONFIG_DCA
+	struct e1000_hw *hw =3D &adapter->hw;
+#endif
=20
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */
@@ -1175,6 +1375,15 @@ static void __devexit igb_remove(struct pci_dev =
*pdev)
=20
 	flush_scheduled_work();
=20
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
+		dev_info(&pdev->dev, "DCA disabled\n");
+		dca_remove_requester(&pdev->dev);
+		adapter->flags &=3D ~IGB_FLAG_DCA_ENABLED;
+		wr32(E1000_DCA_CTRL, 1);
+	}
+#endif
+
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	igb_release_hw_control(adapter);
@@ -1187,8 +1396,7 @@ static void __devexit igb_remove(struct pci_dev *=
pdev)
 	igb_remove_device(&adapter->hw);
 	igb_reset_interrupt_capability(adapter);
=20
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	igb_free_queues(adapter);
=20
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
@@ -1223,9 +1431,15 @@ static int __devinit igb_sw_init(struct igb_adap=
ter *adapter)
=20
 	/* Number of supported queues. */
 	/* Having more queues than CPUs doesn't make sense. */
+	adapter->num_rx_queues =3D min((u32)IGB_MAX_RX_QUEUES, (u32)num_onlin=
e_cpus());
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	adapter->num_tx_queues =3D min(IGB_MAX_TX_QUEUES, num_online_cpus());
+#else
 	adapter->num_tx_queues =3D 1;
-	adapter->num_rx_queues =3D min(IGB_MAX_RX_QUEUES, num_online_cpus());
+#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
=20
+	/* This call may decrease the number of queues depending on
+	 * interrupt mode. */
 	igb_set_interrupt_capability(adapter);
=20
 	if (igb_alloc_queues(adapter)) {
@@ -1386,8 +1600,6 @@ int igb_setup_tx_resources(struct igb_adapter *ad=
apter,
 	tx_ring->adapter =3D adapter;
 	tx_ring->next_to_use =3D 0;
 	tx_ring->next_to_clean =3D 0;
-	spin_lock_init(&tx_ring->tx_clean_lock);
-	spin_lock_init(&tx_ring->tx_lock);
 	return 0;
=20
 err:
@@ -1407,6 +1619,9 @@ err:
 static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 {
 	int i, err =3D 0;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int r_idx;
+#endif=09
=20
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
 		err =3D igb_setup_tx_resources(adapter, &adapter->tx_ring[i]);
@@ -1419,6 +1634,12 @@ static int igb_setup_all_tx_resources(struct igb=
_adapter *adapter)
 		}
 	}
=20
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i =3D 0; i < IGB_MAX_TX_QUEUES; i++) {
+		r_idx =3D i % adapter->num_tx_queues;
+		adapter->multi_tx_table[i] =3D &adapter->tx_ring[r_idx];
+	}=09
+#endif	=09
 	return err;
 }
=20
@@ -1505,6 +1726,14 @@ int igb_setup_rx_resources(struct igb_adapter *a=
dapter,
 	struct pci_dev *pdev =3D adapter->pdev;
 	int size, desc_len;
=20
+#ifdef CONFIG_IGB_LRO
+	size =3D sizeof(struct net_lro_desc) * MAX_LRO_DESCRIPTORS;
+	rx_ring->lro_mgr.lro_arr =3D vmalloc(size);
+	if (!rx_ring->lro_mgr.lro_arr)
+		goto err;
+	memset(rx_ring->lro_mgr.lro_arr, 0, size);
+#endif
+
 	size =3D sizeof(struct igb_buffer) * rx_ring->count;
 	rx_ring->buffer_info =3D vmalloc(size);
 	if (!rx_ring->buffer_info)
@@ -1525,13 +1754,16 @@ int igb_setup_rx_resources(struct igb_adapter *=
adapter,
=20
 	rx_ring->next_to_clean =3D 0;
 	rx_ring->next_to_use =3D 0;
-	rx_ring->pending_skb =3D NULL;
=20
 	rx_ring->adapter =3D adapter;
=20
 	return 0;
=20
 err:
+#ifdef CONFIG_IGB_LRO
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr =3D NULL;
+#endif
 	vfree(rx_ring->buffer_info);
 	dev_err(&adapter->pdev->dev, "Unable to allocate memory for "
 		"the receive descriptor ring\n");
@@ -1582,10 +1814,12 @@ static void igb_setup_rctl(struct igb_adapter *=
adapter)
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
=20
-	/* disable the stripping of CRC because it breaks
-	 * BMC firmware connected over SMBUS
-	rctl |=3D E1000_RCTL_SECRC;
+	/*
+	 * enable stripping of CRC. It's unlikely this will break BMC
+	 * redirection as it did with e1000. Newer features require
+	 * that the HW strips the CRC.
 	*/
+	rctl |=3D E1000_RCTL_SECRC;
=20
 	rctl &=3D ~E1000_RCTL_SBP;
=20
@@ -1615,15 +1849,6 @@ static void igb_setup_rctl(struct igb_adapter *a=
dapter)
 			rctl |=3D E1000_RCTL_SZ_2048;
 			rctl &=3D ~E1000_RCTL_BSEX;
 			break;
-		case IGB_RXBUFFER_4096:
-			rctl |=3D E1000_RCTL_SZ_4096;
-			break;
-		case IGB_RXBUFFER_8192:
-			rctl |=3D E1000_RCTL_SZ_8192;
-			break;
-		case IGB_RXBUFFER_16384:
-			rctl |=3D E1000_RCTL_SZ_16384;
-			break;
 		}
 	} else {
 		rctl &=3D ~E1000_RCTL_BSEX;
@@ -1641,10 +1866,8 @@ static void igb_setup_rctl(struct igb_adapter *a=
dapter)
 	 * so only enable packet split for jumbo frames */
 	if (rctl & E1000_RCTL_LPE) {
 		adapter->rx_ps_hdr_size =3D IGB_RXBUFFER_128;
-		srrctl =3D adapter->rx_ps_hdr_size <<
+		srrctl |=3D adapter->rx_ps_hdr_size <<
 			 E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
-		/* buffer size is ALWAYS one page */
-		srrctl |=3D PAGE_SIZE >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |=3D E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 	} else {
 		adapter->rx_ps_hdr_size =3D 0;
@@ -1678,8 +1901,7 @@ static void igb_configure_rx(struct igb_adapter *=
adapter)
 	mdelay(10);
=20
 	if (adapter->itr_setting > 3)
-		wr32(E1000_ITR,
-				1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, adapter->itr);
=20
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
@@ -1704,6 +1926,16 @@ static void igb_configure_rx(struct igb_adapter =
*adapter)
 		rxdctl |=3D IGB_RX_HTHRESH << 8;
 		rxdctl |=3D IGB_RX_WTHRESH << 16;
 		wr32(E1000_RXDCTL(i), rxdctl);
+#ifdef CONFIG_IGB_LRO
+		/* Intitial LRO Settings */
+		ring->lro_mgr.max_aggr =3D MAX_LRO_AGGR;
+		ring->lro_mgr.max_desc =3D MAX_LRO_DESCRIPTORS;
+		ring->lro_mgr.get_skb_header =3D igb_get_skb_hdr;
+		ring->lro_mgr.features =3D LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+		ring->lro_mgr.dev =3D adapter->netdev;
+		ring->lro_mgr.ip_summed =3D CHECKSUM_UNNECESSARY;
+		ring->lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
+#endif
 	}
=20
 	if (adapter->num_rx_queues > 1) {
@@ -1717,7 +1949,10 @@ static void igb_configure_rx(struct igb_adapter =
*adapter)
=20
 		get_random_bytes(&random[0], 40);
=20
-		shift =3D 6;
+		if (hw->mac.type >=3D e1000_82576)
+			shift =3D 0;
+		else
+			shift =3D 6;
 		for (j =3D 0; j < (32 * 4); j++) {
 			reta.bytes[j & 3] =3D
 				(j % adapter->num_rx_queues) << shift;
@@ -1892,6 +2127,11 @@ static void igb_free_rx_resources(struct igb_rin=
g *rx_ring)
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info =3D NULL;
=20
+#ifdef CONFIG_IGB_LRO
+	vfree(rx_ring->lro_mgr.lro_arr);
+	rx_ring->lro_mgr.lro_arr =3D NULL;
+#endif=20
+
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma)=
;
=20
 	rx_ring->desc =3D NULL;
@@ -1946,20 +2186,17 @@ static void igb_clean_rx_ring(struct igb_ring *=
rx_ring)
 			buffer_info->skb =3D NULL;
 		}
 		if (buffer_info->page) {
-			pci_unmap_page(pdev, buffer_info->page_dma,
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			if (buffer_info->page_dma)
+				pci_unmap_page(pdev, buffer_info->page_dma,
+					       PAGE_SIZE / 2,
+					       PCI_DMA_FROMDEVICE);
 			put_page(buffer_info->page);
 			buffer_info->page =3D NULL;
 			buffer_info->page_dma =3D 0;
+			buffer_info->page_offset =3D 0;
 		}
 	}
=20
-	/* there also may be some cached data from a chained receive */
-	if (rx_ring->pending_skb) {
-		dev_kfree_skb(rx_ring->pending_skb);
-		rx_ring->pending_skb =3D NULL;
-	}
-
 	size =3D sizeof(struct igb_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
=20
@@ -2043,7 +2280,7 @@ static void igb_set_multi(struct net_device *netd=
ev)
=20
 	if (!netdev->mc_count) {
 		/* nothing to program, so clear mc list */
-		igb_update_mc_addr_list(hw, NULL, 0, 1,
+		igb_update_mc_addr_list_82575(hw, NULL, 0, 1,
 					  mac->rar_entry_count);
 		return;
 	}
@@ -2061,7 +2298,8 @@ static void igb_set_multi(struct net_device *netd=
ev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr =3D mc_ptr->next;
 	}
-	igb_update_mc_addr_list(hw, mta_list, i, 1, mac->rar_entry_count);
+	igb_update_mc_addr_list_82575(hw, mta_list, i, 1,
+	                              mac->rar_entry_count);
 	kfree(mta_list);
 }
=20
@@ -2096,6 +2334,9 @@ static void igb_watchdog_task(struct work_struct =
*work)
 	struct e1000_mac_info *mac =3D &adapter->hw.mac;
 	u32 link;
 	s32 ret_val;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int i;
+#endif
=20
 	if ((netif_carrier_ok(netdev)) &&
 	    (rd32(E1000_STATUS) & E1000_STATUS_LU))
@@ -2152,6 +2393,10 @@ static void igb_watchdog_task(struct work_struct=
 *work)
=20
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			for (i =3D 0; i < adapter->num_tx_queues; i++)
+				netif_wake_subqueue(netdev, i);
+#endif
=20
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -2164,6 +2409,10 @@ static void igb_watchdog_task(struct work_struct=
 *work)
 			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			for (i =3D 0; i < adapter->num_tx_queues; i++)
+				netif_stop_subqueue(netdev, i);
+#endif
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2216,38 +2465,60 @@ enum latency_range {
 };
=20
=20
-static void igb_lower_rx_eitr(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
+/**
+ * igb_update_ring_itr - update the dynamic ITR value based on packet =
size
+ *
+ *      Stores a new ITR value based on strictly on packet size.  This
+ *      algorithm is less sophisticated than that used in igb_update_i=
tr,
+ *      due to the difficulty of synchronizing statistics across multi=
ple
+ *      receive rings.  The divisors and thresholds used by this fucti=
on
+ *      were determined based on theoretical maximum wire speed and te=
sting
+ *      data, in order to minimize response time while increasing bulk
+ *      throughput.
+ *      This functionality is controlled by the InterruptThrottleRate =
module
+ *      parameter (see igb_param.c)
+ *      NOTE:  This function is called only when operating in a multiq=
ueue
+ *             receive environment.
+ * @rx_ring: pointer to ring
+ **/
+static void igb_update_ring_itr(struct igb_ring *rx_ring)
 {
-	struct e1000_hw *hw =3D &adapter->hw;
-	int new_val;
+	int new_val =3D rx_ring->itr_val;
+	int avg_wire_size =3D 0;
+	struct igb_adapter *adapter =3D rx_ring->adapter;
=20
-	new_val =3D rx_ring->itr_val / 2;
-	if (new_val < IGB_MIN_DYN_ITR)
-		new_val =3D IGB_MIN_DYN_ITR;
+	if (!rx_ring->total_packets)
+		goto clear_counts; /* no packets, so don't do anything */
=20
-	if (new_val !=3D rx_ring->itr_val) {
-		rx_ring->itr_val =3D new_val;
-		wr32(rx_ring->itr_register,
-				1000000000 / (new_val * 256));
+	/* For non-gigabit speeds, just fix the interrupt rate at 4000
+	 * ints/sec - ITR timer value of 120 ticks.
+	 */
+	if (adapter->link_speed !=3D SPEED_1000) {
+		new_val =3D 120;
+		goto set_itr_val;
 	}
-}
+	avg_wire_size =3D rx_ring->total_bytes / rx_ring->total_packets;
=20
-static void igb_raise_rx_eitr(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
-{
-	struct e1000_hw *hw =3D &adapter->hw;
-	int new_val;
+	/* Add 24 bytes to size to account for CRC, preamble, and gap */
+	avg_wire_size +=3D 24;
=20
-	new_val =3D rx_ring->itr_val * 2;
-	if (new_val > IGB_MAX_DYN_ITR)
-		new_val =3D IGB_MAX_DYN_ITR;
+	/* Don't starve jumbo frames */
+	avg_wire_size =3D min(avg_wire_size, 3000);
=20
+	/* Give a little boost to mid-size frames */
+	if ((avg_wire_size > 300) && (avg_wire_size < 1200))
+		new_val =3D avg_wire_size / 3;
+	else
+		new_val =3D avg_wire_size / 2;
+
+set_itr_val:
 	if (new_val !=3D rx_ring->itr_val) {
 		rx_ring->itr_val =3D new_val;
-		wr32(rx_ring->itr_register,
-				1000000000 / (new_val * 256));
+		rx_ring->set_itr =3D 1;
 	}
+clear_counts:
+	rx_ring->total_bytes =3D 0;
+	rx_ring->total_packets =3D 0;
 }
=20
 /**
@@ -2314,8 +2585,7 @@ update_itr_done:
 	return retval;
 }
=20
-static void igb_set_itr(struct igb_adapter *adapter, u16 itr_register,
-			int rx_only)
+static void igb_set_itr(struct igb_adapter *adapter)
 {
 	u16 current_itr;
 	u32 new_itr =3D adapter->itr;
@@ -2331,26 +2601,23 @@ static void igb_set_itr(struct igb_adapter *ada=
pter, u16 itr_register,
 				    adapter->rx_itr,
 				    adapter->rx_ring->total_packets,
 				    adapter->rx_ring->total_bytes);
-	/* conservative mode (itr 3) eliminates the lowest_latency setting */
-	if (adapter->itr_setting =3D=3D 3 && adapter->rx_itr =3D=3D lowest_la=
tency)
-		adapter->rx_itr =3D low_latency;
=20
-	if (!rx_only) {
+	if (adapter->rx_ring->buddy) {
 		adapter->tx_itr =3D igb_update_itr(adapter,
 					    adapter->tx_itr,
 					    adapter->tx_ring->total_packets,
 					    adapter->tx_ring->total_bytes);
-		/* conservative mode (itr 3) eliminates the
-		 * lowest_latency setting */
-		if (adapter->itr_setting =3D=3D 3 &&
-		    adapter->tx_itr =3D=3D lowest_latency)
-			adapter->tx_itr =3D low_latency;
=20
 		current_itr =3D max(adapter->rx_itr, adapter->tx_itr);
 	} else {
 		current_itr =3D adapter->rx_itr;
 	}
=20
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting =3D=3D 3 &&
+	    current_itr =3D=3D lowest_latency)
+		current_itr =3D low_latency;
+
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
 	case lowest_latency:
@@ -2367,6 +2634,13 @@ static void igb_set_itr(struct igb_adapter *adap=
ter, u16 itr_register,
 	}
=20
 set_itr_now:
+	adapter->rx_ring->total_bytes =3D 0;
+	adapter->rx_ring->total_packets =3D 0;
+	if (adapter->rx_ring->buddy) {
+		adapter->rx_ring->buddy->total_bytes =3D 0;
+		adapter->rx_ring->buddy->total_packets =3D 0;
+	}
+
 	if (new_itr !=3D adapter->itr) {
 		/* this attempts to bias the interrupt rate towards Bulk
 		 * by adding intermediate steps when interrupt rate is
@@ -2381,7 +2655,8 @@ set_itr_now:
 		 * ends up being correct.
 		 */
 		adapter->itr =3D new_itr;
-		adapter->set_itr =3D 1;
+		adapter->rx_ring->itr_val =3D 1000000000 / (new_itr * 256);
+		adapter->rx_ring->set_itr =3D 1;
 	}
=20
 	return;
@@ -2457,9 +2732,9 @@ static inline int igb_tso_adv(struct igb_adapter =
*adapter,
 	mss_l4len_idx =3D (skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIF=
T);
 	mss_l4len_idx |=3D (l4len << E1000_ADVTXD_L4LEN_SHIFT);
=20
-	/* Context index must be unique per ring.  Luckily, so is the interru=
pt
-	 * mask value. */
-	mss_l4len_idx |=3D tx_ring->eims_value >> 4;
+	/* Context index must be unique per ring. */
+	if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
+		mss_l4len_idx |=3D tx_ring->queue_index << 4;
=20
 	context_desc->mss_l4len_idx =3D cpu_to_le32(mss_l4len_idx);
 	context_desc->seqnum_seed =3D 0;
@@ -2523,8 +2798,9 @@ static inline bool igb_tx_csum_adv(struct igb_ada=
pter *adapter,
=20
 		context_desc->type_tucmd_mlhl =3D cpu_to_le32(tu_cmd);
 		context_desc->seqnum_seed =3D 0;
-		context_desc->mss_l4len_idx =3D
-					  cpu_to_le32(tx_ring->eims_value >> 4);
+		if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
+			context_desc->mss_l4len_idx =3D
+				cpu_to_le32(tx_ring->queue_index << 4);
=20
 		buffer_info->time_stamp =3D jiffies;
 		buffer_info->dma =3D 0;
@@ -2625,9 +2901,10 @@ static inline void igb_tx_queue_adv(struct igb_a=
dapter *adapter,
 		olinfo_status |=3D E1000_TXD_POPTS_TXSM << 8;
 	}
=20
-	if (tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_TSO |
-			IGB_TX_FLAGS_VLAN))
-		olinfo_status |=3D tx_ring->eims_value >> 4;
+	if ((adapter->flags & IGB_FLAG_NEED_CTX_IDX) &&
+	    (tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_TSO |
+			 IGB_TX_FLAGS_VLAN)))
+		olinfo_status |=3D tx_ring->queue_index << 4;
=20
 	olinfo_status |=3D ((paylen - hdr_len) << E1000_ADVTXD_PAYLEN_SHIFT);
=20
@@ -2663,7 +2940,12 @@ static int __igb_maybe_stop_tx(struct net_device=
 *netdev,
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
=20
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 	netif_stop_queue(netdev);
+#endif
+
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -2675,7 +2957,11 @@ static int __igb_maybe_stop_tx(struct net_device=
 *netdev,
 		return -EBUSY;
=20
 	/* A reprieve! */
-	netif_start_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_wake_subqueue(netdev, tx_ring->queue_index);
+#else
+	netif_wake_queue(netdev);
+#endif=09
 	++adapter->restart_queue;
 	return 0;
 }
@@ -2697,7 +2983,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff=
 *skb,
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	unsigned int tx_flags =3D 0;
 	unsigned int len;
-	unsigned long irq_flags;
 	u8 hdr_len =3D 0;
 	int tso =3D 0;
=20
@@ -2713,10 +2998,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buf=
f *skb,
 		return NETDEV_TX_OK;
 	}
=20
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, irq_flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
 	/* need: 1 descriptor per page,
 	 *       + 2 desc gap to keep tail from touching head,
 	 *       + 1 desc for skb->data,
@@ -2724,21 +3005,23 @@ static int igb_xmit_frame_ring_adv(struct sk_bu=
ff *skb,
 	 * otherwise try next time */
 	if (igb_maybe_stop_tx(netdev, tx_ring, skb_shinfo(skb)->nr_frags + 4)=
) {
 		/* this is a hard error */
-		spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 		return NETDEV_TX_BUSY;
 	}
+	skb_orphan(skb);
=20
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |=3D IGB_TX_FLAGS_VLAN;
 		tx_flags |=3D (vlan_tx_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
 	}
=20
+	if (skb->protocol =3D=3D htons(ETH_P_IP))
+		tx_flags |=3D IGB_TX_FLAGS_IPV4;
+
 	tso =3D skb_is_gso(skb) ? igb_tso_adv(adapter, tx_ring, skb, tx_flags=
,
 					      &hdr_len) : 0;
=20
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 		return NETDEV_TX_OK;
 	}
=20
@@ -2748,9 +3031,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff=
 *skb,
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 				tx_flags |=3D IGB_TX_FLAGS_CSUM;
=20
-	if (skb->protocol =3D=3D htons(ETH_P_IP))
-		tx_flags |=3D IGB_TX_FLAGS_IPV4;
-
 	igb_tx_queue_adv(adapter, tx_ring, tx_flags,
 			 igb_tx_map_adv(adapter, tx_ring, skb),
 			 skb->len, hdr_len);
@@ -2760,14 +3040,22 @@ static int igb_xmit_frame_ring_adv(struct sk_bu=
ff *skb,
 	/* Make sure there is space in the ring for the next send. */
 	igb_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 4);
=20
-	spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 	return NETDEV_TX_OK;
 }
=20
 static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *=
netdev)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
-	struct igb_ring *tx_ring =3D &adapter->tx_ring[0];
+	struct igb_ring *tx_ring;
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int r_idx =3D 0;
+	r_idx =3D skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);
+	tx_ring =3D adapter->multi_tx_table[r_idx];
+#else
+	tx_ring =3D &adapter->tx_ring[0];
+#endif
+
=20
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -2862,7 +3150,11 @@ static int igb_change_mtu(struct net_device *net=
dev, int new_mtu)
 	else if (max_frame <=3D IGB_RXBUFFER_2048)
 		adapter->rx_buffer_len =3D IGB_RXBUFFER_2048;
 	else
-		adapter->rx_buffer_len =3D IGB_RXBUFFER_4096;
+#if (PAGE_SIZE / 2) > IGB_RXBUFFER_16384
+		adapter->rx_buffer_len =3D IGB_RXBUFFER_16384;
+#else
+		adapter->rx_buffer_len =3D PAGE_SIZE / 2;
+#endif
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if ((max_frame =3D=3D ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame =3D=3D MAXIMUM_ETHERNET_VLAN_SIZE))
@@ -3035,7 +3327,7 @@ static irqreturn_t igb_msix_other(int irq, void *=
data)
 	/* guard against interrupt when we're going down */
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
-
+=09
 no_link_interrupt:
 	wr32(E1000_IMS, E1000_IMS_LSC);
 	wr32(E1000_EIMS, adapter->eims_other);
@@ -3049,42 +3341,186 @@ static irqreturn_t igb_msix_tx(int irq, void *=
data)
 	struct igb_adapter *adapter =3D tx_ring->adapter;
 	struct e1000_hw *hw =3D &adapter->hw;
=20
-	if (!tx_ring->itr_val)
-		wr32(E1000_EIMC, tx_ring->eims_value);
-
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		igb_update_tx_dca(tx_ring);
+#endif
 	tx_ring->total_bytes =3D 0;
 	tx_ring->total_packets =3D 0;
+
+	/* auto mask will automatically reenable the interrupt when we write
+	 * EICS */
 	if (!igb_clean_tx_irq(tx_ring))
 		/* Ring was not completely cleaned, so fire another interrupt */
 		wr32(E1000_EICS, tx_ring->eims_value);
-
-	if (!tx_ring->itr_val)
+	else
 		wr32(E1000_EIMS, tx_ring->eims_value);
+
 	return IRQ_HANDLED;
 }
=20
+static void igb_write_itr(struct igb_ring *ring)
+{
+	struct e1000_hw *hw =3D &ring->adapter->hw;
+	if ((ring->adapter->itr_setting & 3) && ring->set_itr) {
+		switch (hw->mac.type) {
+		case e1000_82576:
+			wr32(ring->itr_register,
+			     ring->itr_val |
+			     0x80000000);
+			break;
+		default:
+			wr32(ring->itr_register,
+			     ring->itr_val |
+			     (ring->itr_val << 16));
+			break;
+		}
+		ring->set_itr =3D 0;
+	}
+}
+
 static irqreturn_t igb_msix_rx(int irq, void *data)
 {
 	struct igb_ring *rx_ring =3D data;
 	struct igb_adapter *adapter =3D rx_ring->adapter;
-	struct e1000_hw *hw =3D &adapter->hw;
=20
 	/* Write the ITR value calculated at the end of the
 	 * previous interrupt.
 	 */
=20
-	if (adapter->set_itr) {
-		wr32(rx_ring->itr_register,
-		     1000000000 / (rx_ring->itr_val * 256));
-		adapter->set_itr =3D 0;
-	}
+	igb_write_itr(rx_ring);
=20
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
=20
-	return IRQ_HANDLED;
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		igb_update_rx_dca(rx_ring);
+#endif
+		return IRQ_HANDLED;
 }
=20
+#ifdef CONFIG_DCA
+static void igb_update_rx_dca(struct igb_ring *rx_ring)
+{
+	u32 dca_rxctrl;
+	struct igb_adapter *adapter =3D rx_ring->adapter;
+	struct e1000_hw *hw =3D &adapter->hw;
+	int cpu =3D get_cpu();
+	int q =3D rx_ring - adapter->rx_ring;
+
+	if (rx_ring->cpu !=3D cpu) {
+		dca_rxctrl =3D rd32(E1000_DCA_RXCTRL(q));
+		if (hw->mac.type =3D=3D e1000_82576) {
+			dca_rxctrl &=3D ~E1000_DCA_RXCTRL_CPUID_MASK_82576;
+			dca_rxctrl |=3D dca_get_tag(cpu) <<
+			              E1000_DCA_RXCTRL_CPUID_SHIFT;
+		} else {
+			dca_rxctrl &=3D ~E1000_DCA_RXCTRL_CPUID_MASK;
+			dca_rxctrl |=3D dca_get_tag(cpu);
+		}
+		dca_rxctrl |=3D E1000_DCA_RXCTRL_DESC_DCA_EN;
+		dca_rxctrl |=3D E1000_DCA_RXCTRL_HEAD_DCA_EN;
+		dca_rxctrl |=3D E1000_DCA_RXCTRL_DATA_DCA_EN;
+		wr32(E1000_DCA_RXCTRL(q), dca_rxctrl);
+		rx_ring->cpu =3D cpu;
+	}
+	put_cpu();
+}
+
+static void igb_update_tx_dca(struct igb_ring *tx_ring)
+{
+	u32 dca_txctrl;
+	struct igb_adapter *adapter =3D tx_ring->adapter;
+	struct e1000_hw *hw =3D &adapter->hw;
+	int cpu =3D get_cpu();
+	int q =3D tx_ring - adapter->tx_ring;
+
+	if (tx_ring->cpu !=3D cpu) {
+		dca_txctrl =3D rd32(E1000_DCA_TXCTRL(q));
+		if (hw->mac.type =3D=3D e1000_82576) {
+			dca_txctrl &=3D ~E1000_DCA_TXCTRL_CPUID_MASK_82576;
+			dca_txctrl |=3D dca_get_tag(cpu) <<
+			              E1000_DCA_TXCTRL_CPUID_SHIFT;
+		} else {
+			dca_txctrl &=3D ~E1000_DCA_TXCTRL_CPUID_MASK;
+			dca_txctrl |=3D dca_get_tag(cpu);
+		}
+		dca_txctrl |=3D E1000_DCA_TXCTRL_DESC_DCA_EN;
+		wr32(E1000_DCA_TXCTRL(q), dca_txctrl);
+		tx_ring->cpu =3D cpu;
+	}
+	put_cpu();
+}
+
+static void igb_setup_dca(struct igb_adapter *adapter)
+{
+	int i;
+
+	if (!(adapter->flags & IGB_FLAG_DCA_ENABLED))
+		return;
+
+	for (i =3D 0; i < adapter->num_tx_queues; i++) {
+		adapter->tx_ring[i].cpu =3D -1;
+		igb_update_tx_dca(&adapter->tx_ring[i]);
+	}
+	for (i =3D 0; i < adapter->num_rx_queues; i++) {
+		adapter->rx_ring[i].cpu =3D -1;
+		igb_update_rx_dca(&adapter->rx_ring[i]);
+	}
+}
+
+static int __igb_notify_dca(struct device *dev, void *data)
+{
+	struct net_device *netdev =3D dev_get_drvdata(dev);
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	unsigned long event =3D *(unsigned long *)data;
+
+	if (!(adapter->flags & IGB_FLAG_HAS_DCA))
+		goto out;
+
+	switch (event) {
+	case DCA_PROVIDER_ADD:
+		/* if already enabled, don't do it again */
+		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+			break;
+		adapter->flags |=3D IGB_FLAG_DCA_ENABLED;
+		/* Always use CB2 mode, difference is masked
+		 * in the CB driver. */
+		wr32(E1000_DCA_CTRL, 2);
+		if (dca_add_requester(dev) =3D=3D 0) {
+			dev_info(&adapter->pdev->dev, "DCA enabled\n");
+			igb_setup_dca(adapter);
+			break;
+		}
+		/* Fall Through since DCA is disabled. */
+	case DCA_PROVIDER_REMOVE:
+		if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
+			/* without this a class_device is left
+ 			 * hanging around in the sysfs model */
+			dca_remove_requester(dev);
+			dev_info(&adapter->pdev->dev, "DCA disabled\n");
+			adapter->flags &=3D ~IGB_FLAG_DCA_ENABLED;
+			wr32(E1000_DCA_CTRL, 1);
+		}
+		break;
+	}
+out:
+	return 0;
+}
+
+static int igb_notify_dca(struct notifier_block *nb, unsigned long eve=
nt,
+                          void *p)
+{
+	int ret_val;
+
+	ret_val =3D driver_for_each_device(&igb_driver.driver, NULL, &event,
+	                                 __igb_notify_dca);
+
+	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
+}
+#endif /* CONFIG_DCA */
=20
 /**
  * igb_intr_msi - Interrupt Handler
@@ -3099,13 +3535,7 @@ static irqreturn_t igb_intr_msi(int irq, void *d=
ata)
 	/* read ICR disables interrupts using IAM */
 	u32 icr =3D rd32(E1000_ICR);
=20
-	/* Write the ITR value calculated at the end of the
-	 * previous interrupt.
-	 */
-	if (adapter->set_itr) {
-		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
-		adapter->set_itr =3D 0;
-	}
+	igb_write_itr(adapter->rx_ring);
=20
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status =3D 1;
@@ -3135,13 +3565,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 	if (!icr)
 		return IRQ_NONE;  /* Not our interrupt */
=20
-	/* Write the ITR value calculated at the end of the
-	 * previous interrupt.
-	 */
-	if (adapter->set_itr) {
-		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
-		adapter->set_itr =3D 0;
-	}
+	igb_write_itr(adapter->rx_ring);
=20
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
@@ -3163,44 +3587,35 @@ static irqreturn_t igb_intr(int irq, void *data=
)
 }
=20
 /**
- * igb_clean - NAPI Rx polling callback
- * @adapter: board private structure
+ * igb_poll - NAPI Rx polling callback
+ * @napi: napi polling structure
+ * @budget: count of how many packets we should handle
  **/
-static int igb_clean(struct napi_struct *napi, int budget)
+static int igb_poll(struct napi_struct *napi, int budget)
 {
-	struct igb_adapter *adapter =3D container_of(napi, struct igb_adapter=
,
-						   napi);
+	struct igb_ring *rx_ring =3D container_of(napi, struct igb_ring, napi=
);
+	struct igb_adapter *adapter =3D rx_ring->adapter;
 	struct net_device *netdev =3D adapter->netdev;
-	int tx_clean_complete =3D 1, work_done =3D 0;
-	int i;
-
-	/* Must NOT use netdev_priv macro here. */
-	adapter =3D netdev->priv;
-
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
+	int tx_clean_complete, work_done =3D 0;
=20
-	/* igb_clean is called per-cpu.  This lock protects tx_ring[i] from
-	 * being cleaned by multiple cpus simultaneously.  A failure obtainin=
g
-	 * the lock means tx_ring[i] is currently being cleaned anyway. */
-	for (i =3D 0; i < adapter->num_tx_queues; i++) {
-		if (spin_trylock(&adapter->tx_ring[i].tx_clean_lock)) {
-			tx_clean_complete &=3D igb_clean_tx_irq(&adapter->tx_ring[i]);
-			spin_unlock(&adapter->tx_ring[i].tx_clean_lock);
-		}
-	}
+	/* this poll routine only supports one tx and one rx queue */
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		igb_update_tx_dca(&adapter->tx_ring[0]);
+#endif
+	tx_clean_complete =3D igb_clean_tx_irq(&adapter->tx_ring[0]);
=20
-	for (i =3D 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(&adapter->rx_ring[i], &work_done,
-				     adapter->rx_ring[i].napi.weight);
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		igb_update_rx_dca(&adapter->rx_ring[0]);
+#endif
+	igb_clean_rx_irq_adv(&adapter->rx_ring[0], &work_done, budget);
=20
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if ((tx_clean_complete && (work_done < budget)) ||
 	    !netif_running(netdev)) {
-quit_polling:
 		if (adapter->itr_setting & 3)
-			igb_set_itr(adapter, E1000_ITR, false);
+			igb_set_itr(adapter);
 		netif_rx_complete(netdev, napi);
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			igb_irq_enable(adapter);
@@ -3222,6 +3637,10 @@ static int igb_clean_rx_ring_msix(struct napi_st=
ruct *napi, int budget)
 	if (!netif_carrier_ok(netdev))
 		goto quit_polling;
=20
+#ifdef CONFIG_DCA
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		igb_update_rx_dca(rx_ring);
+#endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
=20
=20
@@ -3230,15 +3649,11 @@ static int igb_clean_rx_ring_msix(struct napi_s=
truct *napi, int budget)
 quit_polling:
 		netif_rx_complete(netdev, napi);
=20
-		wr32(E1000_EIMS, rx_ring->eims_value);
-		if ((adapter->itr_setting & 3) && !rx_ring->no_itr_adjust &&
-		    (rx_ring->total_packets > IGB_DYN_ITR_PACKET_THRESHOLD)) {
-			int mean_size =3D rx_ring->total_bytes /
-					rx_ring->total_packets;
-			if (mean_size < IGB_DYN_ITR_LENGTH_LOW)
-				igb_raise_rx_eitr(adapter, rx_ring);
-			else if (mean_size > IGB_DYN_ITR_LENGTH_HIGH)
-				igb_lower_rx_eitr(adapter, rx_ring);
+		if (adapter->itr_setting & 3) {
+			if (adapter->num_rx_queues =3D=3D 1)
+				igb_set_itr(adapter);
+			else
+				igb_update_ring_itr(rx_ring);
 		}
=20
 		if (!test_bit(__IGB_DOWN, &adapter->state))
@@ -3327,11 +3742,19 @@ done_cleaning:
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
+		    !(test_bit(__IGB_DOWN, &adapter->state))) {
+			netif_wake_subqueue(netdev, tx_ring->queue_index);
+			++adapter->restart_queue;
+		}
+#else
 		if (netif_queue_stopped(netdev) &&
 		    !(test_bit(__IGB_DOWN, &adapter->state))) {
 			netif_wake_queue(netdev);
 			++adapter->restart_queue;
 		}
+#endif	=09
 	}
=20
 	if (tx_ring->detect_tx_hung) {
@@ -3348,7 +3771,7 @@ done_cleaning:
 			/* detected Tx unit hang */
 			dev_err(&adapter->pdev->dev,
 				"Detected Tx Unit Hang\n"
-				"  Tx Queue             <%lu>\n"
+				"  Tx Queue             <%d>\n"
 				"  TDH                  <%x>\n"
 				"  TDT                  <%x>\n"
 				"  next_to_use          <%x>\n"
@@ -3358,8 +3781,7 @@ done_cleaning:
 				"  time_stamp           <%lx>\n"
 				"  jiffies              <%lx>\n"
 				"  desc.status          <%x>\n",
-				(unsigned long)((tx_ring - adapter->tx_ring) /
-					sizeof(struct igb_ring)),
+				tx_ring->queue_index,
 				readl(adapter->hw.hw_addr + tx_ring->head),
 				readl(adapter->hw.hw_addr + tx_ring->tail),
 				tx_ring->next_to_use,
@@ -3368,32 +3790,91 @@ done_cleaning:
 				tx_ring->buffer_info[i].time_stamp,
 				jiffies,
 				tx_desc->upper.fields.status);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 			netif_stop_queue(netdev);
+#endif
 		}
 	}
 	tx_ring->total_bytes +=3D total_bytes;
 	tx_ring->total_packets +=3D total_packets;
+	tx_ring->tx_stats.bytes +=3D total_bytes;
+	tx_ring->tx_stats.packets +=3D total_packets;
 	adapter->net_stats.tx_bytes +=3D total_bytes;
 	adapter->net_stats.tx_packets +=3D total_packets;
 	return retval;
 }
=20
+#ifdef CONFIG_IGB_LRO
+ /**
+ * igb_get_skb_hdr - helper function for LRO header processing
+ * @skb: pointer to sk_buff to be added to LRO packet
+ * @iphdr: pointer to ip header structure
+ * @tcph: pointer to tcp header structure
+ * @hdr_flags: pointer to header flags
+ * @priv: pointer to the receive descriptor for the current sk_buff
+ **/
+static int igb_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **t=
cph,
+                           u64 *hdr_flags, void *priv)
+{
+	union e1000_adv_rx_desc *rx_desc =3D priv;
+	u16 pkt_type =3D rx_desc->wb.lower.lo_dword.pkt_info &
+	               (E1000_RXDADV_PKTTYPE_IPV4 | E1000_RXDADV_PKTTYPE_TCP)=
;
+
+	/* Verify that this is a valid IPv4 TCP packet */
+	if (pkt_type !=3D (E1000_RXDADV_PKTTYPE_IPV4 |
+	                  E1000_RXDADV_PKTTYPE_TCP))
+		return -1;
+
+	/* Set network headers */
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, ip_hdrlen(skb));
+	*iphdr =3D ip_hdr(skb);
+	*tcph =3D tcp_hdr(skb);
+	*hdr_flags =3D LRO_IPV4 | LRO_TCP;
+
+	return 0;
+
+}
+#endif /* CONFIG_IGB_LRO */
=20
 /**
  * igb_receive_skb - helper function to handle rx indications
- * @adapter: board private structure
+ * @ring: pointer to receive ring receving this packet=20
  * @status: descriptor status field as written by hardware
  * @vlan: descriptor vlan field as written by hardware (no le/be conve=
rsion)
  * @skb: pointer to sk_buff to be indicated to stack
  **/
-static void igb_receive_skb(struct igb_adapter *adapter, u8 status, __=
le16 vlan,
-			    struct sk_buff *skb)
+static void igb_receive_skb(struct igb_ring *ring, u8 status,
+                            union e1000_adv_rx_desc * rx_desc,
+                            struct sk_buff *skb)
 {
-	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan));
-	else
-		netif_receive_skb(skb);
+	struct igb_adapter * adapter =3D ring->adapter;
+	bool vlan_extracted =3D (adapter->vlgrp && (status & E1000_RXD_STAT_V=
P));
+
+#ifdef CONFIG_IGB_LRO
+	if (adapter->netdev->features & NETIF_F_LRO &&
+	    skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY) {
+		if (vlan_extracted)
+			lro_vlan_hwaccel_receive_skb(&ring->lro_mgr, skb,
+			                   adapter->vlgrp,
+			                   le16_to_cpu(rx_desc->wb.upper.vlan),
+			                   rx_desc);
+		else
+			lro_receive_skb(&ring->lro_mgr,skb, rx_desc);
+		ring->lro_used =3D 1;
+	} else {
+#endif
+		if (vlan_extracted)
+			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
+			                  le16_to_cpu(rx_desc->wb.upper.vlan));
+		else
+
+			netif_receive_skb(skb);
+#ifdef CONFIG_IGB_LRO
+	}
+#endif
 }
=20
=20
@@ -3428,7 +3909,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring =
*rx_ring,
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
 	struct igb_buffer *buffer_info , *next_buffer;
 	struct sk_buff *skb;
-	unsigned int i, j;
+	unsigned int i;
 	u32 length, hlen, staterr;
 	bool cleaned =3D false;
 	int cleaned_count =3D 0;
@@ -3458,64 +3939,48 @@ static bool igb_clean_rx_irq_adv(struct igb_rin=
g *rx_ring,
 		cleaned =3D true;
 		cleaned_count++;
=20
-		if (rx_ring->pending_skb !=3D NULL) {
-			skb =3D rx_ring->pending_skb;
-			rx_ring->pending_skb =3D NULL;
-			j =3D rx_ring->pending_skb_page;
-		} else {
-			skb =3D buffer_info->skb;
-			prefetch(skb->data - NET_IP_ALIGN);
-			buffer_info->skb =3D NULL;
-			if (hlen) {
-				pci_unmap_single(pdev, buffer_info->dma,
-						 adapter->rx_ps_hdr_size +
-						   NET_IP_ALIGN,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb, hlen);
-			} else {
-				pci_unmap_single(pdev, buffer_info->dma,
-						 adapter->rx_buffer_len +
-						   NET_IP_ALIGN,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb, length);
-				goto send_up;
-			}
-			j =3D 0;
+		skb =3D buffer_info->skb;
+		prefetch(skb->data - NET_IP_ALIGN);
+		buffer_info->skb =3D NULL;
+		if (!adapter->rx_ps_hdr_size) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_buffer_len +
+					   NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, length);
+			goto send_up;
 		}
=20
-		while (length) {
+		if (!skb_shinfo(skb)->nr_frags) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_ps_hdr_size +
+					   NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, hlen);
+		}
+
+		if (length) {
 			pci_unmap_page(pdev, buffer_info->page_dma,
-				PAGE_SIZE, PCI_DMA_FROMDEVICE);
+				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma =3D 0;
-			skb_fill_page_desc(skb, j, buffer_info->page,
-						0, length);
-			buffer_info->page =3D NULL;
+
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+						buffer_info->page,
+						buffer_info->page_offset,
+						length);
+
+			if ((adapter->rx_buffer_len > (PAGE_SIZE / 2)) ||
+			    (page_count(buffer_info->page) !=3D 1))
+				buffer_info->page =3D NULL;
+			else
+				get_page(buffer_info->page);
=20
 			skb->len +=3D length;
 			skb->data_len +=3D length;
-			skb->truesize +=3D length;
-			rx_desc->wb.upper.status_error =3D 0;
-			if (staterr & E1000_RXD_STAT_EOP)
-				break;
=20
-			j++;
-			cleaned_count++;
-			i++;
-			if (i =3D=3D rx_ring->count)
-				i =3D 0;
-
-			buffer_info =3D &rx_ring->buffer_info[i];
-			rx_desc =3D E1000_RX_DESC_ADV(*rx_ring, i);
-			staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
-			length =3D le16_to_cpu(rx_desc->wb.upper.length);
-			if (!(staterr & E1000_RXD_STAT_DD)) {
-				rx_ring->pending_skb =3D skb;
-				rx_ring->pending_skb_page =3D j;
-				goto out;
-			}
+			skb->truesize +=3D length;
 		}
 send_up:
-		pskb_trim(skb, skb->len - 4);
 		i++;
 		if (i =3D=3D rx_ring->count)
 			i =3D 0;
@@ -3523,11 +3988,16 @@ send_up:
 		prefetch(next_rxd);
 		next_buffer =3D &rx_ring->buffer_info[i];
=20
+		if (!(staterr & E1000_RXD_STAT_EOP)) {
+			buffer_info->skb =3D xchg(&next_buffer->skb, skb);
+			buffer_info->dma =3D xchg(&next_buffer->dma, 0);
+			goto next_desc;
+		}
+
 		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
-		rx_ring->no_itr_adjust |=3D (staterr & E1000_RXD_STAT_DYNINT);
=20
 		total_bytes +=3D skb->len;
 		total_packets++;
@@ -3536,7 +4006,7 @@ send_up:
=20
 		skb->protocol =3D eth_type_trans(skb, netdev);
=20
-		igb_receive_skb(adapter, staterr, rx_desc->wb.upper.vlan, skb);
+		igb_receive_skb(rx_ring, staterr, rx_desc, skb);
=20
 		netdev->last_rx =3D jiffies;
=20
@@ -3555,10 +4025,17 @@ next_desc:
=20
 		staterr =3D le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
-out:
+
 	rx_ring->next_to_clean =3D i;
 	cleaned_count =3D IGB_DESC_UNUSED(rx_ring);
=20
+#ifdef CONFIG_IGB_LRO
+	if (rx_ring->lro_used) {
+		lro_flush_all(&rx_ring->lro_mgr);
+		rx_ring->lro_used =3D 0;
+	}
+#endif
+
 	if (cleaned_count)
 		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
=20
@@ -3593,16 +4070,22 @@ static void igb_alloc_rx_buffers_adv(struct igb=
_ring *rx_ring,
 	while (cleaned_count--) {
 		rx_desc =3D E1000_RX_DESC_ADV(*rx_ring, i);
=20
-		if (adapter->rx_ps_hdr_size && !buffer_info->page) {
-			buffer_info->page =3D alloc_page(GFP_ATOMIC);
+		if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
-				adapter->alloc_rx_buff_failed++;
-				goto no_buffers;
+				buffer_info->page =3D alloc_page(GFP_ATOMIC);
+				if (!buffer_info->page) {
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
+				buffer_info->page_offset =3D 0;
+			} else {
+				buffer_info->page_offset ^=3D PAGE_SIZE / 2;
 			}
 			buffer_info->page_dma =3D
 				pci_map_page(pdev,
 					     buffer_info->page,
-					     0, PAGE_SIZE,
+					     buffer_info->page_offset,
+					     PAGE_SIZE / 2,
 					     PCI_DMA_FROMDEVICE);
 		}
=20
@@ -3869,7 +4352,7 @@ static int igb_suspend(struct pci_dev *pdev, pm_m=
essage_t state)
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
-	u32 ctrl, ctrl_ext, rctl, status;
+	u32 ctrl, rctl, status;
 	u32 wufc =3D adapter->wol;
 #ifdef CONFIG_PM
 	int retval =3D 0;
@@ -3877,11 +4360,12 @@ static int igb_suspend(struct pci_dev *pdev, pm=
_message_t state)
=20
 	netif_device_detach(netdev);
=20
-	if (netif_running(netdev)) {
-		WARN_ON(test_bit(__IGB_RESETTING, &adapter->state));
-		igb_down(adapter);
-		igb_free_irq(adapter);
-	}
+	if (netif_running(netdev))
+		igb_close(netdev);
+
+	igb_reset_interrupt_capability(adapter);
+
+	igb_free_queues(adapter);
=20
 #ifdef CONFIG_PM
 	retval =3D pci_save_state(pdev);
@@ -3912,33 +4396,24 @@ static int igb_suspend(struct pci_dev *pdev, pm=
_message_t state)
 		ctrl |=3D E1000_CTRL_ADVD3WUC;
 		wr32(E1000_CTRL, ctrl);
=20
-		if (adapter->hw.phy.media_type =3D=3D e1000_media_type_fiber ||
-		   adapter->hw.phy.media_type =3D=3D
-					e1000_media_type_internal_serdes) {
-			/* keep the laser running in D3 */
-			ctrl_ext =3D rd32(E1000_CTRL_EXT);
-			ctrl_ext |=3D E1000_CTRL_EXT_SDP7_DATA;
-			wr32(E1000_CTRL_EXT, ctrl_ext);
-		}
-
 		/* Allow time for pending master requests to run */
 		igb_disable_pcie_master(&adapter->hw);
=20
 		wr32(E1000_WUC, E1000_WUC_PME_EN);
 		wr32(E1000_WUFC, wufc);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
 		wr32(E1000_WUC, 0);
 		wr32(E1000_WUFC, 0);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
=20
-	/* make sure adapter isn't asleep if manageability is enabled */
-	if (adapter->en_mng_pt) {
+	/* make sure adapter isn't asleep if manageability/wol is enabled */
+	if (wufc || adapter->en_mng_pt) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		igb_shutdown_fiber_serdes_link_82575(hw);
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
=20
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
@@ -3977,10 +4452,11 @@ static int igb_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
=20
-	if (netif_running(netdev)) {
-		err =3D igb_request_irq(adapter);
-		if (err)
-			return err;
+	igb_set_interrupt_capability(adapter);
+
+	if (igb_alloc_queues(adapter)) {
+		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
+		return -ENOMEM;
 	}
=20
 	/* e1000_power_up_phy(adapter); */
@@ -3988,10 +4464,11 @@ static int igb_resume(struct pci_dev *pdev)
 	igb_reset(adapter);
 	wr32(E1000_WUS, ~0);
=20
-	igb_init_manageability(adapter);
-
-	if (netif_running(netdev))
-		igb_up(adapter);
+	if (netif_running(netdev)) {
+		err =3D igb_open(netdev);
+		if (err)
+			return err;
+	}
=20
 	netif_device_attach(netdev);
=20
@@ -4021,6 +4498,8 @@ static void igb_netpoll(struct net_device *netdev=
)
 	int work_done =3D 0;
=20
 	igb_irq_disable(adapter);
+	adapter->flags |=3D IGB_FLAG_IN_NETPOLL;
+
 	for (i =3D 0; i < adapter->num_tx_queues; i++)
 		igb_clean_tx_irq(&adapter->tx_ring[i]);
=20
@@ -4029,6 +4508,7 @@ static void igb_netpoll(struct net_device *netdev=
)
 				     &work_done,
 				     adapter->rx_ring[i].napi.weight);
=20
+	adapter->flags &=3D ~IGB_FLAG_IN_NETPOLL;
 	igb_irq_enable(adapter);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
diff --git a/drivers/net/ixgb/Makefile b/drivers/net/ixgb/Makefile
index 838a508..0b20c5e 100644
--- a/drivers/net/ixgb/Makefile
+++ b/drivers/net/ixgb/Makefile
@@ -1,7 +1,7 @@
 ######################################################################=
##########
 #
 # Intel PRO/10GbE Linux driver
-# Copyright(c) 1999 - 2006 Intel Corporation.
+# Copyright(c) 1999 - 2008 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify=
 it
 # under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 16f9c75..804698f 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -89,18 +89,16 @@ struct ixgb_adapter;
=20
=20
 /* TX/RX descriptor defines */
-#define DEFAULT_TXD	 256
-#define MAX_TXD   	4096
-#define MIN_TXD	  64
+#define DEFAULT_TXD      256
+#define MAX_TXD         4096
+#define MIN_TXD           64
=20
 /* hardware cannot reliably support more than 512 descriptors owned by
- * hardware descrioptor cache otherwise an unreliable ring under heavy=
=20
- * recieve load may result */
-/* #define DEFAULT_RXD	   1024 */
-/* #define MAX_RXD	   4096 */
-#define DEFAULT_RXD	512
-#define MAX_RXD	512
-#define MIN_RXD	 64
+ * hardware descriptor cache otherwise an unreliable ring under heavy
+ * receive load may result */
+#define DEFAULT_RXD      512
+#define MAX_RXD          512
+#define MIN_RXD           64
=20
 /* Supported Rx Buffer Sizes */
 #define IXGB_RXBUFFER_2048  2048
@@ -157,7 +155,6 @@ struct ixgb_adapter {
 	u32 part_num;
 	u16 link_speed;
 	u16 link_duplex;
-	spinlock_t tx_lock;
 	struct work_struct tx_timeout_task;
=20
 	struct timer_list blink_timer;
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 2f7ed52..89ffa72 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -108,7 +108,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 		 */
 		eecd_reg &=3D ~IXGB_EECD_DI;
=20
-		if(data & mask)
+		if (data & mask)
 			eecd_reg |=3D IXGB_EECD_DI;
=20
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
@@ -120,7 +120,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
=20
 		mask =3D mask >> 1;
=20
-	} while(mask);
+	} while (mask);
=20
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eecd_reg &=3D ~IXGB_EECD_DI;
@@ -152,14 +152,14 @@ ixgb_shift_in_bits(struct ixgb_hw *hw)
 	eecd_reg &=3D ~(IXGB_EECD_DO | IXGB_EECD_DI);
 	data =3D 0;
=20
-	for(i =3D 0; i < 16; i++) {
+	for (i =3D 0; i < 16; i++) {
 		data =3D data << 1;
 		ixgb_raise_clock(hw, &eecd_reg);
=20
 		eecd_reg =3D IXGB_READ_REG(hw, EECD);
=20
 		eecd_reg &=3D ~(IXGB_EECD_DI);
-		if(eecd_reg & IXGB_EECD_DO)
+		if (eecd_reg & IXGB_EECD_DO)
 			data |=3D 1;
=20
 		ixgb_lower_clock(hw, &eecd_reg);
@@ -205,7 +205,7 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
=20
 	eecd_reg =3D IXGB_READ_REG(hw, EECD);
=20
-	/*  Deselct EEPROM  */
+	/*  Deselect EEPROM  */
 	eecd_reg &=3D ~(IXGB_EECD_CS | IXGB_EECD_SK);
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
 	udelay(50);
@@ -293,14 +293,14 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 	 */
 	ixgb_standby_eeprom(hw);
=20
-	/* Now read DO repeatedly until is high (equal to '1').  The EEEPROM =
will
+	/* Now read DO repeatedly until is high (equal to '1').  The EEPROM w=
ill
 	 * signal that the command has been completed by raising the DO signa=
l.
 	 * If DO does not go high in 10 milliseconds, then error out.
 	 */
-	for(i =3D 0; i < 200; i++) {
+	for (i =3D 0; i < 200; i++) {
 		eecd_reg =3D IXGB_READ_REG(hw, EECD);
=20
-		if(eecd_reg & IXGB_EECD_DO)
+		if (eecd_reg & IXGB_EECD_DO)
 			return (true);
=20
 		udelay(50);
@@ -328,10 +328,10 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 	u16 checksum =3D 0;
 	u16 i;
=20
-	for(i =3D 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
+	for (i =3D 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum +=3D ixgb_read_eeprom(hw, i);
=20
-	if(checksum =3D=3D (u16) EEPROM_SUM)
+	if (checksum =3D=3D (u16) EEPROM_SUM)
 		return (true);
 	else
 		return (false);
@@ -351,7 +351,7 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 	u16 checksum =3D 0;
 	u16 i;
=20
-	for(i =3D 0; i < EEPROM_CHECKSUM_REG; i++)
+	for (i =3D 0; i < EEPROM_CHECKSUM_REG; i++)
 		checksum +=3D ixgb_read_eeprom(hw, i);
=20
 	checksum =3D (u16) EEPROM_SUM - checksum;
@@ -365,7 +365,7 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  * reg - offset within the EEPROM to be written to
- * data - 16 bit word to be writen to the EEPROM
+ * data - 16 bit word to be written to the EEPROM
  *
  * If ixgb_update_eeprom_checksum is not called after this function, t=
he
  * EEPROM will most likely contain an invalid checksum.
@@ -472,7 +472,7 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 	ee_map =3D (struct ixgb_ee_map_type *)hw->eeprom;
=20
 	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
-	for(i =3D 0; i < IXGB_EEPROM_SIZE ; i++) {
+	for (i =3D 0; i < IXGB_EEPROM_SIZE ; i++) {
 		u16 ee_data;
 		ee_data =3D ixgb_read_eeprom(hw, i);
 		checksum +=3D ee_data;
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 4b7bd0d..7ea1265 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -34,11 +34,11 @@
 #define IXGB_ETH_LENGTH_OF_ADDRESS   6
=20
 /* EEPROM Commands */
-#define EEPROM_READ_OPCODE  0x6	/* EERPOM read opcode */
-#define EEPROM_WRITE_OPCODE 0x5	/* EERPOM write opcode */
-#define EEPROM_ERASE_OPCODE 0x7	/* EERPOM erase opcode */
-#define EEPROM_EWEN_OPCODE  0x13	/* EERPOM erase/write enable */
-#define EEPROM_EWDS_OPCODE  0x10	/* EERPOM erast/write disable */
+#define EEPROM_READ_OPCODE  0x6	/* EEPROM read opcode */
+#define EEPROM_WRITE_OPCODE 0x5	/* EEPROM write opcode */
+#define EEPROM_ERASE_OPCODE 0x7	/* EEPROM erase opcode */
+#define EEPROM_EWEN_OPCODE  0x13	/* EEPROM erase/write enable */
+#define EEPROM_EWDS_OPCODE  0x10	/* EEPROM erase/write disable */
=20
 /* EEPROM MAP (Word Offsets) */
 #define EEPROM_IA_1_2_REG        0x0000
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_et=
htool.c
index 8464d8a..288ee1d 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -95,7 +95,7 @@ ixgb_get_settings(struct net_device *netdev, struct e=
thtool_cmd *ecmd)
 	ecmd->port =3D PORT_FIBRE;
 	ecmd->transceiver =3D XCVR_EXTERNAL;
=20
-	if(netif_carrier_ok(adapter->netdev)) {
+	if (netif_carrier_ok(adapter->netdev)) {
 		ecmd->speed =3D SPEED_10000;
 		ecmd->duplex =3D DUPLEX_FULL;
 	} else {
@@ -122,11 +122,11 @@ ixgb_set_settings(struct net_device *netdev, stru=
ct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
=20
-	if(ecmd->autoneg =3D=3D AUTONEG_ENABLE ||
+	if (ecmd->autoneg =3D=3D AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex !=3D SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
-=09
-	if(netif_running(adapter->netdev)) {
+
+	if (netif_running(adapter->netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
@@ -143,14 +143,14 @@ ixgb_get_pauseparam(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	struct ixgb_hw *hw =3D &adapter->hw;
-=09
+
 	pause->autoneg =3D AUTONEG_DISABLE;
-	=09
-	if(hw->fc.type =3D=3D ixgb_fc_rx_pause)
+
+	if (hw->fc.type =3D=3D ixgb_fc_rx_pause)
 		pause->rx_pause =3D 1;
-	else if(hw->fc.type =3D=3D ixgb_fc_tx_pause)
+	else if (hw->fc.type =3D=3D ixgb_fc_tx_pause)
 		pause->tx_pause =3D 1;
-	else if(hw->fc.type =3D=3D ixgb_fc_full) {
+	else if (hw->fc.type =3D=3D ixgb_fc_full) {
 		pause->rx_pause =3D 1;
 		pause->tx_pause =3D 1;
 	}
@@ -162,26 +162,26 @@ ixgb_set_pauseparam(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	struct ixgb_hw *hw =3D &adapter->hw;
-=09
-	if(pause->autoneg =3D=3D AUTONEG_ENABLE)
+
+	if (pause->autoneg =3D=3D AUTONEG_ENABLE)
 		return -EINVAL;
=20
-	if(pause->rx_pause && pause->tx_pause)
+	if (pause->rx_pause && pause->tx_pause)
 		hw->fc.type =3D ixgb_fc_full;
-	else if(pause->rx_pause && !pause->tx_pause)
+	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.type =3D ixgb_fc_rx_pause;
-	else if(!pause->rx_pause && pause->tx_pause)
+	else if (!pause->rx_pause && pause->tx_pause)
 		hw->fc.type =3D ixgb_fc_tx_pause;
-	else if(!pause->rx_pause && !pause->tx_pause)
+	else if (!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type =3D ixgb_fc_none;
=20
-	if(netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
-	=09
+
 	return 0;
 }
=20
@@ -200,7 +200,7 @@ ixgb_set_rx_csum(struct net_device *netdev, u32 dat=
a)
=20
 	adapter->rx_csum =3D data;
=20
-	if(netif_running(netdev)) {
+	if (netif_running(netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
@@ -208,7 +208,7 @@ ixgb_set_rx_csum(struct net_device *netdev, u32 dat=
a)
 		ixgb_reset(adapter);
 	return 0;
 }
-=09
+
 static u32
 ixgb_get_tx_csum(struct net_device *netdev)
 {
@@ -229,12 +229,12 @@ ixgb_set_tx_csum(struct net_device *netdev, u32 d=
ata)
 static int
 ixgb_set_tso(struct net_device *netdev, u32 data)
 {
-	if(data)
+	if (data)
 		netdev->features |=3D NETIF_F_TSO;
 	else
 		netdev->features &=3D ~NETIF_F_TSO;
 	return 0;
-}=20
+}
=20
 static u32
 ixgb_get_msglevel(struct net_device *netdev)
@@ -251,7 +251,7 @@ ixgb_set_msglevel(struct net_device *netdev, u32 da=
ta)
 }
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
=20
-static int=20
+static int
 ixgb_get_regs_len(struct net_device *netdev)
 {
 #define IXGB_REG_DUMP_LEN  136*sizeof(u32)
@@ -301,7 +301,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ =3D IXGB_READ_REG(hw, RXCSUM);	/*  20 */
=20
 	/* there are 16 RAR entries in hardware, we only use 3 */
-	for(i =3D 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
+	for (i =3D 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
 		*reg++ =3D IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
 		*reg++ =3D IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}
@@ -415,7 +415,7 @@ ixgb_get_eeprom(struct net_device *netdev,
 	int i, max_len, first_word, last_word;
 	int ret_val =3D 0;
=20
-	if(eeprom->len =3D=3D 0) {
+	if (eeprom->len =3D=3D 0) {
 		ret_val =3D -EINVAL;
 		goto geeprom_error;
 	}
@@ -424,12 +424,12 @@ ixgb_get_eeprom(struct net_device *netdev,
=20
 	max_len =3D ixgb_get_eeprom_len(netdev);
=20
-	if(eeprom->offset > eeprom->offset + eeprom->len) {
+	if (eeprom->offset > eeprom->offset + eeprom->len) {
 		ret_val =3D -EINVAL;
 		goto geeprom_error;
 	}
=20
-	if((eeprom->offset + eeprom->len) > max_len)
+	if ((eeprom->offset + eeprom->len) > max_len)
 		eeprom->len =3D (max_len - eeprom->offset);
=20
 	first_word =3D eeprom->offset >> 1;
@@ -437,16 +437,14 @@ ixgb_get_eeprom(struct net_device *netdev,
=20
 	eeprom_buff =3D kmalloc(sizeof(__le16) *
 			(last_word - first_word + 1), GFP_KERNEL);
-	if(!eeprom_buff)
+	if (!eeprom_buff)
 		return -ENOMEM;
=20
 	/* note the eeprom was good because the driver loaded */
-	for(i =3D 0; i <=3D (last_word - first_word); i++) {
+	for (i =3D 0; i <=3D (last_word - first_word); i++)
 		eeprom_buff[i] =3D ixgb_get_eeprom_word(hw, (first_word + i));
-	}
=20
-	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
-			eeprom->len);
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
 	kfree(eeprom_buff);
=20
 geeprom_error:
@@ -464,47 +462,47 @@ ixgb_set_eeprom(struct net_device *netdev,
 	int max_len, first_word, last_word;
 	u16 i;
=20
-	if(eeprom->len =3D=3D 0)
+	if (eeprom->len =3D=3D 0)
 		return -EINVAL;
=20
-	if(eeprom->magic !=3D (hw->vendor_id | (hw->device_id << 16)))
+	if (eeprom->magic !=3D (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
=20
 	max_len =3D ixgb_get_eeprom_len(netdev);
=20
-	if(eeprom->offset > eeprom->offset + eeprom->len)
+	if (eeprom->offset > eeprom->offset + eeprom->len)
 		return -EINVAL;
=20
-	if((eeprom->offset + eeprom->len) > max_len)
+	if ((eeprom->offset + eeprom->len) > max_len)
 		eeprom->len =3D (max_len - eeprom->offset);
=20
 	first_word =3D eeprom->offset >> 1;
 	last_word =3D (eeprom->offset + eeprom->len - 1) >> 1;
 	eeprom_buff =3D kmalloc(max_len, GFP_KERNEL);
-	if(!eeprom_buff)
+	if (!eeprom_buff)
 		return -ENOMEM;
=20
 	ptr =3D (void *)eeprom_buff;
=20
-	if(eeprom->offset & 1) {
+	if (eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
 		eeprom_buff[0] =3D ixgb_read_eeprom(hw, first_word);
 		ptr++;
 	}
-	if((eeprom->offset + eeprom->len) & 1) {
+	if ((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word]=20
+		eeprom_buff[last_word - first_word]
 			=3D ixgb_read_eeprom(hw, last_word);
 	}
=20
 	memcpy(ptr, bytes, eeprom->len);
-	for(i =3D 0; i <=3D (last_word - first_word); i++)
+	for (i =3D 0; i <=3D (last_word - first_word); i++)
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
=20
 	/* Update the checksum over the first part of the EEPROM if needed */
-	if(first_word <=3D EEPROM_CHECKSUM_REG)
+	if (first_word <=3D EEPROM_CHECKSUM_REG)
 		ixgb_update_eeprom_checksum(hw);
=20
 	kfree(eeprom_buff);
@@ -534,7 +532,7 @@ ixgb_get_ringparam(struct net_device *netdev,
 	struct ixgb_desc_ring *txdr =3D &adapter->tx_ring;
 	struct ixgb_desc_ring *rxdr =3D &adapter->rx_ring;
=20
-	ring->rx_max_pending =3D MAX_RXD;=20
+	ring->rx_max_pending =3D MAX_RXD;
 	ring->tx_max_pending =3D MAX_TXD;
 	ring->rx_mini_max_pending =3D 0;
 	ring->rx_jumbo_max_pending =3D 0;
@@ -544,7 +542,7 @@ ixgb_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending =3D 0;
 }
=20
-static int=20
+static int
 ixgb_set_ringparam(struct net_device *netdev,
 		struct ethtool_ringparam *ring)
 {
@@ -557,10 +555,10 @@ ixgb_set_ringparam(struct net_device *netdev,
 	tx_old =3D adapter->tx_ring;
 	rx_old =3D adapter->rx_ring;
=20
-	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending))=20
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
=20
-	if(netif_running(adapter->netdev))
+	if (netif_running(adapter->netdev))
 		ixgb_down(adapter, true);
=20
 	rxdr->count =3D max(ring->rx_pending,(u32)MIN_RXD);
@@ -571,11 +569,11 @@ ixgb_set_ringparam(struct net_device *netdev,
 	txdr->count =3D min(txdr->count,(u32)MAX_TXD);
 	txdr->count =3D ALIGN(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
=20
-	if(netif_running(adapter->netdev)) {
+	if (netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
-		if((err =3D ixgb_setup_rx_resources(adapter)))
+		if ((err =3D ixgb_setup_rx_resources(adapter)))
 			goto err_setup_rx;
-		if((err =3D ixgb_setup_tx_resources(adapter)))
+		if ((err =3D ixgb_setup_tx_resources(adapter)))
 			goto err_setup_tx;
=20
 		/* save the new, restore the old in order to free it,
@@ -589,7 +587,7 @@ ixgb_set_ringparam(struct net_device *netdev,
 		ixgb_free_tx_resources(adapter);
 		adapter->rx_ring =3D rx_new;
 		adapter->tx_ring =3D tx_new;
-		if((err =3D ixgb_up(adapter)))
+		if ((err =3D ixgb_up(adapter)))
 			return err;
 		ixgb_set_speed_duplex(netdev);
 	}
@@ -615,7 +613,7 @@ ixgb_led_blink_callback(unsigned long data)
 {
 	struct ixgb_adapter *adapter =3D (struct ixgb_adapter *)data;
=20
-	if(test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
+	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
 		ixgb_led_off(&adapter->hw);
 	else
 		ixgb_led_on(&adapter->hw);
@@ -631,7 +629,7 @@ ixgb_phys_id(struct net_device *netdev, u32 data)
 	if (!data)
 		data =3D INT_MAX;
=20
-	if(!adapter->blink_timer.function) {
+	if (!adapter->blink_timer.function) {
 		init_timer(&adapter->blink_timer);
 		adapter->blink_timer.function =3D ixgb_led_blink_callback;
 		adapter->blink_timer.data =3D (unsigned long)adapter;
@@ -647,7 +645,7 @@ ixgb_phys_id(struct net_device *netdev, u32 data)
 	return 0;
 }
=20
-static int=20
+static int
 ixgb_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
@@ -658,30 +656,30 @@ ixgb_get_sset_count(struct net_device *netdev, in=
t sset)
 	}
 }
=20
-static void=20
-ixgb_get_ethtool_stats(struct net_device *netdev,=20
+static void
+ixgb_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	int i;
=20
 	ixgb_update_stats(adapter);
-	for(i =3D 0; i < IXGB_STATS_LEN; i++) {
-		char *p =3D (char *)adapter+ixgb_gstrings_stats[i].stat_offset;=09
-		data[i] =3D (ixgb_gstrings_stats[i].sizeof_stat =3D=3D=20
+	for (i =3D 0; i < IXGB_STATS_LEN; i++) {
+		char *p =3D (char *)adapter+ixgb_gstrings_stats[i].stat_offset;
+		data[i] =3D (ixgb_gstrings_stats[i].sizeof_stat =3D=3D
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 }
=20
-static void=20
+static void
 ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	int i;
=20
 	switch(stringset) {
 	case ETH_SS_STATS:
-		for(i=3D0; i < IXGB_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN,=20
+		for (i =3D 0; i < IXGB_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
 			ixgb_gstrings_stats[i].stat_string,
 			ETH_GSTRING_LEN);
 		}
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 04d2003..11dcda0 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -125,7 +125,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	/* If we are stopped or resetting exit gracefully and wait to be
 	 * started again before accessing the hardware.
 	 */
-	if(hw->adapter_stopped) {
+	if (hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
 		return false;
 	}
@@ -347,7 +347,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
=20
 	/* Zero out the Multicast HASH table */
 	DEBUGOUT("Zeroing the MTA\n");
-	for(i =3D 0; i < IXGB_MC_TBL_SIZE; i++)
+	for (i =3D 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
=20
 	/* Zero out the VLAN Filter Table Array */
@@ -371,7 +371,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Places the MAC address in receive address register 0 and clears the=
 rest
- * of the receive addresss registers. Clears the multicast table. Assu=
mes
+ * of the receive address registers. Clears the multicast table. Assum=
es
  * the receiver is in reset when the routine is called.
  *********************************************************************=
********/
 static void
@@ -413,7 +413,7 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
=20
 	/* Zero out the other 15 receive addresses. */
 	DEBUGOUT("Clearing RAR[1-15]\n");
-	for(i =3D 1; i < IXGB_RAR_ENTRIES; i++) {
+	for (i =3D 1; i < IXGB_RAR_ENTRIES; i++) {
 		/* Write high reg first to disable the AV bit first */
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
@@ -452,19 +452,18 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
=20
 	/* Clear RAR[1-15] */
 	DEBUGOUT(" Clearing RAR[1-15]\n");
-	for(i =3D rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
+	for (i =3D rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
=20
 	/* Clear the MTA */
 	DEBUGOUT(" Clearing MTA\n");
-	for(i =3D 0; i < IXGB_MC_TBL_SIZE; i++) {
+	for (i =3D 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
-	}
=20
 	/* Add the new addresses */
-	for(i =3D 0; i < mc_addr_count; i++) {
+	for (i =3D 0; i < mc_addr_count; i++) {
 		DEBUGOUT(" Adding the multicast addresses:\n");
 		DEBUGOUT7(" MC Addr #%d =3D%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
 			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
@@ -482,7 +481,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 		/* Place this multicast address in the RAR if there is room, *
 		 * else put it in the MTA
 		 */
-		if(rar_used_count < IXGB_RAR_ENTRIES) {
+		if (rar_used_count < IXGB_RAR_ENTRIES) {
 			ixgb_rar_set(hw,
 				     mc_addr_list +
 				     (i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)),
@@ -649,7 +648,7 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
 {
 	u32 offset;
=20
-	for(offset =3D 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
+	for (offset =3D 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
 	return;
 }
@@ -719,9 +718,8 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	/* Write the new settings */
 	IXGB_WRITE_REG(hw, CTRL0, ctrl_reg);
=20
-	if (pap_reg !=3D 0) {
+	if (pap_reg !=3D 0)
 		IXGB_WRITE_REG(hw, PAP, pap_reg);
-	}
=20
 	/* Set the flow control receive threshold registers.  Normally,
 	 * these registers will be set to a default threshold that may be
@@ -729,14 +727,14 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	 * ability to transmit pause frames in not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if(!(hw->fc.type & ixgb_fc_tx_pause)) {
+	if (!(hw->fc.type & ixgb_fc_tx_pause)) {
 		IXGB_WRITE_REG(hw, FCRTL, 0);
 		IXGB_WRITE_REG(hw, FCRTH, 0);
 	} else {
 	   /* We need to set up the Receive Threshold high and low water
 	    * marks as well as (optionally) enabling the transmission of XON
 	    * frames. */
-		if(hw->fc.send_xon) {
+		if (hw->fc.send_xon) {
 			IXGB_WRITE_REG(hw, FCRTL,
 				(hw->fc.low_water | IXGB_FCRTL_XONE));
 		} else {
@@ -791,7 +789,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
=20
-	for(i =3D 0; i < 10; i++)
+	for (i =3D 0; i < 10; i++)
 	{
 		udelay(10);
=20
@@ -818,7 +816,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
=20
-	for(i =3D 0; i < 10; i++)
+	for (i =3D 0; i < 10; i++)
 	{
 		udelay(10);
=20
@@ -887,7 +885,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 	** from the CPU Write to the Ready bit assertion.
 	**************************************************************/
=20
-	for(i =3D 0; i < 10; i++)
+	for (i =3D 0; i < 10; i++)
 	{
 		udelay(10);
=20
@@ -914,7 +912,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 	** from the CPU Write to the Ready bit assertion.
 	**************************************************************/
=20
-	for(i =3D 0; i < 10; i++)
+	for (i =3D 0; i < 10; i++)
 	{
 		udelay(10);
=20
@@ -965,7 +963,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 }
=20
 /*********************************************************************=
*********
- * Check for a bad link condition that may have occured.
+ * Check for a bad link condition that may have occurred.
  * The indication is that the RFC / LFC registers may be incrementing
  * continually.  A full adapter reset is required to recover.
  *
@@ -1007,7 +1005,7 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
=20
 	/* if we are stopped or resetting exit gracefully */
-	if(hw->adapter_stopped) {
+	if (hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is stopped!!!\n");
 		return;
 	}
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 39cfa47..831fe0c 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 180d20e..2a58847 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -38,11 +38,11 @@
 #define SUN_VENDOR_ID               0x108E
 #define SUN_SUBVENDOR_ID            0x108E
=20
-#define IXGB_DEVICE_ID_82597EX      0x1048  =20
-#define IXGB_DEVICE_ID_82597EX_SR   0x1A48  =20
+#define IXGB_DEVICE_ID_82597EX      0x1048
+#define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 #define IXGB_DEVICE_ID_82597EX_LR   0x1B48
-#define IXGB_SUBDEVICE_ID_A11F      0xA11F  =20
-#define IXGB_SUBDEVICE_ID_A01F      0xA01F  =20
+#define IXGB_SUBDEVICE_ID_A11F      0xA11F
+#define IXGB_SUBDEVICE_ID_A01F      0xA01F
=20
 #define IXGB_DEVICE_ID_82597EX_CX4   0x109E
 #define IXGB_SUBDEVICE_ID_A00C  0xA00C
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 41f3adf..e83feaf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -31,14 +31,16 @@
 char ixgb_driver_name[] =3D "ixgb";
 static char ixgb_driver_string[] =3D "Intel(R) PRO/10GbE Network Drive=
r";
=20
-#ifndef CONFIG_IXGB_NAPI
-#define DRIVERNAPI
-#else
 #define DRIVERNAPI "-NAPI"
-#endif
-#define DRV_VERSION		"1.0.126-k4"DRIVERNAPI
+#define DRV_VERSION "1.0.135-k2" DRIVERNAPI
 const char ixgb_driver_version[] =3D DRV_VERSION;
-static const char ixgb_copyright[] =3D "Copyright (c) 1999-2006 Intel =
Corporation.";
+static const char ixgb_copyright[] =3D "Copyright (c) 1999-2008 Intel =
Corporation.";
+
+#define IXGB_CB_LENGTH 256
+static unsigned int copybreak __read_mostly =3D IXGB_CB_LENGTH;
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
=20
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -55,7 +57,7 @@ static struct pci_device_id ixgb_pci_tbl[] =3D {
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR, =20
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
=20
 	/* required last entry */
@@ -65,16 +67,6 @@ static struct pci_device_id ixgb_pci_tbl[] =3D {
 MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
=20
 /* Local Function Prototypes */
-
-int ixgb_up(struct ixgb_adapter *adapter);
-void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
-void ixgb_reset(struct ixgb_adapter *adapter);
-int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
-void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
-void ixgb_update_stats(struct ixgb_adapter *adapter);
-
 static int ixgb_init_module(void);
 static void ixgb_exit_module(void);
 static int ixgb_probe(struct pci_dev *pdev, const struct pci_device_id=
 *ent);
@@ -96,18 +88,15 @@ static int ixgb_set_mac(struct net_device *netdev, =
void *p);
 static irqreturn_t ixgb_intr(int irq, void *data);
 static bool ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
=20
-#ifdef CONFIG_IXGB_NAPI
-static int ixgb_clean(struct napi_struct *napi, int budget);
-static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
-			      int *work_done, int work_to_do);
-#else
-static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
-#endif
-static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
+static int ixgb_clean(struct napi_struct *, int);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *, int *, int);
+static void ixgb_alloc_rx_buffers(struct ixgb_adapter *, int);
+
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
+
 static void ixgb_vlan_rx_register(struct net_device *netdev,
-				  struct vlan_group *grp);
+                                  struct vlan_group *grp);
 static void ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
@@ -118,7 +107,7 @@ static void ixgb_netpoll(struct net_device *dev);
 #endif
=20
 static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
-	                     enum pci_channel_state state);
+                             enum pci_channel_state state);
 static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
 static void ixgb_io_resume (struct pci_dev *pdev);
=20
@@ -146,14 +135,6 @@ static int debug =3D DEFAULT_DEBUG_LEVEL_SHIFT;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
=20
-/* some defines for controlling descriptor fetches in h/w */
-#define RXDCTL_WTHRESH_DEFAULT 15  /* chip writes back at this many or=
 RXT0 */
-#define RXDCTL_PTHRESH_DEFAULT 0   /* chip considers prefech below
-                                    * this */
-#define RXDCTL_HTHRESH_DEFAULT 0   /* chip will only prefetch if tail
-                                    * is pushed this many descriptors
-                                    * from head */
-
 /**
  * ixgb_init_module - Driver Registration Routine
  *
@@ -236,7 +217,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	ixgb_configure_tx(adapter);
 	ixgb_setup_rctl(adapter);
 	ixgb_configure_rx(adapter);
-	ixgb_alloc_rx_buffers(adapter);
+	ixgb_alloc_rx_buffers(adapter, IXGB_DESC_UNUSED(&adapter->rx_ring));
=20
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
@@ -261,7 +242,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 		return err;
 	}
=20
-	if((hw->max_frame_size !=3D max_frame) ||
+	if ((hw->max_frame_size !=3D max_frame) ||
 		(hw->max_frame_size !=3D
 		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
=20
@@ -269,11 +250,11 @@ ixgb_up(struct ixgb_adapter *adapter)
=20
 		IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
=20
-		if(hw->max_frame_size >
+		if (hw->max_frame_size >
 		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
 			u32 ctrl0 =3D IXGB_READ_REG(hw, CTRL0);
=20
-			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
+			if (!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |=3D IXGB_CTRL0_JFE;
 				IXGB_WRITE_REG(hw, CTRL0, ctrl0);
 			}
@@ -282,9 +263,7 @@ ixgb_up(struct ixgb_adapter *adapter)
=20
 	clear_bit(__IXGB_DOWN, &adapter->flags);
=20
-#ifdef CONFIG_IXGB_NAPI
 	napi_enable(&adapter->napi);
-#endif
 	ixgb_irq_enable(adapter);
=20
 	mod_timer(&adapter->watchdog_timer, jiffies);
@@ -300,9 +279,7 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_w=
atchdog)
 	/* prevent the interrupt handler from restarting watchdog */
 	set_bit(__IXGB_DOWN, &adapter->flags);
=20
-#ifdef CONFIG_IXGB_NAPI
 	napi_disable(&adapter->napi);
-#endif
 	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
@@ -310,7 +287,7 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_w=
atchdog)
 	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
=20
-	if(kill_watchdog)
+	if (kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
=20
 	adapter->link_speed =3D 0;
@@ -357,27 +334,25 @@ ixgb_reset(struct ixgb_adapter *adapter)
  **/
=20
 static int __devinit
-ixgb_probe(struct pci_dev *pdev,
-		const struct pci_device_id *ent)
+ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev =3D NULL;
 	struct ixgb_adapter *adapter;
 	static int cards_found =3D 0;
-	unsigned long mmio_start;
-	int mmio_len;
 	int pci_using_dac;
 	int i;
 	int err;
=20
-	if((err =3D pci_enable_device(pdev)))
+	err =3D pci_enable_device(pdev);
+	if (err)
 		return err;
=20
-	if(!(err =3D pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
-	   !(err =3D pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if (!(err =3D pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
+	    !(err =3D pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac =3D 1;
 	} else {
-		if((err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
-		   (err =3D pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if ((err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
+		    (err =3D pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			printk(KERN_ERR
 			 "ixgb: No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
@@ -385,13 +360,14 @@ ixgb_probe(struct pci_dev *pdev,
 		pci_using_dac =3D 0;
 	}
=20
-	if((err =3D pci_request_regions(pdev, ixgb_driver_name)))
+	err =3D pci_request_regions(pdev, ixgb_driver_name);
+	if (err)
 		goto err_request_regions;
=20
 	pci_set_master(pdev);
=20
 	netdev =3D alloc_etherdev(sizeof(struct ixgb_adapter));
-	if(!netdev) {
+	if (!netdev) {
 		err =3D -ENOMEM;
 		goto err_alloc_etherdev;
 	}
@@ -405,19 +381,17 @@ ixgb_probe(struct pci_dev *pdev,
 	adapter->hw.back =3D adapter;
 	adapter->msg_enable =3D netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHI=
=46T);
=20
-	mmio_start =3D pci_resource_start(pdev, BAR_0);
-	mmio_len =3D pci_resource_len(pdev, BAR_0);
-
-	adapter->hw.hw_addr =3D ioremap(mmio_start, mmio_len);
-	if(!adapter->hw.hw_addr) {
+	adapter->hw.hw_addr =3D ioremap(pci_resource_start(pdev, BAR_0),
+	                              pci_resource_len(pdev, BAR_0));
+	if (!adapter->hw.hw_addr) {
 		err =3D -EIO;
 		goto err_ioremap;
 	}
=20
-	for(i =3D BAR_1; i <=3D BAR_5; i++) {
-		if(pci_resource_len(pdev, i) =3D=3D 0)
+	for (i =3D BAR_1; i <=3D BAR_5; i++) {
+		if (pci_resource_len(pdev, i) =3D=3D 0)
 			continue;
-		if(pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
 			adapter->hw.io_base =3D pci_resource_start(pdev, i);
 			break;
 		}
@@ -433,9 +407,7 @@ ixgb_probe(struct pci_dev *pdev,
 	ixgb_set_ethtool_ops(netdev);
 	netdev->tx_timeout =3D &ixgb_tx_timeout;
 	netdev->watchdog_timeo =3D 5 * HZ;
-#ifdef CONFIG_IXGB_NAPI
 	netif_napi_add(netdev, &adapter->napi, ixgb_clean, 64);
-#endif
 	netdev->vlan_rx_register =3D ixgb_vlan_rx_register;
 	netdev->vlan_rx_add_vid =3D ixgb_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid =3D ixgb_vlan_rx_kill_vid;
@@ -444,9 +416,6 @@ ixgb_probe(struct pci_dev *pdev,
 #endif
=20
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
-	netdev->mem_start =3D mmio_start;
-	netdev->mem_end =3D mmio_start + mmio_len;
-	netdev->base_addr =3D adapter->hw.io_base;
=20
 	adapter->bd_number =3D cards_found;
 	adapter->link_speed =3D 0;
@@ -454,7 +423,8 @@ ixgb_probe(struct pci_dev *pdev,
=20
 	/* setup the private structure */
=20
-	if((err =3D ixgb_sw_init(adapter)))
+	err =3D ixgb_sw_init(adapter);
+	if (err)
 		goto err_sw_init;
=20
 	netdev->features =3D NETIF_F_SG |
@@ -463,16 +433,13 @@ ixgb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |=3D NETIF_F_TSO;
-#ifdef NETIF_F_LLTX
-	netdev->features |=3D NETIF_F_LLTX;
-#endif
=20
-	if(pci_using_dac)
+	if (pci_using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
 	/* make sure the EEPROM is good */
=20
-	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
 		err =3D -EIO;
 		goto err_eeprom;
@@ -481,7 +448,7 @@ ixgb_probe(struct pci_dev *pdev,
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
=20
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err =3D -EIO;
 		goto err_eeprom;
@@ -496,7 +463,8 @@ ixgb_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
=20
 	strcpy(netdev->name, "eth%d");
-	if((err =3D register_netdev(netdev)))
+	err =3D register_netdev(netdev);
+	if (err)
 		goto err_register;
=20
 	/* we're going to reset, so assume we have no link for now */
@@ -543,6 +511,8 @@ ixgb_remove(struct pci_dev *pdev)
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
=20
+	flush_scheduled_work();
+
 	unregister_netdev(netdev);
=20
 	iounmap(adapter->hw.hw_addr);
@@ -575,13 +545,13 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	hw->subsystem_id =3D pdev->subsystem_device;
=20
 	hw->max_frame_size =3D netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENG=
TH;
-	adapter->rx_buffer_len =3D hw->max_frame_size;
+	adapter->rx_buffer_len =3D hw->max_frame_size + 8; /* + 8 for errata =
*/
=20
-	if((hw->device_id =3D=3D IXGB_DEVICE_ID_82597EX)
+	if ((hw->device_id =3D=3D IXGB_DEVICE_ID_82597EX)
 	   || (hw->device_id =3D=3D IXGB_DEVICE_ID_82597EX_CX4)
 	   || (hw->device_id =3D=3D IXGB_DEVICE_ID_82597EX_LR)
 	   || (hw->device_id =3D=3D IXGB_DEVICE_ID_82597EX_SR))
-			hw->mac_type =3D ixgb_82597;
+		hw->mac_type =3D ixgb_82597;
 	else {
 		/* should never have loaded on this device */
 		DPRINTK(PROBE, ERR, "unsupported device id\n");
@@ -590,8 +560,6 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	/* enable flow control to be programmed */
 	hw->fc.send_xon =3D 1;
=20
-	spin_lock_init(&adapter->tx_lock);
-
 	set_bit(__IXGB_DOWN, &adapter->flags);
 	return 0;
 }
@@ -616,16 +584,18 @@ ixgb_open(struct net_device *netdev)
 	int err;
=20
 	/* allocate transmit descriptors */
-
-	if((err =3D ixgb_setup_tx_resources(adapter)))
+	err =3D ixgb_setup_tx_resources(adapter);
+	if (err)
 		goto err_setup_tx;
=20
 	/* allocate receive descriptors */
=20
-	if((err =3D ixgb_setup_rx_resources(adapter)))
+	err =3D ixgb_setup_rx_resources(adapter);
+	if (err)
 		goto err_setup_rx;
=20
-	if((err =3D ixgb_up(adapter)))
+	err =3D ixgb_up(adapter);
+	if (err)
 		goto err_up;
=20
 	return 0;
@@ -681,7 +651,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapte=
r)
=20
 	size =3D sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info =3D vmalloc(size);
-	if(!txdr->buffer_info) {
+	if (!txdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
@@ -694,7 +664,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapte=
r)
 	txdr->size =3D ALIGN(txdr->size, 4096);
=20
 	txdr->desc =3D pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if(!txdr->desc) {
+	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate transmit descriptor memory\n");
@@ -723,8 +693,8 @@ ixgb_configure_tx(struct ixgb_adapter *adapter)
 	u32 tctl;
 	struct ixgb_hw *hw =3D &adapter->hw;
=20
-	/* Setup the Base and Length of the Tx Descriptor Ring=20
-	 * tx_ring.dma can be either a 32 or 64 bit value=20
+	/* Setup the Base and Length of the Tx Descriptor Ring
+	 * tx_ring.dma can be either a 32 or 64 bit value
 	 */
=20
 	IXGB_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
@@ -750,8 +720,8 @@ ixgb_configure_tx(struct ixgb_adapter *adapter)
=20
 	/* Setup Transmit Descriptor Settings for this adapter */
 	adapter->tx_cmd_type =3D
-		IXGB_TX_DESC_TYPE=20
-		| (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
+		IXGB_TX_DESC_TYPE |
+		(adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
 }
=20
 /**
@@ -770,7 +740,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapte=
r)
=20
 	size =3D sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info =3D vmalloc(size);
-	if(!rxdr->buffer_info) {
+	if (!rxdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
@@ -784,7 +754,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapte=
r)
=20
 	rxdr->desc =3D pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
=20
-	if(!rxdr->desc) {
+	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate receive descriptors\n");
@@ -813,8 +783,8 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
 	rctl &=3D ~(3 << IXGB_RCTL_MO_SHIFT);
=20
 	rctl |=3D
-		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |=20
-		IXGB_RCTL_RXEN | IXGB_RCTL_CFF |=20
+		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |
+		IXGB_RCTL_RXEN | IXGB_RCTL_CFF |
 		(adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
=20
 	rctl |=3D IXGB_RCTL_SECRC;
@@ -846,7 +816,6 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	struct ixgb_hw *hw =3D &adapter->hw;
 	u32 rctl;
 	u32 rxcsum;
-	u32 rxdctl;
=20
 	/* make sure receives are disabled while setting up the descriptors *=
/
=20
@@ -868,18 +837,12 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	IXGB_WRITE_REG(hw, RDH, 0);
 	IXGB_WRITE_REG(hw, RDT, 0);
=20
-	/* set up pre-fetching of receive buffers so we get some before we
-	 * run out (default hardware behavior is to run out before fetching
-	 * more).  This sets up to fetch if HTHRESH rx descriptors are avail
-	 * and the descriptors in hw cache are below PTHRESH.  This avoids
-	 * the hardware behavior of fetching <=3D512 descriptors in a single
-	 * burst that pre-empts all other activity, usually causing fifo
-	 * overflows. */
-	/* use WTHRESH to burst write 16 descriptors or burst when RXT0 */
-	rxdctl =3D RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT |
-	         RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT |
-	         RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
-	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
+	/* due to the hardware errata with RXDCTL, we are unable to use any o=
f
+	 * the performance enhancing features of it without causing other
+	 * subtle bugs, some of the bugs could include receive length
+	 * corruption at high data rates (WTHRESH > 0) and/or receive
+	 * descriptor ring irregularites (particularly in hardware cache) */
+	IXGB_WRITE_REG(hw, RXDCTL, 0);
=20
 	/* Enable Receive Checksum Offload for TCP and UDP */
 	if (adapter->rx_csum) {
@@ -918,7 +881,7 @@ ixgb_free_tx_resources(struct ixgb_adapter *adapter=
)
=20
 static void
 ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
-					struct ixgb_buffer *buffer_info)
+                                struct ixgb_buffer *buffer_info)
 {
 	struct pci_dev *pdev =3D adapter->pdev;
=20
@@ -926,8 +889,10 @@ ixgb_unmap_and_free_tx_resource(struct ixgb_adapte=
r *adapter,
 		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
 		               PCI_DMA_TODEVICE);
=20
+	/* okay to call kfree_skb here instead of kfree_skb_any because
+	 * this is never called in interrupt context */
 	if (buffer_info->skb)
-		dev_kfree_skb_any(buffer_info->skb);
+		dev_kfree_skb(buffer_info->skb);
=20
 	buffer_info->skb =3D NULL;
 	buffer_info->dma =3D 0;
@@ -952,7 +917,7 @@ ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
=20
 	/* Free all the Tx ring sk_buffs */
=20
-	for(i =3D 0; i < tx_ring->count; i++) {
+	for (i =3D 0; i < tx_ring->count; i++) {
 		buffer_info =3D &tx_ring->buffer_info[i];
 		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
@@ -1010,9 +975,9 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
=20
 	/* Free all the Rx ring sk_buffs */
=20
-	for(i =3D 0; i < rx_ring->count; i++) {
+	for (i =3D 0; i < rx_ring->count; i++) {
 		buffer_info =3D &rx_ring->buffer_info[i];
-		if(buffer_info->skb) {
+		if (buffer_info->skb) {
=20
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
@@ -1053,7 +1018,7 @@ ixgb_set_mac(struct net_device *netdev, void *p)
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	struct sockaddr *addr =3D p;
=20
-	if(!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
=20
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -1086,16 +1051,16 @@ ixgb_set_multi(struct net_device *netdev)
=20
 	rctl =3D IXGB_READ_REG(hw, RCTL);
=20
-	if(netdev->flags & IFF_PROMISC) {
+	if (netdev->flags & IFF_PROMISC) {
 		rctl |=3D (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
-	} else if(netdev->flags & IFF_ALLMULTI) {
+	} else if (netdev->flags & IFF_ALLMULTI) {
 		rctl |=3D IXGB_RCTL_MPE;
 		rctl &=3D ~IXGB_RCTL_UPE;
 	} else {
 		rctl &=3D ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 	}
=20
-	if(netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |=3D IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1104,10 +1069,11 @@ ixgb_set_multi(struct net_device *netdev)
=20
 		IXGB_WRITE_REG(hw, RCTL, rctl);
=20
-		for(i =3D 0, mc_ptr =3D netdev->mc_list; mc_ptr;
-			i++, mc_ptr =3D mc_ptr->next)
+		for (i =3D 0, mc_ptr =3D netdev->mc_list;
+		     mc_ptr;
+		     i++, mc_ptr =3D mc_ptr->next)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
-				   mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
=20
 		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
 	}
@@ -1132,8 +1098,8 @@ ixgb_watchdog(unsigned long data)
 		netif_stop_queue(netdev);
 	}
=20
-	if(adapter->hw.link_up) {
-		if(!netif_carrier_ok(netdev)) {
+	if (adapter->hw.link_up) {
+		if (!netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO,
 			        "NIC Link is Up 10000 Mbps Full Duplex\n");
 			adapter->link_speed =3D 10000;
@@ -1142,7 +1108,7 @@ ixgb_watchdog(unsigned long data)
 			netif_wake_queue(netdev);
 		}
 	} else {
-		if(netif_carrier_ok(netdev)) {
+		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed =3D 0;
 			adapter->link_duplex =3D 0;
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
@@ -1154,8 +1120,8 @@ ixgb_watchdog(unsigned long data)
=20
 	ixgb_update_stats(adapter);
=20
-	if(!netif_carrier_ok(netdev)) {
-		if(IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
+	if (!netif_carrier_ok(netdev)) {
+		if (IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
@@ -1227,7 +1193,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_=
buff *skb)
 		context_desc->hdr_len =3D hdr_len;
 		context_desc->status =3D 0;
 		context_desc->cmd_type_len =3D cpu_to_le32(
-						  IXGB_CONTEXT_DESC_TYPE=20
+						  IXGB_CONTEXT_DESC_TYPE
 						| IXGB_CONTEXT_DESC_CMD_TSE
 						| IXGB_CONTEXT_DESC_CMD_IP
 						| IXGB_CONTEXT_DESC_CMD_TCP
@@ -1235,7 +1201,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_=
buff *skb)
 						| (skb->len - (hdr_len)));
=20
=20
-		if(++i =3D=3D adapter->tx_ring.count) i =3D 0;
+		if (++i =3D=3D adapter->tx_ring.count) i =3D 0;
 		adapter->tx_ring.next_to_use =3D i;
=20
 		return 1;
@@ -1251,7 +1217,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct=
 sk_buff *skb)
 	unsigned int i;
 	u8 css, cso;
=20
-	if(likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
+	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
 		struct ixgb_buffer *buffer_info;
 		css =3D skb_transport_offset(skb);
 		cso =3D css + skb->csum_offset;
@@ -1273,7 +1239,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct=
 sk_buff *skb)
 			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
 				    | IXGB_TX_DESC_CMD_IDE);
=20
-		if(++i =3D=3D adapter->tx_ring.count) i =3D 0;
+		if (++i =3D=3D adapter->tx_ring.count) i =3D 0;
 		adapter->tx_ring.next_to_use =3D i;
=20
 		return true;
@@ -1302,7 +1268,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct =
sk_buff *skb,
=20
 	i =3D tx_ring->next_to_use;
=20
-	while(len) {
+	while (len) {
 		buffer_info =3D &tx_ring->buffer_info[i];
 		size =3D min(len, IXGB_MAX_DATA_PER_TXD);
 		/* Workaround for premature desc write-backs
@@ -1312,28 +1278,28 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struc=
t sk_buff *skb,
=20
 		buffer_info->length =3D size;
 		WARN_ON(buffer_info->dma !=3D 0);
+		buffer_info->time_stamp =3D jiffies;
 		buffer_info->dma =3D
 			pci_map_single(adapter->pdev,
 				skb->data + offset,
 				size,
 				PCI_DMA_TODEVICE);
-		buffer_info->time_stamp =3D jiffies;
 		buffer_info->next_to_watch =3D 0;
=20
 		len -=3D size;
 		offset +=3D size;
 		count++;
-		if(++i =3D=3D tx_ring->count) i =3D 0;
+		if (++i =3D=3D tx_ring->count) i =3D 0;
 	}
=20
-	for(f =3D 0; f < nr_frags; f++) {
+	for (f =3D 0; f < nr_frags; f++) {
 		struct skb_frag_struct *frag;
=20
 		frag =3D &skb_shinfo(skb)->frags[f];
 		len =3D frag->size;
 		offset =3D 0;
=20
-		while(len) {
+		while (len) {
 			buffer_info =3D &tx_ring->buffer_info[i];
 			size =3D min(len, IXGB_MAX_DATA_PER_TXD);
=20
@@ -1344,19 +1310,19 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struc=
t sk_buff *skb,
 				size -=3D 4;
=20
 			buffer_info->length =3D size;
+			buffer_info->time_stamp =3D jiffies;
 			buffer_info->dma =3D
 				pci_map_page(adapter->pdev,
 					frag->page,
 					frag->page_offset + offset,
 					size,
 					PCI_DMA_TODEVICE);
-			buffer_info->time_stamp =3D jiffies;
 			buffer_info->next_to_watch =3D 0;
=20
 			len -=3D size;
 			offset +=3D size;
 			count++;
-			if(++i =3D=3D tx_ring->count) i =3D 0;
+			if (++i =3D=3D tx_ring->count) i =3D 0;
 		}
 	}
 	i =3D (i =3D=3D 0) ? tx_ring->count - 1 : i - 1;
@@ -1377,21 +1343,20 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int=
 count, int vlan_id,int tx_flags)
 	u8 popts =3D 0;
 	unsigned int i;
=20
-	if(tx_flags & IXGB_TX_FLAGS_TSO) {
+	if (tx_flags & IXGB_TX_FLAGS_TSO) {
 		cmd_type_len |=3D IXGB_TX_DESC_CMD_TSE;
 		popts |=3D (IXGB_TX_DESC_POPTS_IXSM | IXGB_TX_DESC_POPTS_TXSM);
 	}
=20
-	if(tx_flags & IXGB_TX_FLAGS_CSUM)
+	if (tx_flags & IXGB_TX_FLAGS_CSUM)
 		popts |=3D IXGB_TX_DESC_POPTS_TXSM;
=20
-	if(tx_flags & IXGB_TX_FLAGS_VLAN) {
+	if (tx_flags & IXGB_TX_FLAGS_VLAN)
 		cmd_type_len |=3D IXGB_TX_DESC_CMD_VLE;
-	}
=20
 	i =3D tx_ring->next_to_use;
=20
-	while(count--) {
+	while (count--) {
 		buffer_info =3D &tx_ring->buffer_info[i];
 		tx_desc =3D IXGB_TX_DESC(*tx_ring, i);
 		tx_desc->buff_addr =3D cpu_to_le64(buffer_info->dma);
@@ -1401,11 +1366,11 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int=
 count, int vlan_id,int tx_flags)
 		tx_desc->popts =3D popts;
 		tx_desc->vlan =3D cpu_to_le16(vlan_id);
=20
-		if(++i =3D=3D tx_ring->count) i =3D 0;
+		if (++i =3D=3D tx_ring->count) i =3D 0;
 	}
=20
-	tx_desc->cmd_type_len |=3D cpu_to_le32(IXGB_TX_DESC_CMD_EOP=20
-				| IXGB_TX_DESC_CMD_RS );
+	tx_desc->cmd_type_len |=3D
+		cpu_to_le32(IXGB_TX_DESC_CMD_EOP | IXGB_TX_DESC_CMD_RS);
=20
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -1461,7 +1426,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_d=
evice *netdev)
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	unsigned int first;
 	unsigned int tx_flags =3D 0;
-	unsigned long flags;
 	int vlan_id =3D 0;
 	int tso;
=20
@@ -1470,51 +1434,31 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net=
_device *netdev)
 		return NETDEV_TX_OK;
 	}
=20
-	if(skb->len <=3D 0) {
-		dev_kfree_skb_any(skb);
+	if (skb->len <=3D 0) {
+		dev_kfree_skb(skb);
 		return 0;
 	}
=20
-#ifdef NETIF_F_LLTX
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-#else
-	spin_lock_irqsave(&adapter->tx_lock, flags);
-#endif
-
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
-                     DESC_NEEDED))) {
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+                     DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
-	}
=20
-#ifndef NETIF_F_LLTX
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
-
-	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |=3D IXGB_TX_FLAGS_VLAN;
 		vlan_id =3D vlan_tx_tag_get(skb);
 	}
=20
 	first =3D adapter->tx_ring.next_to_use;
-=09
+
 	tso =3D ixgb_tso(adapter, skb);
 	if (tso < 0) {
-		dev_kfree_skb_any(skb);
-#ifdef NETIF_F_LLTX
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
+		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
=20
 	if (likely(tso))
 		tx_flags |=3D IXGB_TX_FLAGS_TSO;
-	else if(ixgb_tx_csum(adapter, skb))
+	else if (ixgb_tx_csum(adapter, skb))
 		tx_flags |=3D IXGB_TX_FLAGS_CSUM;
=20
 	ixgb_tx_queue(adapter, ixgb_tx_map(adapter, skb, first), vlan_id,
@@ -1522,13 +1466,9 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_=
device *netdev)
=20
 	netdev->trans_start =3D jiffies;
=20
-#ifdef NETIF_F_LLTX
 	/* Make sure there is space in the ring for the next send. */
 	ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
=20
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-
-#endif
 	return NETDEV_TX_OK;
 }
=20
@@ -1588,21 +1528,25 @@ ixgb_change_mtu(struct net_device *netdev, int =
new_mtu)
 	int max_frame =3D new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	int old_max_frame =3D netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGT=
H;
=20
-
-	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGT=
H)
-	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
+	/* MTU < 68 is an error for IPv4 traffic, just don't allow it */
+	if ((new_mtu < 68) ||
+	    (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
 		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
=20
-	adapter->rx_buffer_len =3D max_frame;
+	if (old_max_frame =3D=3D max_frame)
+		return 0;
+
+	if (netif_running(netdev))
+		ixgb_down(adapter, true);
+
+	adapter->rx_buffer_len =3D max_frame + 8; /* + 8 for errata */
=20
 	netdev->mtu =3D new_mtu;
=20
-	if ((old_max_frame !=3D max_frame) && netif_running(netdev)) {
-		ixgb_down(adapter, true);
+	if (netif_running(netdev))
 		ixgb_up(adapter);
-	}
=20
 	return 0;
 }
@@ -1622,21 +1566,21 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 	if (pci_channel_offline(pdev))
 		return;
=20
-	if((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
+	if ((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) |=
|
 	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
 		u64 multi =3D IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l =3D IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h =3D IXGB_READ_REG(&adapter->hw, BPRCH);
-		u64 bcast =3D ((u64)bcast_h << 32) | bcast_l;=20
+		u64 bcast =3D ((u64)bcast_h << 32) | bcast_l;
=20
 		multi |=3D ((u64)IXGB_READ_REG(&adapter->hw, MPRCH) << 32);
 		/* fix up multicast stats by removing broadcasts */
-		if(multi >=3D bcast)
+		if (multi >=3D bcast)
 			multi -=3D bcast;
-	=09
+
 		adapter->stats.mprcl +=3D (multi & 0xFFFFFFFF);
 		adapter->stats.mprch +=3D (multi >> 32);
-		adapter->stats.bprcl +=3D bcast_l;=20
+		adapter->stats.bprcl +=3D bcast_l;
 		adapter->stats.bprch +=3D bcast_h;
 	} else {
 		adapter->stats.mprcl +=3D IXGB_READ_REG(&adapter->hw, MPRCL);
@@ -1751,41 +1695,26 @@ ixgb_intr(int irq, void *data)
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	struct ixgb_hw *hw =3D &adapter->hw;
 	u32 icr =3D IXGB_READ_REG(hw, ICR);
-#ifndef CONFIG_IXGB_NAPI
-	unsigned int i;
-#endif
=20
-	if(unlikely(!icr))
+	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
=20
 	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC)))
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies);
=20
-#ifdef CONFIG_IXGB_NAPI
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
=20
-		/* Disable interrupts and register for poll. The flush=20
+		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
=20
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}
-#else
-	/* yes, that is actually a & and it is meant to make sure that
-	 * every pass through this for loop checks both receive and
-	 * transmit queues for completed descriptors, intended to
-	 * avoid starvation issues and assist tx/rx fairness. */
-	for(i =3D 0; i < IXGB_MAX_INTR; i++)
-		if(!ixgb_clean_rx_irq(adapter) &
-		   !ixgb_clean_tx_irq(adapter))
-			break;
-#endif=20
 	return IRQ_HANDLED;
 }
=20
-#ifdef CONFIG_IXGB_NAPI
 /**
  * ixgb_clean - NAPI Rx polling callback
  * @adapter: board private structure
@@ -1804,12 +1733,12 @@ ixgb_clean(struct napi_struct *napi, int budget=
)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		ixgb_irq_enable(adapter);
+		if (!test_bit(__IXGB_DOWN, &adapter->flags))
+			ixgb_irq_enable(adapter);
 	}
=20
 	return work_done;
 }
-#endif
=20
 /**
  * ixgb_clean_tx_irq - Reclaim resources after transmit completes
@@ -1830,15 +1759,15 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	eop =3D tx_ring->buffer_info[i].next_to_watch;
 	eop_desc =3D IXGB_TX_DESC(*tx_ring, eop);
=20
-	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
+	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
=20
 		for (cleaned =3D false; !cleaned; ) {
 			tx_desc =3D IXGB_TX_DESC(*tx_ring, i);
 			buffer_info =3D &tx_ring->buffer_info[i];
=20
-			if (tx_desc->popts
-			    & (IXGB_TX_DESC_POPTS_TXSM |
-			       IXGB_TX_DESC_POPTS_IXSM))
+			if (tx_desc->popts &
+			   (IXGB_TX_DESC_POPTS_TXSM |
+			    IXGB_TX_DESC_POPTS_IXSM))
 				adapter->hw_csum_tx_good++;
=20
 			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -1846,7 +1775,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 			*(u32 *)&(tx_desc->status) =3D 0;
=20
 			cleaned =3D (i =3D=3D eop);
-			if(++i =3D=3D tx_ring->count) i =3D 0;
+			if (++i =3D=3D tx_ring->count) i =3D 0;
 		}
=20
 		eop =3D tx_ring->buffer_info[i].next_to_watch;
@@ -1855,15 +1784,20 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
=20
 	tx_ring->next_to_clean =3D i;
=20
-	if (unlikely(netif_queue_stopped(netdev))) {
-		spin_lock(&adapter->tx_lock);
-		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
-		    (IXGB_DESC_UNUSED(tx_ring) >=3D DESC_NEEDED))
+	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
+		     IXGB_DESC_UNUSED(tx_ring) >=3D DESC_NEEDED)) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean. */
+		smp_mb();
+
+		if (netif_queue_stopped(netdev) &&
+		    !(test_bit(__IXGB_DOWN, &adapter->flags))) {
 			netif_wake_queue(netdev);
-		spin_unlock(&adapter->tx_lock);
+			++adapter->restart_queue;
+		}
 	}
=20
-	if(adapter->detect_tx_hung) {
+	if (adapter->detect_tx_hung) {
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung =3D false;
@@ -1906,13 +1840,13 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
=20
 static void
 ixgb_rx_checksum(struct ixgb_adapter *adapter,
-		 struct ixgb_rx_desc *rx_desc,
-		 struct sk_buff *skb)
+                 struct ixgb_rx_desc *rx_desc,
+                 struct sk_buff *skb)
 {
 	/* Ignore Checksum bit is set OR
 	 * TCP Checksum has not been calculated
 	 */
-	if((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
+	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
 	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
 		skb->ip_summed =3D CHECKSUM_NONE;
 		return;
@@ -1920,7 +1854,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
=20
 	/* At this point we know the hardware did the TCP checksum */
 	/* now look at the TCP checksum error bit */
-	if(rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
+	if (rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
 		/* let the stack verify checksum errors */
 		skb->ip_summed =3D CHECKSUM_NONE;
 		adapter->hw_csum_rx_error++;
@@ -1937,11 +1871,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
  **/
=20
 static bool
-#ifdef CONFIG_IXGB_NAPI
 ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int wo=
rk_to_do)
-#else
-ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
-#endif
 {
 	struct ixgb_desc_ring *rx_ring =3D &adapter->rx_ring;
 	struct net_device *netdev =3D adapter->netdev;
@@ -1950,50 +1880,50 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
 	u32 length;
 	unsigned int i, j;
+	int cleaned_count =3D 0;
 	bool cleaned =3D false;
=20
 	i =3D rx_ring->next_to_clean;
 	rx_desc =3D IXGB_RX_DESC(*rx_ring, i);
 	buffer_info =3D &rx_ring->buffer_info[i];
=20
-	while(rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
-		struct sk_buff *skb, *next_skb;
+	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
+		struct sk_buff *skb;
 		u8 status;
=20
-#ifdef CONFIG_IXGB_NAPI
-		if(*work_done >=3D work_to_do)
+		if (*work_done >=3D work_to_do)
 			break;
=20
 		(*work_done)++;
-#endif
 		status =3D rx_desc->status;
 		skb =3D buffer_info->skb;
 		buffer_info->skb =3D NULL;
=20
-		prefetch(skb->data);
+		prefetch(skb->data - NET_IP_ALIGN);
=20
-		if(++i =3D=3D rx_ring->count) i =3D 0;
+		if (++i =3D=3D rx_ring->count) i =3D 0;
 		next_rxd =3D IXGB_RX_DESC(*rx_ring, i);
 		prefetch(next_rxd);
=20
-		if((j =3D i + 1) =3D=3D rx_ring->count) j =3D 0;
+		if ((j =3D i + 1) =3D=3D rx_ring->count) j =3D 0;
 		next2_buffer =3D &rx_ring->buffer_info[j];
 		prefetch(next2_buffer);
=20
 		next_buffer =3D &rx_ring->buffer_info[i];
-		next_skb =3D next_buffer->skb;
-		prefetch(next_skb);
=20
 		cleaned =3D true;
+		cleaned_count++;
=20
 		pci_unmap_single(pdev,
 				 buffer_info->dma,
 				 buffer_info->length,
 				 PCI_DMA_FROMDEVICE);
+		buffer_info->dma =3D 0;
=20
 		length =3D le16_to_cpu(rx_desc->length);
+		rx_desc->length =3D 0;
=20
-		if(unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
+		if (unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
=20
 			/* All receives must fit into a single buffer */
=20
@@ -2004,11 +1934,9 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 			goto rxdesc_done;
 		}
=20
-		if (unlikely(rx_desc->errors
-			     & (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE
-				| IXGB_RX_DESC_ERRORS_P |
-				IXGB_RX_DESC_ERRORS_RXE))) {
-
+		if (unlikely(rx_desc->errors &
+		    (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE |
+		     IXGB_RX_DESC_ERRORS_P | IXGB_RX_DESC_ERRORS_RXE))) {
 			dev_kfree_skb_irq(skb);
 			goto rxdesc_done;
 		}
@@ -2016,8 +1944,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */
-#define IXGB_CB_LENGTH 256
-		if (length < IXGB_CB_LENGTH) {
+		if (length < copybreak) {
 			struct sk_buff *new_skb =3D
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
@@ -2042,27 +1969,24 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		ixgb_rx_checksum(adapter, rx_desc, skb);
=20
 		skb->protocol =3D eth_type_trans(skb, netdev);
-#ifdef CONFIG_IXGB_NAPI
-		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
+		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special));
+			                        le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
-#else /* CONFIG_IXGB_NAPI */
-		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
-			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special));
-		} else {
-			netif_rx(skb);
-		}
-#endif /* CONFIG_IXGB_NAPI */
 		netdev->last_rx =3D jiffies;
=20
 rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
 		rx_desc->status =3D 0;
=20
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >=3D IXGB_RX_BUFFER_WRITE)) {
+			ixgb_alloc_rx_buffers(adapter, cleaned_count);
+			cleaned_count =3D 0;
+		}
+
 		/* use prefetched values */
 		rx_desc =3D next_rxd;
 		buffer_info =3D next_buffer;
@@ -2070,7 +1994,9 @@ rxdesc_done:
=20
 	rx_ring->next_to_clean =3D i;
=20
-	ixgb_alloc_rx_buffers(adapter);
+	cleaned_count =3D IXGB_DESC_UNUSED(rx_ring);
+	if (cleaned_count)
+		ixgb_alloc_rx_buffers(adapter, cleaned_count);
=20
 	return cleaned;
 }
@@ -2081,7 +2007,7 @@ rxdesc_done:
  **/
=20
 static void
-ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
+ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter, int cleaned_count)
 {
 	struct ixgb_desc_ring *rx_ring =3D &adapter->rx_ring;
 	struct net_device *netdev =3D adapter->netdev;
@@ -2098,7 +2024,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapte=
r)
=20
=20
 	/* leave three descriptors unused */
-	while(--cleancount > 2) {
+	while (--cleancount > 2 && cleaned_count--) {
 		/* recycle! its good for you */
 		skb =3D buffer_info->skb;
 		if (skb) {
@@ -2131,12 +2057,12 @@ map_skb:
 		rx_desc =3D IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr =3D cpu_to_le64(buffer_info->dma);
 		/* guarantee DD bit not set now before h/w gets descriptor
-		 * this is the rest of the workaround for h/w double=20
+		 * this is the rest of the workaround for h/w double
 		 * writeback. */
 		rx_desc->status =3D 0;
=20
=20
-		if(++i =3D=3D rx_ring->count) i =3D 0;
+		if (++i =3D=3D rx_ring->count) i =3D 0;
 		buffer_info =3D &rx_ring->buffer_info[i];
 	}
=20
@@ -2156,7 +2082,7 @@ map_skb:
=20
 /**
  * ixgb_vlan_rx_register - enables or disables vlan tagging/stripping.
- *=20
+ *
  * @param netdev network interface device structure
  * @param grp indicates to enable or disable tagging/stripping
  **/
@@ -2169,7 +2095,7 @@ ixgb_vlan_rx_register(struct net_device *netdev, =
struct vlan_group *grp)
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp =3D grp;
=20
-	if(grp) {
+	if (grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl =3D IXGB_READ_REG(&adapter->hw, CTRL0);
 		ctrl |=3D IXGB_CTRL0_VME;
@@ -2241,10 +2167,10 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 {
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
=20
-	if(adapter->vlgrp) {
+	if (adapter->vlgrp) {
 		u16 vid;
-		for(vid =3D 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if(!vlan_group_get_device(adapter->vlgrp, vid))
+		for (vid =3D 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
 		}
@@ -2276,13 +2202,13 @@ static void ixgb_netpoll(struct net_device *dev=
)
  * This callback is called by the PCI subsystem whenever
  * a PCI bus error is detected.
  */
-static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
-			             enum pci_channel_state state)
+static pci_ers_result_t ixgb_io_error_detected(struct pci_dev *pdev,
+                                               enum pci_channel_state =
state)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
=20
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		ixgb_down(adapter, true);
=20
 	pci_disable_device(pdev);
@@ -2295,17 +2221,17 @@ static pci_ers_result_t ixgb_io_error_detected =
(struct pci_dev *pdev,
  * ixgb_io_slot_reset - called after the pci bus has been reset.
  * @pdev    pointer to pci device with error
  *
- * This callback is called after the PCI buss has been reset.
+ * This callback is called after the PCI bus has been reset.
  * Basically, this tries to restart the card from scratch.
  * This is a shortened version of the device probe/discovery code,
  * it resembles the first-half of the ixgb_probe() routine.
  */
-static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
+static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
=20
-	if(pci_enable_device(pdev)) {
+	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -2321,14 +2247,14 @@ static pci_ers_result_t ixgb_io_slot_reset (str=
uct pci_dev *pdev)
 	ixgb_reset(adapter);
=20
 	/* Make sure the EEPROM is good */
-	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		DPRINTK(PROBE, ERR, "After reset, the EEPROM checksum is not valid.\=
n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
=20
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "After reset, invalid MAC address.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
@@ -2344,15 +2270,15 @@ static pci_ers_result_t ixgb_io_slot_reset (str=
uct pci_dev *pdev)
  * normal operation. Implementation resembles the second-half
  * of the ixgb_probe() routine.
  */
-static void ixgb_io_resume (struct pci_dev *pdev)
+static void ixgb_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
=20
 	pci_set_master(pdev);
=20
-	if(netif_running(netdev)) {
-		if(ixgb_up(adapter)) {
+	if (netif_running(netdev)) {
+		if (ixgb_up(adapter)) {
 			printk ("ixgb: can't bring device back up after reset\n");
 			return;
 		}
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osde=
p.h
index 4be1b27..d92e72b 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -40,7 +40,7 @@
 #include <linux/sched.h>
=20
 #undef ASSERT
-#define ASSERT(x)	if(!(x)) BUG()
+#define ASSERT(x)	if (!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
=20
 #ifdef DBG
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_para=
m.c
index 865d14d..af35e1d 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -1,7 +1,7 @@
 /*********************************************************************=
**********
=20
   Intel PRO/10GbE Linux driver
-  Copyright(c) 1999 - 2006 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
=20
   This program is free software; you can redistribute it and/or modify=
 it
   under the terms and conditions of the GNU General Public License,
@@ -136,7 +136,7 @@ IXGB_PARAM(RxFCLowThresh, "Receive Flow Control Low=
 Threshold");
 /* Flow control request timeout (how long to pause the link partner's =
tx)
  * (PAP 15:0)
  *
- * Valid Range: 1 - 65535=20
+ * Valid Range: 1 - 65535
  *
  * Default Value:  65535 (0xffff) (we'll send an xon if we recover)
  */
@@ -200,7 +200,7 @@ struct ixgb_option {
 static int __devinit
 ixgb_validate_option(unsigned int *value, const struct ixgb_option *op=
t)
 {
-	if(*value =3D=3D OPTION_UNSET) {
+	if (*value =3D=3D OPTION_UNSET) {
 		*value =3D opt->def;
 		return 0;
 	}
@@ -217,7 +217,7 @@ ixgb_validate_option(unsigned int *value, const str=
uct ixgb_option *opt)
 		}
 		break;
 	case range_option:
-		if(*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
+		if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
 			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
 			return 0;
 		}
@@ -226,10 +226,10 @@ ixgb_validate_option(unsigned int *value, const s=
truct ixgb_option *opt)
 		int i;
 		struct ixgb_opt_list *ent;
=20
-		for(i =3D 0; i < opt->arg.l.nr; i++) {
+		for (i =3D 0; i < opt->arg.l.nr; i++) {
 			ent =3D &opt->arg.l.p[i];
-			if(*value =3D=3D ent->i) {
-				if(ent->str[0] !=3D '\0')
+			if (*value =3D=3D ent->i) {
+				if (ent->str[0] !=3D '\0')
 					printk(KERN_INFO "%s\n", ent->str);
 				return 0;
 			}
@@ -260,7 +260,7 @@ void __devinit
 ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd =3D adapter->bd_number;
-	if(bd >=3D IXGB_MAX_NIC) {
+	if (bd >=3D IXGB_MAX_NIC) {
 		printk(KERN_NOTICE
 			   "Warning: no configuration for board #%i\n", bd);
 		printk(KERN_NOTICE "Using defaults for all values\n");
@@ -277,7 +277,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 		struct ixgb_desc_ring *tx_ring =3D &adapter->tx_ring;
=20
-		if(num_TxDescriptors > bd) {
+		if (num_TxDescriptors > bd) {
 			tx_ring->count =3D TxDescriptors[bd];
 			ixgb_validate_option(&tx_ring->count, &opt);
 		} else {
@@ -296,7 +296,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		};
 		struct ixgb_desc_ring *rx_ring =3D &adapter->rx_ring;
=20
-		if(num_RxDescriptors > bd) {
+		if (num_RxDescriptors > bd) {
 			rx_ring->count =3D RxDescriptors[bd];
 			ixgb_validate_option(&rx_ring->count, &opt);
 		} else {
@@ -312,7 +312,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.def  =3D OPTION_ENABLED
 		};
=20
-		if(num_XsumRX > bd) {
+		if (num_XsumRX > bd) {
 			unsigned int rx_csum =3D XsumRX[bd];
 			ixgb_validate_option(&rx_csum, &opt);
 			adapter->rx_csum =3D rx_csum;
@@ -338,7 +338,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .p =3D fc_list }}
 		};
=20
-		if(num_FlowControl > bd) {
+		if (num_FlowControl > bd) {
 			unsigned int fc =3D FlowControl[bd];
 			ixgb_validate_option(&fc, &opt);
 			adapter->hw.fc.type =3D fc;
@@ -356,14 +356,14 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max =3D MAX_FCRTH}}
 		};
=20
-		if(num_RxFCHighThresh > bd) {
+		if (num_RxFCHighThresh > bd) {
 			adapter->hw.fc.high_water =3D RxFCHighThresh[bd];
 			ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
 		} else {
 			adapter->hw.fc.high_water =3D opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
@@ -376,14 +376,14 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max =3D MAX_FCRTL}}
 		};
=20
-		if(num_RxFCLowThresh > bd) {
+		if (num_RxFCLowThresh > bd) {
 			adapter->hw.fc.low_water =3D RxFCLowThresh[bd];
 			ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
 		} else {
 			adapter->hw.fc.low_water =3D opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
@@ -396,7 +396,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					.max =3D MAX_FCPAUSE}}
 		};
=20
-		if(num_FCReqTimeout > bd) {
+		if (num_FCReqTimeout > bd) {
 			unsigned int pause_time =3D FCReqTimeout[bd];
 			ixgb_validate_option(&pause_time, &opt);
 			adapter->hw.fc.pause_time =3D pause_time;
@@ -404,7 +404,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.pause_time =3D opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
@@ -412,7 +412,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk (KERN_INFO=20
+			printk(KERN_INFO
 				"RxFCHighThresh must be >=3D (RxFCLowThresh + 8), "
 				"Using Defaults\n");
 			adapter->hw.fc.high_water =3D DEFAULT_FCRTH;
@@ -429,7 +429,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max =3D MAX_RDTR}}
 		};
=20
-		if(num_RxIntDelay > bd) {
+		if (num_RxIntDelay > bd) {
 			adapter->rx_int_delay =3D RxIntDelay[bd];
 			ixgb_validate_option(&adapter->rx_int_delay, &opt);
 		} else {
@@ -446,7 +446,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 					 .max =3D MAX_TIDV}}
 		};
=20
-		if(num_TxIntDelay > bd) {
+		if (num_TxIntDelay > bd) {
 			adapter->tx_int_delay =3D TxIntDelay[bd];
 			ixgb_validate_option(&adapter->tx_int_delay, &opt);
 		} else {
@@ -462,7 +462,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.def  =3D OPTION_ENABLED
 		};
=20
-		if(num_IntDelayEnable > bd) {
+		if (num_IntDelayEnable > bd) {
 			unsigned int ide =3D IntDelayEnable[bd];
 			ixgb_validate_option(&ide, &opt);
 			adapter->tx_int_delay_enable =3D ide;
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitb=
ang.c
index 2747b1f..c01b780 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -177,6 +177,7 @@ struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ct=
rl *ctrl)
=20
 	return bus;
 }
+EXPORT_SYMBOL(alloc_mdio_bitbang);
=20
 void free_mdio_bitbang(struct mii_bus *bus)
 {
@@ -185,5 +186,6 @@ void free_mdio_bitbang(struct mii_bus *bus)
 	module_put(ctrl->ops->owner);
 	kfree(bus);
 }
+EXPORT_SYMBOL(free_mdio_bitbang);
=20
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 51a9115..517425d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
=20
-#define DRV_VERSION "2.0.26.24"
+#define DRV_VERSION "2.0.26.25"
=20
 /* S2io Driver name & version. */
 static char s2io_driver_name[] =3D "Neterion";
@@ -1891,8 +1891,6 @@ static int init_nic(struct s2io_nic *nic)
=20
 static int s2io_link_fault_indication(struct s2io_nic *nic)
 {
-	if (nic->config.intr_type !=3D INTA)
-		return MAC_RMAC_ERR_TIMER;
 	if (nic->device_type =3D=3D XFRAME_II_DEVICE)
 		return LINK_UP_DOWN_INTERRUPT;
 	else
@@ -1925,7 +1923,9 @@ static void en_dis_err_alarms(struct s2io_nic *ni=
c, u16 mask, int flag)
 {
 	struct XENA_dev_config __iomem *bar0 =3D nic->bar0;
 	register u64 gen_int_mask =3D 0;
+	u64 interruptible;
=20
+	writeq(DISABLE_ALL_INTRS, &bar0->general_int_mask);
 	if (mask & TX_DMA_INTR) {
=20
 		gen_int_mask |=3D TXDMA_INT_M;
@@ -2015,10 +2015,12 @@ static void en_dis_err_alarms(struct s2io_nic *=
nic, u16 mask, int flag)
 		gen_int_mask |=3D RXMAC_INT_M;
 		do_s2io_write_bits(MAC_INT_STATUS_RMAC_INT, flag,
 				&bar0->mac_int_mask);
-		do_s2io_write_bits(RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
+		interruptible =3D RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
 				RMAC_UNUSED_INT | RMAC_SINGLE_ECC_ERR |
-				RMAC_DOUBLE_ECC_ERR |
-				RMAC_LINK_STATE_CHANGE_INT,
+				RMAC_DOUBLE_ECC_ERR;
+		if (s2io_link_fault_indication(nic) =3D=3D MAC_RMAC_ERR_TIMER)
+			interruptible |=3D RMAC_LINK_STATE_CHANGE_INT;
+		do_s2io_write_bits(interruptible,
 				flag, &bar0->mac_rmac_err_mask);
 	}
=20
@@ -2501,6 +2503,9 @@ static void stop_nic(struct s2io_nic *nic)
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
  *  @ring_info: per ring structure
+ *  @from_card_up: If this is true, we will map the buffer to get
+ *     the dma address for buf0 and buf1 to give it to the card.
+ *     Else we will sync the already mapped buffer to give it to the c=
ard.
  *  Description:
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the=
 NIC
@@ -2518,7 +2523,7 @@ static void stop_nic(struct s2io_nic *nic)
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
=20
-static int fill_rx_buffers(struct ring_info *ring)
+static int fill_rx_buffers(struct ring_info *ring, int from_card_up)
 {
 	struct sk_buff *skb;
 	struct RxD_t *rxdp;
@@ -2637,17 +2642,16 @@ static int fill_rx_buffers(struct ring_info *ri=
ng)
 			skb->data =3D (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
=20
-			/* AK: check is wrong. 0 can be valid dma address */
-			if (!(rxdp3->Buffer0_ptr))
+			if (from_card_up) {
 				rxdp3->Buffer0_ptr =3D
 				   pci_map_single(ring->pdev, ba->ba_0,
 					BUF0_LEN, PCI_DMA_FROMDEVICE);
-			else
+				if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
+					goto pci_map_failed;
+			} else
 				pci_dma_sync_single_for_device(ring->pdev,
 				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
-				goto pci_map_failed;
=20
 			rxdp->Control_2 =3D SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (ring->rxd_mode =3D=3D RXD_MODE_3B) {
@@ -2664,21 +2668,22 @@ static int fill_rx_buffers(struct ring_info *ri=
ng)
 				if (pci_dma_mapping_error(rxdp3->Buffer2_ptr))
 					goto pci_map_failed;
=20
-				/* AK: check is wrong */
-				if (!rxdp3->Buffer1_ptr)
+				if (from_card_up) {
 					rxdp3->Buffer1_ptr =3D
 						pci_map_single(ring->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
=20
-				if (pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
-					pci_unmap_single
-						(ring->pdev,
-						(dma_addr_t)(unsigned long)
-						skb->data,
-						ring->mtu + 4,
-						PCI_DMA_FROMDEVICE);
-					goto pci_map_failed;
+					if (pci_dma_mapping_error
+						(rxdp3->Buffer1_ptr)) {
+						pci_unmap_single
+							(ring->pdev,
+						    (dma_addr_t)(unsigned long)
+							skb->data,
+							ring->mtu + 4,
+							PCI_DMA_FROMDEVICE);
+						goto pci_map_failed;
+					}
 				}
 				rxdp->Control_2 |=3D SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |=3D SET_BUFFER2_SIZE_3
@@ -2813,7 +2818,7 @@ static void free_rx_buffers(struct s2io_nic *sp)
=20
 static int s2io_chk_rx_buffers(struct ring_info *ring)
 {
-	if (fill_rx_buffers(ring) =3D=3D -ENOMEM) {
+	if (fill_rx_buffers(ring, 0) =3D=3D -ENOMEM) {
 		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
 		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
@@ -2944,7 +2949,7 @@ static void s2io_netpoll(struct net_device *dev)
 		rx_intr_handler(&mac_control->rings[i], 0);
=20
 	for (i =3D 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) =3D=3D -ENOMEM) {
+		if (fill_rx_buffers(&mac_control->rings[i], 0) =3D=3D -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
@@ -4373,18 +4378,24 @@ static irqreturn_t s2io_msix_fifo_handle(int ir=
q, void *dev_id)
 		/* Nothing much can be done. Get out */
 		return IRQ_HANDLED;
=20
-	writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+	if (reason & (GEN_INTR_TXPIC | GEN_INTR_TXTRAFFIC)) {
+		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
=20
-	if (reason & GEN_INTR_TXTRAFFIC)
-		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+		if (reason & GEN_INTR_TXPIC)
+			s2io_txpic_intr_handle(sp);
=20
-	for (i =3D 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&fifos[i]);
+		if (reason & GEN_INTR_TXTRAFFIC)
+			writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
=20
-	writeq(sp->general_int_mask, &bar0->general_int_mask);
-	readl(&bar0->general_int_status);
+		for (i =3D 0; i < config->tx_fifo_num; i++)
+			tx_intr_handler(&fifos[i]);
=20
-	return IRQ_HANDLED;
+		writeq(sp->general_int_mask, &bar0->general_int_mask);
+		readl(&bar0->general_int_status);
+		return IRQ_HANDLED;
+	}
+	/* The interrupt was not raised by us */
+	return IRQ_NONE;
 }
=20
 static void s2io_txpic_intr_handle(struct s2io_nic *sp)
@@ -7112,6 +7123,9 @@ static void do_s2io_card_down(struct s2io_nic * s=
p, int do_io)
=20
 	s2io_rem_isr(sp);
=20
+	/* stop the tx queue, indicate link down */
+	s2io_link(sp, LINK_DOWN);
+
 	/* Check if the device is Quiescent and then Reset the NIC */
 	while(do_io) {
 		/* As per the HW requirement we need to replenish the
@@ -7183,7 +7197,7 @@ static int s2io_card_up(struct s2io_nic * sp)
=20
 	for (i =3D 0; i < config->rx_ring_num; i++) {
 		mac_control->rings[i].mtu =3D dev->mtu;
-		ret =3D fill_rx_buffers(&mac_control->rings[i]);
+		ret =3D fill_rx_buffers(&mac_control->rings[i], 1);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
 				  dev->name);
@@ -7244,17 +7258,19 @@ static int s2io_card_up(struct s2io_nic * sp)
=20
 	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
=20
+	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
+
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
-	if (sp->config.intr_type !=3D INTA)
-		en_dis_able_nic_intrs(sp, TX_TRAFFIC_INTR, ENABLE_INTRS);
-	else {
+	if (sp->config.intr_type !=3D INTA) {
+		interruptible =3D TX_TRAFFIC_INTR | TX_PIC_INTR;
+		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
+	} else {
 		interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 		interruptible |=3D TX_PIC_INTR;
 		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
 	}
=20
-	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
 	return 0;
 }
=20
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 483b17c..6722a2f 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -1107,6 +1107,7 @@ static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
 static int rx_intr_handler(struct ring_info *ring_data, int budget);
+static void s2io_txpic_intr_handle(struct s2io_nic *sp);
 static void tx_intr_handler(struct fifo_info *fifo_data);
 static void s2io_handle_errors(void * dev_id);
=20
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
deleted file mode 100644
index c65199d..0000000
--- a/drivers/net/saa9730.c
+++ /dev/null
@@ -1,1139 +0,0 @@
-/*
- * Copyright (C) 2000, 2005  MIPS Technologies, Inc.  All rights reser=
ved.
- *	Authors: Carsten Langgaard <carstenl@mips.com>
- *		 Maciej W. Rozycki <macro@mips.com>
- * Copyright (C) 2004 Ralf Baechle <ralf@linux-mips.org>
- *
- *  This program is free software; you can distribute it and/or modify=
 it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WIT=
HOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY=
 or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Lice=
nse
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License =
along
- *  with this program; if not, write to the Free Software Foundation, =
Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- *
- * SAA9730 ethernet driver.
- *
- * Changes:
- * Angelo Dell'Aera <buffer@antifork.org> :	Conversion to the new PCI =
API
- *						(pci_driver).
- *						Conversion to spinlocks.
- *						Error handling fixes.
- */
-
-#include <linux/init.h>
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-#include <linux/etherdevice.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/pci.h>
-#include <linux/spinlock.h>
-#include <linux/types.h>
-
-#include <asm/addrspace.h>
-#include <asm/io.h>
-
-#include <asm/mips-boards/prom.h>
-
-#include "saa9730.h"
-
-#ifdef LAN_SAA9730_DEBUG
-int lan_saa9730_debug =3D LAN_SAA9730_DEBUG;
-#else
-int lan_saa9730_debug;
-#endif
-
-#define DRV_MODULE_NAME "saa9730"
-
-static struct pci_device_id saa9730_pci_tbl[] =3D {
-	{ PCI_VENDOR_ID_PHILIPS, PCI_DEVICE_ID_PHILIPS_SAA9730,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
-	{ 0, }
-};
-
-MODULE_DEVICE_TABLE(pci, saa9730_pci_tbl);
-
-/* Non-zero only if the current card is a PCI with BIOS-set IRQ. */
-static unsigned int pci_irq_line;
-
-static void evm_saa9730_enable_lan_int(struct lan_saa9730_private *lp)
-{
-	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptBlock1);
-	writel(readl(&lp->evm_saa9730_regs->InterruptStatus1) | EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptStatus1);
-	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) | EVM_LAN_INT |
-	       EVM_MASTER_EN, &lp->evm_saa9730_regs->InterruptEnable1);
-}
-
-static void evm_saa9730_disable_lan_int(struct lan_saa9730_private *lp=
)
-{
-	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptBlock1);
-	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) & ~EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptEnable1);
-}
-
-static void evm_saa9730_clear_lan_int(struct lan_saa9730_private *lp)
-{
-	writel(EVM_LAN_INT, &lp->evm_saa9730_regs->InterruptStatus1);
-}
-
-static void evm_saa9730_block_lan_int(struct lan_saa9730_private *lp)
-{
-	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptBlock1);
-}
-
-static void evm_saa9730_unblock_lan_int(struct lan_saa9730_private *lp=
)
-{
-	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	       &lp->evm_saa9730_regs->InterruptBlock1);
-}
-
-static void __used show_saa9730_regs(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	int i, j;
-
-	printk("TxmBufferA =3D %p\n", lp->TxmBuffer[0][0]);
-	printk("TxmBufferB =3D %p\n", lp->TxmBuffer[1][0]);
-	printk("RcvBufferA =3D %p\n", lp->RcvBuffer[0][0]);
-	printk("RcvBufferB =3D %p\n", lp->RcvBuffer[1][0]);
-
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_TXM_Q_SIZE; j++) {
-			printk("TxmBuffer[%d][%d] =3D %x\n", i, j,
-			       le32_to_cpu(*(unsigned int *)
-					   lp->TxmBuffer[i][j]));
-		}
-	}
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_RCV_Q_SIZE; j++) {
-			printk("RcvBuffer[%d][%d] =3D %x\n", i, j,
-			       le32_to_cpu(*(unsigned int *)
-					   lp->RcvBuffer[i][j]));
-		}
-	}
-	printk("lp->evm_saa9730_regs->InterruptBlock1 =3D %x\n",
-	       readl(&lp->evm_saa9730_regs->InterruptBlock1));
-	printk("lp->evm_saa9730_regs->InterruptStatus1 =3D %x\n",
-	       readl(&lp->evm_saa9730_regs->InterruptStatus1));
-	printk("lp->evm_saa9730_regs->InterruptEnable1 =3D %x\n",
-	       readl(&lp->evm_saa9730_regs->InterruptEnable1));
-	printk("lp->lan_saa9730_regs->Ok2Use =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->Ok2Use));
-	printk("lp->NextTxmBufferIndex =3D %x\n", lp->NextTxmBufferIndex);
-	printk("lp->NextTxmPacketIndex =3D %x\n", lp->NextTxmPacketIndex);
-	printk("lp->PendingTxmBufferIndex =3D %x\n",
-	       lp->PendingTxmBufferIndex);
-	printk("lp->PendingTxmPacketIndex =3D %x\n",
-	       lp->PendingTxmPacketIndex);
-	printk("lp->lan_saa9730_regs->LanDmaCtl =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->LanDmaCtl));
-	printk("lp->lan_saa9730_regs->DmaStatus =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DmaStatus));
-	printk("lp->lan_saa9730_regs->CamCtl =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->CamCtl));
-	printk("lp->lan_saa9730_regs->TxCtl =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->TxCtl));
-	printk("lp->lan_saa9730_regs->TxStatus =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->TxStatus));
-	printk("lp->lan_saa9730_regs->RxCtl =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->RxCtl));
-	printk("lp->lan_saa9730_regs->RxStatus =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->RxStatus));
-
-	for (i =3D 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
-		writel(i, &lp->lan_saa9730_regs->CamAddress);
-		printk("lp->lan_saa9730_regs->CamData =3D %x\n",
-		       readl(&lp->lan_saa9730_regs->CamData));
-	}
-
-	printk("dev->stats.tx_packets =3D %lx\n", dev->stats.tx_packets);
-	printk("dev->stats.tx_errors =3D %lx\n", dev->stats.tx_errors);
-	printk("dev->stats.tx_aborted_errors =3D %lx\n",
-	       dev->stats.tx_aborted_errors);
-	printk("dev->stats.tx_window_errors =3D %lx\n",
-	       dev->stats.tx_window_errors);
-	printk("dev->stats.tx_carrier_errors =3D %lx\n",
-	       dev->stats.tx_carrier_errors);
-	printk("dev->stats.tx_fifo_errors =3D %lx\n",
-	       dev->stats.tx_fifo_errors);
-	printk("dev->stats.tx_heartbeat_errors =3D %lx\n",
-	       dev->stats.tx_heartbeat_errors);
-	printk("dev->stats.collisions =3D %lx\n", dev->stats.collisions);
-
-	printk("dev->stats.rx_packets =3D %lx\n", dev->stats.rx_packets);
-	printk("dev->stats.rx_errors =3D %lx\n", dev->stats.rx_errors);
-	printk("dev->stats.rx_dropped =3D %lx\n", dev->stats.rx_dropped);
-	printk("dev->stats.rx_crc_errors =3D %lx\n", dev->stats.rx_crc_errors=
);
-	printk("dev->stats.rx_frame_errors =3D %lx\n",
-	       dev->stats.rx_frame_errors);
-	printk("dev->stats.rx_fifo_errors =3D %lx\n",
-	       dev->stats.rx_fifo_errors);
-	printk("dev->stats.rx_length_errors =3D %lx\n",
-	       dev->stats.rx_length_errors);
-
-	printk("lp->lan_saa9730_regs->DebugPCIMasterAddr =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugPCIMasterAddr));
-	printk("lp->lan_saa9730_regs->DebugLanTxStateMachine =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugLanTxStateMachine));
-	printk("lp->lan_saa9730_regs->DebugLanRxStateMachine =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugLanRxStateMachine));
-	printk("lp->lan_saa9730_regs->DebugLanTxFifoPointers =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugLanTxFifoPointers));
-	printk("lp->lan_saa9730_regs->DebugLanRxFifoPointers =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugLanRxFifoPointers));
-	printk("lp->lan_saa9730_regs->DebugLanCtlStateMachine =3D %x\n",
-	       readl(&lp->lan_saa9730_regs->DebugLanCtlStateMachine));
-}
-
-static void lan_saa9730_buffer_init(struct lan_saa9730_private *lp)
-{
-	int i, j;
-
-	/* Init RX buffers */
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_RCV_Q_SIZE; j++) {
-			*(unsigned int *) lp->RcvBuffer[i][j] =3D
-			    cpu_to_le32(RXSF_READY <<
-					RX_STAT_CTL_OWNER_SHF);
-		}
-	}
-
-	/* Init TX buffers */
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_TXM_Q_SIZE; j++) {
-			*(unsigned int *) lp->TxmBuffer[i][j] =3D
-			    cpu_to_le32(TXSF_EMPTY <<
-					TX_STAT_CTL_OWNER_SHF);
-		}
-	}
-}
-
-static void lan_saa9730_free_buffers(struct pci_dev *pdev,
-				     struct lan_saa9730_private *lp)
-{
-	pci_free_consistent(pdev, lp->buffer_size, lp->buffer_start,
-			    lp->dma_addr);
-}
-
-static int lan_saa9730_allocate_buffers(struct pci_dev *pdev,
-					struct lan_saa9730_private *lp)
-{
-	void *Pa;
-	unsigned int i, j, rxoffset, txoffset;
-	int ret;
-
-	/* Initialize buffer space */
-	lp->DmaRcvPackets =3D LAN_SAA9730_RCV_Q_SIZE;
-	lp->DmaTxmPackets =3D LAN_SAA9730_TXM_Q_SIZE;
-
-	/* Initialize Rx Buffer Index */
-	lp->NextRcvPacketIndex =3D 0;
-	lp->NextRcvBufferIndex =3D 0;
-
-	/* Set current buffer index & next available packet index */
-	lp->NextTxmPacketIndex =3D 0;
-	lp->NextTxmBufferIndex =3D 0;
-	lp->PendingTxmPacketIndex =3D 0;
-	lp->PendingTxmBufferIndex =3D 0;
-
-	/*
-	 * Allocate all RX and TX packets in one chunk.
-	 * The Rx and Tx packets must be PACKET_SIZE aligned.
-	 */
-	lp->buffer_size =3D ((LAN_SAA9730_RCV_Q_SIZE + LAN_SAA9730_TXM_Q_SIZE=
) *
-			   LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_BUFFERS) +
-			  LAN_SAA9730_PACKET_SIZE;
-	lp->buffer_start =3D pci_alloc_consistent(pdev, lp->buffer_size,
-						&lp->dma_addr);
-	if (!lp->buffer_start) {
-		ret =3D -ENOMEM;
-		goto out;
-	}
-
-	Pa =3D (void *)ALIGN((unsigned long)lp->buffer_start,
-			   LAN_SAA9730_PACKET_SIZE);
-
-	rxoffset =3D Pa - lp->buffer_start;
-
-	/* Init RX buffers */
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_RCV_Q_SIZE; j++) {
-			*(unsigned int *) Pa =3D
-			    cpu_to_le32(RXSF_READY <<
-					RX_STAT_CTL_OWNER_SHF);
-			lp->RcvBuffer[i][j] =3D Pa;
-			Pa +=3D LAN_SAA9730_PACKET_SIZE;
-		}
-	}
-
-	txoffset =3D Pa - lp->buffer_start;
-
-	/* Init TX buffers */
-	for (i =3D 0; i < LAN_SAA9730_BUFFERS; i++) {
-		for (j =3D 0; j < LAN_SAA9730_TXM_Q_SIZE; j++) {
-			*(unsigned int *) Pa =3D
-			    cpu_to_le32(TXSF_EMPTY <<
-					TX_STAT_CTL_OWNER_SHF);
-			lp->TxmBuffer[i][j] =3D Pa;
-			Pa +=3D LAN_SAA9730_PACKET_SIZE;
-		}
-	}
-
-	/*
-	 * Set rx buffer A and rx buffer B to point to the first two buffer
-	 * spaces.
-	 */
-	writel(lp->dma_addr + rxoffset, &lp->lan_saa9730_regs->RxBuffA);
-	writel(lp->dma_addr + rxoffset +
-	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_RCV_Q_SIZE,
-	       &lp->lan_saa9730_regs->RxBuffB);
-
-	/*
-	 * Set txm_buf_a and txm_buf_b to point to the first two buffer
-	 * space
-	 */
-	writel(lp->dma_addr + txoffset,
-	       &lp->lan_saa9730_regs->TxBuffA);
-	writel(lp->dma_addr + txoffset +
-	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_TXM_Q_SIZE,
-	       &lp->lan_saa9730_regs->TxBuffB);
-
-	/* Set packet number */
-	writel((lp->DmaRcvPackets << PK_COUNT_RX_A_SHF) |
-	       (lp->DmaRcvPackets << PK_COUNT_RX_B_SHF) |
-	       (lp->DmaTxmPackets << PK_COUNT_TX_A_SHF) |
-	       (lp->DmaTxmPackets << PK_COUNT_TX_B_SHF),
-	       &lp->lan_saa9730_regs->PacketCount);
-
-	return 0;
-
-out:
-	return ret;
-}
-
-static int lan_saa9730_cam_load(struct lan_saa9730_private *lp)
-{
-	unsigned int i;
-	unsigned char *NetworkAddress;
-
-	NetworkAddress =3D (unsigned char *) &lp->PhysicalAddress[0][0];
-
-	for (i =3D 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
-		/* First set address to where data is written */
-		writel(i, &lp->lan_saa9730_regs->CamAddress);
-		writel((NetworkAddress[0] << 24) | (NetworkAddress[1] << 16) |
-		       (NetworkAddress[2] << 8) | NetworkAddress[3],
-		       &lp->lan_saa9730_regs->CamData);
-		NetworkAddress +=3D 4;
-	}
-	return 0;
-}
-
-static int lan_saa9730_cam_init(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	unsigned int i;
-
-	/* Copy MAC-address into all entries. */
-	for (i =3D 0; i < LAN_SAA9730_CAM_ENTRIES; i++) {
-		memcpy((unsigned char *) lp->PhysicalAddress[i],
-		       (unsigned char *) dev->dev_addr, 6);
-	}
-
-	return 0;
-}
-
-static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
-{
-	int i, l;
-
-	/* Check link status, spin here till station is not busy. */
-	i =3D 0;
-	while (readl(&lp->lan_saa9730_regs->StationMgmtCtl) & MD_CA_BUSY) {
-		i++;
-		if (i > 100) {
-			printk("Error: lan_saa9730_mii_init: timeout\n");
-			return -1;
-		}
-		mdelay(1);	/* wait 1 ms. */
-	}
-
-	/* Now set the control and address register. */
-	writel(MD_CA_BUSY | PHY_STATUS | PHY_ADDRESS << MD_CA_PHY_SHF,
-	       &lp->lan_saa9730_regs->StationMgmtCtl);
-
-	/* check link status, spin here till station is not busy */
-	i =3D 0;
-	while (readl(&lp->lan_saa9730_regs->StationMgmtCtl) & MD_CA_BUSY) {
-		i++;
-		if (i > 100) {
-			printk("Error: lan_saa9730_mii_init: timeout\n");
-			return -1;
-		}
-		mdelay(1);	/* wait 1 ms. */
-	}
-
-	/* Wait for 1 ms. */
-	mdelay(1);
-
-	/* Check the link status. */
-	if (readl(&lp->lan_saa9730_regs->StationMgmtData) &
-	    PHY_STATUS_LINK_UP) {
-		/* Link is up. */
-		return 0;
-	} else {
-		/* Link is down, reset the PHY first. */
-
-		/* set PHY address =3D 'CONTROL' */
-		writel(PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR | PHY_CONTROL,
-		       &lp->lan_saa9730_regs->StationMgmtCtl);
-
-		/* Wait for 1 ms. */
-		mdelay(1);
-
-		/* set 'CONTROL' =3D force reset and renegotiate */
-		writel(PHY_CONTROL_RESET | PHY_CONTROL_AUTO_NEG |
-		       PHY_CONTROL_RESTART_AUTO_NEG,
-		       &lp->lan_saa9730_regs->StationMgmtData);
-
-		/* Wait for 50 ms. */
-		mdelay(50);
-
-		/* set 'BUSY' to start operation */
-		writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR |
-		       PHY_CONTROL, &lp->lan_saa9730_regs->StationMgmtCtl);
-
-		/* await completion */
-		i =3D 0;
-		while (readl(&lp->lan_saa9730_regs->StationMgmtCtl) &
-		       MD_CA_BUSY) {
-			i++;
-			if (i > 100) {
-				printk
-				    ("Error: lan_saa9730_mii_init: timeout\n");
-				return -1;
-			}
-			mdelay(1);	/* wait 1 ms. */
-		}
-
-		/* Wait for 1 ms. */
-		mdelay(1);
-
-		for (l =3D 0; l < 2; l++) {
-			/* set PHY address =3D 'STATUS' */
-			writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF |
-			       PHY_STATUS,
-			       &lp->lan_saa9730_regs->StationMgmtCtl);
-
-			/* await completion */
-			i =3D 0;
-			while (readl(&lp->lan_saa9730_regs->StationMgmtCtl) &
-			       MD_CA_BUSY) {
-				i++;
-				if (i > 100) {
-					printk
-					    ("Error: lan_saa9730_mii_init: timeout\n");
-					return -1;
-				}
-				mdelay(1);	/* wait 1 ms. */
-			}
-
-			/* wait for 3 sec. */
-			mdelay(3000);
-
-			/* check the link status */
-			if (readl(&lp->lan_saa9730_regs->StationMgmtData) &
-			    PHY_STATUS_LINK_UP) {
-				/* link is up */
-				break;
-			}
-		}
-	}
-
-	return 0;
-}
-
-static int lan_saa9730_control_init(struct lan_saa9730_private *lp)
-{
-	/* Initialize DMA control register. */
-	writel((LANMB_ANY << DMA_CTL_MAX_XFER_SHF) |
-	       (LANEND_LITTLE << DMA_CTL_ENDIAN_SHF) |
-	       (LAN_SAA9730_RCV_Q_INT_THRESHOLD << DMA_CTL_RX_INT_COUNT_SHF)
-	       | DMA_CTL_RX_INT_TO_EN | DMA_CTL_RX_INT_EN |
-	       DMA_CTL_MAC_RX_INT_EN | DMA_CTL_MAC_TX_INT_EN,
-	       &lp->lan_saa9730_regs->LanDmaCtl);
-
-	/* Initial MAC control register. */
-	writel((MACCM_MII << MAC_CONTROL_CONN_SHF) | MAC_CONTROL_FULL_DUP,
-	       &lp->lan_saa9730_regs->MacCtl);
-
-	/* Initialize CAM control register. */
-	writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_BROAD_ACC,
-	       &lp->lan_saa9730_regs->CamCtl);
-
-	/*
-	 * Initialize CAM enable register, only turn on first entry, should
-	 * contain own addr.
-	 */
-	writel(0x0001, &lp->lan_saa9730_regs->CamEnable);
-
-	/* Initialize Tx control register */
-	writel(TX_CTL_EN_COMP, &lp->lan_saa9730_regs->TxCtl);
-
-	/* Initialize Rcv control register */
-	writel(RX_CTL_STRIP_CRC, &lp->lan_saa9730_regs->RxCtl);
-
-	/* Reset DMA engine */
-	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
-
-	return 0;
-}
-
-static int lan_saa9730_stop(struct lan_saa9730_private *lp)
-{
-	int i;
-
-	/* Stop DMA first */
-	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) &
-	       ~(DMA_CTL_EN_TX_DMA | DMA_CTL_EN_RX_DMA),
-	       &lp->lan_saa9730_regs->LanDmaCtl);
-
-	/* Set the SW Reset bits in DMA and MAC control registers */
-	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
-	writel(readl(&lp->lan_saa9730_regs->MacCtl) | MAC_CONTROL_RESET,
-	       &lp->lan_saa9730_regs->MacCtl);
-
-	/*
-	 * Wait for MAC reset to have finished. The reset bit is auto cleared
-	 * when the reset is done.
-	 */
-	i =3D 0;
-	while (readl(&lp->lan_saa9730_regs->MacCtl) & MAC_CONTROL_RESET) {
-		i++;
-		if (i > 100) {
-			printk
-			    ("Error: lan_sa9730_stop: MAC reset timeout\n");
-			return -1;
-		}
-		mdelay(1);	/* wait 1 ms. */
-	}
-
-	return 0;
-}
-
-static int lan_saa9730_dma_init(struct lan_saa9730_private *lp)
-{
-	/* Stop lan controller. */
-	lan_saa9730_stop(lp);
-
-	writel(LAN_SAA9730_DEFAULT_TIME_OUT_CNT,
-	       &lp->lan_saa9730_regs->Timeout);
-
-	return 0;
-}
-
-static int lan_saa9730_start(struct lan_saa9730_private *lp)
-{
-	lan_saa9730_buffer_init(lp);
-
-	/* Initialize Rx Buffer Index */
-	lp->NextRcvPacketIndex =3D 0;
-	lp->NextRcvBufferIndex =3D 0;
-
-	/* Set current buffer index & next available packet index */
-	lp->NextTxmPacketIndex =3D 0;
-	lp->NextTxmBufferIndex =3D 0;
-	lp->PendingTxmPacketIndex =3D 0;
-	lp->PendingTxmBufferIndex =3D 0;
-
-	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) | DMA_CTL_EN_TX_DMA |
-	       DMA_CTL_EN_RX_DMA, &lp->lan_saa9730_regs->LanDmaCtl);
-
-	/* For Tx, turn on MAC then DMA */
-	writel(readl(&lp->lan_saa9730_regs->TxCtl) | TX_CTL_TX_EN,
-	       &lp->lan_saa9730_regs->TxCtl);
-
-	/* For Rx, turn on DMA then MAC */
-	writel(readl(&lp->lan_saa9730_regs->RxCtl) | RX_CTL_RX_EN,
-	       &lp->lan_saa9730_regs->RxCtl);
-
-	/* Set Ok2Use to let hardware own the buffers.	*/
-	writel(OK2USE_RX_A | OK2USE_RX_B, &lp->lan_saa9730_regs->Ok2Use);
-
-	return 0;
-}
-
-static int lan_saa9730_restart(struct lan_saa9730_private *lp)
-{
-	lan_saa9730_stop(lp);
-	lan_saa9730_start(lp);
-
-	return 0;
-}
-
-static int lan_saa9730_tx(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	unsigned int *pPacket;
-	unsigned int tx_status;
-
-	if (lan_saa9730_debug > 5)
-		printk("lan_saa9730_tx interrupt\n");
-
-	/* Clear interrupt. */
-	writel(DMA_STATUS_MAC_TX_INT, &lp->lan_saa9730_regs->DmaStatus);
-
-	while (1) {
-		pPacket =3D lp->TxmBuffer[lp->PendingTxmBufferIndex]
-				       [lp->PendingTxmPacketIndex];
-
-		/* Get status of first packet transmitted. */
-		tx_status =3D le32_to_cpu(*pPacket);
-
-		/* Check ownership. */
-		if ((tx_status & TX_STAT_CTL_OWNER_MSK) !=3D
-		    (TXSF_HWDONE << TX_STAT_CTL_OWNER_SHF)) break;
-
-		/* Check for error. */
-		if (tx_status & TX_STAT_CTL_ERROR_MSK) {
-			if (lan_saa9730_debug > 1)
-				printk("lan_saa9730_tx: tx error =3D %x\n",
-				       tx_status);
-
-			dev->stats.tx_errors++;
-			if (tx_status &
-			    (TX_STATUS_EX_COLL << TX_STAT_CTL_STATUS_SHF))
-				dev->stats.tx_aborted_errors++;
-			if (tx_status &
-			    (TX_STATUS_LATE_COLL << TX_STAT_CTL_STATUS_SHF))
-				dev->stats.tx_window_errors++;
-			if (tx_status &
-			    (TX_STATUS_L_CARR << TX_STAT_CTL_STATUS_SHF))
-				dev->stats.tx_carrier_errors++;
-			if (tx_status &
-			    (TX_STATUS_UNDER << TX_STAT_CTL_STATUS_SHF))
-				dev->stats.tx_fifo_errors++;
-			if (tx_status &
-			    (TX_STATUS_SQ_ERR << TX_STAT_CTL_STATUS_SHF))
-				dev->stats.tx_heartbeat_errors++;
-
-			dev->stats.collisions +=3D
-				tx_status & TX_STATUS_TX_COLL_MSK;
-		}
-
-		/* Free buffer. */
-		*pPacket =3D
-		    cpu_to_le32(TXSF_EMPTY << TX_STAT_CTL_OWNER_SHF);
-
-		/* Update pending index pointer. */
-		lp->PendingTxmPacketIndex++;
-		if (lp->PendingTxmPacketIndex >=3D LAN_SAA9730_TXM_Q_SIZE) {
-			lp->PendingTxmPacketIndex =3D 0;
-			lp->PendingTxmBufferIndex ^=3D 1;
-		}
-	}
-
-	/* The tx buffer is no longer full. */
-	netif_wake_queue(dev);
-
-	return 0;
-}
-
-static int lan_saa9730_rx(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	int len =3D 0;
-	struct sk_buff *skb =3D 0;
-	unsigned int rx_status;
-	int BufferIndex;
-	int PacketIndex;
-	unsigned int *pPacket;
-	unsigned char *pData;
-
-	if (lan_saa9730_debug > 5)
-		printk("lan_saa9730_rx interrupt\n");
-
-	/* Clear receive interrupts. */
-	writel(DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
-	       DMA_STATUS_RX_TO_INT, &lp->lan_saa9730_regs->DmaStatus);
-
-	/* Address next packet */
-	BufferIndex =3D lp->NextRcvBufferIndex;
-	PacketIndex =3D lp->NextRcvPacketIndex;
-	pPacket =3D lp->RcvBuffer[BufferIndex][PacketIndex];
-	rx_status =3D le32_to_cpu(*pPacket);
-
-	/* Process each packet. */
-	while ((rx_status & RX_STAT_CTL_OWNER_MSK) =3D=3D
-	       (RXSF_HWDONE << RX_STAT_CTL_OWNER_SHF)) {
-		/* Check the rx status. */
-		if (rx_status & (RX_STATUS_GOOD << RX_STAT_CTL_STATUS_SHF)) {
-			/* Received packet is good. */
-			len =3D (rx_status & RX_STAT_CTL_LENGTH_MSK) >>
-			    RX_STAT_CTL_LENGTH_SHF;
-
-			pData =3D (unsigned char *) pPacket;
-			pData +=3D 4;
-			skb =3D dev_alloc_skb(len + 2);
-			if (skb =3D=3D 0) {
-				printk
-				    ("%s: Memory squeeze, deferring packet.\n",
-				     dev->name);
-				dev->stats.rx_dropped++;
-			} else {
-				dev->stats.rx_bytes +=3D len;
-				dev->stats.rx_packets++;
-				skb_reserve(skb, 2);	/* 16 byte align */
-				skb_put(skb, len);	/* make room */
-				skb_copy_to_linear_data(skb,
-						 (unsigned char *) pData,
-						 len);
-				skb->protocol =3D eth_type_trans(skb, dev);
-				netif_rx(skb);
-				dev->last_rx =3D jiffies;
-			}
-		} else {
-			/* We got an error packet. */
-			if (lan_saa9730_debug > 2)
-				printk
-				    ("lan_saa9730_rx: We got an error packet =3D %x\n",
-				     rx_status);
-
-			dev->stats.rx_errors++;
-			if (rx_status &
-			    (RX_STATUS_CRC_ERR << RX_STAT_CTL_STATUS_SHF))
-				dev->stats.rx_crc_errors++;
-			if (rx_status &
-			    (RX_STATUS_ALIGN_ERR << RX_STAT_CTL_STATUS_SHF))
-				dev->stats.rx_frame_errors++;
-			if (rx_status &
-			    (RX_STATUS_OVERFLOW << RX_STAT_CTL_STATUS_SHF))
-				dev->stats.rx_fifo_errors++;
-			if (rx_status &
-			    (RX_STATUS_LONG_ERR << RX_STAT_CTL_STATUS_SHF))
-				dev->stats.rx_length_errors++;
-		}
-
-		/* Indicate we have processed the buffer. */
-		*pPacket =3D cpu_to_le32(RXSF_READY << RX_STAT_CTL_OWNER_SHF);
-
-		/* Make sure A or B is available to hardware as appropriate. */
-		writel(BufferIndex ? OK2USE_RX_B : OK2USE_RX_A,
-		       &lp->lan_saa9730_regs->Ok2Use);
-
-		/* Go to next packet in sequence. */
-		lp->NextRcvPacketIndex++;
-		if (lp->NextRcvPacketIndex >=3D LAN_SAA9730_RCV_Q_SIZE) {
-			lp->NextRcvPacketIndex =3D 0;
-			lp->NextRcvBufferIndex ^=3D 1;
-		}
-
-		/* Address next packet */
-		BufferIndex =3D lp->NextRcvBufferIndex;
-		PacketIndex =3D lp->NextRcvPacketIndex;
-		pPacket =3D lp->RcvBuffer[BufferIndex][PacketIndex];
-		rx_status =3D le32_to_cpu(*pPacket);
-	}
-
-	return 0;
-}
-
-static irqreturn_t lan_saa9730_interrupt(const int irq, void *dev_id)
-{
-	struct net_device *dev =3D dev_id;
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	if (lan_saa9730_debug > 5)
-		printk("lan_saa9730_interrupt\n");
-
-	/* Disable the EVM LAN interrupt. */
-	evm_saa9730_block_lan_int(lp);
-
-	/* Clear the EVM LAN interrupt. */
-	evm_saa9730_clear_lan_int(lp);
-
-	/* Service pending transmit interrupts. */
-	if (readl(&lp->lan_saa9730_regs->DmaStatus) & DMA_STATUS_MAC_TX_INT)
-		lan_saa9730_tx(dev);
-
-	/* Service pending receive interrupts. */
-	if (readl(&lp->lan_saa9730_regs->DmaStatus) &
-	    (DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
-	     DMA_STATUS_RX_TO_INT)) lan_saa9730_rx(dev);
-
-	/* Enable the EVM LAN interrupt. */
-	evm_saa9730_unblock_lan_int(lp);
-
-	return IRQ_HANDLED;
-}
-
-static int lan_saa9730_open(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	/* Associate IRQ with lan_saa9730_interrupt */
-	if (request_irq(dev->irq, &lan_saa9730_interrupt, 0, "SAA9730 Eth",
-			dev)) {
-		printk("lan_saa9730_open: Can't get irq %d\n", dev->irq);
-		return -EAGAIN;
-	}
-
-	/* Enable the Lan interrupt in the event manager. */
-	evm_saa9730_enable_lan_int(lp);
-
-	/* Start the LAN controller */
-	if (lan_saa9730_start(lp))
-		return -1;
-
-	netif_start_queue(dev);
-
-	return 0;
-}
-
-static int lan_saa9730_write(struct lan_saa9730_private *lp,
-			     struct sk_buff *skb, int skblen)
-{
-	unsigned char *pbData =3D skb->data;
-	unsigned int len =3D skblen;
-	unsigned char *pbPacketData;
-	unsigned int tx_status;
-	int BufferIndex;
-	int PacketIndex;
-
-	if (lan_saa9730_debug > 5)
-		printk("lan_saa9730_write: skb=3D%p\n", skb);
-
-	BufferIndex =3D lp->NextTxmBufferIndex;
-	PacketIndex =3D lp->NextTxmPacketIndex;
-
-	tx_status =3D le32_to_cpu(*(unsigned int *)lp->TxmBuffer[BufferIndex]
-							      [PacketIndex]);
-	if ((tx_status & TX_STAT_CTL_OWNER_MSK) !=3D
-	    (TXSF_EMPTY << TX_STAT_CTL_OWNER_SHF)) {
-		if (lan_saa9730_debug > 4)
-			printk
-			    ("lan_saa9730_write: Tx buffer not available: tx_status =3D %x\=
n",
-			     tx_status);
-		return -1;
-	}
-
-	lp->NextTxmPacketIndex++;
-	if (lp->NextTxmPacketIndex >=3D LAN_SAA9730_TXM_Q_SIZE) {
-		lp->NextTxmPacketIndex =3D 0;
-		lp->NextTxmBufferIndex ^=3D 1;
-	}
-
-	pbPacketData =3D lp->TxmBuffer[BufferIndex][PacketIndex];
-	pbPacketData +=3D 4;
-
-	/* copy the bits */
-	memcpy(pbPacketData, pbData, len);
-
-	/* Set transmit status for hardware */
-	*(unsigned int *)lp->TxmBuffer[BufferIndex][PacketIndex] =3D
-		cpu_to_le32((TXSF_READY << TX_STAT_CTL_OWNER_SHF) |
-			    (TX_STAT_CTL_INT_AFTER_TX <<
-			     TX_STAT_CTL_FRAME_SHF) |
-			    (len << TX_STAT_CTL_LENGTH_SHF));
-
-	/* Make sure A or B is available to hardware as appropriate. */
-	writel(BufferIndex ? OK2USE_TX_B : OK2USE_TX_A,
-	       &lp->lan_saa9730_regs->Ok2Use);
-
-	return 0;
-}
-
-static void lan_saa9730_tx_timeout(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	/* Transmitter timeout, serious problems */
-	dev->stats.tx_errors++;
-	printk("%s: transmit timed out, reset\n", dev->name);
-	/*show_saa9730_regs(dev); */
-	lan_saa9730_restart(lp);
-
-	dev->trans_start =3D jiffies;
-	netif_wake_queue(dev);
-}
-
-static int lan_saa9730_start_xmit(struct sk_buff *skb,
-				  struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	unsigned long flags;
-	int skblen;
-	int len;
-
-	if (lan_saa9730_debug > 4)
-		printk("Send packet: skb=3D%p\n", skb);
-
-	skblen =3D skb->len;
-
-	spin_lock_irqsave(&lp->lock, flags);
-
-	len =3D (skblen <=3D ETH_ZLEN) ? ETH_ZLEN : skblen;
-
-	if (lan_saa9730_write(lp, skb, skblen)) {
-		spin_unlock_irqrestore(&lp->lock, flags);
-		printk("Error when writing packet to controller: skb=3D%p\n", skb);
-		netif_stop_queue(dev);
-		return -1;
-	}
-
-	dev->stats.tx_bytes +=3D len;
-	dev->stats.tx_packets++;
-
-	dev->trans_start =3D jiffies;
-	netif_wake_queue(dev);
-	dev_kfree_skb(skb);
-
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	return 0;
-}
-
-static int lan_saa9730_close(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	if (lan_saa9730_debug > 1)
-		printk("lan_saa9730_close:\n");
-
-	netif_stop_queue(dev);
-
-	/* Disable the Lan interrupt in the event manager. */
-	evm_saa9730_disable_lan_int(lp);
-
-	/* Stop the controller */
-	if (lan_saa9730_stop(lp))
-		return -1;
-
-	free_irq(dev->irq, (void *) dev);
-
-	return 0;
-}
-
-static void lan_saa9730_set_multicast(struct net_device *dev)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	/* Stop the controller */
-	lan_saa9730_stop(lp);
-
-	if (dev->flags & IFF_PROMISC) {
-		/* accept all packets */
-		writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_STATION_ACC |
-		       CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
-		       &lp->lan_saa9730_regs->CamCtl);
-	} else {
-		if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
-			/* accept all multicast packets */
-			/*
-			 * Will handle the multicast stuff later. -carstenl
-			 */
-			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
-			       CAM_CONTROL_BROAD_ACC,
-			       &lp->lan_saa9730_regs->CamCtl);
-		}
-	}
-
-	lan_saa9730_restart(lp);
-}
-
-
-static void __devexit saa9730_remove_one(struct pci_dev *pdev)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-
-	if (dev) {
-		unregister_netdev(dev);
-		lan_saa9730_free_buffers(pdev, lp);
-		iounmap(lp->lan_saa9730_regs);
-		iounmap(lp->evm_saa9730_regs);
-		free_netdev(dev);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
-	}
-}
-
-
-static int lan_saa9730_init(struct net_device *dev, struct pci_dev *pd=
ev,
-	unsigned long ioaddr, int irq)
-{
-	struct lan_saa9730_private *lp =3D netdev_priv(dev);
-	unsigned char ethernet_addr[6];
-	int ret;
-
-	if (get_ethernet_addr(ethernet_addr)) {
-		ret =3D -ENODEV;
-		goto out;
-	}
-
-	memcpy(dev->dev_addr, ethernet_addr, 6);
-	dev->base_addr =3D ioaddr;
-	dev->irq =3D irq;
-
-	lp->pci_dev =3D pdev;
-
-	/* Set SAA9730 LAN base address. */
-	lp->lan_saa9730_regs =3D ioremap(ioaddr + SAA9730_LAN_REGS_ADDR,
-				       SAA9730_LAN_REGS_SIZE);
-	if (!lp->lan_saa9730_regs) {
-		ret =3D -ENOMEM;
-		goto out;
-	}
-
-	/* Set SAA9730 EVM base address. */
-	lp->evm_saa9730_regs =3D ioremap(ioaddr + SAA9730_EVM_REGS_ADDR,
-				       SAA9730_EVM_REGS_SIZE);
-	if (!lp->evm_saa9730_regs) {
-		ret =3D -ENOMEM;
-		goto out_iounmap_lan;
-	}
-
-	/* Allocate LAN RX/TX frame buffer space. */
-	if ((ret =3D lan_saa9730_allocate_buffers(pdev, lp)))
-		goto out_iounmap;
-
-	/* Stop LAN controller. */
-	if ((ret =3D lan_saa9730_stop(lp)))
-		goto out_free_consistent;
-
-	/* Initialize CAM registers. */
-	if ((ret =3D lan_saa9730_cam_init(dev)))
-		goto out_free_consistent;
-
-	/* Initialize MII registers. */
-	if ((ret =3D lan_saa9730_mii_init(lp)))
-		goto out_free_consistent;
-
-	/* Initialize control registers. */
-	if ((ret =3D lan_saa9730_control_init(lp)))
-		goto out_free_consistent;
-
-	/* Load CAM registers. */
-	if ((ret =3D lan_saa9730_cam_load(lp)))
-		goto out_free_consistent;
-
-	/* Initialize DMA context registers. */
-	if ((ret =3D lan_saa9730_dma_init(lp)))
-		goto out_free_consistent;
-
-	spin_lock_init(&lp->lock);
-
-	dev->open =3D lan_saa9730_open;
-	dev->hard_start_xmit =3D lan_saa9730_start_xmit;
-	dev->stop =3D lan_saa9730_close;
-	dev->set_multicast_list =3D lan_saa9730_set_multicast;
-	dev->tx_timeout =3D lan_saa9730_tx_timeout;
-	dev->watchdog_timeo =3D (HZ >> 1);
-	dev->dma =3D 0;
-
-	ret =3D register_netdev (dev);
-	if (ret)
-		goto out_free_consistent;
-
-	return 0;
-
-out_free_consistent:
-	lan_saa9730_free_buffers(pdev, lp);
-out_iounmap:
-	iounmap(lp->evm_saa9730_regs);
-out_iounmap_lan:
-	iounmap(lp->lan_saa9730_regs);
-out:
-	return ret;
-}
-
-
-static int __devinit saa9730_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
-{
-	struct net_device *dev =3D NULL;
-	unsigned long pci_ioaddr;
-	int err;
-
-	if (lan_saa9730_debug > 1)
-		printk("saa9730.c: PCI bios is present, checking for devices...\n");
-
-	err =3D pci_enable_device(pdev);
-	if (err) {
-		printk(KERN_ERR "Cannot enable PCI device, aborting.\n");
-		goto out;
-	}
-
-	err =3D pci_request_regions(pdev, DRV_MODULE_NAME);
-	if (err) {
-		printk(KERN_ERR "Cannot obtain PCI resources, aborting.\n");
-		goto out_disable_pdev;
-	}
-
-	pci_irq_line =3D pdev->irq;
-	/* LAN base address in located at BAR 1. */
-
-	pci_ioaddr =3D pci_resource_start(pdev, 1);
-	pci_set_master(pdev);
-
-	printk("Found SAA9730 (PCI) at %lx, irq %d.\n",
-	       pci_ioaddr, pci_irq_line);
-
-	dev =3D alloc_etherdev(sizeof(struct lan_saa9730_private));
-	if (!dev)
-		goto out_disable_pdev;
-
-	err =3D lan_saa9730_init(dev, pdev, pci_ioaddr, pci_irq_line);
-	if (err) {
-		printk("LAN init failed");
-		goto out_free_netdev;
-	}
-
-	pci_set_drvdata(pdev, dev);
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	return 0;
-
-out_free_netdev:
-	free_netdev(dev);
-out_disable_pdev:
-	pci_disable_device(pdev);
-out:
-	pci_set_drvdata(pdev, NULL);
-	return err;
-}
-
-
-static struct pci_driver saa9730_driver =3D {
-	.name		=3D DRV_MODULE_NAME,
-	.id_table	=3D saa9730_pci_tbl,
-	.probe		=3D saa9730_init_one,
-	.remove		=3D __devexit_p(saa9730_remove_one),
-};
-
-
-static int __init saa9730_init(void)
-{
-	return pci_register_driver(&saa9730_driver);
-}
-
-static void __exit saa9730_cleanup(void)
-{
-	pci_unregister_driver(&saa9730_driver);
-}
-
-module_init(saa9730_init);
-module_exit(saa9730_cleanup);
-
-MODULE_AUTHOR("Ralf Baechle <ralf@linux-mips.org>");
-MODULE_DESCRIPTION("Philips SAA9730 ethernet driver");
-MODULE_LICENSE("GPL");
diff --git a/drivers/net/saa9730.h b/drivers/net/saa9730.h
deleted file mode 100644
index 010a120..0000000
--- a/drivers/net/saa9730.h
+++ /dev/null
@@ -1,384 +0,0 @@
-/*
- * Copyright (C) 2000, 2005  MIPS Technologies, Inc.  All rights reser=
ved.
- *	Authors: Carsten Langgaard <carstenl@mips.com>
- *		 Maciej W. Rozycki <macro@mips.com>
- *
- * ###################################################################=
#####
- *
- *  This program is free software; you can distribute it and/or modify=
 it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WIT=
HOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY=
 or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Lice=
nse
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License =
along
- *  with this program; if not, write to the Free Software Foundation, =
Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
- *
- * ###################################################################=
#####
- *
- * SAA9730 ethernet driver description.
- *
- */
-#ifndef _SAA9730_H
-#define _SAA9730_H
-
-
-/* Number of 6-byte entries in the CAM. */
-#define LAN_SAA9730_CAM_ENTRIES              10
-#define	LAN_SAA9730_CAM_DWORDS               ((LAN_SAA9730_CAM_ENTRIES=
*6)/4)
-
-/* TX and RX packet size: fixed to 2048 bytes, according to HW require=
ments. */
-#define LAN_SAA9730_PACKET_SIZE                       2048
-
-/*
- * Number of TX buffers =3D number of RX buffers =3D 2, which is fixed=
 according
- * to HW requirements.
- */
-#define LAN_SAA9730_BUFFERS                           2
-
-/* Number of RX packets per RX buffer. */
-#define LAN_SAA9730_RCV_Q_SIZE                        15
-
-/* Number of TX packets per TX buffer. */
-#define LAN_SAA9730_TXM_Q_SIZE                        15
-
-/*
- * We get an interrupt for each LAN_SAA9730_DEFAULT_RCV_Q_INT_THRESHOL=
D
- * packets received.
- * If however we receive less than  LAN_SAA9730_DEFAULT_RCV_Q_INT_THRE=
SHOLD
- * packets, the hardware can timeout after a certain time and still te=
ll
- * us packets have arrived.
- * The timeout value in unit of 32 PCI clocks (33Mhz).
- * The value 200 approximates 0.0002 seconds.
- */
-#define LAN_SAA9730_RCV_Q_INT_THRESHOLD               1
-#define LAN_SAA9730_DEFAULT_TIME_OUT_CNT              10
-
-#define RXSF_NDIS                       0
-#define RXSF_READY                      2
-#define RXSF_HWDONE                     3
-
-#define TXSF_EMPTY                      0
-#define TXSF_READY                      2
-#define TXSF_HWDONE                     3
-
-#define LANEND_LITTLE                   0
-#define LANEND_BIG_2143                 1
-#define LANEND_BIG_4321                 2
-
-#define LANMB_ANY                       0
-#define LANMB_8                         1
-#define LANMB_32                        2
-#define LANMB_64                        3
-
-#define MACCM_AUTOMATIC                 0
-#define MACCM_10MB                      1
-#define MACCM_MII                       2
-
-/*
- * PHY definitions for Basic registers of QS6612 (used on MIPS ATLAS b=
oard)
- */
-#define PHY_CONTROL                     0x0
-#define PHY_STATUS                      0x1
-#define PHY_STATUS_LINK_UP              0x4
-#define PHY_CONTROL_RESET               0x8000
-#define PHY_CONTROL_AUTO_NEG            0x1000
-#define PHY_CONTROL_RESTART_AUTO_NEG    0x0200
-#define PHY_ADDRESS                     0x0
-
-/* PK_COUNT register. */
-#define PK_COUNT_TX_A_SHF               24
-#define PK_COUNT_TX_A_MSK               (0xff << PK_COUNT_TX_A_SHF)
-#define PK_COUNT_TX_B_SHF               16
-#define PK_COUNT_TX_B_MSK               (0xff << PK_COUNT_TX_B_SHF)
-#define PK_COUNT_RX_A_SHF               8
-#define PK_COUNT_RX_A_MSK               (0xff << PK_COUNT_RX_A_SHF)
-#define PK_COUNT_RX_B_SHF               0
-#define PK_COUNT_RX_B_MSK               (0xff << PK_COUNT_RX_B_SHF)
-
-/* OK2USE register. */
-#define OK2USE_TX_A                     0x8
-#define OK2USE_TX_B                     0x4
-#define OK2USE_RX_A                     0x2
-#define OK2USE_RX_B                     0x1
-
-/* LAN DMA CONTROL register. */
-#define DMA_CTL_BLK_INT                 0x80000000
-#define DMA_CTL_MAX_XFER_SHF            18
-#define DMA_CTL_MAX_XFER_MSK            (0x3 << LAN_DMA_CTL_MAX_XFER_S=
HF)
-#define DMA_CTL_ENDIAN_SHF              16
-#define DMA_CTL_ENDIAN_MSK              (0x3 << LAN_DMA_CTL_ENDIAN_SHF=
)
-#define DMA_CTL_RX_INT_COUNT_SHF        8
-#define DMA_CTL_RX_INT_COUNT_MSK        (0xff << LAN_DMA_CTL_RX_INT_CO=
UNT_SHF)
-#define DMA_CTL_EN_TX_DMA               0x00000080
-#define DMA_CTL_EN_RX_DMA               0x00000040
-#define DMA_CTL_RX_INT_BUFFUL_EN        0x00000020
-#define DMA_CTL_RX_INT_TO_EN            0x00000010
-#define DMA_CTL_RX_INT_EN               0x00000008
-#define DMA_CTL_TX_INT_EN               0x00000004
-#define DMA_CTL_MAC_TX_INT_EN           0x00000002
-#define DMA_CTL_MAC_RX_INT_EN           0x00000001
-
-/* DMA STATUS register. */
-#define DMA_STATUS_BAD_ADDR_SHF         16
-#define DMA_STATUS_BAD_ADDR_MSK         (0xf << DMA_STATUS_BAD_ADDR_SH=
=46)
-#define DMA_STATUS_RX_PKTS_RECEIVED_SHF 8
-#define DMA_STATUS_RX_PKTS_RECEIVED_MSK (0xff << DMA_STATUS_RX_PKTS_RE=
CEIVED_SHF)
-#define DMA_STATUS_TX_EN_SYNC           0x00000080
-#define DMA_STATUS_RX_BUF_A_FUL         0x00000040
-#define DMA_STATUS_RX_BUF_B_FUL         0x00000020
-#define DMA_STATUS_RX_TO_INT            0x00000010
-#define DMA_STATUS_RX_INT               0x00000008
-#define DMA_STATUS_TX_INT               0x00000004
-#define DMA_STATUS_MAC_TX_INT           0x00000002
-#define DMA_STATUS_MAC_RX_INT           0x00000001
-
-/* DMA TEST/PANIC SWITHES register. */
-#define DMA_TEST_LOOPBACK               0x01000000
-#define DMA_TEST_SW_RESET               0x00000001
-
-/* MAC CONTROL register. */
-#define MAC_CONTROL_EN_MISS_ROLL        0x00002000
-#define MAC_CONTROL_MISS_ROLL           0x00000400
-#define MAC_CONTROL_LOOP10              0x00000080
-#define MAC_CONTROL_CONN_SHF            5
-#define MAC_CONTROL_CONN_MSK            (0x3 << MAC_CONTROL_CONN_SHF)
-#define MAC_CONTROL_MAC_LOOP            0x00000010
-#define MAC_CONTROL_FULL_DUP            0x00000008
-#define MAC_CONTROL_RESET               0x00000004
-#define MAC_CONTROL_HALT_IMM            0x00000002
-#define MAC_CONTROL_HALT_REQ            0x00000001
-
-/* CAM CONTROL register. */
-#define CAM_CONTROL_COMP_EN             0x00000010
-#define CAM_CONTROL_NEG_CAM             0x00000008
-#define CAM_CONTROL_BROAD_ACC           0x00000004
-#define CAM_CONTROL_GROUP_ACC           0x00000002
-#define CAM_CONTROL_STATION_ACC         0x00000001
-
-/* TRANSMIT CONTROL register. */
-#define TX_CTL_EN_COMP                  0x00004000
-#define TX_CTL_EN_TX_PAR                0x00002000
-#define TX_CTL_EN_LATE_COLL             0x00001000
-#define TX_CTL_EN_EX_COLL               0x00000800
-#define TX_CTL_EN_L_CARR                0x00000400
-#define TX_CTL_EN_EX_DEFER              0x00000200
-#define TX_CTL_EN_UNDER                 0x00000100
-#define TX_CTL_MII10                    0x00000080
-#define TX_CTL_SD_PAUSE                 0x00000040
-#define TX_CTL_NO_EX_DEF0               0x00000020
-#define TX_CTL_F_BACK                   0x00000010
-#define TX_CTL_NO_CRC                   0x00000008
-#define TX_CTL_NO_PAD                   0x00000004
-#define TX_CTL_TX_HALT                  0x00000002
-#define TX_CTL_TX_EN                    0x00000001
-
-/* TRANSMIT STATUS register. */
-#define TX_STATUS_SQ_ERR                0x00010000
-#define TX_STATUS_TX_HALTED             0x00008000
-#define TX_STATUS_COMP                  0x00004000
-#define TX_STATUS_TX_PAR                0x00002000
-#define TX_STATUS_LATE_COLL             0x00001000
-#define TX_STATUS_TX10_STAT             0x00000800
-#define TX_STATUS_L_CARR                0x00000400
-#define TX_STATUS_EX_DEFER              0x00000200
-#define TX_STATUS_UNDER                 0x00000100
-#define TX_STATUS_IN_TX                 0x00000080
-#define TX_STATUS_PAUSED                0x00000040
-#define TX_STATUS_TX_DEFERRED           0x00000020
-#define TX_STATUS_EX_COLL               0x00000010
-#define TX_STATUS_TX_COLL_SHF           0
-#define TX_STATUS_TX_COLL_MSK           (0xf << TX_STATUS_TX_COLL_SHF)
-
-/* RECEIVE CONTROL register. */
-#define RX_CTL_EN_GOOD                  0x00004000
-#define RX_CTL_EN_RX_PAR                0x00002000
-#define RX_CTL_EN_LONG_ERR              0x00000800
-#define RX_CTL_EN_OVER                  0x00000400
-#define RX_CTL_EN_CRC_ERR               0x00000200
-#define RX_CTL_EN_ALIGN                 0x00000100
-#define RX_CTL_IGNORE_CRC               0x00000040
-#define RX_CTL_PASS_CTL                 0x00000020
-#define RX_CTL_STRIP_CRC                0x00000010
-#define RX_CTL_SHORT_EN                 0x00000008
-#define RX_CTL_LONG_EN                  0x00000004
-#define RX_CTL_RX_HALT                  0x00000002
-#define RX_CTL_RX_EN                    0x00000001
-
-/* RECEIVE STATUS register. */
-#define RX_STATUS_RX_HALTED             0x00008000
-#define RX_STATUS_GOOD                  0x00004000
-#define RX_STATUS_RX_PAR                0x00002000
-#define RX_STATUS_LONG_ERR              0x00000800
-#define RX_STATUS_OVERFLOW              0x00000400
-#define RX_STATUS_CRC_ERR               0x00000200
-#define RX_STATUS_ALIGN_ERR             0x00000100
-#define RX_STATUS_RX10_STAT             0x00000080
-#define RX_STATUS_INT_RX                0x00000040
-#define RX_STATUS_CTL_RECD              0x00000020
-
-/* MD_CA register. */
-#define MD_CA_PRE_SUP                   0x00001000
-#define MD_CA_BUSY                      0x00000800
-#define MD_CA_WR                        0x00000400
-#define MD_CA_PHY_SHF                   5
-#define MD_CA_PHY_MSK                   (0x1f << MD_CA_PHY_SHF)
-#define MD_CA_ADDR_SHF                  0
-#define MD_CA_ADDR_MSK                  (0x1f << MD_CA_ADDR_SHF)
-
-/* Tx Status/Control. */
-#define TX_STAT_CTL_OWNER_SHF           30
-#define TX_STAT_CTL_OWNER_MSK           (0x3 << TX_STAT_CTL_OWNER_SHF)
-#define TX_STAT_CTL_FRAME_SHF           27
-#define TX_STAT_CTL_FRAME_MSK           (0x7 << TX_STAT_CTL_FRAME_SHF)
-#define TX_STAT_CTL_STATUS_SHF          11
-#define TX_STAT_CTL_STATUS_MSK          (0x1ffff << TX_STAT_CTL_STATUS=
_SHF)
-#define TX_STAT_CTL_LENGTH_SHF          0
-#define TX_STAT_CTL_LENGTH_MSK          (0x7ff << TX_STAT_CTL_LENGTH_S=
HF)
-
-#define TX_STAT_CTL_ERROR_MSK           ((TX_STATUS_SQ_ERR      |     =
\
-					  TX_STATUS_TX_HALTED   |     \
-					  TX_STATUS_TX_PAR      |     \
-					  TX_STATUS_LATE_COLL   |     \
-					  TX_STATUS_L_CARR      |     \
-					  TX_STATUS_EX_DEFER    |     \
-					  TX_STATUS_UNDER       |     \
-					  TX_STATUS_PAUSED      |     \
-					  TX_STATUS_TX_DEFERRED |     \
-					  TX_STATUS_EX_COLL     |     \
-					  TX_STATUS_TX_COLL_MSK)      \
-                                                    << TX_STAT_CTL_STA=
TUS_SHF)
-#define TX_STAT_CTL_INT_AFTER_TX        0x4
-
-/* Rx Status/Control. */
-#define RX_STAT_CTL_OWNER_SHF           30
-#define RX_STAT_CTL_OWNER_MSK           (0x3 << RX_STAT_CTL_OWNER_SHF)
-#define RX_STAT_CTL_STATUS_SHF          11
-#define RX_STAT_CTL_STATUS_MSK          (0xffff << RX_STAT_CTL_STATUS_=
SHF)
-#define RX_STAT_CTL_LENGTH_SHF          0
-#define RX_STAT_CTL_LENGTH_MSK          (0x7ff << RX_STAT_CTL_LENGTH_S=
HF)
-
-
-
-/* The SAA9730 (LAN) controller register map, as seen via the PCI-bus.=
 */
-#define SAA9730_LAN_REGS_ADDR   0x20400
-#define SAA9730_LAN_REGS_SIZE   0x00400
-
-struct lan_saa9730_regmap {
-	volatile unsigned int TxBuffA;			/* 0x20400 */
-	volatile unsigned int TxBuffB;			/* 0x20404 */
-	volatile unsigned int RxBuffA;			/* 0x20408 */
-	volatile unsigned int RxBuffB;			/* 0x2040c */
-	volatile unsigned int PacketCount;		/* 0x20410 */
-	volatile unsigned int Ok2Use;			/* 0x20414 */
-	volatile unsigned int LanDmaCtl;		/* 0x20418 */
-	volatile unsigned int Timeout;			/* 0x2041c */
-	volatile unsigned int DmaStatus;		/* 0x20420 */
-	volatile unsigned int DmaTest;			/* 0x20424 */
-	volatile unsigned char filler20428[0x20430 - 0x20428];
-	volatile unsigned int PauseCount;		/* 0x20430 */
-	volatile unsigned int RemotePauseCount;		/* 0x20434 */
-	volatile unsigned char filler20438[0x20440 - 0x20438];
-	volatile unsigned int MacCtl;			/* 0x20440 */
-	volatile unsigned int CamCtl;			/* 0x20444 */
-	volatile unsigned int TxCtl;			/* 0x20448 */
-	volatile unsigned int TxStatus;			/* 0x2044c */
-	volatile unsigned int RxCtl;			/* 0x20450 */
-	volatile unsigned int RxStatus;			/* 0x20454 */
-	volatile unsigned int StationMgmtData;		/* 0x20458 */
-	volatile unsigned int StationMgmtCtl;		/* 0x2045c */
-	volatile unsigned int CamAddress;		/* 0x20460 */
-	volatile unsigned int CamData;			/* 0x20464 */
-	volatile unsigned int CamEnable;		/* 0x20468 */
-	volatile unsigned char filler2046c[0x20500 - 0x2046c];
-	volatile unsigned int DebugPCIMasterAddr;	/* 0x20500 */
-	volatile unsigned int DebugLanTxStateMachine;	/* 0x20504 */
-	volatile unsigned int DebugLanRxStateMachine;	/* 0x20508 */
-	volatile unsigned int DebugLanTxFifoPointers;	/* 0x2050c */
-	volatile unsigned int DebugLanRxFifoPointers;	/* 0x20510 */
-	volatile unsigned int DebugLanCtlStateMachine;	/* 0x20514 */
-};
-typedef volatile struct lan_saa9730_regmap t_lan_saa9730_regmap;
-
-
-/* EVM interrupt control registers. */
-#define EVM_LAN_INT                     0x00010000
-#define EVM_MASTER_EN                   0x00000001
-
-/* The SAA9730 (EVM) controller register map, as seen via the PCI-bus.=
 */
-#define SAA9730_EVM_REGS_ADDR   0x02000
-#define SAA9730_EVM_REGS_SIZE   0x00400
-
-struct evm_saa9730_regmap {
-	volatile unsigned int InterruptStatus1;		/* 0x2000 */
-	volatile unsigned int InterruptEnable1;		/* 0x2004 */
-	volatile unsigned int InterruptMonitor1;	/* 0x2008 */
-	volatile unsigned int Counter;			/* 0x200c */
-	volatile unsigned int CounterThreshold;		/* 0x2010 */
-	volatile unsigned int CounterControl;		/* 0x2014 */
-	volatile unsigned int GpioControl1;		/* 0x2018 */
-	volatile unsigned int InterruptStatus2;		/* 0x201c */
-	volatile unsigned int InterruptEnable2;		/* 0x2020 */
-	volatile unsigned int InterruptMonitor2;	/* 0x2024 */
-	volatile unsigned int GpioControl2;		/* 0x2028 */
-	volatile unsigned int InterruptBlock1;		/* 0x202c */
-	volatile unsigned int InterruptBlock2;		/* 0x2030 */
-};
-typedef volatile struct evm_saa9730_regmap t_evm_saa9730_regmap;
-
-
-struct lan_saa9730_private {
-	/*
-	 * Rx/Tx packet buffers.
-	 * The Rx and Tx packets must be PACKET_SIZE aligned.
-	 */
-	void		*buffer_start;
-	unsigned int	buffer_size;
-
-	/*
-	 * DMA address of beginning of this object, returned
-	 * by pci_alloc_consistent().
-	 */
-	dma_addr_t	dma_addr;
-
-	/* Pointer to the associated pci device structure */
-	struct pci_dev	*pci_dev;
-
-	/* Pointer for the SAA9730 LAN controller register set. */
-	t_lan_saa9730_regmap *lan_saa9730_regs;
-
-	/* Pointer to the SAA9730 EVM register. */
-	t_evm_saa9730_regmap *evm_saa9730_regs;
-
-	/* Rcv buffer Index. */
-	unsigned char NextRcvPacketIndex;
-	/* Next buffer index. */
-	unsigned char NextRcvBufferIndex;
-
-	/* Index of next packet to use in that buffer. */
-	unsigned char NextTxmPacketIndex;
-	/* Next buffer index. */
-	unsigned char NextTxmBufferIndex;
-
-	/* Index of first pending packet ready to send. */
-	unsigned char PendingTxmPacketIndex;
-	/* Pending buffer index. */
-	unsigned char PendingTxmBufferIndex;
-
-	unsigned char DmaRcvPackets;
-	unsigned char DmaTxmPackets;
-
-	void	      *TxmBuffer[LAN_SAA9730_BUFFERS][LAN_SAA9730_TXM_Q_SIZE];
-	void	      *RcvBuffer[LAN_SAA9730_BUFFERS][LAN_SAA9730_RCV_Q_SIZE];
-	unsigned int TxBufferFree[LAN_SAA9730_BUFFERS];
-
-	unsigned char PhysicalAddress[LAN_SAA9730_CAM_ENTRIES][6];
-
-	spinlock_t lock;
-};
-
-#endif /* _SAA9730_H */
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fb0b918..07933f7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3500,11 +3500,7 @@ static int ucc_geth_rx(struct ucc_geth_private *=
ugeth, u8 rxQ, int rx_work_limit
=20
 			dev->stats.rx_bytes +=3D length;
 			/* Send the packet up the stack */
-#ifdef CONFIG_UGETH_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif				/* CONFIG_UGETH_NAPI */
 		}
=20
 		ugeth->dev->last_rx =3D jiffies;
@@ -3580,7 +3576,6 @@ static int ucc_geth_tx(struct net_device *dev, u8=
 txQ)
 	return 0;
 }
=20
-#ifdef CONFIG_UGETH_NAPI
 static int ucc_geth_poll(struct napi_struct *napi, int budget)
 {
 	struct ucc_geth_private *ugeth =3D container_of(napi, struct ucc_geth=
_private, napi);
@@ -3607,7 +3602,6 @@ static int ucc_geth_poll(struct napi_struct *napi=
, int budget)
=20
 	return howmany;
 }
-#endif				/* CONFIG_UGETH_NAPI */
=20
 static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 {
@@ -3617,9 +3611,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, =
void *info)
 	struct ucc_geth_info *ug_info;
 	register u32 ucce;
 	register u32 uccm;
-#ifndef CONFIG_UGETH_NAPI
-	register u32 rx_mask;
-#endif
 	register u32 tx_mask;
 	u8 i;
=20
@@ -3636,21 +3627,11 @@ static irqreturn_t ucc_geth_irq_handler(int irq=
, void *info)
=20
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
-#ifdef CONFIG_UGETH_NAPI
 		if (netif_rx_schedule_prep(dev, &ugeth->napi)) {
 			uccm &=3D ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
 			__netif_rx_schedule(dev, &ugeth->napi);
 		}
-#else
-		rx_mask =3D UCCE_RXBF_SINGLE_MASK;
-		for (i =3D 0; i < ug_info->numQueuesRx; i++) {
-			if (ucce & rx_mask)
-				ucc_geth_rx(ugeth, i, (int)ugeth->ug_info->bdRingLenRx[i]);
-			ucce &=3D ~rx_mask;
-			rx_mask <<=3D 1;
-		}
-#endif /* CONFIG_UGETH_NAPI */
 	}
=20
 	/* Tx event processing */
@@ -3720,9 +3701,8 @@ static int ucc_geth_open(struct net_device *dev)
 		return err;
 	}
=20
-#ifdef CONFIG_UGETH_NAPI
 	napi_enable(&ugeth->napi);
-#endif
+
 	err =3D ucc_geth_startup(ugeth);
 	if (err) {
 		if (netif_msg_ifup(ugeth))
@@ -3783,9 +3763,8 @@ static int ucc_geth_open(struct net_device *dev)
 	return err;
=20
 out_err:
-#ifdef CONFIG_UGETH_NAPI
 	napi_disable(&ugeth->napi);
-#endif
+
 	return err;
 }
=20
@@ -3796,9 +3775,7 @@ static int ucc_geth_close(struct net_device *dev)
=20
 	ugeth_vdbg("%s: IN", __FUNCTION__);
=20
-#ifdef CONFIG_UGETH_NAPI
 	napi_disable(&ugeth->napi);
-#endif
=20
 	ucc_geth_stop(ugeth);
=20
@@ -4050,9 +4027,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	dev->hard_start_xmit =3D ucc_geth_start_xmit;
 	dev->tx_timeout =3D ucc_geth_timeout;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
-#ifdef CONFIG_UGETH_NAPI
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT)=
;
-#endif				/* CONFIG_UGETH_NAPI */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D ucc_netpoll;
 #endif
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8c9d6ae..96dff04 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -73,12 +73,7 @@ static const int multicast_filter_limit =3D 32;
    There are no ill effects from too-large receive rings. */
 #define TX_RING_SIZE	16
 #define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
-#ifdef CONFIG_VIA_RHINE_NAPI
 #define RX_RING_SIZE	64
-#else
-#define RX_RING_SIZE	16
-#endif
-
=20
 /* Operational parameters that usually are not changed. */
=20
@@ -583,7 +578,6 @@ static void rhine_poll(struct net_device *dev)
 }
 #endif
=20
-#ifdef CONFIG_VIA_RHINE_NAPI
 static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
 	struct rhine_private *rp =3D container_of(napi, struct rhine_private,=
 napi);
@@ -604,7 +598,6 @@ static int rhine_napipoll(struct napi_struct *napi,=
 int budget)
 	}
 	return work_done;
 }
-#endif
=20
 static void __devinit rhine_hw_init(struct net_device *dev, long pioad=
dr)
 {
@@ -784,9 +777,8 @@ static int __devinit rhine_init_one(struct pci_dev =
*pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D rhine_poll;
 #endif
-#ifdef CONFIG_VIA_RHINE_NAPI
 	netif_napi_add(dev, &rp->napi, rhine_napipoll, 64);
-#endif
+
 	if (rp->quirks & rqRhineI)
 		dev->features |=3D NETIF_F_SG|NETIF_F_HW_CSUM;
=20
@@ -1056,9 +1048,7 @@ static void init_registers(struct net_device *dev=
)
=20
 	rhine_set_rx_mode(dev);
=20
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_enable(&rp->napi);
-#endif
=20
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
@@ -1193,9 +1183,7 @@ static void rhine_tx_timeout(struct net_device *d=
ev)
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
=20
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
=20
 	spin_lock(&rp->lock);
=20
@@ -1319,16 +1307,12 @@ static irqreturn_t rhine_interrupt(int irq, voi=
d *dev_instance)
=20
 		if (intr_status & (IntrRxDone | IntrRxErr | IntrRxDropped |
 				   IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
-#ifdef CONFIG_VIA_RHINE_NAPI
 			iowrite16(IntrTxAborted |
 				  IntrTxDone | IntrTxError | IntrTxUnderrun |
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
=20
 			netif_rx_schedule(dev, &rp->napi);
-#else
-			rhine_rx(dev, RX_RING_SIZE);
-#endif
 		}
=20
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
@@ -1520,11 +1504,7 @@ static int rhine_rx(struct net_device *dev, int =
limit)
 						 PCI_DMA_FROMDEVICE);
 			}
 			skb->protocol =3D eth_type_trans(skb, dev);
-#ifdef CONFIG_VIA_RHINE_NAPI
 			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif
 			dev->last_rx =3D jiffies;
 			rp->stats.rx_bytes +=3D pkt_len;
 			rp->stats.rx_packets++;
@@ -1836,9 +1816,7 @@ static int rhine_close(struct net_device *dev)
 	spin_lock_irq(&rp->lock);
=20
 	netif_stop_queue(dev);
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
=20
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
@@ -1937,9 +1915,8 @@ static int rhine_suspend(struct pci_dev *pdev, pm=
_message_t state)
 	if (!netif_running(dev))
 		return 0;
=20
-#ifdef CONFIG_VIA_RHINE_NAPI
 	napi_disable(&rp->napi);
-#endif
+
 	netif_device_detach(dev);
 	pci_save_state(pdev);
=20
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index bcbf2fa..370ce30 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1102,61 +1102,41 @@ static int __devinit velocity_get_pci_info(stru=
ct velocity_info *vptr, struct pc
=20
 static int velocity_init_rings(struct velocity_info *vptr)
 {
-	int i;
-	unsigned int psize;
-	unsigned int tsize;
+	struct velocity_opt *opt =3D &vptr->options;
+	const unsigned int rx_ring_size =3D opt->numrx * sizeof(struct rx_des=
c);
+	const unsigned int tx_ring_size =3D opt->numtx * sizeof(struct tx_des=
c);
+	struct pci_dev *pdev =3D vptr->pdev;
 	dma_addr_t pool_dma;
-	u8 *pool;
-
-	/*
-	 *	Allocate all RD/TD rings a single pool
-	 */
-
-	psize =3D vptr->options.numrx * sizeof(struct rx_desc) +
-		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+	void *pool;
+	unsigned int i;
=20
 	/*
+	 * Allocate all RD/TD rings a single pool.
+	 *
 	 * pci_alloc_consistent() fulfills the requirement for 64 bytes
 	 * alignment
 	 */
-	pool =3D pci_alloc_consistent(vptr->pdev, psize, &pool_dma);
-
-	if (pool =3D=3D NULL) {
-		printk(KERN_ERR "%s : DMA memory allocation failed.\n",
-					vptr->dev->name);
+	pool =3D pci_alloc_consistent(pdev, tx_ring_size * vptr->num_txq +
+				    rx_ring_size, &pool_dma);
+	if (!pool) {
+		dev_err(&pdev->dev, "%s : DMA memory allocation failed.\n",
+			vptr->dev->name);
 		return -ENOMEM;
 	}
=20
-	memset(pool, 0, psize);
-
-	vptr->rd_ring =3D (struct rx_desc *) pool;
-
+	vptr->rd_ring =3D pool;
 	vptr->rd_pool_dma =3D pool_dma;
=20
-	tsize =3D vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
-	vptr->tx_bufs =3D pci_alloc_consistent(vptr->pdev, tsize,
-						&vptr->tx_bufs_dma);
-
-	if (vptr->tx_bufs =3D=3D NULL) {
-		printk(KERN_ERR "%s: DMA memory allocation failed.\n",
-					vptr->dev->name);
-		pci_free_consistent(vptr->pdev, psize, pool, pool_dma);
-		return -ENOMEM;
-	}
-
-	memset(vptr->tx_bufs, 0, vptr->options.numtx * PKT_BUF_SZ * vptr->num=
_txq);
+	pool +=3D rx_ring_size;
+	pool_dma +=3D rx_ring_size;
=20
-	i =3D vptr->options.numrx * sizeof(struct rx_desc);
-	pool +=3D i;
-	pool_dma +=3D i;
 	for (i =3D 0; i < vptr->num_txq; i++) {
-		int offset =3D vptr->options.numtx * sizeof(struct tx_desc);
-
+		vptr->td_rings[i] =3D pool;
 		vptr->td_pool_dma[i] =3D pool_dma;
-		vptr->td_rings[i] =3D (struct tx_desc *) pool;
-		pool +=3D offset;
-		pool_dma +=3D offset;
+		pool +=3D tx_ring_size;
+		pool_dma +=3D tx_ring_size;
 	}
+
 	return 0;
 }
=20
@@ -1169,19 +1149,13 @@ static int velocity_init_rings(struct velocity_=
info *vptr)
=20
 static void velocity_free_rings(struct velocity_info *vptr)
 {
-	int size;
-
-	size =3D vptr->options.numrx * sizeof(struct rx_desc) +
-	       vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+	const int size =3D vptr->options.numrx * sizeof(struct rx_desc) +
+		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
=20
 	pci_free_consistent(vptr->pdev, size, vptr->rd_ring, vptr->rd_pool_dm=
a);
-
-	size =3D vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
-
-	pci_free_consistent(vptr->pdev, size, vptr->tx_bufs, vptr->tx_bufs_dm=
a);
 }
=20
-static inline void velocity_give_many_rx_descs(struct velocity_info *v=
ptr)
+static void velocity_give_many_rx_descs(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem *regs =3D vptr->mac_regs;
 	int avail, dirty, unusable;
@@ -1208,7 +1182,7 @@ static inline void velocity_give_many_rx_descs(st=
ruct velocity_info *vptr)
=20
 static int velocity_rx_refill(struct velocity_info *vptr)
 {
-	int dirty =3D vptr->rd_dirty, done =3D 0, ret =3D 0;
+	int dirty =3D vptr->rd_dirty, done =3D 0;
=20
 	do {
 		struct rx_desc *rd =3D vptr->rd_ring + dirty;
@@ -1218,8 +1192,7 @@ static int velocity_rx_refill(struct velocity_inf=
o *vptr)
 			break;
=20
 		if (!vptr->rd_info[dirty].skb) {
-			ret =3D velocity_alloc_rx_buf(vptr, dirty);
-			if (ret < 0)
+			if (velocity_alloc_rx_buf(vptr, dirty) < 0)
 				break;
 		}
 		done++;
@@ -1229,10 +1202,14 @@ static int velocity_rx_refill(struct velocity_i=
nfo *vptr)
 	if (done) {
 		vptr->rd_dirty =3D dirty;
 		vptr->rd_filled +=3D done;
-		velocity_give_many_rx_descs(vptr);
 	}
=20
-	return ret;
+	return done;
+}
+
+static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu=
)
+{
+	vptr->rx_buf_sz =3D (mtu <=3D ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 }
=20
 /**
@@ -1245,25 +1222,24 @@ static int velocity_rx_refill(struct velocity_i=
nfo *vptr)
=20
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
-	int ret;
-	int mtu =3D vptr->dev->mtu;
-
-	vptr->rx_buf_sz =3D (mtu <=3D ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
+	int ret =3D -ENOMEM;
=20
 	vptr->rd_info =3D kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
 	if (!vptr->rd_info)
-		return -ENOMEM;
+		goto out;
=20
 	vptr->rd_filled =3D vptr->rd_dirty =3D vptr->rd_curr =3D 0;
=20
-	ret =3D velocity_rx_refill(vptr);
-	if (ret < 0) {
+	if (velocity_rx_refill(vptr) !=3D vptr->options.numrx) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
 			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
 		velocity_free_rd_ring(vptr);
+		goto out;
 	}
=20
+	ret =3D 0;
+out:
 	return ret;
 }
=20
@@ -1313,10 +1289,8 @@ static void velocity_free_rd_ring(struct velocit=
y_info *vptr)
=20
 static int velocity_init_td_ring(struct velocity_info *vptr)
 {
-	int i, j;
 	dma_addr_t curr;
-	struct tx_desc *td;
-	struct velocity_td_info *td_info;
+	unsigned int j;
=20
 	/* Init the TD ring entries */
 	for (j =3D 0; j < vptr->num_txq; j++) {
@@ -1331,14 +1305,6 @@ static int velocity_init_td_ring(struct velocity=
_info *vptr)
 			return -ENOMEM;
 		}
=20
-		for (i =3D 0; i < vptr->options.numtx; i++, curr +=3D sizeof(struct =
tx_desc)) {
-			td =3D &(vptr->td_rings[j][i]);
-			td_info =3D &(vptr->td_infos[j][i]);
-			td_info->buf =3D vptr->tx_bufs +
-				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
-			td_info->buf_dma =3D vptr->tx_bufs_dma +
-				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
-		}
 		vptr->td_tail[j] =3D vptr->td_curr[j] =3D vptr->td_used[j] =3D 0;
 	}
 	return 0;
@@ -1448,10 +1414,8 @@ static int velocity_rx_srv(struct velocity_info =
*vptr, int status)
=20
 	vptr->rd_curr =3D rd_curr;
=20
-	if (works > 0 && velocity_rx_refill(vptr) < 0) {
-		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
-			"%s: rx buf allocation failure\n", vptr->dev->name);
-	}
+	if ((works > 0) && (velocity_rx_refill(vptr) > 0))
+		velocity_give_many_rx_descs(vptr);
=20
 	VAR_USED(stats);
 	return works;
@@ -1867,7 +1831,7 @@ static void velocity_free_tx_buf(struct velocity_=
info *vptr, struct velocity_td_
 	/*
 	 *	Don't unmap the pre-allocated tx_bufs
 	 */
-	if (tdinfo->skb_dma && (tdinfo->skb_dma[0] !=3D tdinfo->buf_dma)) {
+	if (tdinfo->skb_dma) {
=20
 		for (i =3D 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
@@ -1898,6 +1862,8 @@ static int velocity_open(struct net_device *dev)
 	struct velocity_info *vptr =3D netdev_priv(dev);
 	int ret;
=20
+	velocity_set_rxbufsize(vptr, dev->mtu);
+
 	ret =3D velocity_init_rings(vptr);
 	if (ret < 0)
 		goto out;
@@ -1913,6 +1879,8 @@ static int velocity_open(struct net_device *dev)
 	/* Ensure chip is running */
 	pci_set_power_state(vptr->pdev, PCI_D0);
=20
+	velocity_give_many_rx_descs(vptr);
+
 	velocity_init_registers(vptr, VELOCITY_INIT_COLD);
=20
 	ret =3D request_irq(vptr->pdev->irq, &velocity_intr, IRQF_SHARED,
@@ -1977,6 +1945,8 @@ static int velocity_change_mtu(struct net_device =
*dev, int new_mtu)
=20
 		dev->mtu =3D new_mtu;
=20
+		velocity_set_rxbufsize(vptr, new_mtu);
+
 		ret =3D velocity_init_rd_ring(vptr);
 		if (ret < 0)
 			goto out_unlock;
@@ -2063,9 +2033,19 @@ static int velocity_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	struct tx_desc *td_ptr;
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
-	int index;
 	int pktlen =3D skb->len;
-	__le16 len =3D cpu_to_le16(pktlen);
+	__le16 len;
+	int index;
+
+
+
+	if (skb->len < ETH_ZLEN) {
+		if (skb_padto(skb, ETH_ZLEN))
+			goto out;
+		pktlen =3D ETH_ZLEN;
+	}
+
+	len =3D cpu_to_le16(pktlen);
=20
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
@@ -2083,23 +2063,6 @@ static int velocity_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	td_ptr->tdesc1.TCR =3D TCR0_TIC;
 	td_ptr->td_buf[0].size &=3D ~TD_QUEUE;
=20
-	/*
-	 *	Pad short frames.
-	 */
-	if (pktlen < ETH_ZLEN) {
-		/* Cannot occur until ZC support */
-		pktlen =3D ETH_ZLEN;
-		len =3D cpu_to_le16(ETH_ZLEN);
-		skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
-		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
-		tdinfo->skb =3D skb;
-		tdinfo->skb_dma[0] =3D tdinfo->buf_dma;
-		td_ptr->tdesc0.len =3D len;
-		td_ptr->td_buf[0].pa_low =3D cpu_to_le32(tdinfo->skb_dma[0]);
-		td_ptr->td_buf[0].pa_high =3D 0;
-		td_ptr->td_buf[0].size =3D len;	/* queue is 0 anyway */
-		tdinfo->nskb_dma =3D 1;
-	} else
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 0) {
 		int nfrags =3D skb_shinfo(skb)->nr_frags;
@@ -2191,7 +2154,8 @@ static int velocity_xmit(struct sk_buff *skb, str=
uct net_device *dev)
 	}
 	dev->trans_start =3D jiffies;
 	spin_unlock_irqrestore(&vptr->lock, flags);
-	return 0;
+out:
+	return NETDEV_TX_OK;
 }
=20
 /**
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 7387be4..8644614 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -236,10 +236,8 @@ struct velocity_rd_info {
=20
 struct velocity_td_info {
 	struct sk_buff *skb;
-	u8 *buf;
 	int nskb_dma;
 	dma_addr_t skb_dma[7];
-	dma_addr_t buf_dma;
 };
=20
 enum  velocity_owner {
@@ -1506,9 +1504,6 @@ struct velocity_info {
 	dma_addr_t rd_pool_dma;
 	dma_addr_t td_pool_dma[TX_QUEUE_NO];
=20
-	dma_addr_t tx_bufs_dma;
-	u8 *tx_bufs;
-
 	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
 	enum chip_type chip_id;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4452306..c28d7cb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -550,7 +550,8 @@ static struct virtio_device_id id_table[] =3D {
 };
=20
 static unsigned int features[] =3D {
-	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
+	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
+	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6=
,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
 };
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 203c550..b54ec16 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -828,6 +828,19 @@ static inline void netif_napi_add(struct net_devic=
e *dev,
 	set_bit(NAPI_STATE_SCHED, &napi->state);
 }
=20
+/**
+ *  netif_napi_del - remove a napi context
+ *  @napi: napi context
+ *
+ *  netif_napi_del() removes a napi context from the network device na=
pi list
+ */
+static inline void netif_napi_del(struct napi_struct *napi)
+{
+#ifdef CONFIG_NETPOLL
+	list_del(&napi->dev_list);
+#endif
+}
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
