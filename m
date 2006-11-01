From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 18/18] e1000: update README for e1000
Date: Wed, 01 Nov 2006 09:52:10 -0800
Message-ID: <20061101175210.2356.23328.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:24848 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946982AbWKARqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:46:19 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 Documentation/networking/e1000.txt |  451 +++++++++++++++++++++-------=
--------
 1 files changed, 266 insertions(+), 185 deletions(-)

diff --git a/Documentation/networking/e1000.txt b/Documentation/network=
ing/e1000.txt
index 5c0a5cc..61b171c 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-November 15, 2005
+September 26, 2006
=20
=20
 Contents
@@ -9,6 +9,7 @@ Contents
=20
 - In This Release
 - Identifying Your Adapter
+- Building and Installation
 - Command Line Parameters
 - Speed and Duplex Configuration
 - Additional Configurations
@@ -41,6 +42,9 @@ or later), lspci, and ifconfig to obtain
 Instructions on updating ethtool can be found in the section "Addition=
al
 Configurations" later in this document.
=20
+NOTE: The Intel(R) 82562v 10/100 Network Connection only provides 10/1=
00
+support.
+
=20
 Identifying Your Adapter
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -51,28 +55,27 @@ Driver ID Guide at:
     http://support.intel.com/support/network/adapter/pro100/21397.htm
=20
 For the latest Intel network drivers for Linux, refer to the following
-website. In the search field, enter your adapter name or type, or use =
the
+website.  In the search field, enter your adapter name or type, or use=
 the
 networking link on the left to search for your adapter:
=20
     http://downloadfinder.intel.com/scripts-df/support_intel.asp
=20
=20
-Command Line Parameters =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
+Command Line Parameters
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 If the driver is built as a module, the  following optional parameters
-are used by entering them on the command line with the modprobe or ins=
mod
-command using this syntax:
+are used by entering them on the command line with the modprobe comman=
d
+using this syntax:
=20
      modprobe e1000 [<option>=3D<VAL1>,<VAL2>,...]
=20
-     insmod e1000 [<option>=3D<VAL1>,<VAL2>,...]
-
 For example, with two PRO/1000 PCI adapters, entering:
=20
-     insmod e1000 TxDescriptors=3D80,128
+     modprobe e1000 TxDescriptors=3D80,128
=20
-loads the e1000 driver with 80 TX descriptors for the first adapter an=
d 128
-TX descriptors for the second adapter.
+loads the e1000 driver with 80 TX descriptors for the first adapter an=
d
+128 TX descriptors for the second adapter.
=20
 The default value for each parameter is generally the recommended sett=
ing,
 unless otherwise noted.
@@ -87,7 +90,7 @@ NOTES:  For more information about the A
         http://www.intel.com/design/network/applnots/ap450.htm
=20
         A descriptor describes a data buffer and attributes related to
-        the data buffer. This information is accessed by the hardware.
+        the data buffer.  This information is accessed by the hardware=
=2E
=20
=20
 AutoNeg
@@ -96,9 +99,9 @@ AutoNeg
 Valid Range:   0x01-0x0F, 0x20-0x2F
 Default Value: 0x2F
=20
-This parameter is a bit mask that specifies which speed and duplex
-settings the board advertises. When this parameter is used, the Speed
-and Duplex parameters must not be specified.
+This parameter is a bit-mask that specifies the speed and duplex setti=
ngs
+advertised by the adapter.  When this parameter is used, the Speed and
+Duplex parameters must not be specified.
=20
 NOTE:  Refer to the Speed and Duplex section of this readme for more
        information on the AutoNeg parameter.
@@ -110,14 +113,15 @@ Duplex
 Valid Range:   0-2 (0=3Dauto-negotiate, 1=3Dhalf, 2=3Dfull)
 Default Value: 0
=20
-Defines the direction in which data is allowed to flow. Can be either
-one or two-directional. If both Duplex and the link partner are set to
-auto-negotiate, the board auto-detects the correct duplex. If the link
-partner is forced (either full or half), Duplex defaults to half-duple=
x.
+This defines the direction in which data is allowed to flow.  Can be
+either one or two-directional.  If both Duplex and the link partner ar=
e
+set to auto-negotiate, the board auto-detects the correct duplex.  If =
the
+link partner is forced (either full or half), Duplex defaults to half-
+duplex.
=20
=20
 FlowControl
-----------
+-----------
 Valid Range:   0-3 (0=3Dnone, 1=3DRx only, 2=3DTx only, 3=3DRx&Tx)
 Default Value: Reads flow control settings from the EEPROM
=20
@@ -127,57 +131,107 @@ to Ethernet PAUSE frames.
=20
 InterruptThrottleRate
 ---------------------
-(not supported on Intel 82542, 82543 or 82544-based adapters)
-Valid Range:   100-100000 (0=3Doff, 1=3Ddynamic)
-Default Value: 8000
-
-This value represents the maximum number of interrupts per second the
-controller generates. InterruptThrottleRate is another setting used in
-interrupt moderation. Dynamic mode uses a heuristic algorithm to adjus=
t
-InterruptThrottleRate based on the current traffic load.
+(not supported on Intel(R) 82542, 82543 or 82544-based adapters)
+Valid Range:   0,1,3,100-100000 (0=3Doff, 1=3Ddynamic, 3=3Ddynamic con=
servative)
+Default Value: 3
+
+The driver can limit the amount of interrupts per second that the adap=
ter
+will generate for incoming packets. It does this by writing a value to=
 the=20
+adapter that is based on the maximum amount of interrupts that the ada=
pter=20
+will generate per second.
+
+Setting InterruptThrottleRate to a value greater or equal to 100
+will program the adapter to send out a maximum of that many interrupts
+per second, even if more packets have come in. This reduces interrupt
+load on the system and can lower CPU utilization under heavy load,
+but will increase latency as packets are not processed as quickly.
+
+The default behaviour of the driver previously assumed a static=20
+InterruptThrottleRate value of 8000, providing a good fallback value f=
or=20
+all traffic types,but lacking in small packet performance and latency.=
=20
+The hardware can handle many more small packets per second however, an=
d=20
+for this reason an adaptive interrupt moderation algorithm was impleme=
nted.
+
+Since 7.3.x, the driver has two adaptive modes (setting 1 or 3) in whi=
ch
+it dynamically adjusts the InterruptThrottleRate value based on the tr=
affic=20
+that it receives. After determining the type of incoming traffic in th=
e last
+timeframe, it will adjust the InterruptThrottleRate to an appropriate =
value=20
+for that traffic.
+
+The algorithm classifies the incoming traffic every interval into
+classes.  Once the class is determined, the InterruptThrottleRate valu=
e is=20
+adjusted to suit that traffic type the best. There are three classes d=
efined:=20
+"Bulk traffic", for large amounts of packets of normal size; "Low late=
ncy",
+for small amounts of traffic and/or a significant percentage of small
+packets; and "Lowest latency", for almost completely small packets or=20
+minimal traffic.
+
+In dynamic conservative mode, the InterruptThrottleRate value is set t=
o 4000=20
+for traffic that falls in class "Bulk traffic". If traffic falls in th=
e "Low=20
+latency" or "Lowest latency" class, the InterruptThrottleRate is incre=
ased=20
+stepwise to 20000. This default mode is suitable for most applications=
=2E
+
+For situations where low latency is vital such as cluster or
+grid computing, the algorithm can reduce latency even more when
+InterruptThrottleRate is set to mode 1. In this mode, which operates
+the same as mode 3, the InterruptThrottleRate will be increased stepwi=
se to=20
+70000 for traffic in class "Lowest latency".
+
+Setting InterruptThrottleRate to 0 turns off any interrupt moderation
+and may improve small packet latency, but is generally not suitable
+for bulk throughput traffic.
=20
 NOTE:  InterruptThrottleRate takes precedence over the TxAbsIntDelay a=
nd
-       RxAbsIntDelay parameters. In other words, minimizing the receiv=
e
+       RxAbsIntDelay parameters.  In other words, minimizing the recei=
ve
        and/or transmit absolute delays does not force the controller t=
o
        generate more interrupts than what the Interrupt Throttle Rate
        allows.
=20
-CAUTION:  If you are using the Intel PRO/1000 CT Network Connection
+CAUTION:  If you are using the Intel(R) PRO/1000 CT Network Connection
           (controller 82547), setting InterruptThrottleRate to a value
           greater than 75,000, may hang (stop transmitting) adapters
-          under certain network conditions. If this occurs a NETDEV
-          WATCHDOG message is logged in the system event log. In
+          under certain network conditions.  If this occurs a NETDEV
+          WATCHDOG message is logged in the system event log.  In
           addition, the controller is automatically reset, restoring
-          the network connection. To eliminate the potential for the
+          the network connection.  To eliminate the potential for the
           hang, ensure that InterruptThrottleRate is set no greater
           than 75,000 and is not set to 0.
=20
 NOTE:  When e1000 is loaded with default settings and multiple adapter=
s
        are in use simultaneously, the CPU utilization may increase non=
-
-       linearly. In order to limit the CPU utilization without impacti=
ng
+       linearly.  In order to limit the CPU utilization without impact=
ing
        the overall throughput, we recommend that you load the driver a=
s
        follows:
=20
-           insmod e1000.o InterruptThrottleRate=3D3000,3000,3000
+           modprobe e1000 InterruptThrottleRate=3D3000,3000,3000
=20
        This sets the InterruptThrottleRate to 3000 interrupts/sec for
-       the first, second, and third instances of the driver. The range
+       the first, second, and third instances of the driver.  The rang=
e
        of 2000 to 3000 interrupts per second works on a majority of
        systems and is a good starting point, but the optimal value wil=
l
-       be platform-specific. If CPU utilization is not a concern, use
+       be platform-specific.  If CPU utilization is not a concern, use
        RX_POLLING (NAPI) and default driver settings.
=20
=20
+
 RxDescriptors
 -------------
 Valid Range:   80-256 for 82542 and 82543-based adapters
                80-4096 for all other supported adapters
 Default Value: 256
=20
-This value specifies the number of receive descriptors allocated by th=
e
-driver. Increasing this value allows the driver to buffer more incomin=
g
-packets.  Each descriptor is 16 bytes.  A receive buffer is also
-allocated for each descriptor and is 2048.
+This value specifies the number of receive buffer descriptors allocate=
d
+by the driver.  Increasing this value allows the driver to buffer more
+incoming packets, at the expense of increased system memory utilizatio=
n.
+
+Each descriptor is 16 bytes.  A receive buffer is also allocated for e=
ach
+descriptor and can be either 2048, 4096, 8192, or 16384 bytes, dependi=
ng=20
+on the MTU setting. The maximum MTU size is 16110.
+
+NOTE:  MTU designates the frame size.  It only needs to be set for Jum=
bo=20
+       Frames.  Depending on the available system resources, the reque=
st=20
+       for a higher number of receive descriptors may be denied.  In t=
his=20
+       case, use a lower number.
=20
=20
 RxIntDelay
@@ -187,17 +241,17 @@ Default Value: 0
=20
 This value delays the generation of receive interrupts in units of 1.0=
24
 microseconds.  Receive interrupt reduction can improve CPU efficiency =
if
-properly tuned for specific network traffic. Increasing this value add=
s
+properly tuned for specific network traffic.  Increasing this value ad=
ds
 extra latency to frame reception and can end up decreasing the through=
put
-of TCP traffic. If the system is reporting dropped receives, this valu=
e
+of TCP traffic.  If the system is reporting dropped receives, this val=
ue
 may be set too high, causing the driver to run out of available receiv=
e
 descriptors.
=20
 CAUTION:  When setting RxIntDelay to a value other than 0, adapters ma=
y
-          hang (stop transmitting) under certain network conditions. I=
f
+          hang (stop transmitting) under certain network conditions.  =
If
           this occurs a NETDEV WATCHDOG message is logged in the syste=
m
-          event log. In addition, the controller is automatically rese=
t,
-          restoring the network connection. To eliminate the potential
+          event log.  In addition, the controller is automatically res=
et,
+          restoring the network connection.  To eliminate the potentia=
l
           for the hang ensure that RxIntDelay is set to 0.
=20
=20
@@ -208,7 +262,7 @@ Valid Range:   0-65535 (0=3Doff)
 Default Value: 128
=20
 This value, in units of 1.024 microseconds, limits the delay in which =
a
-receive interrupt is generated. Useful only if RxIntDelay is non-zero,
+receive interrupt is generated.  Useful only if RxIntDelay is non-zero=
,
 this value ensures that an interrupt is generated after the initial
 packet is received within the set amount of time.  Proper tuning,
 along with RxIntDelay, may improve traffic throughput in specific netw=
ork
@@ -222,9 +276,9 @@ Valid Settings: 0, 10, 100, 1000
 Default Value:  0 (auto-negotiate at all supported speeds)
=20
 Speed forces the line speed to the specified value in megabits per sec=
ond
-(Mbps). If this parameter is not specified or is set to 0 and the link
+(Mbps).  If this parameter is not specified or is set to 0 and the lin=
k
 partner is set to auto-negotiate, the board will auto-detect the corre=
ct
-speed. Duplex should also be set when Speed is set to either 10 or 100=
=2E
+speed.  Duplex should also be set when Speed is set to either 10 or 10=
0.
=20
=20
 TxDescriptors
@@ -234,7 +288,7 @@ Valid Range:   80-256 for 82542 and 8254
 Default Value: 256
=20
 This value is the number of transmit descriptors allocated by the driv=
er.
-Increasing this value allows the driver to queue more transmits. Each
+Increasing this value allows the driver to queue more transmits.  Each
 descriptor is 16 bytes.
=20
 NOTE:  Depending on the available system resources, the request for a
@@ -248,8 +302,8 @@ Valid Range:   0-65535 (0=3Doff)
 Default Value: 64
=20
 This value delays the generation of transmit interrupts in units of
-1.024 microseconds. Transmit interrupt reduction can improve CPU
-efficiency if properly tuned for specific network traffic. If the
+1.024 microseconds.  Transmit interrupt reduction can improve CPU
+efficiency if properly tuned for specific network traffic.  If the
 system is reporting dropped transmits, this value may be set too high
 causing the driver to run out of available transmit descriptors.
=20
@@ -261,7 +315,7 @@ Valid Range:   0-65535 (0=3Doff)
 Default Value: 64
=20
 This value, in units of 1.024 microseconds, limits the delay in which =
a
-transmit interrupt is generated. Useful only if TxIntDelay is non-zero=
,
+transmit interrupt is generated.  Useful only if TxIntDelay is non-zer=
o,
 this value ensures that an interrupt is generated after the initial
 packet is sent on the wire within the set amount of time.  Proper tuni=
ng,
 along with TxIntDelay, may improve traffic throughput in specific
@@ -288,15 +342,15 @@ fiber interface board only links at 1000
=20
 For copper-based boards, the keywords interact as follows:
=20
-  The default operation is auto-negotiate. The board advertises all
+  The default operation is auto-negotiate.  The board advertises all
   supported speed and duplex combinations, and it links at the highest
   common speed and duplex mode IF the link partner is set to auto-nego=
tiate.
=20
   If Speed =3D 1000, limited auto-negotiation is enabled and only 1000=
 Mbps
   is advertised (The 1000BaseT spec requires auto-negotiation.)
=20
-  If Speed =3D 10 or 100, then both Speed and Duplex should be set. Au=
to-
-  negotiation is disabled, and the AutoNeg parameter is ignored. Partn=
er
+  If Speed =3D 10 or 100, then both Speed and Duplex should be set.  A=
uto-
+  negotiation is disabled, and the AutoNeg parameter is ignored.  Part=
ner
   SHOULD also be forced.
=20
 The AutoNeg parameter is used when more control is required over the
@@ -304,7 +358,7 @@ auto-negotiation process.  It should be=20
 speed and duplex combinations are advertised during the auto-negotiati=
on
 process.
=20
-The parameter may be specified as either a decimal or hexidecimal valu=
e as
+The parameter may be specified as either a decimal or hexadecimal valu=
e as
 determined by the bitmap below.
=20
 Bit position   7      6      5       4       3      2      1       0
@@ -337,20 +391,19 @@ Additional Configurations
=20
   Configuring the Driver on Different Distributions
   -------------------------------------------------
-
   Configuring a network driver to load properly when the system is sta=
rted
-  is distribution dependent. Typically, the configuration process invo=
lves
+  is distribution dependent.  Typically, the configuration process inv=
olves
   adding an alias line to /etc/modules.conf or /etc/modprobe.conf as w=
ell
-  as editing other system startup scripts and/or configuration files. =
Many
+  as editing other system startup scripts and/or configuration files. =
 Many
   popular Linux distributions ship with tools to make these changes fo=
r you.
   To learn the proper way to configure a network device for your syste=
m,
-  refer to your distribution documentation. If during this process you=
 are
+  refer to your distribution documentation.  If during this process yo=
u are
   asked for the driver or module name, the name for the Linux Base Dri=
ver
-  for the Intel PRO/1000 Family of Adapters is e1000.
+  for the Intel(R) PRO/1000 Family of Adapters is e1000.
=20
   As an example, if you install the e1000 driver for two PRO/1000 adap=
ters
   (eth0 and eth1) and set the speed and duplex to 10full and 100half, =
add
-  the following to modules.conf or modprobe.conf:
+  the following to modules.conf or or modprobe.conf:
=20
        alias eth0 e1000
        alias eth1 e1000
@@ -358,9 +411,8 @@ Additional Configurations
=20
   Viewing Link Messages
   ---------------------
-
   Link messages will not be displayed to the console if the distributi=
on is
-  restricting system messages. In order to see network driver link mes=
sages
+  restricting system messages.  In order to see network driver link me=
ssages
   on your console, set dmesg to eight by entering the following:
=20
        dmesg -n 8
@@ -369,11 +421,9 @@ Additional Configurations
=20
   Jumbo Frames
   ------------
-
-  The driver supports Jumbo Frames for all adapters except 82542 and
-  82573-based adapters. Jumbo Frames support is enabled by changing th=
e
-  MTU to a value larger than the default of 1500. Use the ifconfig com=
mand
-  to increase the MTU size. For example:
+  Jumbo Frames support is enabled by changing the MTU to a value large=
r than
+  the default of 1500.  Use the ifconfig command to increase the MTU s=
ize.
+  For example:
=20
        ifconfig eth<x> mtu 9000 up
=20
@@ -390,26 +440,49 @@ Additional Configurations
=20
   - To enable Jumbo Frames, increase the MTU size on the interface bey=
ond
     1500.
-  - The maximum MTU setting for Jumbo Frames is 16110. This value coin=
cides
+
+  - The maximum MTU setting for Jumbo Frames is 16110.  This value coi=
ncides
     with the maximum Jumbo Frames size of 16128.
+
   - Using Jumbo Frames at 10 or 100 Mbps may result in poor performanc=
e or
     loss of link.
+
   - Some Intel gigabit adapters that support Jumbo Frames have a frame=
 size
     limit of 9238 bytes, with a corresponding MTU size limit of 9216 b=
ytes.
-    The adapters with this limitation are based on the Intel 82571EB a=
nd
-    82572EI controllers, which correspond to these product names:
-     Intel=AE PRO/1000 PT Dual Port Server Adapter
-     Intel=AE PRO/1000 PF Dual Port Server Adapter
-     Intel=AE PRO/1000 PT Server Adapter
-     Intel=AE PRO/1000 PT Desktop Adapter
-     Intel=AE PRO/1000 PF Server Adapter
-
-  - The Intel PRO/1000 PM Network Connection does not support jumbo fr=
ames.
+    The adapters with this limitation are based on the Intel(R) 82571E=
B,
+    82572EI, 82573L and 80003ES2LAN controller.  These correspond to t=
he
+    following product names:
+     Intel(R) PRO/1000 PT Server Adapter
+     Intel(R) PRO/1000 PT Desktop Adapter
+     Intel(R) PRO/1000 PT Network Connection
+     Intel(R) PRO/1000 PT Dual Port Server Adapter
+     Intel(R) PRO/1000 PT Dual Port Network Connection
+     Intel(R) PRO/1000 PF Server Adapter
+     Intel(R) PRO/1000 PF Network Connection
+     Intel(R) PRO/1000 PF Dual Port Server Adapter
+     Intel(R) PRO/1000 PB Server Connection
+     Intel(R) PRO/1000 PL Network Connection
+     Intel(R) PRO/1000 EB Network Connection with I/O Acceleration
+     Intel(R) PRO/1000 EB Backplane Connection with I/O Acceleration
+     Intel(R) PRO/1000 PT Quad Port Server Adapter
+
+  - Adapters based on the Intel(R) 82542 and 82573V/E controller do no=
t
+    support Jumbo Frames. These correspond to the following product na=
mes:
+     Intel(R) PRO/1000 Gigabit Server Adapter
+     Intel(R) PRO/1000 PM Network Connection
+
+  - The following adapters do not support Jumbo Frames:
+     Intel(R) 82562V 10/100 Network Connection
+     Intel(R) 82566DM Gigabit Network Connection
+     Intel(R) 82566DC Gigabit Network Connection
+     Intel(R) 82566MM Gigabit Network Connection
+     Intel(R) 82566MC Gigabit Network Connection
+     Intel(R) 82562GT 10/100 Network Connection
+     Intel(R) 82562G 10/100 Network Connection
=20
=20
   Ethtool
   -------
-
   The driver utilizes the ethtool interface for driver configuration a=
nd
   diagnostics, as well as displaying statistical information.  Ethtool
   version 1.6 or later is required for this functionality.
@@ -417,15 +490,14 @@ Additional Configurations
   The latest release of ethtool can be found from
   http://sourceforge.net/projects/gkernel.
=20
-  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Su=
pport
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options.  S=
upport
   for a more complete ethtool feature set can be enabled by upgrading
   ethtool to ethtool-1.8.1.
=20
   Enabling Wake on LAN* (WoL)
   ---------------------------
-
-  WoL is configured through the Ethtool* utility. Ethtool is included =
with
-  all versions of Red Hat after Red Hat 7.2. For other Linux distribut=
ions,
+  WoL is configured through the Ethtool* utility.  Ethtool is included=
 with
+  all versions of Red Hat after Red Hat 7.2.  For other Linux distribu=
tions,
   download and install Ethtool from the following website:
   http://sourceforge.net/projects/gkernel.
=20
@@ -436,11 +508,17 @@ Additional Configurations
   For this driver version, in order to enable WoL, the e1000 driver mu=
st be
   loaded when shutting down or rebooting the system.
=20
+  Wake On LAN is only supported on port A for the following devices:
+  Intel(R) PRO/1000 PT Dual Port Network Connection
+  Intel(R) PRO/1000 PT Dual Port Server Connection
+  Intel(R) PRO/1000 PT Dual Port Server Adapter
+  Intel(R) PRO/1000 PF Dual Port Server Adapter
+  Intel(R) PRO/1000 PT Quad Port Server Adapter=20
+
   NAPI
   ----
-
-  NAPI (Rx polling mode) is supported in the e1000 driver. NAPI is ena=
bled
-  or disabled based on the configuration of the kernel. To override
+  NAPI (Rx polling mode) is supported in the e1000 driver.  NAPI is en=
abled
+  or disabled based on the configuration of the kernel.  To override
   the default, use the following compile-time flags.
=20
   To enable NAPI, compile the driver module, passing in a configuratio=
n option:
@@ -457,88 +535,105 @@ Additional Configurations
 Known Issues
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-  Jumbo Frames System Requirement
-  -------------------------------
-
-  Memory allocation failures have been observed on Linux systems with =
64 MB
-  of RAM or less that are running Jumbo Frames. If you are using Jumbo
-  Frames, your system may require more than the advertised minimum
-  requirement of 64 MB of system memory.
-
-  Performance Degradation with Jumbo Frames
-  -----------------------------------------
-
-  Degradation in throughput performance may be observed in some Jumbo =
frames
-  environments. If this is observed, increasing the application's sock=
et
-  buffer size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry =
values
-  may help. See the specific application manual and
-  /usr/src/linux*/Documentation/
-  networking/ip-sysctl.txt for more details.
-
-  Jumbo frames on Foundry BigIron 8000 switch
-  -------------------------------------------
-  There is a known issue using Jumbo frames when connected to a Foundr=
y
-  BigIron 8000 switch. This is a 3rd party limitation. If you experien=
ce
-  loss of packets, lower the MTU size.
-
-  Multiple Interfaces on Same Ethernet Broadcast Network
-  ------------------------------------------------------
-
-  Due to the default ARP behavior on Linux, it is not possible to have
-  one system on two IP networks in the same Ethernet broadcast domain
-  (non-partitioned switch) behave as expected. All Ethernet interfaces
-  will respond to IP traffic for any IP address assigned to the system=
=2E
-  This results in unbalanced receive traffic.
-
-  If you have multiple interfaces in a server, either turn on ARP
-  filtering by entering:
-
-      echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
-  (this only works if your kernel's version is higher than 2.4.5),
-
-  NOTE: This setting is not saved across reboots. The configuration
-  change can be made permanent by adding the line:
-      net.ipv4.conf.all.arp_filter =3D 1
-  to the file /etc/sysctl.conf
-
-        or,
-
-  install the interfaces in separate broadcast domains (either in
-  different switches or in a switch partitioned to VLANs).
-
-  82541/82547 can't link or are slow to link with some link partners
-  -----------------------------------------------------------------
-
-  There is a known compatibility issue with 82541/82547 and some
-  low-end switches where the link will not be established, or will
-  be slow to establish.  In particular, these switches are known to
-  be incompatible with 82541/82547:
-
-      Planex FXG-08TE
-      I-O Data ETG-SH8
-
-  To workaround this issue, the driver can be compiled with an overrid=
e
-  of the PHY's master/slave setting.  Forcing master or forcing slave
-  mode will improve time-to-link.
-
-      # make EXTRA_CFLAGS=3D-DE1000_MASTER_SLAVE=3D<n>
-
-  Where <n> is:
-
-      0 =3D Hardware default
-      1 =3D Master mode
-      2 =3D Slave mode
-      3 =3D Auto master/slave
-
-  Disable rx flow control with ethtool
-  ------------------------------------
-
-  In order to disable receive flow control using ethtool, you must tur=
n
-  off auto-negotiation on the same command line.
-
-  For example:
-
-     ethtool -A eth? autoneg off rx off
+Dropped Receive Packets on Half-duplex 10/100 Networks
+------------------------------------------------------
+If you have an Intel PCI Express adapter running at 10mbps or 100mbps,=
 half-
+duplex, you may observe occasional dropped receive packets.  There are=
 no
+workarounds for this problem in this network configuration.  The netwo=
rk must
+be updated to operate in full-duplex, and/or 1000mbps only.
+
+Jumbo Frames System Requirement
+-------------------------------
+Memory allocation failures have been observed on Linux systems with 64=
 MB
+of RAM or less that are running Jumbo Frames.  If you are using Jumbo
+Frames, your system may require more than the advertised minimum
+requirement of 64 MB of system memory.
+
+Performance Degradation with Jumbo Frames
+-----------------------------------------
+Degradation in throughput performance may be observed in some Jumbo fr=
ames
+environments.  If this is observed, increasing the application's socke=
t
+buffer size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry va=
lues
+may help.  See the specific application manual and
+/usr/src/linux*/Documentation/
+networking/ip-sysctl.txt for more details.
+
+Jumbo Frames on Foundry BigIron 8000 switch
+-------------------------------------------
+There is a known issue using Jumbo frames when connected to a Foundry
+BigIron 8000 switch.  This is a 3rd party limitation.  If you experien=
ce
+loss of packets, lower the MTU size.
+
+Allocating Rx Buffers when Using Jumbo Frames=20
+---------------------------------------------
+Allocating Rx buffers when using Jumbo Frames on 2.6.x kernels may fai=
l if=20
+the available memory is heavily fragmented. This issue may be seen wit=
h PCI-X=20
+adapters or with packet split disabled. This can be reduced or elimina=
ted=20
+by changing the amount of available memory for receive buffer allocati=
on, by
+increasing /proc/sys/vm/min_free_kbytes.=20
+
+Multiple Interfaces on Same Ethernet Broadcast Network
+------------------------------------------------------
+Due to the default ARP behavior on Linux, it is not possible to have
+one system on two IP networks in the same Ethernet broadcast domain
+(non-partitioned switch) behave as expected.  All Ethernet interfaces
+will respond to IP traffic for any IP address assigned to the system.
+This results in unbalanced receive traffic.
+
+If you have multiple interfaces in a server, either turn on ARP
+filtering by entering:
+
+    echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
+(this only works if your kernel's version is higher than 2.4.5),
+
+NOTE: This setting is not saved across reboots.  The configuration
+change can be made permanent by adding the line:
+    net.ipv4.conf.all.arp_filter =3D 1
+to the file /etc/sysctl.conf
+
+      or,
+
+install the interfaces in separate broadcast domains (either in
+different switches or in a switch partitioned to VLANs).
+
+82541/82547 can't link or are slow to link with some link partners
+-----------------------------------------------------------------
+There is a known compatibility issue with 82541/82547 and some
+low-end switches where the link will not be established, or will
+be slow to establish.  In particular, these switches are known to
+be incompatible with 82541/82547:
+
+    Planex FXG-08TE
+    I-O Data ETG-SH8
+
+To workaround this issue, the driver can be compiled with an override
+of the PHY's master/slave setting.  Forcing master or forcing slave
+mode will improve time-to-link.
+
+    # make CFLAGS_EXTRA=3D-DE1000_MASTER_SLAVE=3D<n>
+
+Where <n> is:
+
+    0 =3D Hardware default
+    1 =3D Master mode
+    2 =3D Slave mode
+    3 =3D Auto master/slave
+
+Disable rx flow control with ethtool
+------------------------------------
+In order to disable receive flow control using ethtool, you must turn
+off auto-negotiation on the same command line.
+
+For example:
+
+   ethtool -A eth? autoneg off rx off
+
+Unplugging network cable while ethtool -p is running
+----------------------------------------------------
+In kernel versions 2.5.50 and later (including 2.6 kernel), unplugging
+the network cable while ethtool -p is running will cause the system to
+become unresponsive to keyboard commands, except for control-alt-delet=
e.
+Restarting the system appears to be the only remedy.
=20
=20
 Support
@@ -548,24 +643,10 @@ For general information, go to the Intel
=20
     http://support.intel.com
=20
-    or the Intel Wired Networking project hosted by Sourceforge at:
+or the Intel Wired Networking project hosted by Sourceforge at:
=20
     http://sourceforge.net/projects/e1000
=20
 If an issue is identified with the released source code on the support=
ed
 kernel with a supported adapter, email the specific information relate=
d
-to the issue to e1000-devel@lists.sourceforge.net
-
-
-License
-=3D=3D=3D=3D=3D=3D=3D
-
-This software program is released under the terms of a license agreeme=
nt
-between you ('Licensee') and Intel. Do not use or load this software o=
r any
-associated materials (collectively, the 'Software') until you have car=
efully
-read the full terms and conditions of the file COPYING located in this=
 software
-package. By loading or using the Software, you agree to the terms of t=
his
-Agreement. If you do not agree with the terms of this Agreement, do no=
t
-install or use the Software.
-
-* Other names and brands may be claimed as the property of others.
+to the issue to e1000-devel@lists.sf.net



---
Auke Kok <auke-jan.h.kok@intel.com>
