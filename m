From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: biosdevname v0.3.2
Date: Tue, 07 Dec 2010 18:16:22 +0000
Message-ID: <1291745782.21627.6.camel@bwh-desktop>
References: <20101206140649.GA13628@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Colin Watson <cjwatson@ubuntu.com>
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101206140649.GA13628@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-12-06 at 08:06 -0600, Matt Domsch wrote:
> Bugfix update to biosdevname, now version 0.3.2.
> 
> The legacy code for reading the PCI IRQ Routing Table ($PIR) and the
> PCMCIA information has been removed.  This means biosdevname will only
> report BIOS-provided names if your system has SMBIOS 2.6 or higher and
> has the information in Type 9 or Type 41.  This is in preparation for
> widespread use, and will keep biosdevname from suggesting names on
> systems that are well into or beyond their useful lifetime and
> introducing an unexpected change of behavior on them.  Dell PowerEdge
> 10G and newer, HP ProLiant G6 and newer are known to have SMBIOS 2.6,
> as do a number of desktop, laptop, and netbook-class systems as
> reported on the fedora-devel mailing list.
> 
> This release also provides correct names for Intel and Broadcom
> quad-port GigE cards that I've tried.  Format is pci<slot>#<port>.
[...]

I tried this on a Supermicro board here, which doesn't have this
information.  eth0 and eth1 are LOM ports, eth2 and eth3 are on a NIC.
The debug output is:

BIOS device: 
Kernel name: eth2
Assigned MAC : 00:0F:53:01:41:14
Driver: sfc
Driver version: 3.0
Firmware version: 3.0.8.2217
Bus Info: 0000:01:00.0
PCI name      : 0000:01:00.0
PCI Slot      : Unknown
Index in slot: 7

BIOS device: 
Kernel name: eth3
Assigned MAC : 00:0F:53:01:41:15
Driver: sfc
Driver version: 3.0
Firmware version: 3.0.8.2217
Bus Info: 0000:01:00.1
PCI name      : 0000:01:00.1
PCI Slot      : Unknown
Index in slot: 8

BIOS device: 
Kernel name: eth0
Permanant MAC: 00:30:48:90:81:9E
Assigned MAC : 00:30:48:90:81:9E
Driver: e1000e
Driver version: 1.2.7-k2
Firmware version: 0.15-4
Bus Info: 0000:0d:00.0
PCI name      : 0000:0d:00.0
PCI Slot      : Unknown
Index in slot: 9

BIOS device: 
Kernel name: eth1
Permanant MAC: 00:30:48:90:81:9F
Assigned MAC : 00:30:48:90:81:9F
Driver: e1000e
Driver version: 1.2.7-k2
Firmware version: 0.5-7
Bus Info: 0000:0e:00.0
PCI name      : 0000:0e:00.0
PCI Slot      : Unknown
Index in slot: 10

It appears that 'unknown slot' is treated as a specific slot and all
devices with an unknown slot are given unique indices.  Perhaps this
doesn't matter in the end, since no name is generated when the slot is
unknown.

However, the 2 NIC ports do have their own indices (specified with the
dev_id attribute) and it should be possible to distinguish slots by
PCI/PCIe topology even though the name given won't correspond to any
markings on the motherboard.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

