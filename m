From: "Graham, David" <david.graham@intel.com>
Subject: RE: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro X7DB3
Date: Wed, 8 Oct 2008 08:25:49 -0700
Message-ID: <E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F498F4EDC@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Hockert, Jeff W" <jeff.w.hockert@intel.com>,
	"Graham, David" <david.graham@intel.com>
To: "Hillier, Gernot "
	<IMCEAMAILTO-gernot+2Ehillier+40siemens+2Ecom@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754769AbYJHP0R@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gernot,

Thanks for reporting this issue. We have witnessed this in our labs too,
only on platforms that have BMC management firmware. I'm very familiar
with the problem, and believe that we have fixed it, though the
application of the fix may not be simple. The problem is a result of
improper synchronization between the platform FW and the e1000e driver
when they attempt concurrent access to LAN resources, and fixes were
made both on the driver side, and on the FW side. On some platforms a
simple driver update resolves the problem, others require FW fixes too.

The 0.2.0 driver in 2.6.25 has no fixes for this problem, and so I am
not surprised that you see it there. The first set of changes for this
issue are already in the 0.3.3.3-k2 driver that you are still seeing the
problem with on 2.6.26, so either those changes are not good, or your
issue requires one of the additional fixes.

There have been further improvements made to the driver synchronization
code since the 0.3.3.3-k2 driver, and it is possible that a newer driver
would resolve the issue. It'd be good for us to know if that's the case.
The driver version is not yet (AFAICS) upstream, but is already
available in the standalone e1000e-0.4.1.7 driver on sourceforge.
(google "sourceforge e1000e"). Would you be able to try that, as a first
step ? 

If this does not resolve the issue for the Supermicro board, you likely
also require a "FW-side" fix, and this comes in one of two flavors. If
the board has an INTEL BMC, then we will need to update it with a new
BMC version. If the board has a Supermicro BMC (I expect that it does),
then we can provide a patch to some of the platform microcode using a
EEPROM update.  To determine which is appropriate for you, we'll need to
know more about the platform. There's probably a BMC version number on
one of the BIOS menus. I can work with you to find the info we need, and
then, to help you to perform the necessary steps to perform an upgrade. 

Dave



Dave-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Hillier, Gernot
Sent: Tuesday, October 07, 2008 7:26 AM
To: Brandeburg, Jesse
Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Allan, Bruce W
Subject: e1000e: sporadic "hardware error"s with Intel 82563EB on
Supermicro X7DB3

Hi there,

On at least two machines using the Supermicro X7DB3 board with Intel
82563EB (a.k.a. PCI device 8086:1096), we see sporadic problems on
modprobe
(about 1 time in some hundred tries):

e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
e1000e 0000:06:00.0: setting latency timer to 64
0000:06:00.0: 0000:06:00.0: Hardware Error
0000:06:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:30:48:67:f5:f6
0000:06:00.0: eth0: Intel(R) PRO/1000 Network Connection
0000:06:00.0: eth0: MAC: 3, PHY: 5, PBA No: 2050ff-0ff
e1000e 0000:06:00.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
e1000e 0000:06:00.1: setting latency timer to 64
0000:06:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:30:48:67:f5:f7
0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection
0000:06:00.1: eth1: MAC: 3, PHY: 5, PBA No: 2050ff-0ff
0000:06:00.0: eth0: Hardware Error

eth0 is not available after module loading. During boot, this means the
machine won't come up correctly. Problem can be "fixed" by removing and
reloading the module.

This happens on the rather old SUSE-patched 2.6.25.11 with e1000e 0.2.0
as
well as with vanilla 2.6.27-rc8 including e1000e 0.3.3.3-k2.

The machines are equipped with two Quad-Core Xeons E5440 and 8GB of RAM.
Both kernels are compiled for x86_64.

Supermicro claims that there's no known hardware problem with these
boards
and that the Windows driver doesn't show any issue...

Is there anything I can do to help narrowing down the problem? Anything
I
can test? Any help greatly appreciated...

TIA!

--
Gernot Hillier
Siemens AG, CT SE 2, Corporate Competence Center Embedded Linux
