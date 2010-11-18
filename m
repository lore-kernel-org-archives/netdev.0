From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: extended netdevice naming proposal
Date: Thu, 18 Nov 2010 12:51:25 -0600
Message-ID: <20101118185125.GA4952@auslistsprd01.us.dell.com>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com> <20101118021039.GA18707@nostromo.devel.redhat.com> <1290047397.3818.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Nottingham <notting@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com, jcm@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290047397.3818.3.camel@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2010 at 02:29:57AM +0000, Ben Hutchings wrote:
> On Wed, 2010-11-17 at 21:10 -0500, Bill Nottingham wrote:
> > Matt Domsch (Matt_Domsch@dell.com) said: 
> > > (location)(slot)#(port)/(instance).(vlan)
> > 
> > AIUI, the kernel explicitly rejects '/' in the name (for fairly obvious
> > sysfs reasons.) So you'd at least need a different delimiter. There may
> > also be potential confusion with pci01#03:02.0001 with someone thinking
> > that's bus/dev/fn, if we're being really petty.
> 
> ':' is also reserved for alias interfaces, the old way of assigning
> multiple IP addresses.
> 
> I would say '-' is a good separator, but that might result in ambiguity
> in IRQ names.

How about underscore to separate VFs? 
(location)(slot)#(port)_(instance).(vlan)

And 'em' as prefix for embedded?

See below this implementation in biosdevname now.  This is a system
with 4 onboard NICs, plus an add-in dual-port Intel Niantic card in
PCI slot 2.  It exposes 63 VFs per port (max_vfs=63).  Here see the
devices get named

onboard: emX
add-in card: pci2#0, pci2#1
VFs there: pci2#0_0, pci2#1_62

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO

BIOS device: em1
Kernel name: lom1
Permanant MAC: 00:22:19:59:8E:56
Assigned MAC : 00:22:19:59:8E:56
Driver: bnx2
Driver version: 2.0.18
Firmware version: bc 5.0.11 NCSI 2.0.5
Bus Info: 0000:01:00.0
PCI name      : 0000:01:00.0
PCI Slot      : embedded
SMBIOS Device Type: Ethernet
SMBIOS Instance: 1
SMBIOS Enabled: True
SMBIOS Label: Embedded NIC 1
sysfs Index: 1
sysfs Label: Embedded NIC 1                          
Index in slot: 0

BIOS device: em2
Kernel name: lom2
Permanant MAC: 00:22:19:59:8E:58
Assigned MAC : 00:22:19:59:8E:58
Driver: bnx2
Driver version: 2.0.18
Firmware version: bc 5.0.11 NCSI 2.0.5
Bus Info: 0000:01:00.1
PCI name      : 0000:01:00.1
PCI Slot      : embedded
SMBIOS Device Type: Ethernet
SMBIOS Instance: 2
SMBIOS Enabled: True
SMBIOS Label: Embedded NIC 2
sysfs Index: 2
sysfs Label: Embedded NIC 2                          
Index in slot: 1

BIOS device: em3
Kernel name: lom3
Permanant MAC: 00:22:19:59:8E:5A
Assigned MAC : 00:22:19:59:8E:5A
Driver: bnx2
Driver version: 2.0.18
Firmware version: bc 5.0.11 NCSI 2.0.5
Bus Info: 0000:02:00.0
PCI name      : 0000:02:00.0
PCI Slot      : embedded
SMBIOS Device Type: Ethernet
SMBIOS Instance: 3
SMBIOS Enabled: True
SMBIOS Label: Embedded NIC 3
sysfs Index: 3
sysfs Label: Embedded NIC 3                          
Index in slot: 2

BIOS device: em4
Kernel name: lom4
Permanant MAC: 00:22:19:59:8E:5C
Assigned MAC : 00:22:19:59:8E:5C
Driver: bnx2
Driver version: 2.0.18
Firmware version: bc 5.0.11 NCSI 2.0.5
Bus Info: 0000:02:00.1
PCI name      : 0000:02:00.1
PCI Slot      : embedded
SMBIOS Device Type: Ethernet
SMBIOS Instance: 4
SMBIOS Enabled: True
SMBIOS Label: Embedded NIC 4
sysfs Index: 4
sysfs Label: Embedded NIC 4                          
Index in slot: 3

BIOS device: pci2#0
Kernel name: eth63-eth4
Permanant MAC: 00:1B:21:42:66:30
Assigned MAC : 00:1B:21:42:66:30
Driver: ixgbe
Driver version: 2.0.84-k2
Firmware version: 0.9-3
Bus Info: 0000:05:00.0
PCI name      : 0000:05:00.0
PCI Slot      : 2
SMBIOS Label: PCI2
Index in slot: 0
Virtual Functions:
0000:05:10.0
0000:05:10.2
0000:05:10.4
0000:05:10.6
0000:05:11.0
0000:05:11.2
0000:05:11.4
0000:05:11.6
0000:05:12.0
0000:05:12.2
0000:05:12.4
0000:05:12.6
0000:05:13.0
0000:05:13.2
0000:05:13.4
0000:05:13.6
0000:05:14.0
0000:05:14.2
0000:05:14.4
0000:05:14.6
0000:05:15.0
0000:05:15.2
0000:05:15.4
0000:05:15.6
0000:05:16.0
0000:05:16.2
0000:05:16.4
0000:05:16.6
0000:05:17.0
0000:05:17.2
0000:05:17.4
0000:05:17.6
0000:05:18.0
0000:05:18.2
0000:05:18.4
0000:05:18.6
0000:05:19.0
0000:05:19.2
0000:05:19.4
0000:05:19.6
0000:05:1a.0
0000:05:1a.2
0000:05:1a.4
0000:05:1a.6
0000:05:1b.0
0000:05:1b.2
0000:05:1b.4
0000:05:1b.6
0000:05:1c.0
0000:05:1c.2
0000:05:1c.4
0000:05:1c.6
0000:05:1d.0
0000:05:1d.2
0000:05:1d.4
0000:05:1d.6
0000:05:1e.0
0000:05:1e.2
0000:05:1e.4
0000:05:1e.6
0000:05:1f.0
0000:05:1f.2
0000:05:1f.4

BIOS device: pci2#1
Kernel name: eth127-eth5
Permanant MAC: 00:1B:21:42:66:31
Assigned MAC : 00:1B:21:42:66:31
Driver: ixgbe
Driver version: 2.0.84-k2
Firmware version: 0.9-3
Bus Info: 0000:05:00.1
PCI name      : 0000:05:00.1
PCI Slot      : 2
Index in slot: 1
Virtual Functions:
0000:05:10.1
0000:05:10.3
0000:05:10.5
0000:05:10.7
0000:05:11.1
0000:05:11.3
0000:05:11.5
0000:05:11.7
0000:05:12.1
0000:05:12.3
0000:05:12.5
0000:05:12.7
0000:05:13.1
0000:05:13.3
0000:05:13.5
0000:05:13.7
0000:05:14.1
0000:05:14.3
0000:05:14.5
0000:05:14.7
0000:05:15.1
0000:05:15.3
0000:05:15.5
0000:05:15.7
0000:05:16.1
0000:05:16.3
0000:05:16.5
0000:05:16.7
0000:05:17.1
0000:05:17.3
0000:05:17.5
0000:05:17.7
0000:05:18.1
0000:05:18.3
0000:05:18.5
0000:05:18.7
0000:05:19.1
0000:05:19.3
0000:05:19.5
0000:05:19.7
0000:05:1a.1
0000:05:1a.3
0000:05:1a.5
0000:05:1a.7
0000:05:1b.1
0000:05:1b.3
0000:05:1b.5
0000:05:1b.7
0000:05:1c.1
0000:05:1c.3
0000:05:1c.5
0000:05:1c.7
0000:05:1d.1
0000:05:1d.3
0000:05:1d.5
0000:05:1d.7
0000:05:1e.1
0000:05:1e.3
0000:05:1e.5
0000:05:1e.7
0000:05:1f.1
0000:05:1f.3
0000:05:1f.5

BIOS device: pci2#0_0
Kernel name: eth0
Permanant MAC: 82:CB:F4:96:48:54
Assigned MAC : 82:CB:F4:96:48:54
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.0
PCI name      : 0000:05:10.0
PCI Slot      : 2
Index in slot: 2

BIOS device: pci2#1_0
Kernel name: eth64
Permanant MAC: 1E:F9:6D:E6:49:2A
Assigned MAC : 1E:F9:6D:E6:49:2A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.1
PCI name      : 0000:05:10.1
PCI Slot      : 2
Index in slot: 3

BIOS device: pci2#0_1
Kernel name: eth1
Permanant MAC: F2:54:AF:2F:03:2B
Assigned MAC : F2:54:AF:2F:03:2B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.2
PCI name      : 0000:05:10.2
PCI Slot      : 2
Index in slot: 4

BIOS device: pci2#1_1
Kernel name: eth65
Permanant MAC: CE:C9:30:B1:77:80
Assigned MAC : CE:C9:30:B1:77:80
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.3
PCI name      : 0000:05:10.3
PCI Slot      : 2
Index in slot: 5

BIOS device: pci2#0_2
Kernel name: eth2
Permanant MAC: D2:D9:37:E5:9C:2B
Assigned MAC : D2:D9:37:E5:9C:2B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.4
PCI name      : 0000:05:10.4
PCI Slot      : 2
Index in slot: 6

BIOS device: pci2#1_2
Kernel name: eth66
Permanant MAC: 8E:2B:51:24:D5:DC
Assigned MAC : 8E:2B:51:24:D5:DC
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.5
PCI name      : 0000:05:10.5
PCI Slot      : 2
Index in slot: 7

BIOS device: pci2#0_3
Kernel name: eth3
Permanant MAC: E2:F6:5F:A1:29:0E
Assigned MAC : E2:F6:5F:A1:29:0E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.6
PCI name      : 0000:05:10.6
PCI Slot      : 2
Index in slot: 8

BIOS device: pci2#1_3
Kernel name: eth67
Permanant MAC: 8A:15:38:A9:69:5D
Assigned MAC : 8A:15:38:A9:69:5D
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:10.7
PCI name      : 0000:05:10.7
PCI Slot      : 2
Index in slot: 9

BIOS device: pci2#0_4
Kernel name: eth4
Permanant MAC: 4A:D3:97:44:5C:57
Assigned MAC : 4A:D3:97:44:5C:57
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.0
PCI name      : 0000:05:11.0
PCI Slot      : 2
Index in slot: 10

BIOS device: pci2#1_4
Kernel name: eth68
Permanant MAC: 46:4A:E0:1B:C3:5E
Assigned MAC : 46:4A:E0:1B:C3:5E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.1
PCI name      : 0000:05:11.1
PCI Slot      : 2
Index in slot: 11

BIOS device: pci2#0_5
Kernel name: eth5
Permanant MAC: CE:AF:3A:41:EC:3A
Assigned MAC : CE:AF:3A:41:EC:3A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.2
PCI name      : 0000:05:11.2
PCI Slot      : 2
Index in slot: 12

BIOS device: pci2#1_5
Kernel name: eth69
Permanant MAC: 5E:47:92:64:09:B3
Assigned MAC : 5E:47:92:64:09:B3
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.3
PCI name      : 0000:05:11.3
PCI Slot      : 2
Index in slot: 13

BIOS device: pci2#0_6
Kernel name: eth6
Permanant MAC: 6E:71:3B:A3:4C:15
Assigned MAC : 6E:71:3B:A3:4C:15
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.4
PCI name      : 0000:05:11.4
PCI Slot      : 2
Index in slot: 14

BIOS device: pci2#1_6
Kernel name: eth70
Permanant MAC: B2:92:86:3A:FD:D0
Assigned MAC : B2:92:86:3A:FD:D0
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.5
PCI name      : 0000:05:11.5
PCI Slot      : 2
Index in slot: 15

BIOS device: pci2#0_7
Kernel name: eth7
Permanant MAC: 8A:57:06:78:91:7E
Assigned MAC : 8A:57:06:78:91:7E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.6
PCI name      : 0000:05:11.6
PCI Slot      : 2
Index in slot: 16

BIOS device: pci2#1_7
Kernel name: eth71
Permanant MAC: FE:CC:6E:C4:E0:7F
Assigned MAC : FE:CC:6E:C4:E0:7F
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:11.7
PCI name      : 0000:05:11.7
PCI Slot      : 2
Index in slot: 17

BIOS device: pci2#0_8
Kernel name: eth8
Permanant MAC: 26:99:89:D7:10:20
Assigned MAC : 26:99:89:D7:10:20
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.0
PCI name      : 0000:05:12.0
PCI Slot      : 2
Index in slot: 18

BIOS device: pci2#1_8
Kernel name: eth72
Permanant MAC: 52:06:71:E6:38:F3
Assigned MAC : 52:06:71:E6:38:F3
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.1
PCI name      : 0000:05:12.1
PCI Slot      : 2
Index in slot: 19

BIOS device: pci2#0_9
Kernel name: eth9
Permanant MAC: 26:63:72:7C:CB:16
Assigned MAC : 26:63:72:7C:CB:16
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.2
PCI name      : 0000:05:12.2
PCI Slot      : 2
Index in slot: 20

BIOS device: pci2#1_9
Kernel name: eth73
Permanant MAC: 16:66:FE:82:ED:F7
Assigned MAC : 16:66:FE:82:ED:F7
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.3
PCI name      : 0000:05:12.3
PCI Slot      : 2
Index in slot: 21

BIOS device: pci2#0_10
Kernel name: eth10
Permanant MAC: 76:91:58:71:5A:6E
Assigned MAC : 76:91:58:71:5A:6E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.4
PCI name      : 0000:05:12.4
PCI Slot      : 2
Index in slot: 22

BIOS device: pci2#1_10
Kernel name: eth74
Permanant MAC: 46:59:F6:8C:0F:C8
Assigned MAC : 46:59:F6:8C:0F:C8
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.5
PCI name      : 0000:05:12.5
PCI Slot      : 2
Index in slot: 23

BIOS device: pci2#0_11
Kernel name: eth11
Permanant MAC: 32:13:93:10:58:D2
Assigned MAC : 32:13:93:10:58:D2
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.6
PCI name      : 0000:05:12.6
PCI Slot      : 2
Index in slot: 24

BIOS device: pci2#1_11
Kernel name: eth75
Permanant MAC: B6:A0:1B:C3:3A:34
Assigned MAC : B6:A0:1B:C3:3A:34
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:12.7
PCI name      : 0000:05:12.7
PCI Slot      : 2
Index in slot: 25

BIOS device: pci2#0_12
Kernel name: eth12
Permanant MAC: CA:C7:B1:56:76:1E
Assigned MAC : CA:C7:B1:56:76:1E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.0
PCI name      : 0000:05:13.0
PCI Slot      : 2
Index in slot: 26

BIOS device: pci2#1_12
Kernel name: eth76
Permanant MAC: 62:9B:85:9A:23:B8
Assigned MAC : 62:9B:85:9A:23:B8
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.1
PCI name      : 0000:05:13.1
PCI Slot      : 2
Index in slot: 27

BIOS device: pci2#0_13
Kernel name: eth13
Permanant MAC: EA:F0:B4:B4:7A:B0
Assigned MAC : EA:F0:B4:B4:7A:B0
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.2
PCI name      : 0000:05:13.2
PCI Slot      : 2
Index in slot: 28

BIOS device: pci2#1_13
Kernel name: eth77
Permanant MAC: F2:50:7C:40:1C:02
Assigned MAC : F2:50:7C:40:1C:02
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.3
PCI name      : 0000:05:13.3
PCI Slot      : 2
Index in slot: 29

BIOS device: pci2#0_14
Kernel name: eth14
Permanant MAC: 1A:80:AA:1A:F8:B9
Assigned MAC : 1A:80:AA:1A:F8:B9
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.4
PCI name      : 0000:05:13.4
PCI Slot      : 2
Index in slot: 30

BIOS device: pci2#1_14
Kernel name: eth78
Permanant MAC: CA:E1:AA:57:50:E4
Assigned MAC : CA:E1:AA:57:50:E4
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.5
PCI name      : 0000:05:13.5
PCI Slot      : 2
Index in slot: 31

BIOS device: pci2#0_15
Kernel name: eth15
Permanant MAC: 16:01:8B:BA:3D:73
Assigned MAC : 16:01:8B:BA:3D:73
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.6
PCI name      : 0000:05:13.6
PCI Slot      : 2
Index in slot: 32

BIOS device: pci2#1_15
Kernel name: eth79
Permanant MAC: EE:28:73:D7:CF:0B
Assigned MAC : EE:28:73:D7:CF:0B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:13.7
PCI name      : 0000:05:13.7
PCI Slot      : 2
Index in slot: 33

BIOS device: pci2#0_16
Kernel name: eth16
Permanant MAC: 42:E8:DB:54:F5:5B
Assigned MAC : 42:E8:DB:54:F5:5B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.0
PCI name      : 0000:05:14.0
PCI Slot      : 2
Index in slot: 34

BIOS device: pci2#1_16
Kernel name: eth80
Permanant MAC: 0A:CD:C2:38:9F:97
Assigned MAC : 0A:CD:C2:38:9F:97
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.1
PCI name      : 0000:05:14.1
PCI Slot      : 2
Index in slot: 35

BIOS device: pci2#0_17
Kernel name: eth17
Permanant MAC: A2:47:7C:AF:7C:EE
Assigned MAC : A2:47:7C:AF:7C:EE
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.2
PCI name      : 0000:05:14.2
PCI Slot      : 2
Index in slot: 36

BIOS device: pci2#1_17
Kernel name: eth81
Permanant MAC: A2:33:3D:D0:D0:F5
Assigned MAC : A2:33:3D:D0:D0:F5
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.3
PCI name      : 0000:05:14.3
PCI Slot      : 2
Index in slot: 37

BIOS device: pci2#0_18
Kernel name: eth18
Permanant MAC: EE:92:0D:B9:58:68
Assigned MAC : EE:92:0D:B9:58:68
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.4
PCI name      : 0000:05:14.4
PCI Slot      : 2
Index in slot: 38

BIOS device: pci2#1_18
Kernel name: eth82
Permanant MAC: 8A:FD:7F:0C:55:24
Assigned MAC : 8A:FD:7F:0C:55:24
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.5
PCI name      : 0000:05:14.5
PCI Slot      : 2
Index in slot: 39

BIOS device: pci2#0_19
Kernel name: eth19
Permanant MAC: CA:54:82:D0:AF:BF
Assigned MAC : CA:54:82:D0:AF:BF
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.6
PCI name      : 0000:05:14.6
PCI Slot      : 2
Index in slot: 40

BIOS device: pci2#1_19
Kernel name: eth83
Permanant MAC: DE:7D:8E:78:52:AA
Assigned MAC : DE:7D:8E:78:52:AA
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:14.7
PCI name      : 0000:05:14.7
PCI Slot      : 2
Index in slot: 41

BIOS device: pci2#0_20
Kernel name: eth20
Permanant MAC: 16:78:05:72:38:3C
Assigned MAC : 16:78:05:72:38:3C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.0
PCI name      : 0000:05:15.0
PCI Slot      : 2
Index in slot: 42

BIOS device: pci2#1_20
Kernel name: eth84
Permanant MAC: FE:AF:2E:51:23:F4
Assigned MAC : FE:AF:2E:51:23:F4
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.1
PCI name      : 0000:05:15.1
PCI Slot      : 2
Index in slot: 43

BIOS device: pci2#0_21
Kernel name: eth21
Permanant MAC: E6:88:49:E6:73:2E
Assigned MAC : E6:88:49:E6:73:2E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.2
PCI name      : 0000:05:15.2
PCI Slot      : 2
Index in slot: 44

BIOS device: pci2#1_21
Kernel name: eth85
Permanant MAC: 8E:AB:71:7E:8A:0C
Assigned MAC : 8E:AB:71:7E:8A:0C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.3
PCI name      : 0000:05:15.3
PCI Slot      : 2
Index in slot: 45

BIOS device: pci2#0_22
Kernel name: eth22
Permanant MAC: 4A:B8:6B:81:FA:A4
Assigned MAC : 4A:B8:6B:81:FA:A4
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.4
PCI name      : 0000:05:15.4
PCI Slot      : 2
Index in slot: 46

BIOS device: pci2#1_22
Kernel name: eth86
Permanant MAC: 5A:7C:C6:47:FC:AD
Assigned MAC : 5A:7C:C6:47:FC:AD
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.5
PCI name      : 0000:05:15.5
PCI Slot      : 2
Index in slot: 47

BIOS device: pci2#0_23
Kernel name: eth23
Permanant MAC: 42:BD:72:88:5C:34
Assigned MAC : 42:BD:72:88:5C:34
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.6
PCI name      : 0000:05:15.6
PCI Slot      : 2
Index in slot: 48

BIOS device: pci2#1_23
Kernel name: eth87
Permanant MAC: D2:D8:94:DB:8A:10
Assigned MAC : D2:D8:94:DB:8A:10
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:15.7
PCI name      : 0000:05:15.7
PCI Slot      : 2
Index in slot: 49

BIOS device: pci2#0_24
Kernel name: eth24
Permanant MAC: D6:20:20:DA:8D:1A
Assigned MAC : D6:20:20:DA:8D:1A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.0
PCI name      : 0000:05:16.0
PCI Slot      : 2
Index in slot: 50

BIOS device: pci2#1_24
Kernel name: eth88
Permanant MAC: BA:DC:0A:78:95:94
Assigned MAC : BA:DC:0A:78:95:94
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.1
PCI name      : 0000:05:16.1
PCI Slot      : 2
Index in slot: 51

BIOS device: pci2#0_25
Kernel name: eth25
Permanant MAC: 3E:45:98:02:A8:CA
Assigned MAC : 3E:45:98:02:A8:CA
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.2
PCI name      : 0000:05:16.2
PCI Slot      : 2
Index in slot: 52

BIOS device: pci2#1_25
Kernel name: eth89
Permanant MAC: 62:95:A4:78:91:3A
Assigned MAC : 62:95:A4:78:91:3A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.3
PCI name      : 0000:05:16.3
PCI Slot      : 2
Index in slot: 53

BIOS device: pci2#0_26
Kernel name: eth26
Permanant MAC: AE:1E:2E:42:06:26
Assigned MAC : AE:1E:2E:42:06:26
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.4
PCI name      : 0000:05:16.4
PCI Slot      : 2
Index in slot: 54

BIOS device: pci2#1_26
Kernel name: eth90
Permanant MAC: 8A:D2:E7:BB:74:75
Assigned MAC : 8A:D2:E7:BB:74:75
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.5
PCI name      : 0000:05:16.5
PCI Slot      : 2
Index in slot: 55

BIOS device: pci2#0_27
Kernel name: eth27
Permanant MAC: 1A:FB:43:18:6D:0D
Assigned MAC : 1A:FB:43:18:6D:0D
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.6
PCI name      : 0000:05:16.6
PCI Slot      : 2
Index in slot: 56

BIOS device: pci2#1_27
Kernel name: eth91
Permanant MAC: 3E:C4:70:EC:91:6B
Assigned MAC : 3E:C4:70:EC:91:6B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:16.7
PCI name      : 0000:05:16.7
PCI Slot      : 2
Index in slot: 57

BIOS device: pci2#0_28
Kernel name: eth28
Permanant MAC: 02:F9:E3:97:A7:2F
Assigned MAC : 02:F9:E3:97:A7:2F
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.0
PCI name      : 0000:05:17.0
PCI Slot      : 2
Index in slot: 58

BIOS device: pci2#1_28
Kernel name: eth92
Permanant MAC: F2:8F:A4:90:36:DC
Assigned MAC : F2:8F:A4:90:36:DC
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.1
PCI name      : 0000:05:17.1
PCI Slot      : 2
Index in slot: 59

BIOS device: pci2#0_29
Kernel name: eth29
Permanant MAC: 02:71:EC:8B:C3:9C
Assigned MAC : 02:71:EC:8B:C3:9C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.2
PCI name      : 0000:05:17.2
PCI Slot      : 2
Index in slot: 60

BIOS device: pci2#1_29
Kernel name: eth93
Permanant MAC: 32:38:C9:FD:D9:7B
Assigned MAC : 32:38:C9:FD:D9:7B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.3
PCI name      : 0000:05:17.3
PCI Slot      : 2
Index in slot: 61

BIOS device: pci2#0_30
Kernel name: eth30
Permanant MAC: E2:88:EC:3B:B4:83
Assigned MAC : E2:88:EC:3B:B4:83
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.4
PCI name      : 0000:05:17.4
PCI Slot      : 2
Index in slot: 62

BIOS device: pci2#1_30
Kernel name: eth94
Permanant MAC: E6:F4:CB:63:62:5D
Assigned MAC : E6:F4:CB:63:62:5D
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.5
PCI name      : 0000:05:17.5
PCI Slot      : 2
Index in slot: 63

BIOS device: pci2#0_31
Kernel name: eth31
Permanant MAC: 36:39:72:44:CE:8A
Assigned MAC : 36:39:72:44:CE:8A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.6
PCI name      : 0000:05:17.6
PCI Slot      : 2
Index in slot: 64

BIOS device: pci2#1_31
Kernel name: eth95
Permanant MAC: 9E:D8:C0:B3:0A:74
Assigned MAC : 9E:D8:C0:B3:0A:74
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:17.7
PCI name      : 0000:05:17.7
PCI Slot      : 2
Index in slot: 65

BIOS device: pci2#0_32
Kernel name: eth32
Permanant MAC: E6:43:86:56:42:25
Assigned MAC : E6:43:86:56:42:25
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.0
PCI name      : 0000:05:18.0
PCI Slot      : 2
Index in slot: 66

BIOS device: pci2#1_32
Kernel name: eth96
Permanant MAC: 52:16:FB:B3:DE:EB
Assigned MAC : 52:16:FB:B3:DE:EB
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.1
PCI name      : 0000:05:18.1
PCI Slot      : 2
Index in slot: 67

BIOS device: pci2#0_33
Kernel name: eth33
Permanant MAC: AE:60:EC:3F:1F:80
Assigned MAC : AE:60:EC:3F:1F:80
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.2
PCI name      : 0000:05:18.2
PCI Slot      : 2
Index in slot: 68

BIOS device: pci2#1_33
Kernel name: eth97
Permanant MAC: CA:E4:94:9A:92:54
Assigned MAC : CA:E4:94:9A:92:54
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.3
PCI name      : 0000:05:18.3
PCI Slot      : 2
Index in slot: 69

BIOS device: pci2#0_34
Kernel name: eth34
Permanant MAC: B2:FB:37:8B:05:4C
Assigned MAC : B2:FB:37:8B:05:4C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.4
PCI name      : 0000:05:18.4
PCI Slot      : 2
Index in slot: 70

BIOS device: pci2#1_34
Kernel name: eth98
Permanant MAC: AE:16:C0:16:D5:8C
Assigned MAC : AE:16:C0:16:D5:8C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.5
PCI name      : 0000:05:18.5
PCI Slot      : 2
Index in slot: 71

BIOS device: pci2#0_35
Kernel name: eth35
Permanant MAC: FE:E5:B2:3B:01:3B
Assigned MAC : FE:E5:B2:3B:01:3B
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.6
PCI name      : 0000:05:18.6
PCI Slot      : 2
Index in slot: 72

BIOS device: pci2#1_35
Kernel name: eth99
Permanant MAC: 9A:BD:81:21:64:F1
Assigned MAC : 9A:BD:81:21:64:F1
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:18.7
PCI name      : 0000:05:18.7
PCI Slot      : 2
Index in slot: 73

BIOS device: pci2#0_36
Kernel name: eth36
Permanant MAC: 9A:51:3F:AC:8D:E9
Assigned MAC : 9A:51:3F:AC:8D:E9
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.0
PCI name      : 0000:05:19.0
PCI Slot      : 2
Index in slot: 74

BIOS device: pci2#1_36
Kernel name: eth100
Permanant MAC: C6:36:AE:8F:F4:E2
Assigned MAC : C6:36:AE:8F:F4:E2
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.1
PCI name      : 0000:05:19.1
PCI Slot      : 2
Index in slot: 75

BIOS device: pci2#0_37
Kernel name: eth37
Permanant MAC: 3E:B2:03:1C:EA:BF
Assigned MAC : 3E:B2:03:1C:EA:BF
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.2
PCI name      : 0000:05:19.2
PCI Slot      : 2
Index in slot: 76

BIOS device: pci2#1_37
Kernel name: eth101
Permanant MAC: E6:2A:AF:AD:5A:2C
Assigned MAC : E6:2A:AF:AD:5A:2C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.3
PCI name      : 0000:05:19.3
PCI Slot      : 2
Index in slot: 77

BIOS device: pci2#0_38
Kernel name: eth38
Permanant MAC: 1A:E4:80:E7:8E:00
Assigned MAC : 1A:E4:80:E7:8E:00
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.4
PCI name      : 0000:05:19.4
PCI Slot      : 2
Index in slot: 78

BIOS device: pci2#1_38
Kernel name: eth102
Permanant MAC: 16:84:9C:C6:6A:65
Assigned MAC : 16:84:9C:C6:6A:65
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.5
PCI name      : 0000:05:19.5
PCI Slot      : 2
Index in slot: 79

BIOS device: pci2#0_39
Kernel name: eth39
Permanant MAC: 5E:C8:FF:AD:F3:58
Assigned MAC : 5E:C8:FF:AD:F3:58
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.6
PCI name      : 0000:05:19.6
PCI Slot      : 2
Index in slot: 80

BIOS device: pci2#1_39
Kernel name: eth103
Permanant MAC: D2:C5:6A:9C:BA:94
Assigned MAC : D2:C5:6A:9C:BA:94
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:19.7
PCI name      : 0000:05:19.7
PCI Slot      : 2
Index in slot: 81

BIOS device: pci2#0_40
Kernel name: eth40
Permanant MAC: 9A:A5:E6:92:4B:FF
Assigned MAC : 9A:A5:E6:92:4B:FF
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.0
PCI name      : 0000:05:1a.0
PCI Slot      : 2
Index in slot: 82

BIOS device: pci2#1_40
Kernel name: eth104
Permanant MAC: 6A:BD:6C:AC:12:D1
Assigned MAC : 6A:BD:6C:AC:12:D1
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.1
PCI name      : 0000:05:1a.1
PCI Slot      : 2
Index in slot: 83

BIOS device: pci2#0_41
Kernel name: eth41
Permanant MAC: DA:6A:7E:22:BF:36
Assigned MAC : DA:6A:7E:22:BF:36
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.2
PCI name      : 0000:05:1a.2
PCI Slot      : 2
Index in slot: 84

BIOS device: pci2#1_41
Kernel name: eth105
Permanant MAC: FA:5C:DF:30:BC:D7
Assigned MAC : FA:5C:DF:30:BC:D7
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.3
PCI name      : 0000:05:1a.3
PCI Slot      : 2
Index in slot: 85

BIOS device: pci2#0_42
Kernel name: eth42
Permanant MAC: CA:43:B6:6C:D6:F1
Assigned MAC : CA:43:B6:6C:D6:F1
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.4
PCI name      : 0000:05:1a.4
PCI Slot      : 2
Index in slot: 86

BIOS device: pci2#1_42
Kernel name: eth106
Permanant MAC: DE:93:8B:36:47:48
Assigned MAC : DE:93:8B:36:47:48
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.5
PCI name      : 0000:05:1a.5
PCI Slot      : 2
Index in slot: 87

BIOS device: pci2#0_43
Kernel name: eth43
Permanant MAC: B2:82:9C:2C:F3:65
Assigned MAC : B2:82:9C:2C:F3:65
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.6
PCI name      : 0000:05:1a.6
PCI Slot      : 2
Index in slot: 88

BIOS device: pci2#1_43
Kernel name: eth107
Permanant MAC: 62:43:76:F4:1D:54
Assigned MAC : 62:43:76:F4:1D:54
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1a.7
PCI name      : 0000:05:1a.7
PCI Slot      : 2
Index in slot: 89

BIOS device: pci2#0_44
Kernel name: eth44
Permanant MAC: C6:2D:C7:55:30:3A
Assigned MAC : C6:2D:C7:55:30:3A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.0
PCI name      : 0000:05:1b.0
PCI Slot      : 2
Index in slot: 90

BIOS device: pci2#1_44
Kernel name: eth108
Permanant MAC: D6:26:42:7C:7B:66
Assigned MAC : D6:26:42:7C:7B:66
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.1
PCI name      : 0000:05:1b.1
PCI Slot      : 2
Index in slot: 91

BIOS device: pci2#0_45
Kernel name: eth45
Permanant MAC: 9A:2C:DD:AE:7D:2C
Assigned MAC : 9A:2C:DD:AE:7D:2C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.2
PCI name      : 0000:05:1b.2
PCI Slot      : 2
Index in slot: 92

BIOS device: pci2#1_45
Kernel name: eth109
Permanant MAC: DA:1D:20:14:66:E3
Assigned MAC : DA:1D:20:14:66:E3
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.3
PCI name      : 0000:05:1b.3
PCI Slot      : 2
Index in slot: 93

BIOS device: pci2#0_46
Kernel name: eth46
Permanant MAC: 26:3B:25:3A:31:64
Assigned MAC : 26:3B:25:3A:31:64
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.4
PCI name      : 0000:05:1b.4
PCI Slot      : 2
Index in slot: 94

BIOS device: pci2#1_46
Kernel name: eth110
Permanant MAC: 9E:75:E0:61:5A:22
Assigned MAC : 9E:75:E0:61:5A:22
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.5
PCI name      : 0000:05:1b.5
PCI Slot      : 2
Index in slot: 95

BIOS device: pci2#0_47
Kernel name: eth47
Permanant MAC: 36:77:F3:1A:7A:DB
Assigned MAC : 36:77:F3:1A:7A:DB
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.6
PCI name      : 0000:05:1b.6
PCI Slot      : 2
Index in slot: 96

BIOS device: pci2#1_47
Kernel name: eth111
Permanant MAC: BA:17:5D:3C:17:50
Assigned MAC : BA:17:5D:3C:17:50
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1b.7
PCI name      : 0000:05:1b.7
PCI Slot      : 2
Index in slot: 97

BIOS device: pci2#0_48
Kernel name: eth48
Permanant MAC: 9E:01:90:05:38:8D
Assigned MAC : 9E:01:90:05:38:8D
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.0
PCI name      : 0000:05:1c.0
PCI Slot      : 2
Index in slot: 98

BIOS device: pci2#1_48
Kernel name: eth112
Permanant MAC: 36:0C:F8:F2:59:AC
Assigned MAC : 36:0C:F8:F2:59:AC
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.1
PCI name      : 0000:05:1c.1
PCI Slot      : 2
Index in slot: 99

BIOS device: pci2#0_49
Kernel name: eth49
Permanant MAC: 82:C6:7E:85:8A:D6
Assigned MAC : 82:C6:7E:85:8A:D6
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.2
PCI name      : 0000:05:1c.2
PCI Slot      : 2
Index in slot: 100

BIOS device: pci2#1_49
Kernel name: eth113
Permanant MAC: BA:46:ED:93:D2:0E
Assigned MAC : BA:46:ED:93:D2:0E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.3
PCI name      : 0000:05:1c.3
PCI Slot      : 2
Index in slot: 101

BIOS device: pci2#0_50
Kernel name: eth50
Permanant MAC: 56:0E:4B:88:A5:8E
Assigned MAC : 56:0E:4B:88:A5:8E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.4
PCI name      : 0000:05:1c.4
PCI Slot      : 2
Index in slot: 102

BIOS device: pci2#1_50
Kernel name: eth114
Permanant MAC: 8A:6F:9B:F4:4C:E5
Assigned MAC : 8A:6F:9B:F4:4C:E5
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.5
PCI name      : 0000:05:1c.5
PCI Slot      : 2
Index in slot: 103

BIOS device: pci2#0_51
Kernel name: eth51
Permanant MAC: 62:37:A2:D1:A4:57
Assigned MAC : 62:37:A2:D1:A4:57
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.6
PCI name      : 0000:05:1c.6
PCI Slot      : 2
Index in slot: 104

BIOS device: pci2#1_51
Kernel name: eth115
Permanant MAC: 9E:FB:A9:23:3F:E9
Assigned MAC : 9E:FB:A9:23:3F:E9
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1c.7
PCI name      : 0000:05:1c.7
PCI Slot      : 2
Index in slot: 105

BIOS device: pci2#0_52
Kernel name: eth52
Permanant MAC: DA:8F:99:6D:22:25
Assigned MAC : DA:8F:99:6D:22:25
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.0
PCI name      : 0000:05:1d.0
PCI Slot      : 2
Index in slot: 106

BIOS device: pci2#1_52
Kernel name: eth116
Permanant MAC: 1E:14:98:50:7A:79
Assigned MAC : 1E:14:98:50:7A:79
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.1
PCI name      : 0000:05:1d.1
PCI Slot      : 2
Index in slot: 107

BIOS device: pci2#0_53
Kernel name: eth53
Permanant MAC: 3E:4C:CD:C9:67:3A
Assigned MAC : 3E:4C:CD:C9:67:3A
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.2
PCI name      : 0000:05:1d.2
PCI Slot      : 2
Index in slot: 108

BIOS device: pci2#1_53
Kernel name: eth117
Permanant MAC: DA:88:D7:FD:CC:25
Assigned MAC : DA:88:D7:FD:CC:25
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.3
PCI name      : 0000:05:1d.3
PCI Slot      : 2
Index in slot: 109

BIOS device: pci2#0_54
Kernel name: eth54
Permanant MAC: 76:97:E4:8B:92:5C
Assigned MAC : 76:97:E4:8B:92:5C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.4
PCI name      : 0000:05:1d.4
PCI Slot      : 2
Index in slot: 110

BIOS device: pci2#1_54
Kernel name: eth118
Permanant MAC: 6E:D2:22:E6:71:88
Assigned MAC : 6E:D2:22:E6:71:88
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.5
PCI name      : 0000:05:1d.5
PCI Slot      : 2
Index in slot: 111

BIOS device: pci2#0_55
Kernel name: eth55
Permanant MAC: E6:5C:51:CD:88:5C
Assigned MAC : E6:5C:51:CD:88:5C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.6
PCI name      : 0000:05:1d.6
PCI Slot      : 2
Index in slot: 112

BIOS device: pci2#1_55
Kernel name: eth119
Permanant MAC: 8A:71:2B:B5:27:FC
Assigned MAC : 8A:71:2B:B5:27:FC
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1d.7
PCI name      : 0000:05:1d.7
PCI Slot      : 2
Index in slot: 113

BIOS device: pci2#0_56
Kernel name: eth56
Permanant MAC: 12:29:5D:8E:37:CF
Assigned MAC : 12:29:5D:8E:37:CF
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.0
PCI name      : 0000:05:1e.0
PCI Slot      : 2
Index in slot: 114

BIOS device: pci2#1_56
Kernel name: eth120
Permanant MAC: 6A:C2:99:E5:CE:27
Assigned MAC : 6A:C2:99:E5:CE:27
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.1
PCI name      : 0000:05:1e.1
PCI Slot      : 2
Index in slot: 115

BIOS device: pci2#0_57
Kernel name: eth57
Permanant MAC: 32:A4:1B:CB:42:28
Assigned MAC : 32:A4:1B:CB:42:28
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.2
PCI name      : 0000:05:1e.2
PCI Slot      : 2
Index in slot: 116

BIOS device: pci2#1_57
Kernel name: eth121
Permanant MAC: 6E:3F:07:B1:1E:28
Assigned MAC : 6E:3F:07:B1:1E:28
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.3
PCI name      : 0000:05:1e.3
PCI Slot      : 2
Index in slot: 117

BIOS device: pci2#0_58
Kernel name: eth58
Permanant MAC: 02:63:BE:D0:F6:5C
Assigned MAC : 02:63:BE:D0:F6:5C
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.4
PCI name      : 0000:05:1e.4
PCI Slot      : 2
Index in slot: 118

BIOS device: pci2#1_58
Kernel name: eth122
Permanant MAC: 12:71:66:F9:99:72
Assigned MAC : 12:71:66:F9:99:72
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.5
PCI name      : 0000:05:1e.5
PCI Slot      : 2
Index in slot: 119

BIOS device: pci2#0_59
Kernel name: eth59
Permanant MAC: 6E:20:60:C3:55:A3
Assigned MAC : 6E:20:60:C3:55:A3
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.6
PCI name      : 0000:05:1e.6
PCI Slot      : 2
Index in slot: 120

BIOS device: pci2#1_59
Kernel name: eth123
Permanant MAC: 76:BB:88:2F:01:9E
Assigned MAC : 76:BB:88:2F:01:9E
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1e.7
PCI name      : 0000:05:1e.7
PCI Slot      : 2
Index in slot: 121

BIOS device: pci2#0_60
Kernel name: eth60
Permanant MAC: AE:18:C6:B9:D2:0D
Assigned MAC : AE:18:C6:B9:D2:0D
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.0
PCI name      : 0000:05:1f.0
PCI Slot      : 2
Index in slot: 122

BIOS device: pci2#1_60
Kernel name: eth124
Permanant MAC: 12:54:8B:A6:9C:A5
Assigned MAC : 12:54:8B:A6:9C:A5
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.1
PCI name      : 0000:05:1f.1
PCI Slot      : 2
Index in slot: 123

BIOS device: pci2#0_61
Kernel name: eth61
Permanant MAC: 92:0E:6C:58:8F:CA
Assigned MAC : 92:0E:6C:58:8F:CA
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.2
PCI name      : 0000:05:1f.2
PCI Slot      : 2
Index in slot: 124

BIOS device: pci2#1_61
Kernel name: eth125
Permanant MAC: 9E:F7:72:12:0F:BA
Assigned MAC : 9E:F7:72:12:0F:BA
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.3
PCI name      : 0000:05:1f.3
PCI Slot      : 2
Index in slot: 125

BIOS device: pci2#0_62
Kernel name: eth62
Permanant MAC: 0E:1A:1E:0D:B6:56
Assigned MAC : 0E:1A:1E:0D:B6:56
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.4
PCI name      : 0000:05:1f.4
PCI Slot      : 2
Index in slot: 126

BIOS device: pci2#1_62
Kernel name: eth126
Permanant MAC: 2E:B2:27:24:03:15
Assigned MAC : 2E:B2:27:24:03:15
Driver: ixgbevf
Driver version: 1.0.0-k0
Firmware version: N/A
Bus Info: 0000:05:1f.5
PCI name      : 0000:05:1f.5
PCI Slot      : 2
Index in slot: 127

