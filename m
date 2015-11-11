From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: regression in ixgbe SFP detection patch
Date: Wed, 11 Nov 2015 20:33:13 +0000
Message-ID: <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
References: <20151111173527.GA3641@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: William Dauchy <william@gandi.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56599 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbbKKUdT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 15:33:19 -0500
In-Reply-To: <20151111173527.GA3641@gandi.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: William Dauchy [mailto:william@gandi.net]
>Sent: Wednesday, November 11, 2015 9:35 AM
>To: Kirsher, Jeffrey T; Tantilov, Emil S
>Cc: davem@davemloft.net; netdev@vger.kernel.org; Schmitt, Phillip J; intel-
>wired-lan@lists.osuosl.org
>Subject: regression in ixgbe SFP detection patch
>
>Hello,
>
>I upgraded a machine from 3.14.x to v4.1.x and noted that I now have two
>kworker very often on D state, just after boot while I am not doing
>anything special. This issue remains indefinitely.
>
>This machine has four network interfaces:
>
>
>01:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network
>Connection (rev 01)
>        Subsystem: Inventec Corporation Device 004a
>        Flags: bus master, fast devsel, latency 0, IRQ 17
>        Memory at fbce0000 (32-bit, non-prefetchable) [size=128K]
>        Memory at fbcc0000 (32-bit, non-prefetchable) [size=128K]
>        I/O ports at cc00 [size=32]
>        Memory at fbc9c000 (32-bit, non-prefetchable) [size=16K]
>        Expansion ROM at fbca0000 [disabled] [size=128K]
>        Capabilities: [40] Power Management version 3
>        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
>        Capabilities: [70] MSI-X: Enable+ Count=10 Masked-
>        Capabilities: [a0] Express Endpoint, MSI 00
>        Capabilities: [100] Advanced Error Reporting
>        Capabilities: [140] Device Serial Number 00-26-6c-ff-ff-ff-af-71
>        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
>        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
>        Kernel driver in use: igb
>
>01:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network
>Connection (rev 01)
>        Subsystem: Inventec Corporation Device 004a
>        Flags: bus master, fast devsel, latency 0, IRQ 16
>        Memory at fbc20000 (32-bit, non-prefetchable) [size=128K]
>        Memory at fbc00000 (32-bit, non-prefetchable) [size=128K]
>        I/O ports at c880 [size=32]
>        Memory at fbbdc000 (32-bit, non-prefetchable) [size=16K]
>        Expansion ROM at fbbe0000 [disabled] [size=128K]
>        Capabilities: [40] Power Management version 3
>        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
>        Capabilities: [70] MSI-X: Enable+ Count=10 Masked-
>        Capabilities: [a0] Express Endpoint, MSI 00
>        Capabilities: [100] Advanced Error Reporting
>        Capabilities: [140] Device Serial Number 00-26-6c-ff-ff-ff-af-71
>        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
>        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
>        Kernel driver in use: igb
>
>03:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+
>Network Connection (rev 01)
>        Subsystem: Inventec Corporation Device 004c
>        Flags: bus master, fast devsel, latency 0, IRQ 56
>        Memory at fbdc0000 (64-bit, non-prefetchable) [size=256K]
>        I/O ports at dc00 [size=32]
>        Memory at fbd9c000 (64-bit, non-prefetchable) [size=16K]
>        Expansion ROM at fbda0000 [disabled] [size=128K]
>        Capabilities: [40] Power Management version 3
>        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
>        Capabilities: [70] MSI-X: Enable+ Count=64 Masked-
>        Capabilities: [a0] Express Endpoint, MSI 00
>        Capabilities: [e0] Vital Product Data
>        Capabilities: [100] Advanced Error Reporting
>        Capabilities: [140] Device Serial Number 00-8c-fa-ff-ff-01-cf-c2
>        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
>        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
>        Kernel driver in use: ixgbe
>
>03:00.1 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+
>Network Connection (rev 01)
>        Subsystem: Inventec Corporation Device 004c
>        Flags: bus master, fast devsel, latency 0, IRQ 82
>        Memory at fbd40000 (64-bit, non-prefetchable) [size=256K]
>        I/O ports at d880 [size=32]
>        Memory at fbd1c000 (64-bit, non-prefetchable) [size=16K]
>        Expansion ROM at fbd20000 [disabled] [size=128K]
>        Capabilities: [40] Power Management version 3
>        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
>        Capabilities: [70] MSI-X: Enable+ Count=64 Masked-
>        Capabilities: [a0] Express Endpoint, MSI 00
>        Capabilities: [e0] Vital Product Data
>        Capabilities: [100] Advanced Error Reporting
>        Capabilities: [140] Device Serial Number 00-8c-fa-ff-ff-01-cf-c2
>        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
>        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
>        Kernel driver in use: ixgbe
>
>
>The two ixgbe interfaces are not used (UP but no-carrier):
>
>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group
>defa
>    link/ether 00:26:6c:ff:af:70 brd ff:ff:ff:ff:ff:ff
>    inet 10.5.5.58/24 brd 10.5.5.255 scope global eth0
>       valid_lft forever preferred_lft forever
>3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group
>defa
>    link/ether 00:26:6c:ff:af:71 brd ff:ff:ff:ff:ff:ff
>4: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN
>group
>    link/ether 00:8c:fa:01:cf:c2 brd ff:ff:ff:ff:ff:ff
>5: eth3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN
>group
>    link/ether 00:8c:fa:01:cf:c3 brd ff:ff:ff:ff:ff:ff
>
>
>if I turn them down (ip link set dev eth{2,3} down); the problem
>disappear, the two kworker in D disappear as well.
The kworkers are needed to detect the SFP+ modules when they are plugged in.

>Since I consider this as a regression because I only change the kernel
>version, I did a bisection in order to localize the issue.

It's a change and the below commit explains in good detail why it is needed.

>What I got at the end is: (bisected between v3.14.x and v4.1.x)
># first bad commit: [d9cd46cd391a132a43cbde7bdac12c16284b618f] ixgbe: fix
>detection of SFP+ capable interfaces
>
>After some tests, I reverted the only part present in ixgbe_main:
>
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>@@ -4786,8 +4786,6 @@
> 	case ixgbe_phy_qsfp_active_unknown:
> 	case ixgbe_phy_qsfp_intel:
> 	case ixgbe_phy_qsfp_unknown:
>-	/* ixgbe_phy_none is set when no SFP module is present */
>-	case ixgbe_phy_none:
> 		return true;
> 	case ixgbe_phy_nl:
> 		if (hw->mac.type == ixgbe_mac_82598EB)
>
>
>It also fixes my issue: even if eth{2,3} are still up with no carrier, I
>don't have any kworker in D state.

It appears that you have 2 ports with empty cages. If that is the case there 
is no reason to keep the interfaces up. If you bring them down, or plug the SFP+
modules the kworkers should stop.

>
>
>So, is it something we should consider as a regression, in that case I
>can send a formal patch, or do you need some more information to help
>you debug it?

If the diff above is the patch you are referring to then you will break the
SFP+ detection in the case where the driver was loaded while there were no
SFP+ modules present in the cages.

Thanks,
Emil

>
>Thanks,
>--
>William
