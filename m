From: Christian Schwarz <me@cschwarz.com>
Subject: [Bug] Apple Thunderbolt Ethernet Adapter not Working After Suspend &
 Resume
Date: Wed, 28 Oct 2015 17:26:27 +0100
Message-ID: <5630F733.3030002@cschwarz.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070502040401080406030802"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.uberspace.de ([95.143.172.79]:54372 "EHLO
	orion.uberspace.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbJ1Qcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 12:32:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070502040401080406030802
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

(Greg Kroah-Hartman told me to contact his mailing list. For the
original bug check [1])
(Since this is my first bug-report to a Linux Kernel mailing list, I
hope I met all the formal expectations.)

---

==Summary==

Apple Thunderbolt Ethernet Adapter not Working After Suspend & Resume

==Overview==

On a Retina MacBook Pro 11,3, with an Apple Thunderbolt Ethernet Adapter
plugged in, the previously working adapter does not work after suspend &
resume.

==Steps to Reproduce==

1) Boot the Retina MacBook Pro 11,3. Plug in the Apple Thunderbolt
Ethernet Adapter. (Thunderbolt hot-plugging works on my setup.) The
adapter is usable now (Link is reported up, lspci output in attachment).
Suspend the machine (I close the lid which works when disabling 'XHCI'
in `/proc/acpi/wakeup`)

3) Resume the machine (Open the lid)

4) The adapter does not work now. It is reported DOWN by `ip link`.
lspci output shows different lables (see attachments). Many error
messages in log output.

==Actual Result==

As described above: The Thunderbolt Ethernet Adapter does not work
anymore after resume.
Unplug and re-plugin does not resolve the issue.
(See additional information for my current workarounds)

==Expected Result==

The Thunderbolt Ethernet Adapter should continue to work link before
suspend.

==Build Data & Hardware==

Linux 4.3.0-rc7
https://www.kernel.org/pub/linux/kernel/v4.x/testing/linux-4.3-rc7.tar.xz
Kernel Config: See attachment
Userland: Arch Linux
Retina MacBook Pro 11,3
http://www.everymac.com/systems/apple/macbook_pro/specs/macbook-pro-core-i7-2.3-15-dual-graphics-late-2013-retina-display-specs.html
Apple Thunderbolt Ethernet Adapter (labeled BCM2590 on the backside,
can't explain why this identifier differs from lspci output. I think
this is not of critical importance for this bug report.)

==Addtitional Information==

Workaround 1: The obvious workaround is to unplug the adapter before
suspending.
Workaround 2: If the machine is in the state described in "Steps to
Reproduce", unplug the adapter in normal operation, the suspend and
resume, then plug-in again. The adapter works again.
	
==Attachments==

kernel_config
The kernel configuration file of my system.

thunderbolt_ethernet_normal_plugin_unplug.log
Log output of what happens when just plugging in and shortly after
unplugging the adapter. All this works as expected. (meant as a possible
reference)

thunderbolt_ethernet_after_resume.log
Log output of what happens after resuming the system (as in "Steps to
Reproduce")

thunderbolt_ethernet_lspci_before_suspend.txt
lspci -k output before suspending the system (as in "Steps to Reproduce")

thunderbolt_ethernet_lspci_after_resume.log
lspci -k output after resuming the system (as in "Steps to Reproduce")

thunderbolt_ethernet_workaround_2_after_resume.log
Log output of what happens when resuming like in workaround 2

---

[1] https://bugzilla.kernel.org/show_bug.cgi?id=106681#c10


--------------070502040401080406030802
Content-Type: text/x-log;
 name="thunderbolt_ethernet_workaround_2_after_resume.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="thunderbolt_ethernet_workaround_2_after_resume.log"

Okt 27 11:00:58 csarch kernel: ACPI: Waking up from system sleep state S3
Okt 27 11:00:58 csarch kernel: pcieport 0000:07:05.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 11:00:58 csarch kernel: pcieport 0000:07:06.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 11:00:58 csarch kernel: pcieport 0000:07:03.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 11:00:58 csarch kernel: pcieport 0000:07:04.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: resuming...
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: control channel starting...
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: starting TX ring 0
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: enabling interrupt at register 0x38200 bit 0 (0x0 -> 0x1)
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: starting RX ring 0
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: enabling interrupt at register 0x38200 bit 12 (0x1 -> 0x1001)
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: resetting switch at 0
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: 0: resuming switch
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: resume finished
Okt 27 11:00:58 csarch kernel: pcieport 0000:09:00.0: Refused to change power state, currently in D3
Okt 27 11:00:58 csarch kernel: pcieport 0000:0a:00.0: Refused to change power state, currently in D3
Okt 27 11:00:58 csarch kernel: tg3 0000:0b:00.0: Refused to change power state, currently in D3
Okt 27 11:00:58 csarch kernel: PM: noirq resume of devices complete after 63.979 msecs
Okt 27 11:00:58 csarch kernel: PM: early resume of devices complete after 49.561 msecs
Okt 27 11:00:58 csarch kernel: wl_resume: PCI Resume handler
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:c.
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: 0:c: hotplug: scanning
Okt 27 11:00:58 csarch kernel: thunderbolt 0000:08:00.0: 0:c: hotplug: no switch found
Okt 27 11:00:58 csarch kernel: sd 0:0:0:0: [sda] Starting disk
Okt 27 11:00:58 csarch kernel: wl0: link down (wlan0)
Okt 27 11:00:58 csarch kernel: pciehp 0000:0a:00.0:pcie24: unloading service driver pciehp
Okt 27 11:00:58 csarch kernel: pciehp 0000:0a:00.0:pcie24: Timeout on hotplug command 0x1038 (issued 3145466 msec ago)
Okt 27 11:00:58 csarch kernel: pciehp 0000:0a:00.0:pcie24: pcie_do_write_cmd: no response from device
Okt 27 11:00:58 csarch kernel: pci_bus 0000:0b: busn_res: [bus 0b] is released
Okt 27 11:00:58 csarch kernel: pci_bus 0000:0a: busn_res: [bus 0a-0b] is released
Okt 27 11:00:58 csarch kernel: acpiphp: Slot [1] unregistered
Okt 27 11:00:58 csarch kernel: acpiphp: Slot [2-1] unregistered
Okt 27 11:00:58 csarch kernel: acpiphp: Slot [3-2] unregistered
Okt 27 11:00:58 csarch kernel: acpiphp: Slot [4-2] unregistered
Okt 27 11:00:58 csarch kernel: acpiphp: Slot [5-2] unregistered
Okt 27 11:00:58 csarch kernel: pciehp 0000:07:00.0:pcie24: Device 0000:08:00.0 already exists at 0000:08:00, cannot hot-add
Okt 27 11:00:58 csarch kernel: pciehp 0000:07:00.0:pcie24: Cannot add device at 0000:08:00
Okt 27 11:00:58 csarch kernel: ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Okt 27 11:00:58 csarch kernel: ata1.00: unexpected _GTF length (8)
Okt 27 11:00:58 csarch kernel: ata1.00: unexpected _GTF length (8)
Okt 27 11:00:58 csarch kernel: ata1.00: configured for UDMA/133
Okt 27 11:00:58 csarch kernel: pciehp 0000:00:1c.0:pcie04: link training error: status 0x1001
Okt 27 11:00:58 csarch kernel: pciehp 0000:00:1c.0:pcie04: Failed to check link status
Okt 27 11:00:58 csarch kernel: rtc_cmos 00:02: System wakeup disabled by ACPI
Okt 27 11:00:58 csarch kernel: PM: resume of devices complete after 2611.872 msecs
Okt 27 11:00:58 csarch kernel: PM: Finishing wakeup.
Okt 27 11:00:58 csarch kernel: Restarting tasks ... done.

Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:3.
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3: hotplug: scanning
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is up (state: 2)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: initializing Switch at 0x3 (depth: 1, up port: 1)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: old switch config:
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:  Switch: 8086:1549 (Revision: 0, TB Version: 1)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max Port Number: 2
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Config:
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:    Upstream Port Number: 0 Depth: 0 Route String: 0x0 Enabled: 0, PlugEventsDelay: 10
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:    unknown1: 0x0 unknown4: 0x0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3: reading drom (length: 0x7b)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3: uid: 0x1000201828e40
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:  Port 0: 8086:1549 (Revision: 0, TB Version: 1, Type: Port (0x1))
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 7/7
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x700000
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:  Port 1: 8086:1549 (Revision: 0, TB Version: 1, Type: Port (0x1))
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 8/8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 4
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x3c00000
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:  Port 2: 8086:1549 (Revision: 0, TB Version: 1, Type: PCIe (0x100102))
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 8/8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 2
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x700000
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3: hotplug: activating pcie devices
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6 <-> 3:2 (PCI): activating
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: activating path from 0:6 to 3:2
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1: Writing hop 1, index 8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1:  Hop through port 2 to hop 8 (enabled)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1:    Counter enabled: 0 Counter index: 2047
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6: Writing hop 0, index 8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6:  Hop through port 3 to hop 8 (enabled)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6:    Counter enabled: 0 Counter index: 2047
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: activating path from 3:2 to 0:6
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3: Writing hop 1, index 8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3:  Hop through port 6 to hop 8 (enabled)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3:    Counter enabled: 0 Counter index: 2047
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2: Writing hop 0, index 8
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2:  Hop through port 1 to hop 8 (enabled)
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2:    Counter enabled: 0 Counter index: 2047
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:02:49 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 11:02:49 csarch kernel: pciehp 0000:07:03.0:pcie24: Card present on Slot(3-1)
Okt 27 11:02:49 csarch kernel: pciehp 0000:07:03.0:pcie24: slot(3-1): Link Up event
Okt 27 11:02:49 csarch kernel: pciehp 0000:07:03.0:pcie24: Link Up event ignored on slot(3-1): already powering on
Okt 27 11:02:49 csarch libvirtd[1429]: Device 0000:09:00.0 not found: could not access /sys/bus/pci/devices/0000:09:00.0/config: No such file 
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: [8086:1549] type 01 class 0x060400
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: supports D1 D2
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: PME# supported from D0 D1 D2 D3hot D3cold
Okt 27 11:02:49 csarch libvirtd[1429]: Device 0000:0a:00.0 not found: could not access /sys/bus/pci/devices/0000:0a:00.0/config: No such file 
Okt 27 11:02:49 csarch libvirtd[1429]: Device 0000:0b:00.0 not found: could not access /sys/bus/pci/devices/0000:0b:00.0/config: No such file 
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: bridge configuration invalid ([bus 00-00]), reconfiguring
Okt 27 11:02:49 csarch kernel: acpiphp: Slot [1] registered
Okt 27 11:02:49 csarch kernel: acpiphp: Slot [2-1] registered
Okt 27 11:02:49 csarch kernel: acpiphp: Slot [3-2] registered
Okt 27 11:02:49 csarch kernel: acpiphp: Slot [4-2] registered
Okt 27 11:02:49 csarch kernel: acpiphp: Slot [5-2] registered
Okt 27 11:02:49 csarch kernel: pci_bus 0000:0a: busn_res: can not insert [bus 0a-ff] under [bus 09-39] (conflicts with (null) [bus 09-39])
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: [8086:1549] type 01 class 0x060400
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: supports D1 D2
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: PME# supported from D0 D1 D2 D3hot D3cold

Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: PCI bridge to [bus 0a-ff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [io  0x0000-0x0fff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0x00000000-0x000fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: bridge configuration invalid ([bus 00-00]), reconfiguring
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: [14e4:1682] type 00 class 0x020000
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: reg 0x10: [mem 0x00000000-0x0000ffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: reg 0x18: [mem 0x00000000-0x0000ffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: reg 0x30: [mem 0x00000000-0x0000ffff pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: PME# supported from D0 D3hot D3cold
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: PCI bridge to [bus 0b-ff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [io  0x0000-0x0fff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0x00000000-0x000fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci_bus 0000:0b: busn_res: [bus 0b-ff] end is updated to 0b
Okt 27 11:02:49 csarch kernel: pci_bus 0000:0a: busn_res: [bus 0a-ff] end is updated to 0b
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: bridge window [mem 0x00100000-0x001fffff 64bit pref] to [bus 0b] add_size 200000 add_align 10
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: bridge window [mem 0x00100000-0x001fffff] to [bus 0b] add_size 200000 add_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: bridge window [mem 0x00100000-0x001fffff 64bit pref] to [bus 0a-0b] add_size 200000 add_align
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: bridge window [mem 0x00100000-0x001fffff] to [bus 0a-0b] add_size 200000 add_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: res[14]=[mem 0x00100000-0x003fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: res[15]=[mem 0x00100000-0x003fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: BAR 14: assigned [mem 0xc2000000-0xc22fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: BAR 15: assigned [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: BAR 13: assigned [io  0x3000-0x3fff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x003fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x003fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: BAR 14: assigned [mem 0xc2000000-0xc22fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: BAR 15: assigned [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: BAR 13: assigned [io  0x3000-0x3fff]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: BAR 0: assigned [mem 0xce000000-0xce00ffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: BAR 2: assigned [mem 0xce010000-0xce01ffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0b:00.0: BAR 6: assigned [mem 0xc2000000-0xc200ffff pref]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0: PCI bridge to [bus 0b]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0xc2000000-0xc22fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0xc2000000-0xc22fffff]
Okt 27 11:02:49 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pcieport 0000:07:03.0: PCI bridge to [bus 09-39]
Okt 27 11:02:49 csarch kernel: pcieport 0000:07:03.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:02:49 csarch kernel: pcieport 0000:07:03.0:   bridge window [mem 0xc2000000-0xc5ffffff]
Okt 27 11:02:49 csarch kernel: pcieport 0000:07:03.0:   bridge window [mem 0xce000000-0xd1ffffff 64bit pref]
Okt 27 11:02:49 csarch kernel: pcieport 0000:09:00.0: enabling device (0000 -> 0003)
Okt 27 11:02:49 csarch kernel: pcieport 0000:0a:00.0: enabling device (0000 -> 0003)
Okt 27 11:02:49 csarch kernel: pciehp 0000:0a:00.0:pcie24: Slot #9 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+ Interlock- NoCom
Okt 27 11:02:49 csarch kernel: pciehp 0000:0a:00.0:pcie24: service driver pciehp loaded
Okt 27 11:02:49 csarch kernel: tg3 0000:0b:00.0: enabling device (0000 -> 0002)
Okt 27 11:02:49 csarch NetworkManager[703]: <warn>  (eth0): failed to find device 20 'eth0' with udev
Okt 27 11:02:49 csarch NetworkManager[703]: <info>  (eth0): new Ethernet device (carrier: OFF, driver: 'tg3', ifindex: 20)
Okt 27 11:02:49 csarch kernel: tg3 0000:0b:00.0 eth0: Tigon3 [partno(BCM957762) rev 57766000] (PCI Express) MAC address 10:dd:b1:d3:7d:85
Okt 27 11:02:49 csarch kernel: tg3 0000:0b:00.0 eth0: attached PHY is 57765 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
Okt 27 11:02:49 csarch kernel: tg3 0000:0b:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
Okt 27 11:02:49 csarch kernel: tg3 0000:0b:00.0 eth0: dma_rwctrl[00000001] dma_mask[64-bit]
Okt 27 11:02:49 csarch NetworkManager[703]: <info>  (eth0): device state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
Okt 27 11:02:49 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Okt 27 11:02:49 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Okt 27 11:02:50 csarch kernel: tg3 0000:0b:00.0 eth0: Link is up at 100 Mbps, full duplex
Okt 27 11:02:50 csarch kernel: tg3 0000:0b:00.0 eth0: Flow control is on for TX and on for RX
Okt 27 11:02:50 csarch kernel: tg3 0000:0b:00.0 eth0: EEE is disabled

Okt 27 11:02:50 csarch kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready


--------------070502040401080406030802
Content-Type: text/plain; charset=UTF-8;
 name="thunderbolt_ethernet_lspci_before_suspend.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="thunderbolt_ethernet_lspci_before_suspend.txt"

MDg6MDAuMCBTeXN0ZW0gcGVyaXBoZXJhbDogSW50ZWwgQ29ycG9yYXRpb24gRGV2aWNlIDE1
NmMKCVN1YnN5c3RlbTogRGV2aWNlIDIyMjI6MTExMQoJS2VybmVsIGRyaXZlciBpbiB1c2U6
IHRodW5kZXJib2x0CglLZXJuZWwgbW9kdWxlczogdGh1bmRlcmJvbHQKMDk6MDAuMCBQQ0kg
YnJpZGdlOiBJbnRlbCBDb3Jwb3JhdGlvbiBEU0wzNTEwIFRodW5kZXJib2x0IENvbnRyb2xs
ZXIgW0NhY3R1cyBSaWRnZV0KCUtlcm5lbCBkcml2ZXIgaW4gdXNlOiBwY2llcG9ydAoJS2Vy
bmVsIG1vZHVsZXM6IHNocGNocAowYTowMC4wIFBDSSBicmlkZ2U6IEludGVsIENvcnBvcmF0
aW9uIERTTDM1MTAgVGh1bmRlcmJvbHQgQ29udHJvbGxlciBbQ2FjdHVzIFJpZGdlXQoJS2Vy
bmVsIGRyaXZlciBpbiB1c2U6IHBjaWVwb3J0CglLZXJuZWwgbW9kdWxlczogc2hwY2hwCjBi
OjAwLjAgRXRoZXJuZXQgY29udHJvbGxlcjogQnJvYWRjb20gQ29ycG9yYXRpb24gTmV0WHRy
ZW1lIEJDTTU3NzYyIEdpZ2FiaXQgRXRoZXJuZXQgUENJZQoJU3Vic3lzdGVtOiBBcHBsZSBJ
bmMuIERldmljZSAwMGY2CglLZXJuZWwgZHJpdmVyIGluIHVzZTogdGczCglLZXJuZWwgbW9k
dWxlczogdGczCgo=
--------------070502040401080406030802
Content-Type: text/x-log;
 name="thunderbolt_ethernet_normal_plugin_unplug.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="thunderbolt_ethernet_normal_plugin_unplug.log"

Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:3.
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3: hotplug: scanning
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is up (state: 2)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: initializing Switch at 0x3 (depth: 1, up port: 1)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: old switch config:
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:  Switch: 8086:1549 (Revision: 0, TB Version: 1)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max Port Number: 2
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Config:
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:    Upstream Port Number: 0 Depth: 0 Route String: 0x0 Enabled: 0, PlugEventsDelay: 10
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:    unknown1: 0x0 unknown4: 0x0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3: reading drom (length: 0x7b)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3: uid: 0x1000201828e40
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:  Port 0: 8086:1549 (Revision: 0, TB Version: 1, Type: Port (0x1))
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 7/7
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x700000
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:  Port 1: 8086:1549 (Revision: 0, TB Version: 1, Type: Port (0x1))
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 8/8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 4
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x3c00000
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:  Port 2: 8086:1549 (Revision: 0, TB Version: 1, Type: PCIe (0x100102))
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max hop id (in/out): 8/8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   Max counters: 2
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0:   NFC Credits: 0x700000
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3: hotplug: activating pcie devices
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6 <-> 3:2 (PCI): activating
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: activating path from 0:6 to 3:2
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1: Writing hop 1, index 8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1:  Hop through port 2 to hop 8 (enabled)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1:    Counter enabled: 0 Counter index: 2047
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6: Writing hop 0, index 8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6:  Hop through port 3 to hop 8 (enabled)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6:    Counter enabled: 0 Counter index: 2047
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: activating path from 3:2 to 0:6
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3: Writing hop 1, index 8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3:  Hop through port 6 to hop 8 (enabled)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3:    Counter enabled: 0 Counter index: 2047
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2: Writing hop 0, index 8
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2:  Hop through port 1 to hop 8 (enabled)
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2:    Counter enabled: 0 Counter index: 2047
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 11:06:36 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 11:06:36 csarch kernel: pciehp 0000:07:03.0:pcie24: Card present on Slot(3-1)
Okt 27 11:06:36 csarch kernel: pciehp 0000:07:03.0:pcie24: slot(3-1): Link Up event
Okt 27 11:06:36 csarch kernel: pciehp 0000:07:03.0:pcie24: Link Up event ignored on slot(3-1): already powering on
Okt 27 11:06:36 csarch libvirtd[1429]: Device 0000:09:00.0 not found: could not access /sys/bus/pci/devices/0000:09:00.0/config: No such file 
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: [8086:1549] type 01 class 0x060400
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: supports D1 D2
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: PME# supported from D0 D1 D2 D3hot D3cold
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: bridge configuration invalid ([bus 00-00]), reconfiguring
Okt 27 11:06:36 csarch kernel: acpiphp: Slot [1] registered
Okt 27 11:06:36 csarch kernel: acpiphp: Slot [2-1] registered
Okt 27 11:06:36 csarch kernel: acpiphp: Slot [3-2] registered
Okt 27 11:06:36 csarch kernel: acpiphp: Slot [4-2] registered
Okt 27 11:06:36 csarch kernel: acpiphp: Slot [5-2] registered

Okt 27 11:06:36 csarch kernel: pci_bus 0000:0a: busn_res: can not insert [bus 0a-ff] under [bus 09-39] (conflicts with (null) [bus 09-39])
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: [8086:1549] type 01 class 0x060400
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: supports D1 D2
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: PME# supported from D0 D1 D2 D3hot D3cold
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: PCI bridge to [bus 0a-ff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [io  0x0000-0x0fff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0x00000000-0x000fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: bridge configuration invalid ([bus 00-00]), reconfiguring
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: [14e4:1682] type 00 class 0x020000
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: reg 0x10: [mem 0x00000000-0x0000ffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: reg 0x18: [mem 0x00000000-0x0000ffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: reg 0x30: [mem 0x00000000-0x0000ffff pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: PME# supported from D0 D3hot D3cold
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: PCI bridge to [bus 0b-ff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [io  0x0000-0x0fff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0x00000000-0x000fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0x00000000-0x000fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci_bus 0000:0b: busn_res: [bus 0b-ff] end is updated to 0b
Okt 27 11:06:36 csarch kernel: pci_bus 0000:0a: busn_res: [bus 0a-ff] end is updated to 0b
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: bridge window [mem 0x00100000-0x001fffff 64bit pref] to [bus 0b] add_size 200000 add_align 10
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: bridge window [mem 0x00100000-0x001fffff] to [bus 0b] add_size 200000 add_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: bridge window [mem 0x00100000-0x001fffff 64bit pref] to [bus 0a-0b] add_size 200000 add_align
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: bridge window [mem 0x00100000-0x001fffff] to [bus 0a-0b] add_size 200000 add_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: res[14]=[mem 0x00100000-0x003fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: res[15]=[mem 0x00100000-0x003fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: BAR 14: assigned [mem 0xc2000000-0xc22fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: BAR 15: assigned [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: BAR 13: assigned [io  0x3000-0x3fff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x001fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[14]=[mem 0x00100000-0x003fffff] res_to_dev_res add_size 200000 min_align 100000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x001fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: res[15]=[mem 0x00100000-0x003fffff 64bit pref] res_to_dev_res add_size 200000 min_align 10000
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: BAR 14: assigned [mem 0xc2000000-0xc22fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: BAR 15: assigned [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: BAR 13: assigned [io  0x3000-0x3fff]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: BAR 0: assigned [mem 0xce000000-0xce00ffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: BAR 2: assigned [mem 0xce010000-0xce01ffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0b:00.0: BAR 6: assigned [mem 0xc2000000-0xc200ffff pref]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0: PCI bridge to [bus 0b]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0xc2000000-0xc22fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:0a:00.0:   bridge window [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0: PCI bridge to [bus 0a-0b]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0xc2000000-0xc22fffff]
Okt 27 11:06:36 csarch kernel: pci 0000:09:00.0:   bridge window [mem 0xce000000-0xce2fffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pcieport 0000:07:03.0: PCI bridge to [bus 09-39]
Okt 27 11:06:36 csarch kernel: pcieport 0000:07:03.0:   bridge window [io  0x3000-0x3fff]
Okt 27 11:06:36 csarch kernel: pcieport 0000:07:03.0:   bridge window [mem 0xc2000000-0xc5ffffff]
Okt 27 11:06:36 csarch kernel: pcieport 0000:07:03.0:   bridge window [mem 0xce000000-0xd1ffffff 64bit pref]
Okt 27 11:06:36 csarch kernel: pcieport 0000:09:00.0: enabling device (0000 -> 0003)
Okt 27 11:06:36 csarch kernel: pcieport 0000:0a:00.0: enabling device (0000 -> 0003)
Okt 27 11:06:36 csarch kernel: pciehp 0000:0a:00.0:pcie24: Slot #9 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+ Interlock- NoCom
Okt 27 11:06:36 csarch kernel: pciehp 0000:0a:00.0:pcie24: service driver pciehp loaded
Okt 27 11:06:36 csarch kernel: tg3 0000:0b:00.0: enabling device (0000 -> 0002)
Okt 27 11:06:36 csarch NetworkManager[703]: <warn>  (eth0): failed to find device 22 'eth0' with udev
Okt 27 11:06:36 csarch NetworkManager[703]: <info>  (eth0): new Ethernet device (carrier: OFF, driver: 'tg3', ifindex: 22)
Okt 27 11:06:36 csarch kernel: tg3 0000:0b:00.0 eth0: Tigon3 [partno(BCM957762) rev 57766000] (PCI Express) MAC address 10:dd:b1:d3:7d:85
Okt 27 11:06:36 csarch kernel: tg3 0000:0b:00.0 eth0: attached PHY is 57765 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
Okt 27 11:06:36 csarch kernel: tg3 0000:0b:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
Okt 27 11:06:36 csarch kernel: tg3 0000:0b:00.0 eth0: dma_rwctrl[00000001] dma_mask[64-bit]
Okt 27 11:06:36 csarch NetworkManager[703]: <info>  (eth0): device state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
Okt 27 11:06:36 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Okt 27 11:06:37 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Okt 27 11:06:38 csarch kernel: tg3 0000:0b:00.0 eth0: Link is up at 100 Mbps, full duplex
Okt 27 11:06:38 csarch kernel: tg3 0000:0b:00.0 eth0: Flow control is on for TX and on for RX
Okt 27 11:06:38 csarch kernel: tg3 0000:0b:00.0 eth0: EEE is disabled
Okt 27 11:06:38 csarch kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): link connected
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: unavailable -> disconnected (reason 'carrier-changed') [20 30
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: disconnected -> prepare (reason 'none') [30 40 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: prepare -> config (reason 'none') [40 50 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: config -> ip-config (reason 'none') [50 70 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): DHCPv4 state changed unknown -> bound
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: ip-config -> ip-check (reason 'none') [70 80 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: ip-check -> secondaries (reason 'none') [80 90 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): device state change: secondaries -> activated (reason 'none') [90 100 0]
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  NetworkManager state is now CONNECTED_LOCAL
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  NetworkManager state is now CONNECTED_GLOBAL
Okt 27 11:06:38 csarch NetworkManager[703]: <info>  (eth0): Activation: successful, device activated.
Okt 27 11:06:42 csarch kernel: pciehp 0000:07:03.0:pcie24: Card not present on Slot(3-1)
Okt 27 11:06:42 csarch kernel: pciehp 0000:07:03.0:pcie24: slot(3-1): Link Down event
Okt 27 11:06:42 csarch kernel: pciehp 0000:07:03.0:pcie24: Link Down event ignored on slot(3-1): already powering off
Okt 27 11:06:42 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:3.
Okt 27 11:06:42 csarch kernel: thunderbolt 0000:08:00.0: 0:3: unplugged
Okt 27 11:06:42 csarch kernel: thunderbolt 0000:08:00.0: 0:6 <-> 3:2 (PCI): deactivating
Okt 27 11:06:43 csarch kernel: tg3 0000:0b:00.0: tg3_abort_hw timed out, TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff
Okt 27 11:06:43 csarch dhclient[20207]: receive_packet failed on eth0: Network is down
Okt 27 11:06:43 csarch NetworkManager[703]: <info>  (eth0): device state change: activated -> unmanaged (reason 'removed') [100 10 36]
Okt 27 11:06:43 csarch kernel: thunderbolt 0000:08:00.0: 3:2: TB_CAP_PCIE not found: -5
Okt 27 11:06:43 csarch kernel: thunderbolt 0000:08:00.0: deactivating path from 3:2 to 0:6
Okt 27 11:06:43 csarch kernel: thunderbolt 0000:08:00.0: 3:2: hop deactivation failed for hop 0, index 8
Okt 27 11:06:43 csarch kernel: thunderbolt 0000:08:00.0: deactivating path from 0:6 to 3:2
Okt 27 11:06:43 csarch kernel: thunderbolt 0000:08:00.0: 3:1: hop deactivation failed for hop 1, index 8
Okt 27 11:06:43 csarch NetworkManager[703]: <info>  (eth0): canceled DHCP transaction, DHCP client pid 20207
Okt 27 11:06:43 csarch NetworkManager[703]: <info>  (eth0): DHCPv4 state changed bound -> done
Okt 27 11:06:43 csarch kernel: pciehp 0000:0a:00.0:pcie24: unloading service driver pciehp
Okt 27 11:06:43 csarch kernel: pciehp 0000:0a:00.0:pcie24: Timeout on hotplug command 0x1038 (issued 7190 msec ago)
Okt 27 11:06:43 csarch kernel: pciehp 0000:0a:00.0:pcie24: pcie_do_write_cmd: no response from device
Okt 27 11:06:43 csarch kernel: pci_bus 0000:0b: busn_res: [bus 0b] is released
Okt 27 11:06:44 csarch kernel: pci_bus 0000:0a: busn_res: [bus 0a-0b] is released
Okt 27 11:06:44 csarch kernel: acpiphp: Slot [1] unregistered
Okt 27 11:06:44 csarch kernel: acpiphp: Slot [2-1] unregistered
Okt 27 11:06:44 csarch kernel: acpiphp: Slot [3-2] unregistered
Okt 27 11:06:44 csarch kernel: acpiphp: Slot [4-2] unregistered
Okt 27 11:06:44 csarch kernel: acpiphp: Slot [5-2] unregistered
Okt 27 11:06:44 csarch NetworkManager[703]: <warn>  (eth0): failed to disable userspace IPv6LL address handling



--------------070502040401080406030802
Content-Type: text/plain; charset=UTF-8;
 name="kernel_config"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="kernel_config"

IwojIEF1dG9tYXRpY2FsbHkgZ2VuZXJhdGVkIGZpbGU7IERPIE5PVCBFRElULgojIExpbnV4
L3g4NiA0LjMuMC1yYzcgS2VybmVsIENvbmZpZ3VyYXRpb24KIwpDT05GSUdfNjRCSVQ9eQpD
T05GSUdfWDg2XzY0PXkKQ09ORklHX1g4Nj15CkNPTkZJR19JTlNUUlVDVElPTl9ERUNPREVS
PXkKQ09ORklHX1BFUkZfRVZFTlRTX0lOVEVMX1VOQ09SRT15CkNPTkZJR19PVVRQVVRfRk9S
TUFUPSJlbGY2NC14ODYtNjQiCkNPTkZJR19BUkNIX0RFRkNPTkZJRz0iYXJjaC94ODYvY29u
Zmlncy94ODZfNjRfZGVmY29uZmlnIgpDT05GSUdfTE9DS0RFUF9TVVBQT1JUPXkKQ09ORklH
X1NUQUNLVFJBQ0VfU1VQUE9SVD15CkNPTkZJR19IQVZFX0xBVEVOQ1lUT1BfU1VQUE9SVD15
CkNPTkZJR19NTVU9eQpDT05GSUdfTkVFRF9ETUFfTUFQX1NUQVRFPXkKQ09ORklHX05FRURf
U0dfRE1BX0xFTkdUSD15CkNPTkZJR19HRU5FUklDX0lTQV9ETUE9eQpDT05GSUdfR0VORVJJ
Q19CVUc9eQpDT05GSUdfR0VORVJJQ19CVUdfUkVMQVRJVkVfUE9JTlRFUlM9eQpDT05GSUdf
R0VORVJJQ19IV0VJR0hUPXkKQ09ORklHX0FSQ0hfTUFZX0hBVkVfUENfRkRDPXkKQ09ORklH
X1JXU0VNX1hDSEdBRERfQUxHT1JJVEhNPXkKQ09ORklHX0dFTkVSSUNfQ0FMSUJSQVRFX0RF
TEFZPXkKQ09ORklHX0FSQ0hfSEFTX0NQVV9SRUxBWD15CkNPTkZJR19BUkNIX0hBU19DQUNI
RV9MSU5FX1NJWkU9eQpDT05GSUdfSEFWRV9TRVRVUF9QRVJfQ1BVX0FSRUE9eQpDT05GSUdf
TkVFRF9QRVJfQ1BVX0VNQkVEX0ZJUlNUX0NIVU5LPXkKQ09ORklHX05FRURfUEVSX0NQVV9Q
QUdFX0ZJUlNUX0NIVU5LPXkKQ09ORklHX0FSQ0hfSElCRVJOQVRJT05fUE9TU0lCTEU9eQpD
T05GSUdfQVJDSF9TVVNQRU5EX1BPU1NJQkxFPXkKQ09ORklHX0FSQ0hfV0FOVF9IVUdFX1BN
RF9TSEFSRT15CkNPTkZJR19BUkNIX1dBTlRfR0VORVJBTF9IVUdFVExCPXkKQ09ORklHX1pP
TkVfRE1BMzI9eQpDT05GSUdfQVVESVRfQVJDSD15CkNPTkZJR19BUkNIX1NVUFBPUlRTX09Q
VElNSVpFRF9JTkxJTklORz15CkNPTkZJR19BUkNIX1NVUFBPUlRTX0RFQlVHX1BBR0VBTExP
Qz15CkNPTkZJR19IQVZFX0lOVEVMX1RYVD15CkNPTkZJR19YODZfNjRfU01QPXkKQ09ORklH
X0FSQ0hfSFdFSUdIVF9DRkxBR1M9Ii1mY2FsbC1zYXZlZC1yZGkgLWZjYWxsLXNhdmVkLXJz
aSAtZmNhbGwtc2F2ZWQtcmR4IC1mY2FsbC1zYXZlZC1yY3ggLWZjYWxsLXNhdmVkLXI4IC1m
Y2FsbC1zYXZlZC1yOSAtZmNhbGwtc2F2ZWQtcjEwIC1mY2FsbC1zYXZlZC1yMTEiCkNPTkZJ
R19BUkNIX1NVUFBPUlRTX1VQUk9CRVM9eQpDT05GSUdfRklYX0VBUkxZQ09OX01FTT15CkNP
TkZJR19QR1RBQkxFX0xFVkVMUz00CkNPTkZJR19ERUZDT05GSUdfTElTVD0iL2xpYi9tb2R1
bGVzLyRVTkFNRV9SRUxFQVNFLy5jb25maWciCkNPTkZJR19JUlFfV09SSz15CkNPTkZJR19C
VUlMRFRJTUVfRVhUQUJMRV9TT1JUPXkKCiMKIyBHZW5lcmFsIHNldHVwCiMKQ09ORklHX0lO
SVRfRU5WX0FSR19MSU1JVD0zMgpDT05GSUdfQ1JPU1NfQ09NUElMRT0iIgojIENPTkZJR19D
T01QSUxFX1RFU1QgaXMgbm90IHNldApDT05GSUdfTE9DQUxWRVJTSU9OPSItQ1VTVE9NIgpD
T05GSUdfTE9DQUxWRVJTSU9OX0FVVE89eQpDT05GSUdfSEFWRV9LRVJORUxfR1pJUD15CkNP
TkZJR19IQVZFX0tFUk5FTF9CWklQMj15CkNPTkZJR19IQVZFX0tFUk5FTF9MWk1BPXkKQ09O
RklHX0hBVkVfS0VSTkVMX1haPXkKQ09ORklHX0hBVkVfS0VSTkVMX0xaTz15CkNPTkZJR19I
QVZFX0tFUk5FTF9MWjQ9eQpDT05GSUdfS0VSTkVMX0daSVA9eQojIENPTkZJR19LRVJORUxf
QlpJUDIgaXMgbm90IHNldAojIENPTkZJR19LRVJORUxfTFpNQSBpcyBub3Qgc2V0CiMgQ09O
RklHX0tFUk5FTF9YWiBpcyBub3Qgc2V0CiMgQ09ORklHX0tFUk5FTF9MWk8gaXMgbm90IHNl
dAojIENPTkZJR19LRVJORUxfTFo0IGlzIG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfSE9TVE5B
TUU9Iihub25lKSIKQ09ORklHX1NXQVA9eQpDT05GSUdfU1lTVklQQz15CkNPTkZJR19TWVNW
SVBDX1NZU0NUTD15CkNPTkZJR19QT1NJWF9NUVVFVUU9eQpDT05GSUdfUE9TSVhfTVFVRVVF
X1NZU0NUTD15CkNPTkZJR19DUk9TU19NRU1PUllfQVRUQUNIPXkKQ09ORklHX0ZIQU5ETEU9
eQojIENPTkZJR19VU0VMSUIgaXMgbm90IHNldAojIENPTkZJR19BVURJVCBpcyBub3Qgc2V0
CkNPTkZJR19IQVZFX0FSQ0hfQVVESVRTWVNDQUxMPXkKCiMKIyBJUlEgc3Vic3lzdGVtCiMK
Q09ORklHX0dFTkVSSUNfSVJRX1BST0JFPXkKQ09ORklHX0dFTkVSSUNfSVJRX1NIT1c9eQpD
T05GSUdfR0VORVJJQ19QRU5ESU5HX0lSUT15CkNPTkZJR19JUlFfRE9NQUlOPXkKQ09ORklH
X0lSUV9ET01BSU5fSElFUkFSQ0hZPXkKQ09ORklHX0dFTkVSSUNfTVNJX0lSUT15CkNPTkZJ
R19HRU5FUklDX01TSV9JUlFfRE9NQUlOPXkKIyBDT05GSUdfSVJRX0RPTUFJTl9ERUJVRyBp
cyBub3Qgc2V0CkNPTkZJR19JUlFfRk9SQ0VEX1RIUkVBRElORz15CkNPTkZJR19TUEFSU0Vf
SVJRPXkKQ09ORklHX0NMT0NLU09VUkNFX1dBVENIRE9HPXkKQ09ORklHX0FSQ0hfQ0xPQ0tT
T1VSQ0VfREFUQT15CkNPTkZJR19DTE9DS1NPVVJDRV9WQUxJREFURV9MQVNUX0NZQ0xFPXkK
Q09ORklHX0dFTkVSSUNfVElNRV9WU1lTQ0FMTD15CkNPTkZJR19HRU5FUklDX0NMT0NLRVZF
TlRTPXkKQ09ORklHX0dFTkVSSUNfQ0xPQ0tFVkVOVFNfQlJPQURDQVNUPXkKQ09ORklHX0dF
TkVSSUNfQ0xPQ0tFVkVOVFNfTUlOX0FESlVTVD15CkNPTkZJR19HRU5FUklDX0NNT1NfVVBE
QVRFPXkKCiMKIyBUaW1lcnMgc3Vic3lzdGVtCiMKQ09ORklHX1RJQ0tfT05FU0hPVD15CkNP
TkZJR19OT19IWl9DT01NT049eQojIENPTkZJR19IWl9QRVJJT0RJQyBpcyBub3Qgc2V0CkNP
TkZJR19OT19IWl9JRExFPXkKIyBDT05GSUdfTk9fSFpfRlVMTCBpcyBub3Qgc2V0CiMgQ09O
RklHX05PX0haIGlzIG5vdCBzZXQKQ09ORklHX0hJR0hfUkVTX1RJTUVSUz15CgojCiMgQ1BV
L1Rhc2sgdGltZSBhbmQgc3RhdHMgYWNjb3VudGluZwojCkNPTkZJR19USUNLX0NQVV9BQ0NP
VU5USU5HPXkKIyBDT05GSUdfVklSVF9DUFVfQUNDT1VOVElOR19HRU4gaXMgbm90IHNldAoj
IENPTkZJR19JUlFfVElNRV9BQ0NPVU5USU5HIGlzIG5vdCBzZXQKQ09ORklHX0JTRF9QUk9D
RVNTX0FDQ1Q9eQpDT05GSUdfQlNEX1BST0NFU1NfQUNDVF9WMz15CkNPTkZJR19UQVNLU1RB
VFM9eQpDT05GSUdfVEFTS19ERUxBWV9BQ0NUPXkKQ09ORklHX1RBU0tfWEFDQ1Q9eQpDT05G
SUdfVEFTS19JT19BQ0NPVU5USU5HPXkKCiMKIyBSQ1UgU3Vic3lzdGVtCiMKQ09ORklHX1BS
RUVNUFRfUkNVPXkKIyBDT05GSUdfUkNVX0VYUEVSVCBpcyBub3Qgc2V0CkNPTkZJR19TUkNV
PXkKIyBDT05GSUdfVEFTS1NfUkNVIGlzIG5vdCBzZXQKQ09ORklHX1JDVV9TVEFMTF9DT01N
T049eQojIENPTkZJR19UUkVFX1JDVV9UUkFDRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JDVV9F
WFBFRElURV9CT09UIGlzIG5vdCBzZXQKQ09ORklHX0JVSUxEX0JJTjJDPXkKQ09ORklHX0lL
Q09ORklHPXkKQ09ORklHX0lLQ09ORklHX1BST0M9eQpDT05GSUdfTE9HX0JVRl9TSElGVD0x
OQpDT05GSUdfTE9HX0NQVV9NQVhfQlVGX1NISUZUPTEyCkNPTkZJR19IQVZFX1VOU1RBQkxF
X1NDSEVEX0NMT0NLPXkKQ09ORklHX0FSQ0hfU1VQUE9SVFNfTlVNQV9CQUxBTkNJTkc9eQpD
T05GSUdfQVJDSF9XQU5UX0JBVENIRURfVU5NQVBfVExCX0ZMVVNIPXkKQ09ORklHX0FSQ0hf
U1VQUE9SVFNfSU5UMTI4PXkKQ09ORklHX05VTUFfQkFMQU5DSU5HPXkKQ09ORklHX05VTUFf
QkFMQU5DSU5HX0RFRkFVTFRfRU5BQkxFRD15CkNPTkZJR19DR1JPVVBTPXkKIyBDT05GSUdf
Q0dST1VQX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX0NHUk9VUF9GUkVFWkVSPXkKQ09ORklH
X0NHUk9VUF9QSURTPXkKQ09ORklHX0NHUk9VUF9ERVZJQ0U9eQpDT05GSUdfQ1BVU0VUUz15
CkNPTkZJR19QUk9DX1BJRF9DUFVTRVQ9eQpDT05GSUdfQ0dST1VQX0NQVUFDQ1Q9eQpDT05G
SUdfUEFHRV9DT1VOVEVSPXkKQ09ORklHX01FTUNHPXkKQ09ORklHX01FTUNHX1NXQVA9eQpD
T05GSUdfTUVNQ0dfU1dBUF9FTkFCTEVEPXkKQ09ORklHX01FTUNHX0tNRU09eQojIENPTkZJ
R19DR1JPVVBfSFVHRVRMQiBpcyBub3Qgc2V0CiMgQ09ORklHX0NHUk9VUF9QRVJGIGlzIG5v
dCBzZXQKQ09ORklHX0NHUk9VUF9TQ0hFRD15CkNPTkZJR19GQUlSX0dST1VQX1NDSEVEPXkK
Q09ORklHX0NGU19CQU5EV0lEVEg9eQojIENPTkZJR19SVF9HUk9VUF9TQ0hFRCBpcyBub3Qg
c2V0CkNPTkZJR19CTEtfQ0dST1VQPXkKIyBDT05GSUdfREVCVUdfQkxLX0NHUk9VUCBpcyBu
b3Qgc2V0CkNPTkZJR19DR1JPVVBfV1JJVEVCQUNLPXkKIyBDT05GSUdfQ0hFQ0tQT0lOVF9S
RVNUT1JFIGlzIG5vdCBzZXQKQ09ORklHX05BTUVTUEFDRVM9eQpDT05GSUdfVVRTX05TPXkK
Q09ORklHX0lQQ19OUz15CkNPTkZJR19VU0VSX05TPXkKQ09ORklHX1BJRF9OUz15CkNPTkZJ
R19ORVRfTlM9eQpDT05GSUdfU0NIRURfQVVUT0dST1VQPXkKIyBDT05GSUdfU1lTRlNfREVQ
UkVDQVRFRCBpcyBub3Qgc2V0CkNPTkZJR19SRUxBWT15CkNPTkZJR19CTEtfREVWX0lOSVRS
RD15CkNPTkZJR19JTklUUkFNRlNfU09VUkNFPSIiCkNPTkZJR19SRF9HWklQPXkKQ09ORklH
X1JEX0JaSVAyPXkKQ09ORklHX1JEX0xaTUE9eQpDT05GSUdfUkRfWFo9eQpDT05GSUdfUkRf
TFpPPXkKQ09ORklHX1JEX0xaND15CiMgQ09ORklHX0NDX09QVElNSVpFX0ZPUl9TSVpFIGlz
IG5vdCBzZXQKQ09ORklHX1NZU0NUTD15CkNPTkZJR19BTk9OX0lOT0RFUz15CkNPTkZJR19I
QVZFX1VJRDE2PXkKQ09ORklHX1NZU0NUTF9FWENFUFRJT05fVFJBQ0U9eQpDT05GSUdfSEFW
RV9QQ1NQS1JfUExBVEZPUk09eQpDT05GSUdfQlBGPXkKIyBDT05GSUdfRVhQRVJUIGlzIG5v
dCBzZXQKQ09ORklHX1VJRDE2PXkKQ09ORklHX01VTFRJVVNFUj15CkNPTkZJR19TR0VUTUFT
S19TWVNDQUxMPXkKQ09ORklHX1NZU0ZTX1NZU0NBTEw9eQojIENPTkZJR19TWVNDVExfU1lT
Q0FMTCBpcyBub3Qgc2V0CkNPTkZJR19LQUxMU1lNUz15CiMgQ09ORklHX0tBTExTWU1TX0FM
TCBpcyBub3Qgc2V0CkNPTkZJR19QUklOVEs9eQpDT05GSUdfQlVHPXkKQ09ORklHX0VMRl9D
T1JFPXkKQ09ORklHX1BDU1BLUl9QTEFURk9STT15CkNPTkZJR19CQVNFX0ZVTEw9eQpDT05G
SUdfRlVURVg9eQpDT05GSUdfRVBPTEw9eQpDT05GSUdfU0lHTkFMRkQ9eQpDT05GSUdfVElN
RVJGRD15CkNPTkZJR19FVkVOVEZEPXkKIyBDT05GSUdfQlBGX1NZU0NBTEwgaXMgbm90IHNl
dApDT05GSUdfU0hNRU09eQpDT05GSUdfQUlPPXkKQ09ORklHX0FEVklTRV9TWVNDQUxMUz15
CiMgQ09ORklHX1VTRVJGQVVMVEZEIGlzIG5vdCBzZXQKQ09ORklHX1BDSV9RVUlSS1M9eQpD
T05GSUdfTUVNQkFSUklFUj15CiMgQ09ORklHX0VNQkVEREVEIGlzIG5vdCBzZXQKQ09ORklH
X0hBVkVfUEVSRl9FVkVOVFM9eQoKIwojIEtlcm5lbCBQZXJmb3JtYW5jZSBFdmVudHMgQW5k
IENvdW50ZXJzCiMKQ09ORklHX1BFUkZfRVZFTlRTPXkKIyBDT05GSUdfREVCVUdfUEVSRl9V
U0VfVk1BTExPQyBpcyBub3Qgc2V0CkNPTkZJR19WTV9FVkVOVF9DT1VOVEVSUz15CkNPTkZJ
R19TTFVCX0RFQlVHPXkKIyBDT05GSUdfQ09NUEFUX0JSSyBpcyBub3Qgc2V0CiMgQ09ORklH
X1NMQUIgaXMgbm90IHNldApDT05GSUdfU0xVQj15CkNPTkZJR19TTFVCX0NQVV9QQVJUSUFM
PXkKIyBDT05GSUdfU1lTVEVNX0RBVEFfVkVSSUZJQ0FUSU9OIGlzIG5vdCBzZXQKQ09ORklH
X1BST0ZJTElORz15CkNPTkZJR19UUkFDRVBPSU5UUz15CkNPTkZJR19LRVhFQ19DT1JFPXkK
Q09ORklHX09QUk9GSUxFPW0KIyBDT05GSUdfT1BST0ZJTEVfRVZFTlRfTVVMVElQTEVYIGlz
IG5vdCBzZXQKQ09ORklHX0hBVkVfT1BST0ZJTEU9eQpDT05GSUdfT1BST0ZJTEVfTk1JX1RJ
TUVSPXkKQ09ORklHX0tQUk9CRVM9eQpDT05GSUdfSlVNUF9MQUJFTD15CiMgQ09ORklHX1NU
QVRJQ19LRVlTX1NFTEZURVNUIGlzIG5vdCBzZXQKQ09ORklHX0tQUk9CRVNfT05fRlRSQUNF
PXkKQ09ORklHX1VQUk9CRVM9eQojIENPTkZJR19IQVZFXzY0QklUX0FMSUdORURfQUNDRVNT
IGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfRUZGSUNJRU5UX1VOQUxJR05FRF9BQ0NFU1M9eQpD
T05GSUdfQVJDSF9VU0VfQlVJTFRJTl9CU1dBUD15CkNPTkZJR19LUkVUUFJPQkVTPXkKQ09O
RklHX1VTRVJfUkVUVVJOX05PVElGSUVSPXkKQ09ORklHX0hBVkVfSU9SRU1BUF9QUk9UPXkK
Q09ORklHX0hBVkVfS1BST0JFUz15CkNPTkZJR19IQVZFX0tSRVRQUk9CRVM9eQpDT05GSUdf
SEFWRV9PUFRQUk9CRVM9eQpDT05GSUdfSEFWRV9LUFJPQkVTX09OX0ZUUkFDRT15CkNPTkZJ
R19IQVZFX0FSQ0hfVFJBQ0VIT09LPXkKQ09ORklHX0hBVkVfRE1BX0FUVFJTPXkKQ09ORklH
X0hBVkVfRE1BX0NPTlRJR1VPVVM9eQpDT05GSUdfR0VORVJJQ19TTVBfSURMRV9USFJFQUQ9
eQpDT05GSUdfQVJDSF9XQU5UU19EWU5BTUlDX1RBU0tfU1RSVUNUPXkKQ09ORklHX0hBVkVf
UkVHU19BTkRfU1RBQ0tfQUNDRVNTX0FQST15CkNPTkZJR19IQVZFX0NMSz15CkNPTkZJR19I
QVZFX0RNQV9BUElfREVCVUc9eQpDT05GSUdfSEFWRV9IV19CUkVBS1BPSU5UPXkKQ09ORklH
X0hBVkVfTUlYRURfQlJFQUtQT0lOVFNfUkVHUz15CkNPTkZJR19IQVZFX1VTRVJfUkVUVVJO
X05PVElGSUVSPXkKQ09ORklHX0hBVkVfUEVSRl9FVkVOVFNfTk1JPXkKQ09ORklHX0hBVkVf
UEVSRl9SRUdTPXkKQ09ORklHX0hBVkVfUEVSRl9VU0VSX1NUQUNLX0RVTVA9eQpDT05GSUdf
SEFWRV9BUkNIX0pVTVBfTEFCRUw9eQpDT05GSUdfQVJDSF9IQVZFX05NSV9TQUZFX0NNUFhD
SEc9eQpDT05GSUdfSEFWRV9BTElHTkVEX1NUUlVDVF9QQUdFPXkKQ09ORklHX0hBVkVfQ01Q
WENIR19MT0NBTD15CkNPTkZJR19IQVZFX0NNUFhDSEdfRE9VQkxFPXkKQ09ORklHX0FSQ0hf
V0FOVF9DT01QQVRfSVBDX1BBUlNFX1ZFUlNJT049eQpDT05GSUdfQVJDSF9XQU5UX09MRF9D
T01QQVRfSVBDPXkKQ09ORklHX0hBVkVfQVJDSF9TRUNDT01QX0ZJTFRFUj15CkNPTkZJR19T
RUNDT01QX0ZJTFRFUj15CkNPTkZJR19IQVZFX0NDX1NUQUNLUFJPVEVDVE9SPXkKQ09ORklH
X0NDX1NUQUNLUFJPVEVDVE9SPXkKIyBDT05GSUdfQ0NfU1RBQ0tQUk9URUNUT1JfTk9ORSBp
cyBub3Qgc2V0CiMgQ09ORklHX0NDX1NUQUNLUFJPVEVDVE9SX1JFR1VMQVIgaXMgbm90IHNl
dApDT05GSUdfQ0NfU1RBQ0tQUk9URUNUT1JfU1RST05HPXkKQ09ORklHX0hBVkVfQ09OVEVY
VF9UUkFDS0lORz15CkNPTkZJR19IQVZFX1ZJUlRfQ1BVX0FDQ09VTlRJTkdfR0VOPXkKQ09O
RklHX0hBVkVfSVJRX1RJTUVfQUNDT1VOVElORz15CkNPTkZJR19IQVZFX0FSQ0hfVFJBTlNQ
QVJFTlRfSFVHRVBBR0U9eQpDT05GSUdfSEFWRV9BUkNIX0hVR0VfVk1BUD15CkNPTkZJR19I
QVZFX0FSQ0hfU09GVF9ESVJUWT15CkNPTkZJR19NT0RVTEVTX1VTRV9FTEZfUkVMQT15CkNP
TkZJR19IQVZFX0lSUV9FWElUX09OX0lSUV9TVEFDSz15CkNPTkZJR19BUkNIX0hBU19FTEZf
UkFORE9NSVpFPXkKQ09ORklHX0hBVkVfQ09QWV9USFJFQURfVExTPXkKQ09ORklHX09MRF9T
SUdTVVNQRU5EMz15CkNPTkZJR19DT01QQVRfT0xEX1NJR0FDVElPTj15CgojCiMgR0NPVi1i
YXNlZCBrZXJuZWwgcHJvZmlsaW5nCiMKIyBDT05GSUdfR0NPVl9LRVJORUwgaXMgbm90IHNl
dApDT05GSUdfQVJDSF9IQVNfR0NPVl9QUk9GSUxFX0FMTD15CiMgQ09ORklHX0hBVkVfR0VO
RVJJQ19ETUFfQ09IRVJFTlQgaXMgbm90IHNldApDT05GSUdfU0xBQklORk89eQpDT05GSUdf
UlRfTVVURVhFUz15CkNPTkZJR19CQVNFX1NNQUxMPTAKQ09ORklHX01PRFVMRVM9eQpDT05G
SUdfTU9EVUxFX0ZPUkNFX0xPQUQ9eQpDT05GSUdfTU9EVUxFX1VOTE9BRD15CkNPTkZJR19N
T0RVTEVfRk9SQ0VfVU5MT0FEPXkKQ09ORklHX01PRFZFUlNJT05TPXkKIyBDT05GSUdfTU9E
VUxFX1NSQ1ZFUlNJT05fQUxMIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9EVUxFX1NJRyBpcyBu
b3Qgc2V0CkNPTkZJR19NT0RVTEVfQ09NUFJFU1M9eQpDT05GSUdfTU9EVUxFX0NPTVBSRVNT
X0daSVA9eQojIENPTkZJR19NT0RVTEVfQ09NUFJFU1NfWFogaXMgbm90IHNldApDT05GSUdf
TU9EVUxFU19UUkVFX0xPT0tVUD15CkNPTkZJR19TVE9QX01BQ0hJTkU9eQpDT05GSUdfQkxP
Q0s9eQpDT05GSUdfQkxLX0RFVl9CU0c9eQpDT05GSUdfQkxLX0RFVl9CU0dMSUI9eQpDT05G
SUdfQkxLX0RFVl9JTlRFR1JJVFk9eQpDT05GSUdfQkxLX0RFVl9USFJPVFRMSU5HPXkKIyBD
T05GSUdfQkxLX0NNRExJTkVfUEFSU0VSIGlzIG5vdCBzZXQKCiMKIyBQYXJ0aXRpb24gVHlw
ZXMKIwpDT05GSUdfUEFSVElUSU9OX0FEVkFOQ0VEPXkKIyBDT05GSUdfQUNPUk5fUEFSVElU
SU9OIGlzIG5vdCBzZXQKQ09ORklHX0FJWF9QQVJUSVRJT049eQojIENPTkZJR19PU0ZfUEFS
VElUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfQU1JR0FfUEFSVElUSU9OIGlzIG5vdCBzZXQK
IyBDT05GSUdfQVRBUklfUEFSVElUSU9OIGlzIG5vdCBzZXQKQ09ORklHX01BQ19QQVJUSVRJ
T049eQpDT05GSUdfTVNET1NfUEFSVElUSU9OPXkKQ09ORklHX0JTRF9ESVNLTEFCRUw9eQpD
T05GSUdfTUlOSVhfU1VCUEFSVElUSU9OPXkKQ09ORklHX1NPTEFSSVNfWDg2X1BBUlRJVElP
Tj15CiMgQ09ORklHX1VOSVhXQVJFX0RJU0tMQUJFTCBpcyBub3Qgc2V0CkNPTkZJR19MRE1f
UEFSVElUSU9OPXkKIyBDT05GSUdfTERNX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfU0dJ
X1BBUlRJVElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VMVFJJWF9QQVJUSVRJT04gaXMgbm90
IHNldAojIENPTkZJR19TVU5fUEFSVElUSU9OIGlzIG5vdCBzZXQKQ09ORklHX0tBUk1BX1BB
UlRJVElPTj15CkNPTkZJR19FRklfUEFSVElUSU9OPXkKIyBDT05GSUdfU1lTVjY4X1BBUlRJ
VElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0NNRExJTkVfUEFSVElUSU9OIGlzIG5vdCBzZXQK
Q09ORklHX0JMT0NLX0NPTVBBVD15CgojCiMgSU8gU2NoZWR1bGVycwojCkNPTkZJR19JT1ND
SEVEX05PT1A9eQpDT05GSUdfSU9TQ0hFRF9ERUFETElORT15CkNPTkZJR19JT1NDSEVEX0NG
UT15CkNPTkZJR19DRlFfR1JPVVBfSU9TQ0hFRD15CiMgQ09ORklHX0RFRkFVTFRfREVBRExJ
TkUgaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9DRlE9eQojIENPTkZJR19ERUZBVUxUX05P
T1AgaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9JT1NDSEVEPSJjZnEiCkNPTkZJR19QUkVF
TVBUX05PVElGSUVSUz15CkNPTkZJR19QQURBVEE9eQpDT05GSUdfQVNOMT1tCkNPTkZJR19V
TklOTElORV9TUElOX1VOTE9DSz15CkNPTkZJR19BUkNIX1NVUFBPUlRTX0FUT01JQ19STVc9
eQpDT05GSUdfTVVURVhfU1BJTl9PTl9PV05FUj15CkNPTkZJR19SV1NFTV9TUElOX09OX09X
TkVSPXkKQ09ORklHX0xPQ0tfU1BJTl9PTl9PV05FUj15CkNPTkZJR19BUkNIX1VTRV9RVUVV
RURfU1BJTkxPQ0tTPXkKQ09ORklHX1FVRVVFRF9TUElOTE9DS1M9eQpDT05GSUdfQVJDSF9V
U0VfUVVFVUVEX1JXTE9DS1M9eQpDT05GSUdfUVVFVUVEX1JXTE9DS1M9eQpDT05GSUdfRlJF
RVpFUj15CgojCiMgUHJvY2Vzc29yIHR5cGUgYW5kIGZlYXR1cmVzCiMKQ09ORklHX1pPTkVf
RE1BPXkKQ09ORklHX1NNUD15CkNPTkZJR19YODZfRkVBVFVSRV9OQU1FUz15CkNPTkZJR19Y
ODZfWDJBUElDPXkKQ09ORklHX1g4Nl9NUFBBUlNFPXkKIyBDT05GSUdfWDg2X0VYVEVOREVE
X1BMQVRGT1JNIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9JTlRFTF9MUFNTPXkKIyBDT05GSUdf
WDg2X0FNRF9QTEFURk9STV9ERVZJQ0UgaXMgbm90IHNldApDT05GSUdfSU9TRl9NQkk9bQoj
IENPTkZJR19JT1NGX01CSV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19YODZfU1VQUE9SVFNf
TUVNT1JZX0ZBSUxVUkU9eQpDT05GSUdfU0NIRURfT01JVF9GUkFNRV9QT0lOVEVSPXkKQ09O
RklHX0hZUEVSVklTT1JfR1VFU1Q9eQpDT05GSUdfUEFSQVZJUlQ9eQojIENPTkZJR19QQVJB
VklSVF9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX1BBUkFWSVJUX1NQSU5MT0NLUyBpcyBu
b3Qgc2V0CkNPTkZJR19YRU49eQpDT05GSUdfWEVOX0RPTTA9eQpDT05GSUdfWEVOX1BWSFZN
PXkKQ09ORklHX1hFTl81MTJHQj15CkNPTkZJR19YRU5fU0FWRV9SRVNUT1JFPXkKIyBDT05G
SUdfWEVOX0RFQlVHX0ZTIGlzIG5vdCBzZXQKQ09ORklHX1hFTl9QVkg9eQpDT05GSUdfS1ZN
X0dVRVNUPXkKIyBDT05GSUdfS1ZNX0RFQlVHX0ZTIGlzIG5vdCBzZXQKQ09ORklHX1BBUkFW
SVJUX1RJTUVfQUNDT1VOVElORz15CkNPTkZJR19QQVJBVklSVF9DTE9DSz15CkNPTkZJR19O
T19CT09UTUVNPXkKIyBDT05GSUdfTUs4IGlzIG5vdCBzZXQKIyBDT05GSUdfTVBTQyBpcyBu
b3Qgc2V0CkNPTkZJR19NQ09SRTI9eQojIENPTkZJR19NQVRPTSBpcyBub3Qgc2V0CiMgQ09O
RklHX0dFTkVSSUNfQ1BVIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9JTlRFUk5PREVfQ0FDSEVf
U0hJRlQ9NgpDT05GSUdfWDg2X0wxX0NBQ0hFX1NISUZUPTYKQ09ORklHX1g4Nl9JTlRFTF9V
U0VSQ09QWT15CkNPTkZJR19YODZfVVNFX1BQUk9fQ0hFQ0tTVU09eQpDT05GSUdfWDg2X1A2
X05PUD15CkNPTkZJR19YODZfVFNDPXkKQ09ORklHX1g4Nl9DTVBYQ0hHNjQ9eQpDT05GSUdf
WDg2X0NNT1Y9eQpDT05GSUdfWDg2X01JTklNVU1fQ1BVX0ZBTUlMWT02NApDT05GSUdfWDg2
X0RFQlVHQ1RMTVNSPXkKQ09ORklHX0NQVV9TVVBfSU5URUw9eQpDT05GSUdfQ1BVX1NVUF9B
TUQ9eQpDT05GSUdfQ1BVX1NVUF9DRU5UQVVSPXkKQ09ORklHX0hQRVRfVElNRVI9eQpDT05G
SUdfSFBFVF9FTVVMQVRFX1JUQz15CkNPTkZJR19ETUk9eQojIENPTkZJR19HQVJUX0lPTU1V
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0FMR0FSWV9JT01NVSBpcyBub3Qgc2V0CkNPTkZJR19T
V0lPVExCPXkKQ09ORklHX0lPTU1VX0hFTFBFUj15CiMgQ09ORklHX01BWFNNUCBpcyBub3Qg
c2V0CkNPTkZJR19OUl9DUFVTPTEyOApDT05GSUdfU0NIRURfU01UPXkKQ09ORklHX1NDSEVE
X01DPXkKIyBDT05GSUdfUFJFRU1QVF9OT05FIGlzIG5vdCBzZXQKIyBDT05GSUdfUFJFRU1Q
VF9WT0xVTlRBUlkgaXMgbm90IHNldApDT05GSUdfUFJFRU1QVD15CkNPTkZJR19QUkVFTVBU
X0NPVU5UPXkKQ09ORklHX1g4Nl9MT0NBTF9BUElDPXkKQ09ORklHX1g4Nl9JT19BUElDPXkK
Q09ORklHX1g4Nl9SRVJPVVRFX0ZPUl9CUk9LRU5fQk9PVF9JUlFTPXkKQ09ORklHX1g4Nl9N
Q0U9eQpDT05GSUdfWDg2X01DRV9JTlRFTD15CiMgQ09ORklHX1g4Nl9NQ0VfQU1EIGlzIG5v
dCBzZXQKQ09ORklHX1g4Nl9NQ0VfVEhSRVNIT0xEPXkKIyBDT05GSUdfWDg2X01DRV9JTkpF
Q1QgaXMgbm90IHNldApDT05GSUdfWDg2X1RIRVJNQUxfVkVDVE9SPXkKIyBDT05GSUdfVk04
NiBpcyBub3Qgc2V0CkNPTkZJR19YODZfMTZCSVQ9eQpDT05GSUdfWDg2X0VTUEZJWDY0PXkK
Q09ORklHX1g4Nl9WU1lTQ0FMTF9FTVVMQVRJT049eQojIENPTkZJR19JOEsgaXMgbm90IHNl
dApDT05GSUdfTUlDUk9DT0RFPXkKQ09ORklHX01JQ1JPQ09ERV9JTlRFTD15CiMgQ09ORklH
X01JQ1JPQ09ERV9BTUQgaXMgbm90IHNldApDT05GSUdfTUlDUk9DT0RFX09MRF9JTlRFUkZB
Q0U9eQpDT05GSUdfTUlDUk9DT0RFX0lOVEVMX0VBUkxZPXkKQ09ORklHX01JQ1JPQ09ERV9F
QVJMWT15CkNPTkZJR19YODZfTVNSPW0KQ09ORklHX1g4Nl9DUFVJRD1tCkNPTkZJR19BUkNI
X1BIWVNfQUREUl9UXzY0QklUPXkKQ09ORklHX0FSQ0hfRE1BX0FERFJfVF82NEJJVD15CkNP
TkZJR19YODZfRElSRUNUX0dCUEFHRVM9eQpDT05GSUdfTlVNQT15CiMgQ09ORklHX0FNRF9O
VU1BIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl82NF9BQ1BJX05VTUE9eQpDT05GSUdfTk9ERVNf
U1BBTl9PVEhFUl9OT0RFUz15CiMgQ09ORklHX05VTUFfRU1VIGlzIG5vdCBzZXQKQ09ORklH
X05PREVTX1NISUZUPTYKQ09ORklHX0FSQ0hfU1BBUlNFTUVNX0VOQUJMRT15CkNPTkZJR19B
UkNIX1NQQVJTRU1FTV9ERUZBVUxUPXkKQ09ORklHX0FSQ0hfU0VMRUNUX01FTU9SWV9NT0RF
TD15CkNPTkZJR19BUkNIX01FTU9SWV9QUk9CRT15CkNPTkZJR19BUkNIX1BST0NfS0NPUkVf
VEVYVD15CkNPTkZJR19JTExFR0FMX1BPSU5URVJfVkFMVUU9MHhkZWFkMDAwMDAwMDAwMDAw
CkNPTkZJR19TRUxFQ1RfTUVNT1JZX01PREVMPXkKQ09ORklHX1NQQVJTRU1FTV9NQU5VQUw9
eQpDT05GSUdfU1BBUlNFTUVNPXkKQ09ORklHX05FRURfTVVMVElQTEVfTk9ERVM9eQpDT05G
SUdfSEFWRV9NRU1PUllfUFJFU0VOVD15CkNPTkZJR19TUEFSU0VNRU1fRVhUUkVNRT15CkNP
TkZJR19TUEFSU0VNRU1fVk1FTU1BUF9FTkFCTEU9eQpDT05GSUdfU1BBUlNFTUVNX0FMTE9D
X01FTV9NQVBfVE9HRVRIRVI9eQpDT05GSUdfU1BBUlNFTUVNX1ZNRU1NQVA9eQpDT05GSUdf
SEFWRV9NRU1CTE9DSz15CkNPTkZJR19IQVZFX01FTUJMT0NLX05PREVfTUFQPXkKQ09ORklH
X0FSQ0hfRElTQ0FSRF9NRU1CTE9DSz15CkNPTkZJR19NRU1PUllfSVNPTEFUSU9OPXkKIyBD
T05GSUdfTU9WQUJMRV9OT0RFIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfQk9PVE1FTV9JTkZP
X05PREU9eQpDT05GSUdfTUVNT1JZX0hPVFBMVUc9eQpDT05GSUdfTUVNT1JZX0hPVFBMVUdf
U1BBUlNFPXkKQ09ORklHX01FTU9SWV9IT1RSRU1PVkU9eQpDT05GSUdfUEFHRUZMQUdTX0VY
VEVOREVEPXkKQ09ORklHX1NQTElUX1BUTE9DS19DUFVTPTQKQ09ORklHX0FSQ0hfRU5BQkxF
X1NQTElUX1BNRF9QVExPQ0s9eQpDT05GSUdfTUVNT1JZX0JBTExPT049eQpDT05GSUdfQkFM
TE9PTl9DT01QQUNUSU9OPXkKQ09ORklHX0NPTVBBQ1RJT049eQpDT05GSUdfTUlHUkFUSU9O
PXkKQ09ORklHX0FSQ0hfRU5BQkxFX0hVR0VQQUdFX01JR1JBVElPTj15CkNPTkZJR19QSFlT
X0FERFJfVF82NEJJVD15CkNPTkZJR19aT05FX0RNQV9GTEFHPTEKQ09ORklHX0JPVU5DRT15
CkNPTkZJR19WSVJUX1RPX0JVUz15CkNPTkZJR19NTVVfTk9USUZJRVI9eQpDT05GSUdfS1NN
PXkKQ09ORklHX0RFRkFVTFRfTU1BUF9NSU5fQUREUj02NTUzNgpDT05GSUdfQVJDSF9TVVBQ
T1JUU19NRU1PUllfRkFJTFVSRT15CkNPTkZJR19NRU1PUllfRkFJTFVSRT15CkNPTkZJR19I
V1BPSVNPTl9JTkpFQ1Q9bQpDT05GSUdfVFJBTlNQQVJFTlRfSFVHRVBBR0U9eQpDT05GSUdf
VFJBTlNQQVJFTlRfSFVHRVBBR0VfQUxXQVlTPXkKIyBDT05GSUdfVFJBTlNQQVJFTlRfSFVH
RVBBR0VfTUFEVklTRSBpcyBub3Qgc2V0CkNPTkZJR19DTEVBTkNBQ0hFPXkKQ09ORklHX0ZS
T05UU1dBUD15CiMgQ09ORklHX0NNQSBpcyBub3Qgc2V0CkNPTkZJR19aU1dBUD15CkNPTkZJ
R19aUE9PTD15CkNPTkZJR19aQlVEPXkKQ09ORklHX1pTTUFMTE9DPXkKIyBDT05GSUdfUEdU
QUJMRV9NQVBQSU5HIGlzIG5vdCBzZXQKIyBDT05GSUdfWlNNQUxMT0NfU1RBVCBpcyBub3Qg
c2V0CkNPTkZJR19HRU5FUklDX0VBUkxZX0lPUkVNQVA9eQpDT05GSUdfQVJDSF9TVVBQT1JU
U19ERUZFUlJFRF9TVFJVQ1RfUEFHRV9JTklUPXkKIyBDT05GSUdfREVGRVJSRURfU1RSVUNU
X1BBR0VfSU5JVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lETEVfUEFHRV9UUkFDS0lORyBpcyBu
b3Qgc2V0CkNPTkZJR19GUkFNRV9WRUNUT1I9eQpDT05GSUdfWDg2X1BNRU1fTEVHQUNZX0RF
VklDRT15CkNPTkZJR19YODZfUE1FTV9MRUdBQ1k9eQpDT05GSUdfWDg2X0NIRUNLX0JJT1Nf
Q09SUlVQVElPTj15CkNPTkZJR19YODZfQk9PVFBBUkFNX01FTU9SWV9DT1JSVVBUSU9OX0NI
RUNLPXkKQ09ORklHX1g4Nl9SRVNFUlZFX0xPVz02NApDT05GSUdfTVRSUj15CkNPTkZJR19N
VFJSX1NBTklUSVpFUj15CkNPTkZJR19NVFJSX1NBTklUSVpFUl9FTkFCTEVfREVGQVVMVD0w
CkNPTkZJR19NVFJSX1NBTklUSVpFUl9TUEFSRV9SRUdfTlJfREVGQVVMVD0xCkNPTkZJR19Y
ODZfUEFUPXkKQ09ORklHX0FSQ0hfVVNFU19QR19VTkNBQ0hFRD15CkNPTkZJR19BUkNIX1JB
TkRPTT15CkNPTkZJR19YODZfU01BUD15CiMgQ09ORklHX1g4Nl9JTlRFTF9NUFggaXMgbm90
IHNldApDT05GSUdfRUZJPXkKQ09ORklHX0VGSV9TVFVCPXkKQ09ORklHX0VGSV9NSVhFRD15
CkNPTkZJR19TRUNDT01QPXkKIyBDT05GSUdfSFpfMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdf
SFpfMjUwIGlzIG5vdCBzZXQKQ09ORklHX0haXzMwMD15CiMgQ09ORklHX0haXzEwMDAgaXMg
bm90IHNldApDT05GSUdfSFo9MzAwCkNPTkZJR19TQ0hFRF9IUlRJQ0s9eQpDT05GSUdfS0VY
RUM9eQpDT05GSUdfQ1JBU0hfRFVNUD15CkNPTkZJR19LRVhFQ19KVU1QPXkKQ09ORklHX1BI
WVNJQ0FMX1NUQVJUPTB4MTAwMDAwMApDT05GSUdfUkVMT0NBVEFCTEU9eQojIENPTkZJR19S
QU5ET01JWkVfQkFTRSBpcyBub3Qgc2V0CkNPTkZJR19QSFlTSUNBTF9BTElHTj0weDEwMDAw
MDAKQ09ORklHX0hPVFBMVUdfQ1BVPXkKIyBDT05GSUdfQk9PVFBBUkFNX0hPVFBMVUdfQ1BV
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX0hPVFBMVUdfQ1BVMCBpcyBub3Qgc2V0CiMg
Q09ORklHX0NPTVBBVF9WRFNPIGlzIG5vdCBzZXQKIyBDT05GSUdfQ01ETElORV9CT09MIGlz
IG5vdCBzZXQKQ09ORklHX01PRElGWV9MRFRfU1lTQ0FMTD15CkNPTkZJR19IQVZFX0xJVkVQ
QVRDSD15CkNPTkZJR19BUkNIX0VOQUJMRV9NRU1PUllfSE9UUExVRz15CkNPTkZJR19BUkNI
X0VOQUJMRV9NRU1PUllfSE9UUkVNT1ZFPXkKQ09ORklHX1VTRV9QRVJDUFVfTlVNQV9OT0RF
X0lEPXkKCiMKIyBQb3dlciBtYW5hZ2VtZW50IGFuZCBBQ1BJIG9wdGlvbnMKIwpDT05GSUdf
QVJDSF9ISUJFUk5BVElPTl9IRUFERVI9eQpDT05GSUdfU1VTUEVORD15CkNPTkZJR19TVVNQ
RU5EX0ZSRUVaRVI9eQpDT05GSUdfSElCRVJOQVRFX0NBTExCQUNLUz15CkNPTkZJR19ISUJF
Uk5BVElPTj15CkNPTkZJR19QTV9TVERfUEFSVElUSU9OPSIiCkNPTkZJR19QTV9TTEVFUD15
CkNPTkZJR19QTV9TTEVFUF9TTVA9eQpDT05GSUdfUE1fQVVUT1NMRUVQPXkKQ09ORklHX1BN
X1dBS0VMT0NLUz15CkNPTkZJR19QTV9XQUtFTE9DS1NfTElNSVQ9MTAwCkNPTkZJR19QTV9X
QUtFTE9DS1NfR0M9eQpDT05GSUdfUE09eQpDT05GSUdfUE1fREVCVUc9eQpDT05GSUdfUE1f
QURWQU5DRURfREVCVUc9eQojIENPTkZJR19QTV9URVNUX1NVU1BFTkQgaXMgbm90IHNldApD
T05GSUdfUE1fU0xFRVBfREVCVUc9eQpDT05GSUdfRFBNX1dBVENIRE9HPXkKQ09ORklHX0RQ
TV9XQVRDSERPR19USU1FT1VUPTYwCkNPTkZJR19QTV9UUkFDRT15CkNPTkZJR19QTV9UUkFD
RV9SVEM9eQpDT05GSUdfUE1fQ0xLPXkKIyBDT05GSUdfV1FfUE9XRVJfRUZGSUNJRU5UX0RF
RkFVTFQgaXMgbm90IHNldApDT05GSUdfQUNQST15CkNPTkZJR19BQ1BJX0xFR0FDWV9UQUJM
RVNfTE9PS1VQPXkKQ09ORklHX0FSQ0hfTUlHSFRfSEFWRV9BQ1BJX1BEQz15CkNPTkZJR19B
Q1BJX1NZU1RFTV9QT1dFUl9TVEFURVNfU1VQUE9SVD15CkNPTkZJR19BQ1BJX1NMRUVQPXkK
IyBDT05GSUdfQUNQSV9QUk9DRlNfUE9XRVIgaXMgbm90IHNldApDT05GSUdfQUNQSV9SRVZf
T1ZFUlJJREVfUE9TU0lCTEU9eQpDT05GSUdfQUNQSV9FQ19ERUJVR0ZTPW0KQ09ORklHX0FD
UElfQUM9bQpDT05GSUdfQUNQSV9CQVRURVJZPW0KQ09ORklHX0FDUElfQlVUVE9OPW0KQ09O
RklHX0FDUElfVklERU89bQpDT05GSUdfQUNQSV9GQU49bQpDT05GSUdfQUNQSV9ET0NLPXkK
Q09ORklHX0FDUElfQ1BVX0ZSRVFfUFNTPXkKQ09ORklHX0FDUElfUFJPQ0VTU09SX0lETEU9
eQpDT05GSUdfQUNQSV9QUk9DRVNTT1I9bQpDT05GSUdfQUNQSV9JUE1JPW0KQ09ORklHX0FD
UElfSE9UUExVR19DUFU9eQpDT05GSUdfQUNQSV9QUk9DRVNTT1JfQUdHUkVHQVRPUj1tCkNP
TkZJR19BQ1BJX1RIRVJNQUw9bQpDT05GSUdfQUNQSV9OVU1BPXkKIyBDT05GSUdfQUNQSV9D
VVNUT01fRFNEVCBpcyBub3Qgc2V0CkNPTkZJR19BQ1BJX0lOSVRSRF9UQUJMRV9PVkVSUklE
RT15CkNPTkZJR19BQ1BJX0RFQlVHPXkKQ09ORklHX0FDUElfUENJX1NMT1Q9eQpDT05GSUdf
WDg2X1BNX1RJTUVSPXkKQ09ORklHX0FDUElfQ09OVEFJTkVSPXkKQ09ORklHX0FDUElfSE9U
UExVR19NRU1PUlk9eQpDT05GSUdfQUNQSV9IT1RQTFVHX0lPQVBJQz15CkNPTkZJR19BQ1BJ
X1NCUz1tCkNPTkZJR19BQ1BJX0hFRD15CkNPTkZJR19BQ1BJX0NVU1RPTV9NRVRIT0Q9bQpD
T05GSUdfQUNQSV9CR1JUPXkKIyBDT05GSUdfQUNQSV9SRURVQ0VEX0hBUkRXQVJFX09OTFkg
aXMgbm90IHNldApDT05GSUdfQUNQSV9ORklUPW0KIyBDT05GSUdfQUNQSV9ORklUX0RFQlVH
IGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfQUNQSV9BUEVJPXkKQ09ORklHX0hBVkVfQUNQSV9B
UEVJX05NST15CkNPTkZJR19BQ1BJX0FQRUk9eQpDT05GSUdfQUNQSV9BUEVJX0dIRVM9eQpD
T05GSUdfQUNQSV9BUEVJX1BDSUVBRVI9eQpDT05GSUdfQUNQSV9BUEVJX01FTU9SWV9GQUlM
VVJFPXkKQ09ORklHX0FDUElfQVBFSV9FSU5KPW0KQ09ORklHX0FDUElfQVBFSV9FUlNUX0RF
QlVHPW0KQ09ORklHX0FDUElfRVhUTE9HPW0KIyBDT05GSUdfUE1JQ19PUFJFR0lPTiBpcyBu
b3Qgc2V0CkNPTkZJR19TRkk9eQoKIwojIENQVSBGcmVxdWVuY3kgc2NhbGluZwojCkNPTkZJ
R19DUFVfRlJFUT15CkNPTkZJR19DUFVfRlJFUV9HT1ZfQ09NTU9OPXkKQ09ORklHX0NQVV9G
UkVRX1NUQVQ9bQpDT05GSUdfQ1BVX0ZSRVFfU1RBVF9ERVRBSUxTPXkKIyBDT05GSUdfQ1BV
X0ZSRVFfREVGQVVMVF9HT1ZfUEVSRk9STUFOQ0UgaXMgbm90IHNldAojIENPTkZJR19DUFVf
RlJFUV9ERUZBVUxUX0dPVl9QT1dFUlNBVkUgaXMgbm90IHNldAojIENPTkZJR19DUFVfRlJF
UV9ERUZBVUxUX0dPVl9VU0VSU1BBQ0UgaXMgbm90IHNldApDT05GSUdfQ1BVX0ZSRVFfREVG
QVVMVF9HT1ZfT05ERU1BTkQ9eQojIENPTkZJR19DUFVfRlJFUV9ERUZBVUxUX0dPVl9DT05T
RVJWQVRJVkUgaXMgbm90IHNldApDT05GSUdfQ1BVX0ZSRVFfR09WX1BFUkZPUk1BTkNFPXkK
Q09ORklHX0NQVV9GUkVRX0dPVl9QT1dFUlNBVkU9bQpDT05GSUdfQ1BVX0ZSRVFfR09WX1VT
RVJTUEFDRT1tCkNPTkZJR19DUFVfRlJFUV9HT1ZfT05ERU1BTkQ9eQpDT05GSUdfQ1BVX0ZS
RVFfR09WX0NPTlNFUlZBVElWRT1tCgojCiMgQ1BVIGZyZXF1ZW5jeSBzY2FsaW5nIGRyaXZl
cnMKIwpDT05GSUdfWDg2X0lOVEVMX1BTVEFURT15CkNPTkZJR19YODZfUENDX0NQVUZSRVE9
bQpDT05GSUdfWDg2X0FDUElfQ1BVRlJFUT1tCkNPTkZJR19YODZfQUNQSV9DUFVGUkVRX0NQ
Qj15CiMgQ09ORklHX1g4Nl9QT1dFUk5PV19LOCBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9B
TURfRlJFUV9TRU5TSVRJVklUWSBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9TUEVFRFNURVBf
Q0VOVFJJTk8gaXMgbm90IHNldAojIENPTkZJR19YODZfUDRfQ0xPQ0tNT0QgaXMgbm90IHNl
dAoKIwojIHNoYXJlZCBvcHRpb25zCiMKIyBDT05GSUdfWDg2X1NQRUVEU1RFUF9MSUIgaXMg
bm90IHNldAoKIwojIENQVSBJZGxlCiMKQ09ORklHX0NQVV9JRExFPXkKQ09ORklHX0NQVV9J
RExFX0dPVl9MQURERVI9eQpDT05GSUdfQ1BVX0lETEVfR09WX01FTlU9eQojIENPTkZJR19B
UkNIX05FRURTX0NQVV9JRExFX0NPVVBMRUQgaXMgbm90IHNldApDT05GSUdfSU5URUxfSURM
RT15CgojCiMgTWVtb3J5IHBvd2VyIHNhdmluZ3MKIwpDT05GSUdfSTczMDBfSURMRV9JT0FU
X0NIQU5ORUw9eQpDT05GSUdfSTczMDBfSURMRT1tCgojCiMgQnVzIG9wdGlvbnMgKFBDSSBl
dGMuKQojCkNPTkZJR19QQ0k9eQpDT05GSUdfUENJX0RJUkVDVD15CkNPTkZJR19QQ0lfTU1D
T05GSUc9eQpDT05GSUdfUENJX1hFTj15CkNPTkZJR19QQ0lfRE9NQUlOUz15CkNPTkZJR19Q
Q0lFUE9SVEJVUz15CkNPTkZJR19IT1RQTFVHX1BDSV9QQ0lFPXkKQ09ORklHX1BDSUVBRVI9
eQojIENPTkZJR19QQ0lFX0VDUkMgaXMgbm90IHNldAojIENPTkZJR19QQ0lFQUVSX0lOSkVD
VCBpcyBub3Qgc2V0CkNPTkZJR19QQ0lFQVNQTT15CiMgQ09ORklHX1BDSUVBU1BNX0RFQlVH
IGlzIG5vdCBzZXQKQ09ORklHX1BDSUVBU1BNX0RFRkFVTFQ9eQojIENPTkZJR19QQ0lFQVNQ
TV9QT1dFUlNBVkUgaXMgbm90IHNldAojIENPTkZJR19QQ0lFQVNQTV9QRVJGT1JNQU5DRSBp
cyBub3Qgc2V0CkNPTkZJR19QQ0lFX1BNRT15CkNPTkZJR19QQ0lfQlVTX0FERFJfVF82NEJJ
VD15CkNPTkZJR19QQ0lfTVNJPXkKQ09ORklHX1BDSV9NU0lfSVJRX0RPTUFJTj15CiMgQ09O
RklHX1BDSV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19QQ0lfUkVBTExPQ19FTkFCTEVfQVVU
Tz15CkNPTkZJR19QQ0lfU1RVQj1tCkNPTkZJR19YRU5fUENJREVWX0ZST05URU5EPW0KQ09O
RklHX0hUX0lSUT15CkNPTkZJR19QQ0lfQVRTPXkKQ09ORklHX1BDSV9JT1Y9eQpDT05GSUdf
UENJX1BSST15CkNPTkZJR19QQ0lfUEFTSUQ9eQpDT05GSUdfUENJX0xBQkVMPXkKCiMKIyBQ
Q0kgaG9zdCBjb250cm9sbGVyIGRyaXZlcnMKIwpDT05GSUdfSVNBX0RNQV9BUEk9eQpDT05G
SUdfQU1EX05CPXkKIyBDT05GSUdfUENDQVJEIGlzIG5vdCBzZXQKQ09ORklHX0hPVFBMVUdf
UENJPXkKQ09ORklHX0hPVFBMVUdfUENJX0FDUEk9eQpDT05GSUdfSE9UUExVR19QQ0lfQUNQ
SV9JQk09bQpDT05GSUdfSE9UUExVR19QQ0lfQ1BDST15CkNPTkZJR19IT1RQTFVHX1BDSV9D
UENJX1pUNTU1MD1tCkNPTkZJR19IT1RQTFVHX1BDSV9DUENJX0dFTkVSSUM9bQpDT05GSUdf
SE9UUExVR19QQ0lfU0hQQz1tCkNPTkZJR19SQVBJRElPPW0KQ09ORklHX1JBUElESU9fVFNJ
NzIxPW0KQ09ORklHX1JBUElESU9fRElTQ19USU1FT1VUPTMwCiMgQ09ORklHX1JBUElESU9f
RU5BQkxFX1JYX1RYX1BPUlRTIGlzIG5vdCBzZXQKQ09ORklHX1JBUElESU9fRE1BX0VOR0lO
RT15CkNPTkZJR19SQVBJRElPX0RFQlVHPXkKQ09ORklHX1JBUElESU9fRU5VTV9CQVNJQz1t
CgojCiMgUmFwaWRJTyBTd2l0Y2ggZHJpdmVycwojCkNPTkZJR19SQVBJRElPX1RTSTU3WD1t
CkNPTkZJR19SQVBJRElPX0NQU19YWD1tCkNPTkZJR19SQVBJRElPX1RTSTU2OD1tCkNPTkZJ
R19SQVBJRElPX0NQU19HRU4yPW0KIyBDT05GSUdfWDg2X1NZU0ZCIGlzIG5vdCBzZXQKCiMK
IyBFeGVjdXRhYmxlIGZpbGUgZm9ybWF0cyAvIEVtdWxhdGlvbnMKIwpDT05GSUdfQklORk1U
X0VMRj15CkNPTkZJR19DT01QQVRfQklORk1UX0VMRj15CkNPTkZJR19DT1JFX0RVTVBfREVG
QVVMVF9FTEZfSEVBREVSUz15CkNPTkZJR19CSU5GTVRfU0NSSVBUPXkKIyBDT05GSUdfSEFW
RV9BT1VUIGlzIG5vdCBzZXQKQ09ORklHX0JJTkZNVF9NSVNDPXkKQ09ORklHX0NPUkVEVU1Q
PXkKQ09ORklHX0lBMzJfRU1VTEFUSU9OPXkKIyBDT05GSUdfSUEzMl9BT1VUIGlzIG5vdCBz
ZXQKIyBDT05GSUdfWDg2X1gzMiBpcyBub3Qgc2V0CkNPTkZJR19DT01QQVQ9eQpDT05GSUdf
Q09NUEFUX0ZPUl9VNjRfQUxJR05NRU5UPXkKQ09ORklHX1NZU1ZJUENfQ09NUEFUPXkKQ09O
RklHX0tFWVNfQ09NUEFUPXkKQ09ORklHX1g4Nl9ERVZfRE1BX09QUz15CkNPTkZJR19QTUNf
QVRPTT15CkNPTkZJR19ORVQ9eQpDT05GSUdfQ09NUEFUX05FVExJTktfTUVTU0FHRVM9eQpD
T05GSUdfTkVUX0lOR1JFU1M9eQoKIwojIE5ldHdvcmtpbmcgb3B0aW9ucwojCkNPTkZJR19Q
QUNLRVQ9eQpDT05GSUdfUEFDS0VUX0RJQUc9bQpDT05GSUdfVU5JWD15CkNPTkZJR19VTklY
X0RJQUc9bQpDT05GSUdfWEZSTT15CkNPTkZJR19YRlJNX0FMR089bQpDT05GSUdfWEZSTV9V
U0VSPW0KIyBDT05GSUdfWEZSTV9TVUJfUE9MSUNZIGlzIG5vdCBzZXQKIyBDT05GSUdfWEZS
TV9NSUdSQVRFIGlzIG5vdCBzZXQKIyBDT05GSUdfWEZSTV9TVEFUSVNUSUNTIGlzIG5vdCBz
ZXQKQ09ORklHX1hGUk1fSVBDT01QPW0KQ09ORklHX05FVF9LRVk9bQojIENPTkZJR19ORVRf
S0VZX01JR1JBVEUgaXMgbm90IHNldApDT05GSUdfSU5FVD15CkNPTkZJR19JUF9NVUxUSUNB
U1Q9eQpDT05GSUdfSVBfQURWQU5DRURfUk9VVEVSPXkKQ09ORklHX0lQX0ZJQl9UUklFX1NU
QVRTPXkKQ09ORklHX0lQX01VTFRJUExFX1RBQkxFUz15CkNPTkZJR19JUF9ST1VURV9NVUxU
SVBBVEg9eQpDT05GSUdfSVBfUk9VVEVfVkVSQk9TRT15CkNPTkZJR19JUF9ST1VURV9DTEFT
U0lEPXkKIyBDT05GSUdfSVBfUE5QIGlzIG5vdCBzZXQKQ09ORklHX05FVF9JUElQPW0KQ09O
RklHX05FVF9JUEdSRV9ERU1VWD1tCkNPTkZJR19ORVRfSVBfVFVOTkVMPW0KQ09ORklHX05F
VF9JUEdSRT1tCiMgQ09ORklHX05FVF9JUEdSRV9CUk9BRENBU1QgaXMgbm90IHNldApDT05G
SUdfSVBfTVJPVVRFPXkKIyBDT05GSUdfSVBfTVJPVVRFX01VTFRJUExFX1RBQkxFUyBpcyBu
b3Qgc2V0CkNPTkZJR19JUF9QSU1TTV9WMT15CkNPTkZJR19JUF9QSU1TTV9WMj15CkNPTkZJ
R19TWU5fQ09PS0lFUz15CkNPTkZJR19ORVRfSVBWVEk9bQpDT05GSUdfTkVUX1VEUF9UVU5O
RUw9bQpDT05GSUdfTkVUX0ZPVT1tCkNPTkZJR19ORVRfRk9VX0lQX1RVTk5FTFM9eQpDT05G
SUdfSU5FVF9BSD1tCkNPTkZJR19JTkVUX0VTUD1tCkNPTkZJR19JTkVUX0lQQ09NUD1tCkNP
TkZJR19JTkVUX1hGUk1fVFVOTkVMPW0KQ09ORklHX0lORVRfVFVOTkVMPW0KQ09ORklHX0lO
RVRfWEZSTV9NT0RFX1RSQU5TUE9SVD1tCkNPTkZJR19JTkVUX1hGUk1fTU9ERV9UVU5ORUw9
bQpDT05GSUdfSU5FVF9YRlJNX01PREVfQkVFVD1tCkNPTkZJR19JTkVUX0xSTz15CkNPTkZJ
R19JTkVUX0RJQUc9bQpDT05GSUdfSU5FVF9UQ1BfRElBRz1tCkNPTkZJR19JTkVUX1VEUF9E
SUFHPW0KQ09ORklHX1RDUF9DT05HX0FEVkFOQ0VEPXkKQ09ORklHX1RDUF9DT05HX0JJQz1t
CkNPTkZJR19UQ1BfQ09OR19DVUJJQz15CkNPTkZJR19UQ1BfQ09OR19XRVNUV09PRD1tCkNP
TkZJR19UQ1BfQ09OR19IVENQPW0KQ09ORklHX1RDUF9DT05HX0hTVENQPW0KQ09ORklHX1RD
UF9DT05HX0hZQkxBPW0KQ09ORklHX1RDUF9DT05HX1ZFR0FTPW0KQ09ORklHX1RDUF9DT05H
X1NDQUxBQkxFPW0KQ09ORklHX1RDUF9DT05HX0xQPW0KQ09ORklHX1RDUF9DT05HX1ZFTk89
bQpDT05GSUdfVENQX0NPTkdfWUVBSD1tCkNPTkZJR19UQ1BfQ09OR19JTExJTk9JUz1tCkNP
TkZJR19UQ1BfQ09OR19EQ1RDUD1tCkNPTkZJR19UQ1BfQ09OR19DREc9bQpDT05GSUdfREVG
QVVMVF9DVUJJQz15CiMgQ09ORklHX0RFRkFVTFRfUkVOTyBpcyBub3Qgc2V0CkNPTkZJR19E
RUZBVUxUX1RDUF9DT05HPSJjdWJpYyIKQ09ORklHX1RDUF9NRDVTSUc9eQpDT05GSUdfSVBW
Nj15CkNPTkZJR19JUFY2X1JPVVRFUl9QUkVGPXkKQ09ORklHX0lQVjZfUk9VVEVfSU5GTz15
CkNPTkZJR19JUFY2X09QVElNSVNUSUNfREFEPXkKQ09ORklHX0lORVQ2X0FIPW0KQ09ORklH
X0lORVQ2X0VTUD1tCkNPTkZJR19JTkVUNl9JUENPTVA9bQpDT05GSUdfSVBWNl9NSVA2PW0K
IyBDT05GSUdfSVBWNl9JTEEgaXMgbm90IHNldApDT05GSUdfSU5FVDZfWEZSTV9UVU5ORUw9
bQpDT05GSUdfSU5FVDZfVFVOTkVMPW0KQ09ORklHX0lORVQ2X1hGUk1fTU9ERV9UUkFOU1BP
UlQ9bQpDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1RVTk5FTD1tCkNPTkZJR19JTkVUNl9YRlJN
X01PREVfQkVFVD1tCkNPTkZJR19JTkVUNl9YRlJNX01PREVfUk9VVEVPUFRJTUlaQVRJT049
bQpDT05GSUdfSVBWNl9WVEk9bQpDT05GSUdfSVBWNl9TSVQ9bQpDT05GSUdfSVBWNl9TSVRf
NlJEPXkKQ09ORklHX0lQVjZfTkRJU0NfTk9ERVRZUEU9eQpDT05GSUdfSVBWNl9UVU5ORUw9
bQpDT05GSUdfSVBWNl9HUkU9bQpDT05GSUdfSVBWNl9NVUxUSVBMRV9UQUJMRVM9eQpDT05G
SUdfSVBWNl9TVUJUUkVFUz15CiMgQ09ORklHX0lQVjZfTVJPVVRFIGlzIG5vdCBzZXQKQ09O
RklHX05FVExBQkVMPXkKQ09ORklHX05FVFdPUktfU0VDTUFSSz15CkNPTkZJR19ORVRfUFRQ
X0NMQVNTSUZZPXkKQ09ORklHX05FVFdPUktfUEhZX1RJTUVTVEFNUElORz15CkNPTkZJR19O
RVRGSUxURVI9eQojIENPTkZJR19ORVRGSUxURVJfREVCVUcgaXMgbm90IHNldApDT05GSUdf
TkVURklMVEVSX0FEVkFOQ0VEPXkKQ09ORklHX0JSSURHRV9ORVRGSUxURVI9bQoKIwojIENv
cmUgTmV0ZmlsdGVyIENvbmZpZ3VyYXRpb24KIwpDT05GSUdfTkVURklMVEVSX0lOR1JFU1M9
eQpDT05GSUdfTkVURklMVEVSX05FVExJTks9bQpDT05GSUdfTkVURklMVEVSX05FVExJTktf
QUNDVD1tCkNPTkZJR19ORVRGSUxURVJfTkVUTElOS19RVUVVRT1tCkNPTkZJR19ORVRGSUxU
RVJfTkVUTElOS19MT0c9bQpDT05GSUdfTkZfQ09OTlRSQUNLPW0KQ09ORklHX05GX0xPR19D
T01NT049bQpDT05GSUdfTkZfQ09OTlRSQUNLX01BUks9eQpDT05GSUdfTkZfQ09OTlRSQUNL
X1NFQ01BUks9eQpDT05GSUdfTkZfQ09OTlRSQUNLX1pPTkVTPXkKQ09ORklHX05GX0NPTk5U
UkFDS19QUk9DRlM9eQpDT05GSUdfTkZfQ09OTlRSQUNLX0VWRU5UUz15CkNPTkZJR19ORl9D
T05OVFJBQ0tfVElNRU9VVD15CkNPTkZJR19ORl9DT05OVFJBQ0tfVElNRVNUQU1QPXkKQ09O
RklHX05GX0NPTk5UUkFDS19MQUJFTFM9eQpDT05GSUdfTkZfQ1RfUFJPVE9fRENDUD1tCkNP
TkZJR19ORl9DVF9QUk9UT19HUkU9bQpDT05GSUdfTkZfQ1RfUFJPVE9fU0NUUD1tCkNPTkZJ
R19ORl9DVF9QUk9UT19VRFBMSVRFPW0KQ09ORklHX05GX0NPTk5UUkFDS19BTUFOREE9bQpD
T05GSUdfTkZfQ09OTlRSQUNLX0ZUUD1tCkNPTkZJR19ORl9DT05OVFJBQ0tfSDMyMz1tCkNP
TkZJR19ORl9DT05OVFJBQ0tfSVJDPW0KQ09ORklHX05GX0NPTk5UUkFDS19CUk9BRENBU1Q9
bQpDT05GSUdfTkZfQ09OTlRSQUNLX05FVEJJT1NfTlM9bQpDT05GSUdfTkZfQ09OTlRSQUNL
X1NOTVA9bQpDT05GSUdfTkZfQ09OTlRSQUNLX1BQVFA9bQpDT05GSUdfTkZfQ09OTlRSQUNL
X1NBTkU9bQpDT05GSUdfTkZfQ09OTlRSQUNLX1NJUD1tCkNPTkZJR19ORl9DT05OVFJBQ0tf
VEZUUD1tCkNPTkZJR19ORl9DVF9ORVRMSU5LPW0KQ09ORklHX05GX0NUX05FVExJTktfVElN
RU9VVD1tCkNPTkZJR19ORl9DVF9ORVRMSU5LX0hFTFBFUj1tCkNPTkZJR19ORVRGSUxURVJf
TkVUTElOS19RVUVVRV9DVD15CkNPTkZJR19ORl9OQVQ9bQpDT05GSUdfTkZfTkFUX05FRURF
RD15CkNPTkZJR19ORl9OQVRfUFJPVE9fRENDUD1tCkNPTkZJR19ORl9OQVRfUFJPVE9fVURQ
TElURT1tCkNPTkZJR19ORl9OQVRfUFJPVE9fU0NUUD1tCkNPTkZJR19ORl9OQVRfQU1BTkRB
PW0KQ09ORklHX05GX05BVF9GVFA9bQpDT05GSUdfTkZfTkFUX0lSQz1tCkNPTkZJR19ORl9O
QVRfU0lQPW0KQ09ORklHX05GX05BVF9URlRQPW0KQ09ORklHX05GX05BVF9SRURJUkVDVD1t
CkNPTkZJR19ORVRGSUxURVJfU1lOUFJPWFk9bQpDT05GSUdfTkZfVEFCTEVTPW0KQ09ORklH
X05GX1RBQkxFU19JTkVUPW0KQ09ORklHX05GX1RBQkxFU19ORVRERVY9bQpDT05GSUdfTkZU
X0VYVEhEUj1tCkNPTkZJR19ORlRfTUVUQT1tCkNPTkZJR19ORlRfQ1Q9bQpDT05GSUdfTkZU
X1JCVFJFRT1tCkNPTkZJR19ORlRfSEFTSD1tCkNPTkZJR19ORlRfQ09VTlRFUj1tCkNPTkZJ
R19ORlRfTE9HPW0KQ09ORklHX05GVF9MSU1JVD1tCkNPTkZJR19ORlRfTUFTUT1tCkNPTkZJ
R19ORlRfUkVESVI9bQpDT05GSUdfTkZUX05BVD1tCkNPTkZJR19ORlRfUVVFVUU9bQpDT05G
SUdfTkZUX1JFSkVDVD1tCkNPTkZJR19ORlRfUkVKRUNUX0lORVQ9bQpDT05GSUdfTkZUX0NP
TVBBVD1tCkNPTkZJR19ORVRGSUxURVJfWFRBQkxFUz1tCgojCiMgWHRhYmxlcyBjb21iaW5l
ZCBtb2R1bGVzCiMKQ09ORklHX05FVEZJTFRFUl9YVF9NQVJLPW0KQ09ORklHX05FVEZJTFRF
Ul9YVF9DT05OTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfU0VUPW0KCiMKIyBYdGFibGVz
IHRhcmdldHMKIwpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9DSEVDS1NVTT1tCkNPTkZJ
R19ORVRGSUxURVJfWFRfVEFSR0VUX0NMQVNTSUZZPW0KQ09ORklHX05FVEZJTFRFUl9YVF9U
QVJHRVRfQ09OTk1BUks9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9DT05OU0VDTUFS
Sz1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0NUPW0KQ09ORklHX05FVEZJTFRFUl9Y
VF9UQVJHRVRfRFNDUD1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0hMPW0KQ09ORklH
X05FVEZJTFRFUl9YVF9UQVJHRVRfSE1BUks9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdF
VF9JRExFVElNRVI9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9MRUQ9bQpDT05GSUdf
TkVURklMVEVSX1hUX1RBUkdFVF9MT0c9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9N
QVJLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9OQVQ9bQpDT05GSUdfTkVURklMVEVSX1hUX1RB
UkdFVF9ORVRNQVA9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9ORkxPRz1tCkNPTkZJ
R19ORVRGSUxURVJfWFRfVEFSR0VUX05GUVVFVUU9bQpDT05GSUdfTkVURklMVEVSX1hUX1RB
UkdFVF9OT1RSQUNLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfUkFURUVTVD1tCkNP
TkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1JFRElSRUNUPW0KQ09ORklHX05FVEZJTFRFUl9Y
VF9UQVJHRVRfVEVFPW0KQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVFBST1hZPW0KQ09O
RklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVFJBQ0U9bQpDT05GSUdfTkVURklMVEVSX1hUX1RB
UkdFVF9TRUNNQVJLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVENQTVNTPW0KQ09O
RklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVENQT1BUU1RSSVA9bQoKIwojIFh0YWJsZXMgbWF0
Y2hlcwojCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQUREUlRZUEU9bQpDT05GSUdfTkVU
RklMVEVSX1hUX01BVENIX0JQRj1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ0dST1VQ
PW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9DTFVTVEVSPW0KQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9DT01NRU5UPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9DT05OQllU
RVM9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0NPTk5MQUJFTD1tCkNPTkZJR19ORVRG
SUxURVJfWFRfTUFUQ0hfQ09OTkxJTUlUPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9D
T05OTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ09OTlRSQUNLPW0KQ09ORklH
X05FVEZJTFRFUl9YVF9NQVRDSF9DUFU9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0RD
Q1A9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0RFVkdST1VQPW0KQ09ORklHX05FVEZJ
TFRFUl9YVF9NQVRDSF9EU0NQPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9FQ049bQpD
T05GSUdfTkVURklMVEVSX1hUX01BVENIX0VTUD1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFU
Q0hfSEFTSExJTUlUPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9IRUxQRVI9bQpDT05G
SUdfTkVURklMVEVSX1hUX01BVENIX0hMPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9J
UENPTVA9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0lQUkFOR0U9bQpDT05GSUdfTkVU
RklMVEVSX1hUX01BVENIX0lQVlM9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0wyVFA9
bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0xFTkdUSD1tCkNPTkZJR19ORVRGSUxURVJf
WFRfTUFUQ0hfTElNSVQ9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX01BQz1tCkNPTkZJ
R19ORVRGSUxURVJfWFRfTUFUQ0hfTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hf
TVVMVElQT1JUPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9ORkFDQ1Q9bQpDT05GSUdf
TkVURklMVEVSX1hUX01BVENIX09TRj1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfT1dO
RVI9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1BPTElDWT1tCkNPTkZJR19ORVRGSUxU
RVJfWFRfTUFUQ0hfUEhZU0RFVj1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUEtUVFlQ
RT1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUVVPVEE9bQpDT05GSUdfTkVURklMVEVS
X1hUX01BVENIX1JBVEVFU1Q9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1JFQUxNPW0K
Q09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9SRUNFTlQ9bQpDT05GSUdfTkVURklMVEVSX1hU
X01BVENIX1NDVFA9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NPQ0tFVD1tCkNPTkZJ
R19ORVRGSUxURVJfWFRfTUFUQ0hfU1RBVEU9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENI
X1NUQVRJU1RJQz1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfU1RSSU5HPW0KQ09ORklH
X05FVEZJTFRFUl9YVF9NQVRDSF9UQ1BNU1M9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENI
X1RJTUU9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1UzMj1tCkNPTkZJR19JUF9TRVQ9
bQpDT05GSUdfSVBfU0VUX01BWD0yNTYKQ09ORklHX0lQX1NFVF9CSVRNQVBfSVA9bQpDT05G
SUdfSVBfU0VUX0JJVE1BUF9JUE1BQz1tCkNPTkZJR19JUF9TRVRfQklUTUFQX1BPUlQ9bQpD
T05GSUdfSVBfU0VUX0hBU0hfSVA9bQpDT05GSUdfSVBfU0VUX0hBU0hfSVBNQVJLPW0KQ09O
RklHX0lQX1NFVF9IQVNIX0lQUE9SVD1tCkNPTkZJR19JUF9TRVRfSEFTSF9JUFBPUlRJUD1t
CkNPTkZJR19JUF9TRVRfSEFTSF9JUFBPUlRORVQ9bQpDT05GSUdfSVBfU0VUX0hBU0hfTUFD
PW0KQ09ORklHX0lQX1NFVF9IQVNIX05FVFBPUlRORVQ9bQpDT05GSUdfSVBfU0VUX0hBU0hf
TkVUPW0KQ09ORklHX0lQX1NFVF9IQVNIX05FVE5FVD1tCkNPTkZJR19JUF9TRVRfSEFTSF9O
RVRQT1JUPW0KQ09ORklHX0lQX1NFVF9IQVNIX05FVElGQUNFPW0KQ09ORklHX0lQX1NFVF9M
SVNUX1NFVD1tCkNPTkZJR19JUF9WUz1tCkNPTkZJR19JUF9WU19JUFY2PXkKIyBDT05GSUdf
SVBfVlNfREVCVUcgaXMgbm90IHNldApDT05GSUdfSVBfVlNfVEFCX0JJVFM9MTIKCiMKIyBJ
UFZTIHRyYW5zcG9ydCBwcm90b2NvbCBsb2FkIGJhbGFuY2luZyBzdXBwb3J0CiMKQ09ORklH
X0lQX1ZTX1BST1RPX1RDUD15CkNPTkZJR19JUF9WU19QUk9UT19VRFA9eQpDT05GSUdfSVBf
VlNfUFJPVE9fQUhfRVNQPXkKQ09ORklHX0lQX1ZTX1BST1RPX0VTUD15CkNPTkZJR19JUF9W
U19QUk9UT19BSD15CkNPTkZJR19JUF9WU19QUk9UT19TQ1RQPXkKCiMKIyBJUFZTIHNjaGVk
dWxlcgojCkNPTkZJR19JUF9WU19SUj1tCkNPTkZJR19JUF9WU19XUlI9bQpDT05GSUdfSVBf
VlNfTEM9bQpDT05GSUdfSVBfVlNfV0xDPW0KQ09ORklHX0lQX1ZTX0ZPPW0KIyBDT05GSUdf
SVBfVlNfT1ZGIGlzIG5vdCBzZXQKQ09ORklHX0lQX1ZTX0xCTEM9bQpDT05GSUdfSVBfVlNf
TEJMQ1I9bQpDT05GSUdfSVBfVlNfREg9bQpDT05GSUdfSVBfVlNfU0g9bQpDT05GSUdfSVBf
VlNfU0VEPW0KQ09ORklHX0lQX1ZTX05RPW0KCiMKIyBJUFZTIFNIIHNjaGVkdWxlcgojCkNP
TkZJR19JUF9WU19TSF9UQUJfQklUUz04CgojCiMgSVBWUyBhcHBsaWNhdGlvbiBoZWxwZXIK
IwpDT05GSUdfSVBfVlNfRlRQPW0KQ09ORklHX0lQX1ZTX05GQ1Q9eQpDT05GSUdfSVBfVlNf
UEVfU0lQPW0KCiMKIyBJUDogTmV0ZmlsdGVyIENvbmZpZ3VyYXRpb24KIwpDT05GSUdfTkZf
REVGUkFHX0lQVjQ9bQpDT05GSUdfTkZfQ09OTlRSQUNLX0lQVjQ9bQojIENPTkZJR19ORl9D
T05OVFJBQ0tfUFJPQ19DT01QQVQgaXMgbm90IHNldApDT05GSUdfTkZfVEFCTEVTX0lQVjQ9
bQpDT05GSUdfTkZUX0NIQUlOX1JPVVRFX0lQVjQ9bQpDT05GSUdfTkZUX1JFSkVDVF9JUFY0
PW0KIyBDT05GSUdfTkZUX0RVUF9JUFY0IGlzIG5vdCBzZXQKQ09ORklHX05GX1RBQkxFU19B
UlA9bQpDT05GSUdfTkZfRFVQX0lQVjQ9bQpDT05GSUdfTkZfTE9HX0FSUD1tCkNPTkZJR19O
Rl9MT0dfSVBWND1tCkNPTkZJR19ORl9SRUpFQ1RfSVBWND1tCkNPTkZJR19ORl9OQVRfSVBW
ND1tCkNPTkZJR19ORlRfQ0hBSU5fTkFUX0lQVjQ9bQpDT05GSUdfTkZfTkFUX01BU1FVRVJB
REVfSVBWND1tCkNPTkZJR19ORlRfTUFTUV9JUFY0PW0KQ09ORklHX05GVF9SRURJUl9JUFY0
PW0KQ09ORklHX05GX05BVF9TTk1QX0JBU0lDPW0KQ09ORklHX05GX05BVF9QUk9UT19HUkU9
bQpDT05GSUdfTkZfTkFUX1BQVFA9bQpDT05GSUdfTkZfTkFUX0gzMjM9bQpDT05GSUdfSVBf
TkZfSVBUQUJMRVM9bQpDT05GSUdfSVBfTkZfTUFUQ0hfQUg9bQpDT05GSUdfSVBfTkZfTUFU
Q0hfRUNOPW0KQ09ORklHX0lQX05GX01BVENIX1JQRklMVEVSPW0KQ09ORklHX0lQX05GX01B
VENIX1RUTD1tCkNPTkZJR19JUF9ORl9GSUxURVI9bQpDT05GSUdfSVBfTkZfVEFSR0VUX1JF
SkVDVD1tCkNPTkZJR19JUF9ORl9UQVJHRVRfU1lOUFJPWFk9bQpDT05GSUdfSVBfTkZfTkFU
PW0KQ09ORklHX0lQX05GX1RBUkdFVF9NQVNRVUVSQURFPW0KQ09ORklHX0lQX05GX1RBUkdF
VF9ORVRNQVA9bQpDT05GSUdfSVBfTkZfVEFSR0VUX1JFRElSRUNUPW0KQ09ORklHX0lQX05G
X01BTkdMRT1tCkNPTkZJR19JUF9ORl9UQVJHRVRfQ0xVU1RFUklQPW0KQ09ORklHX0lQX05G
X1RBUkdFVF9FQ049bQpDT05GSUdfSVBfTkZfVEFSR0VUX1RUTD1tCkNPTkZJR19JUF9ORl9S
QVc9bQpDT05GSUdfSVBfTkZfU0VDVVJJVFk9bQpDT05GSUdfSVBfTkZfQVJQVEFCTEVTPW0K
Q09ORklHX0lQX05GX0FSUEZJTFRFUj1tCkNPTkZJR19JUF9ORl9BUlBfTUFOR0xFPW0KCiMK
IyBJUHY2OiBOZXRmaWx0ZXIgQ29uZmlndXJhdGlvbgojCkNPTkZJR19ORl9ERUZSQUdfSVBW
Nj1tCkNPTkZJR19ORl9DT05OVFJBQ0tfSVBWNj1tCkNPTkZJR19ORl9UQUJMRVNfSVBWNj1t
CkNPTkZJR19ORlRfQ0hBSU5fUk9VVEVfSVBWNj1tCkNPTkZJR19ORlRfUkVKRUNUX0lQVjY9
bQojIENPTkZJR19ORlRfRFVQX0lQVjYgaXMgbm90IHNldApDT05GSUdfTkZfRFVQX0lQVjY9
bQpDT05GSUdfTkZfUkVKRUNUX0lQVjY9bQpDT05GSUdfTkZfTE9HX0lQVjY9bQpDT05GSUdf
TkZfTkFUX0lQVjY9bQpDT05GSUdfTkZUX0NIQUlOX05BVF9JUFY2PW0KQ09ORklHX05GX05B
VF9NQVNRVUVSQURFX0lQVjY9bQpDT05GSUdfTkZUX01BU1FfSVBWNj1tCkNPTkZJR19ORlRf
UkVESVJfSVBWNj1tCkNPTkZJR19JUDZfTkZfSVBUQUJMRVM9bQpDT05GSUdfSVA2X05GX01B
VENIX0FIPW0KQ09ORklHX0lQNl9ORl9NQVRDSF9FVUk2ND1tCkNPTkZJR19JUDZfTkZfTUFU
Q0hfRlJBRz1tCkNPTkZJR19JUDZfTkZfTUFUQ0hfT1BUUz1tCkNPTkZJR19JUDZfTkZfTUFU
Q0hfSEw9bQpDT05GSUdfSVA2X05GX01BVENIX0lQVjZIRUFERVI9bQpDT05GSUdfSVA2X05G
X01BVENIX01IPW0KQ09ORklHX0lQNl9ORl9NQVRDSF9SUEZJTFRFUj1tCkNPTkZJR19JUDZf
TkZfTUFUQ0hfUlQ9bQpDT05GSUdfSVA2X05GX1RBUkdFVF9ITD1tCkNPTkZJR19JUDZfTkZf
RklMVEVSPW0KQ09ORklHX0lQNl9ORl9UQVJHRVRfUkVKRUNUPW0KQ09ORklHX0lQNl9ORl9U
QVJHRVRfU1lOUFJPWFk9bQpDT05GSUdfSVA2X05GX01BTkdMRT1tCkNPTkZJR19JUDZfTkZf
UkFXPW0KQ09ORklHX0lQNl9ORl9TRUNVUklUWT1tCkNPTkZJR19JUDZfTkZfTkFUPW0KQ09O
RklHX0lQNl9ORl9UQVJHRVRfTUFTUVVFUkFERT1tCkNPTkZJR19JUDZfTkZfVEFSR0VUX05Q
VD1tCkNPTkZJR19ORl9UQUJMRVNfQlJJREdFPW0KQ09ORklHX05GVF9CUklER0VfTUVUQT1t
CkNPTkZJR19ORlRfQlJJREdFX1JFSkVDVD1tCkNPTkZJR19ORl9MT0dfQlJJREdFPW0KQ09O
RklHX0JSSURHRV9ORl9FQlRBQkxFUz1tCkNPTkZJR19CUklER0VfRUJUX0JST1VURT1tCkNP
TkZJR19CUklER0VfRUJUX1RfRklMVEVSPW0KQ09ORklHX0JSSURHRV9FQlRfVF9OQVQ9bQpD
T05GSUdfQlJJREdFX0VCVF84MDJfMz1tCkNPTkZJR19CUklER0VfRUJUX0FNT05HPW0KQ09O
RklHX0JSSURHRV9FQlRfQVJQPW0KQ09ORklHX0JSSURHRV9FQlRfSVA9bQpDT05GSUdfQlJJ
REdFX0VCVF9JUDY9bQpDT05GSUdfQlJJREdFX0VCVF9MSU1JVD1tCkNPTkZJR19CUklER0Vf
RUJUX01BUks9bQpDT05GSUdfQlJJREdFX0VCVF9QS1RUWVBFPW0KQ09ORklHX0JSSURHRV9F
QlRfU1RQPW0KQ09ORklHX0JSSURHRV9FQlRfVkxBTj1tCkNPTkZJR19CUklER0VfRUJUX0FS
UFJFUExZPW0KQ09ORklHX0JSSURHRV9FQlRfRE5BVD1tCkNPTkZJR19CUklER0VfRUJUX01B
UktfVD1tCkNPTkZJR19CUklER0VfRUJUX1JFRElSRUNUPW0KQ09ORklHX0JSSURHRV9FQlRf
U05BVD1tCkNPTkZJR19CUklER0VfRUJUX0xPRz1tCkNPTkZJR19CUklER0VfRUJUX05GTE9H
PW0KQ09ORklHX0lQX0RDQ1A9bQpDT05GSUdfSU5FVF9EQ0NQX0RJQUc9bQoKIwojIERDQ1Ag
Q0NJRHMgQ29uZmlndXJhdGlvbgojCiMgQ09ORklHX0lQX0RDQ1BfQ0NJRDJfREVCVUcgaXMg
bm90IHNldApDT05GSUdfSVBfRENDUF9DQ0lEMz15CiMgQ09ORklHX0lQX0RDQ1BfQ0NJRDNf
REVCVUcgaXMgbm90IHNldApDT05GSUdfSVBfRENDUF9URlJDX0xJQj15CgojCiMgRENDUCBL
ZXJuZWwgSGFja2luZwojCiMgQ09ORklHX0lQX0RDQ1BfREVCVUcgaXMgbm90IHNldApDT05G
SUdfTkVUX0RDQ1BQUk9CRT1tCkNPTkZJR19JUF9TQ1RQPW0KQ09ORklHX05FVF9TQ1RQUFJP
QkU9bQojIENPTkZJR19TQ1RQX0RCR19PQkpDTlQgaXMgbm90IHNldAojIENPTkZJR19TQ1RQ
X0RFRkFVTFRfQ09PS0lFX0hNQUNfTUQ1IGlzIG5vdCBzZXQKQ09ORklHX1NDVFBfREVGQVVM
VF9DT09LSUVfSE1BQ19TSEExPXkKIyBDT05GSUdfU0NUUF9ERUZBVUxUX0NPT0tJRV9ITUFD
X05PTkUgaXMgbm90IHNldApDT05GSUdfU0NUUF9DT09LSUVfSE1BQ19NRDU9eQpDT05GSUdf
U0NUUF9DT09LSUVfSE1BQ19TSEExPXkKIyBDT05GSUdfUkRTIGlzIG5vdCBzZXQKIyBDT05G
SUdfVElQQyBpcyBub3Qgc2V0CkNPTkZJR19BVE09bQpDT05GSUdfQVRNX0NMSVA9bQojIENP
TkZJR19BVE1fQ0xJUF9OT19JQ01QIGlzIG5vdCBzZXQKQ09ORklHX0FUTV9MQU5FPW0KQ09O
RklHX0FUTV9NUE9BPW0KQ09ORklHX0FUTV9CUjI2ODQ9bQojIENPTkZJR19BVE1fQlIyNjg0
X0lQRklMVEVSIGlzIG5vdCBzZXQKQ09ORklHX0wyVFA9bQojIENPTkZJR19MMlRQX0RFQlVH
RlMgaXMgbm90IHNldApDT05GSUdfTDJUUF9WMz15CkNPTkZJR19MMlRQX0lQPW0KQ09ORklH
X0wyVFBfRVRIPW0KQ09ORklHX1NUUD1tCkNPTkZJR19NUlA9bQpDT05GSUdfQlJJREdFPW0K
Q09ORklHX0JSSURHRV9JR01QX1NOT09QSU5HPXkKQ09ORklHX0JSSURHRV9WTEFOX0ZJTFRF
UklORz15CkNPTkZJR19IQVZFX05FVF9EU0E9eQpDT05GSUdfTkVUX0RTQT1tCkNPTkZJR19O
RVRfRFNBX0hXTU9OPXkKQ09ORklHX1ZMQU5fODAyMVE9bQojIENPTkZJR19WTEFOXzgwMjFR
X0dWUlAgaXMgbm90IHNldApDT05GSUdfVkxBTl84MDIxUV9NVlJQPXkKIyBDT05GSUdfREVD
TkVUIGlzIG5vdCBzZXQKQ09ORklHX0xMQz1tCkNPTkZJR19MTEMyPW0KIyBDT05GSUdfSVBY
IGlzIG5vdCBzZXQKIyBDT05GSUdfQVRBTEsgaXMgbm90IHNldAojIENPTkZJR19YMjUgaXMg
bm90IHNldAojIENPTkZJR19MQVBCIGlzIG5vdCBzZXQKQ09ORklHX1BIT05FVD1tCkNPTkZJ
R182TE9XUEFOPW0KQ09ORklHXzZMT1dQQU5fTkhDPW0KQ09ORklHXzZMT1dQQU5fTkhDX0RF
U1Q9bQpDT05GSUdfNkxPV1BBTl9OSENfRlJBR01FTlQ9bQpDT05GSUdfNkxPV1BBTl9OSENf
SE9QPW0KQ09ORklHXzZMT1dQQU5fTkhDX0lQVjY9bQpDT05GSUdfNkxPV1BBTl9OSENfTU9C
SUxJVFk9bQpDT05GSUdfNkxPV1BBTl9OSENfUk9VVElORz1tCkNPTkZJR182TE9XUEFOX05I
Q19VRFA9bQpDT05GSUdfSUVFRTgwMjE1ND1tCkNPTkZJR19JRUVFODAyMTU0X1NPQ0tFVD1t
CkNPTkZJR19JRUVFODAyMTU0XzZMT1dQQU49bQpDT05GSUdfTUFDODAyMTU0PW0KQ09ORklH
X05FVF9TQ0hFRD15CgojCiMgUXVldWVpbmcvU2NoZWR1bGluZwojCkNPTkZJR19ORVRfU0NI
X0NCUT1tCkNPTkZJR19ORVRfU0NIX0hUQj1tCkNPTkZJR19ORVRfU0NIX0hGU0M9bQpDT05G
SUdfTkVUX1NDSF9BVE09bQpDT05GSUdfTkVUX1NDSF9QUklPPW0KQ09ORklHX05FVF9TQ0hf
TVVMVElRPW0KQ09ORklHX05FVF9TQ0hfUkVEPW0KQ09ORklHX05FVF9TQ0hfU0ZCPW0KQ09O
RklHX05FVF9TQ0hfU0ZRPW0KQ09ORklHX05FVF9TQ0hfVEVRTD1tCkNPTkZJR19ORVRfU0NI
X1RCRj1tCkNPTkZJR19ORVRfU0NIX0dSRUQ9bQpDT05GSUdfTkVUX1NDSF9EU01BUks9bQpD
T05GSUdfTkVUX1NDSF9ORVRFTT1tCkNPTkZJR19ORVRfU0NIX0RSUj1tCkNPTkZJR19ORVRf
U0NIX01RUFJJTz1tCkNPTkZJR19ORVRfU0NIX0NIT0tFPW0KQ09ORklHX05FVF9TQ0hfUUZR
PW0KQ09ORklHX05FVF9TQ0hfQ09ERUw9bQpDT05GSUdfTkVUX1NDSF9GUV9DT0RFTD1tCkNP
TkZJR19ORVRfU0NIX0ZRPW0KQ09ORklHX05FVF9TQ0hfSEhGPW0KQ09ORklHX05FVF9TQ0hf
UElFPW0KQ09ORklHX05FVF9TQ0hfSU5HUkVTUz1tCkNPTkZJR19ORVRfU0NIX1BMVUc9bQoK
IwojIENsYXNzaWZpY2F0aW9uCiMKQ09ORklHX05FVF9DTFM9eQpDT05GSUdfTkVUX0NMU19C
QVNJQz1tCkNPTkZJR19ORVRfQ0xTX1RDSU5ERVg9bQpDT05GSUdfTkVUX0NMU19ST1VURTQ9
bQpDT05GSUdfTkVUX0NMU19GVz1tCkNPTkZJR19ORVRfQ0xTX1UzMj1tCiMgQ09ORklHX0NM
U19VMzJfUEVSRiBpcyBub3Qgc2V0CiMgQ09ORklHX0NMU19VMzJfTUFSSyBpcyBub3Qgc2V0
CkNPTkZJR19ORVRfQ0xTX1JTVlA9bQpDT05GSUdfTkVUX0NMU19SU1ZQNj1tCkNPTkZJR19O
RVRfQ0xTX0ZMT1c9bQpDT05GSUdfTkVUX0NMU19DR1JPVVA9bQpDT05GSUdfTkVUX0NMU19C
UEY9bQpDT05GSUdfTkVUX0NMU19GTE9XRVI9bQojIENPTkZJR19ORVRfRU1BVENIIGlzIG5v
dCBzZXQKQ09ORklHX05FVF9DTFNfQUNUPXkKQ09ORklHX05FVF9BQ1RfUE9MSUNFPW0KQ09O
RklHX05FVF9BQ1RfR0FDVD1tCkNPTkZJR19HQUNUX1BST0I9eQpDT05GSUdfTkVUX0FDVF9N
SVJSRUQ9bQpDT05GSUdfTkVUX0FDVF9JUFQ9bQpDT05GSUdfTkVUX0FDVF9OQVQ9bQpDT05G
SUdfTkVUX0FDVF9QRURJVD1tCkNPTkZJR19ORVRfQUNUX1NJTVA9bQpDT05GSUdfTkVUX0FD
VF9TS0JFRElUPW0KQ09ORklHX05FVF9BQ1RfQ1NVTT1tCkNPTkZJR19ORVRfQUNUX1ZMQU49
bQpDT05GSUdfTkVUX0FDVF9CUEY9bQpDT05GSUdfTkVUX0FDVF9DT05OTUFSSz1tCkNPTkZJ
R19ORVRfQ0xTX0lORD15CkNPTkZJR19ORVRfU0NIX0ZJRk89eQojIENPTkZJR19EQ0IgaXMg
bm90IHNldApDT05GSUdfRE5TX1JFU09MVkVSPW0KQ09ORklHX0JBVE1BTl9BRFY9bQpDT05G
SUdfQkFUTUFOX0FEVl9CTEE9eQpDT05GSUdfQkFUTUFOX0FEVl9EQVQ9eQpDT05GSUdfQkFU
TUFOX0FEVl9OQz15CkNPTkZJR19CQVRNQU5fQURWX01DQVNUPXkKIyBDT05GSUdfQkFUTUFO
X0FEVl9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19PUEVOVlNXSVRDSD1tCkNPTkZJR19PUEVO
VlNXSVRDSF9HUkU9bQpDT05GSUdfT1BFTlZTV0lUQ0hfVlhMQU49bQpDT05GSUdfT1BFTlZT
V0lUQ0hfR0VORVZFPW0KQ09ORklHX1ZTT0NLRVRTPW0KQ09ORklHX05FVExJTktfTU1BUD15
CkNPTkZJR19ORVRMSU5LX0RJQUc9bQpDT05GSUdfTVBMUz15CkNPTkZJR19ORVRfTVBMU19H
U089bQpDT05GSUdfTVBMU19ST1VUSU5HPW0KQ09ORklHX0hTUj1tCkNPTkZJR19ORVRfU1dJ
VENIREVWPXkKQ09ORklHX1JQUz15CkNPTkZJR19SRlNfQUNDRUw9eQpDT05GSUdfWFBTPXkK
IyBDT05GSUdfQ0dST1VQX05FVF9QUklPIGlzIG5vdCBzZXQKQ09ORklHX0NHUk9VUF9ORVRf
Q0xBU1NJRD15CkNPTkZJR19ORVRfUlhfQlVTWV9QT0xMPXkKQ09ORklHX0JRTD15CkNPTkZJ
R19CUEZfSklUPXkKQ09ORklHX05FVF9GTE9XX0xJTUlUPXkKCiMKIyBOZXR3b3JrIHRlc3Rp
bmcKIwpDT05GSUdfTkVUX1BLVEdFTj1tCkNPTkZJR19ORVRfVENQUFJPQkU9bQpDT05GSUdf
TkVUX0RST1BfTU9OSVRPUj1tCiMgQ09ORklHX0hBTVJBRElPIGlzIG5vdCBzZXQKQ09ORklH
X0NBTj1tCkNPTkZJR19DQU5fUkFXPW0KQ09ORklHX0NBTl9CQ009bQpDT05GSUdfQ0FOX0dX
PW0KCiMKIyBDQU4gRGV2aWNlIERyaXZlcnMKIwpDT05GSUdfQ0FOX1ZDQU49bQpDT05GSUdf
Q0FOX1NMQ0FOPW0KQ09ORklHX0NBTl9ERVY9bQpDT05GSUdfQ0FOX0NBTENfQklUVElNSU5H
PXkKQ09ORklHX0NBTl9MRURTPXkKQ09ORklHX0NBTl9TSkExMDAwPW0KIyBDT05GSUdfQ0FO
X1NKQTEwMDBfSVNBIGlzIG5vdCBzZXQKQ09ORklHX0NBTl9TSkExMDAwX1BMQVRGT1JNPW0K
Q09ORklHX0NBTl9FTVNfUENJPW0KQ09ORklHX0NBTl9QRUFLX1BDST1tCkNPTkZJR19DQU5f
UEVBS19QQ0lFQz15CkNPTkZJR19DQU5fS1ZBU0VSX1BDST1tCkNPTkZJR19DQU5fUExYX1BD
ST1tCkNPTkZJR19DQU5fQ19DQU49bQpDT05GSUdfQ0FOX0NfQ0FOX1BMQVRGT1JNPW0KQ09O
RklHX0NBTl9DX0NBTl9QQ0k9bQpDT05GSUdfQ0FOX01fQ0FOPW0KQ09ORklHX0NBTl9DQzc3
MD1tCiMgQ09ORklHX0NBTl9DQzc3MF9JU0EgaXMgbm90IHNldApDT05GSUdfQ0FOX0NDNzcw
X1BMQVRGT1JNPW0KCiMKIyBDQU4gU1BJIGludGVyZmFjZXMKIwojIENPTkZJR19DQU5fTUNQ
MjUxWCBpcyBub3Qgc2V0CgojCiMgQ0FOIFVTQiBpbnRlcmZhY2VzCiMKQ09ORklHX0NBTl9F
TVNfVVNCPW0KQ09ORklHX0NBTl9FU0RfVVNCMj1tCkNPTkZJR19DQU5fR1NfVVNCPW0KQ09O
RklHX0NBTl9LVkFTRVJfVVNCPW0KQ09ORklHX0NBTl9QRUFLX1VTQj1tCkNPTkZJR19DQU5f
OERFVl9VU0I9bQpDT05GSUdfQ0FOX1NPRlRJTkc9bQojIENPTkZJR19DQU5fREVCVUdfREVW
SUNFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lSREEgaXMgbm90IHNldApDT05GSUdfQlQ9bQpD
T05GSUdfQlRfQlJFRFI9eQpDT05GSUdfQlRfUkZDT01NPW0KQ09ORklHX0JUX1JGQ09NTV9U
VFk9eQpDT05GSUdfQlRfQk5FUD1tCkNPTkZJR19CVF9CTkVQX01DX0ZJTFRFUj15CkNPTkZJ
R19CVF9CTkVQX1BST1RPX0ZJTFRFUj15CkNPTkZJR19CVF9ISURQPW0KQ09ORklHX0JUX0hT
PXkKQ09ORklHX0JUX0xFPXkKQ09ORklHX0JUXzZMT1dQQU49bQojIENPTkZJR19CVF9TRUxG
VEVTVCBpcyBub3Qgc2V0CkNPTkZJR19CVF9ERUJVR0ZTPXkKCiMKIyBCbHVldG9vdGggZGV2
aWNlIGRyaXZlcnMKIwpDT05GSUdfQlRfSU5URUw9bQpDT05GSUdfQlRfQkNNPW0KQ09ORklH
X0JUX1JUTD1tCkNPTkZJR19CVF9IQ0lCVFVTQj1tCkNPTkZJR19CVF9IQ0lCVFVTQl9CQ009
eQpDT05GSUdfQlRfSENJQlRVU0JfUlRMPXkKQ09ORklHX0JUX0hDSVVBUlQ9bQpDT05GSUdf
QlRfSENJVUFSVF9IND15CkNPTkZJR19CVF9IQ0lVQVJUX0JDU1A9eQpDT05GSUdfQlRfSENJ
VUFSVF9BVEgzSz15CkNPTkZJR19CVF9IQ0lVQVJUX0xMPXkKQ09ORklHX0JUX0hDSVVBUlRf
M1dJUkU9eQpDT05GSUdfQlRfSENJVUFSVF9JTlRFTD15CkNPTkZJR19CVF9IQ0lVQVJUX0JD
TT15CiMgQ09ORklHX0JUX0hDSVVBUlRfUUNBIGlzIG5vdCBzZXQKQ09ORklHX0JUX0hDSUJD
TTIwM1g9bQpDT05GSUdfQlRfSENJQlBBMTBYPW0KQ09ORklHX0JUX0hDSUJGVVNCPW0KQ09O
RklHX0JUX0hDSVZIQ0k9bQpDT05GSUdfQlRfTVJWTD1tCkNPTkZJR19CVF9BVEgzSz1tCkNP
TkZJR19CVF9XSUxJTks9bQpDT05GSUdfQUZfUlhSUEM9bQojIENPTkZJR19BRl9SWFJQQ19E
RUJVRyBpcyBub3Qgc2V0CkNPTkZJR19SWEtBRD1tCkNPTkZJR19GSUJfUlVMRVM9eQpDT05G
SUdfV0lSRUxFU1M9eQpDT05GSUdfV0lSRUxFU1NfRVhUPXkKQ09ORklHX1dFWFRfQ09SRT15
CkNPTkZJR19XRVhUX1BST0M9eQpDT05GSUdfV0VYVF9TUFk9eQpDT05GSUdfV0VYVF9QUklW
PXkKQ09ORklHX0NGRzgwMjExPW0KIyBDT05GSUdfTkw4MDIxMV9URVNUTU9ERSBpcyBub3Qg
c2V0CiMgQ09ORklHX0NGRzgwMjExX0RFVkVMT1BFUl9XQVJOSU5HUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0NGRzgwMjExX1JFR19ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19DRkc4MDIxMV9E
RUZBVUxUX1BTPXkKIyBDT05GSUdfQ0ZHODAyMTFfREVCVUdGUyBpcyBub3Qgc2V0CiMgQ09O
RklHX0NGRzgwMjExX0lOVEVSTkFMX1JFR0RCIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0ZHODAy
MTFfV0VYVCBpcyBub3Qgc2V0CkNPTkZJR19MSUI4MDIxMT1tCkNPTkZJR19MSUI4MDIxMV9D
UllQVF9XRVA9bQpDT05GSUdfTElCODAyMTFfQ1JZUFRfQ0NNUD1tCkNPTkZJR19MSUI4MDIx
MV9DUllQVF9US0lQPW0KIyBDT05GSUdfTElCODAyMTFfREVCVUcgaXMgbm90IHNldApDT05G
SUdfTUFDODAyMTE9bQpDT05GSUdfTUFDODAyMTFfSEFTX1JDPXkKQ09ORklHX01BQzgwMjEx
X1JDX01JTlNUUkVMPXkKQ09ORklHX01BQzgwMjExX1JDX01JTlNUUkVMX0hUPXkKIyBDT05G
SUdfTUFDODAyMTFfUkNfTUlOU1RSRUxfVkhUIGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjEx
X1JDX0RFRkFVTFRfTUlOU1RSRUw9eQpDT05GSUdfTUFDODAyMTFfUkNfREVGQVVMVD0ibWlu
c3RyZWxfaHQiCkNPTkZJR19NQUM4MDIxMV9NRVNIPXkKQ09ORklHX01BQzgwMjExX0xFRFM9
eQpDT05GSUdfTUFDODAyMTFfREVCVUdGUz15CiMgQ09ORklHX01BQzgwMjExX01FU1NBR0Vf
VFJBQ0lORyBpcyBub3Qgc2V0CiMgQ09ORklHX01BQzgwMjExX0RFQlVHX01FTlUgaXMgbm90
IHNldApDT05GSUdfTUFDODAyMTFfU1RBX0hBU0hfTUFYX1NJWkU9MAojIENPTkZJR19XSU1B
WCBpcyBub3Qgc2V0CkNPTkZJR19SRktJTEw9bQpDT05GSUdfUkZLSUxMX0xFRFM9eQpDT05G
SUdfUkZLSUxMX0lOUFVUPXkKQ09ORklHX1JGS0lMTF9HUElPPW0KQ09ORklHX05FVF85UD1t
CkNPTkZJR19ORVRfOVBfVklSVElPPW0KIyBDT05GSUdfTkVUXzlQX0RFQlVHIGlzIG5vdCBz
ZXQKQ09ORklHX0NBSUY9bQojIENPTkZJR19DQUlGX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklH
X0NBSUZfTkVUREVWPW0KQ09ORklHX0NBSUZfVVNCPW0KQ09ORklHX0NFUEhfTElCPW0KIyBD
T05GSUdfQ0VQSF9MSUJfUFJFVFRZREVCVUcgaXMgbm90IHNldAojIENPTkZJR19DRVBIX0xJ
Ql9VU0VfRE5TX1JFU09MVkVSIGlzIG5vdCBzZXQKIyBDT05GSUdfTkZDIGlzIG5vdCBzZXQK
IyBDT05GSUdfTFdUVU5ORUwgaXMgbm90IHNldApDT05GSUdfSEFWRV9CUEZfSklUPXkKCiMK
IyBEZXZpY2UgRHJpdmVycwojCgojCiMgR2VuZXJpYyBEcml2ZXIgT3B0aW9ucwojCiMgQ09O
RklHX1VFVkVOVF9IRUxQRVIgaXMgbm90IHNldApDT05GSUdfREVWVE1QRlM9eQojIENPTkZJ
R19ERVZUTVBGU19NT1VOVCBpcyBub3Qgc2V0CkNPTkZJR19TVEFOREFMT05FPXkKQ09ORklH
X1BSRVZFTlRfRklSTVdBUkVfQlVJTEQ9eQpDT05GSUdfRldfTE9BREVSPXkKIyBDT05GSUdf
RklSTVdBUkVfSU5fS0VSTkVMIGlzIG5vdCBzZXQKQ09ORklHX0VYVFJBX0ZJUk1XQVJFPSIi
CkNPTkZJR19GV19MT0FERVJfVVNFUl9IRUxQRVI9eQojIENPTkZJR19GV19MT0FERVJfVVNF
Ul9IRUxQRVJfRkFMTEJBQ0sgaXMgbm90IHNldApDT05GSUdfQUxMT1dfREVWX0NPUkVEVU1Q
PXkKIyBDT05GSUdfREVCVUdfRFJJVkVSIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfREVW
UkVTIGlzIG5vdCBzZXQKIyBDT05GSUdfU1lTX0hZUEVSVklTT1IgaXMgbm90IHNldAojIENP
TkZJR19HRU5FUklDX0NQVV9ERVZJQ0VTIGlzIG5vdCBzZXQKQ09ORklHX0dFTkVSSUNfQ1BV
X0FVVE9QUk9CRT15CkNPTkZJR19SRUdNQVA9eQpDT05GSUdfUkVHTUFQX0kyQz1tCkNPTkZJ
R19SRUdNQVBfU1BJPW0KQ09ORklHX1JFR01BUF9NTUlPPXkKQ09ORklHX1JFR01BUF9JUlE9
eQpDT05GSUdfRE1BX1NIQVJFRF9CVUZGRVI9eQojIENPTkZJR19GRU5DRV9UUkFDRSBpcyBu
b3Qgc2V0CgojCiMgQnVzIGRldmljZXMKIwpDT05GSUdfQ09OTkVDVE9SPXkKQ09ORklHX1BS
T0NfRVZFTlRTPXkKQ09ORklHX01URD1tCkNPTkZJR19NVERfVEVTVFM9bQpDT05GSUdfTVRE
X1JFREJPT1RfUEFSVFM9bQpDT05GSUdfTVREX1JFREJPT1RfRElSRUNUT1JZX0JMT0NLPS0x
CiMgQ09ORklHX01URF9SRURCT09UX1BBUlRTX1VOQUxMT0NBVEVEIGlzIG5vdCBzZXQKIyBD
T05GSUdfTVREX1JFREJPT1RfUEFSVFNfUkVBRE9OTFkgaXMgbm90IHNldApDT05GSUdfTVRE
X0NNRExJTkVfUEFSVFM9bQpDT05GSUdfTVREX0FSN19QQVJUUz1tCgojCiMgVXNlciBNb2R1
bGVzIEFuZCBUcmFuc2xhdGlvbiBMYXllcnMKIwpDT05GSUdfTVREX0JMS0RFVlM9bQpDT05G
SUdfTVREX0JMT0NLPW0KQ09ORklHX01URF9CTE9DS19STz1tCkNPTkZJR19GVEw9bQpDT05G
SUdfTkZUTD1tCkNPTkZJR19ORlRMX1JXPXkKQ09ORklHX0lORlRMPW0KQ09ORklHX1JGRF9G
VEw9bQpDT05GSUdfU1NGREM9bQojIENPTkZJR19TTV9GVEwgaXMgbm90IHNldApDT05GSUdf
TVREX09PUFM9bQpDT05GSUdfTVREX1NXQVA9bQojIENPTkZJR19NVERfUEFSVElUSU9ORURf
TUFTVEVSIGlzIG5vdCBzZXQKCiMKIyBSQU0vUk9NL0ZsYXNoIGNoaXAgZHJpdmVycwojCkNP
TkZJR19NVERfQ0ZJPW0KQ09ORklHX01URF9KRURFQ1BST0JFPW0KQ09ORklHX01URF9HRU5f
UFJPQkU9bQojIENPTkZJR19NVERfQ0ZJX0FEVl9PUFRJT05TIGlzIG5vdCBzZXQKQ09ORklH
X01URF9NQVBfQkFOS19XSURUSF8xPXkKQ09ORklHX01URF9NQVBfQkFOS19XSURUSF8yPXkK
Q09ORklHX01URF9NQVBfQkFOS19XSURUSF80PXkKIyBDT05GSUdfTVREX01BUF9CQU5LX1dJ
RFRIXzggaXMgbm90IHNldAojIENPTkZJR19NVERfTUFQX0JBTktfV0lEVEhfMTYgaXMgbm90
IHNldAojIENPTkZJR19NVERfTUFQX0JBTktfV0lEVEhfMzIgaXMgbm90IHNldApDT05GSUdf
TVREX0NGSV9JMT15CkNPTkZJR19NVERfQ0ZJX0kyPXkKIyBDT05GSUdfTVREX0NGSV9JNCBp
cyBub3Qgc2V0CiMgQ09ORklHX01URF9DRklfSTggaXMgbm90IHNldApDT05GSUdfTVREX0NG
SV9JTlRFTEVYVD1tCkNPTkZJR19NVERfQ0ZJX0FNRFNURD1tCkNPTkZJR19NVERfQ0ZJX1NU
QUE9bQpDT05GSUdfTVREX0NGSV9VVElMPW0KQ09ORklHX01URF9SQU09bQpDT05GSUdfTVRE
X1JPTT1tCkNPTkZJR19NVERfQUJTRU5UPW0KCiMKIyBNYXBwaW5nIGRyaXZlcnMgZm9yIGNo
aXAgYWNjZXNzCiMKQ09ORklHX01URF9DT01QTEVYX01BUFBJTkdTPXkKIyBDT05GSUdfTVRE
X1BIWVNNQVAgaXMgbm90IHNldAojIENPTkZJR19NVERfU0JDX0dYWCBpcyBub3Qgc2V0CiMg
Q09ORklHX01URF9BTUQ3NlhST00gaXMgbm90IHNldAojIENPTkZJR19NVERfSUNIWFJPTSBp
cyBub3Qgc2V0CiMgQ09ORklHX01URF9FU0IyUk9NIGlzIG5vdCBzZXQKIyBDT05GSUdfTVRE
X0NLODA0WFJPTSBpcyBub3Qgc2V0CkNPTkZJR19NVERfU0NCMl9GTEFTSD1tCiMgQ09ORklH
X01URF9ORVR0ZWwgaXMgbm90IHNldAojIENPTkZJR19NVERfTDQ0MEdYIGlzIG5vdCBzZXQK
Q09ORklHX01URF9QQ0k9bQojIENPTkZJR19NVERfR1BJT19BRERSIGlzIG5vdCBzZXQKIyBD
T05GSUdfTVREX0lOVEVMX1ZSX05PUiBpcyBub3Qgc2V0CkNPTkZJR19NVERfUExBVFJBTT1t
CiMgQ09ORklHX01URF9MQVRDSF9BRERSIGlzIG5vdCBzZXQKCiMKIyBTZWxmLWNvbnRhaW5l
ZCBNVEQgZGV2aWNlIGRyaXZlcnMKIwpDT05GSUdfTVREX1BNQzU1MT1tCiMgQ09ORklHX01U
RF9QTUM1NTFfQlVHRklYIGlzIG5vdCBzZXQKIyBDT05GSUdfTVREX1BNQzU1MV9ERUJVRyBp
cyBub3Qgc2V0CiMgQ09ORklHX01URF9EQVRBRkxBU0ggaXMgbm90IHNldAojIENPTkZJR19N
VERfU1NUMjVMIGlzIG5vdCBzZXQKQ09ORklHX01URF9TTFJBTT1tCkNPTkZJR19NVERfUEhS
QU09bQpDT05GSUdfTVREX01URFJBTT1tCkNPTkZJR19NVERSQU1fVE9UQUxfU0laRT00MDk2
CkNPTkZJR19NVERSQU1fRVJBU0VfU0laRT0xMjgKQ09ORklHX01URF9CTE9DSzJNVEQ9bQoK
IwojIERpc2stT24tQ2hpcCBEZXZpY2UgRHJpdmVycwojCkNPTkZJR19NVERfRE9DRzM9bQpD
T05GSUdfQkNIX0NPTlNUX009MTQKQ09ORklHX0JDSF9DT05TVF9UPTQKQ09ORklHX01URF9O
QU5EX0VDQz1tCkNPTkZJR19NVERfTkFORF9FQ0NfU01DPXkKQ09ORklHX01URF9OQU5EPW0K
IyBDT05GSUdfTVREX05BTkRfRUNDX0JDSCBpcyBub3Qgc2V0CkNPTkZJR19NVERfU01fQ09N
TU9OPW0KIyBDT05GSUdfTVREX05BTkRfREVOQUxJX1BDSSBpcyBub3Qgc2V0CiMgQ09ORklH
X01URF9OQU5EX0RFTkFMSV9EVCBpcyBub3Qgc2V0CkNPTkZJR19NVERfTkFORF9HUElPPW0K
IyBDT05GSUdfTVREX05BTkRfT01BUF9CQ0hfQlVJTEQgaXMgbm90IHNldApDT05GSUdfTVRE
X05BTkRfSURTPW0KQ09ORklHX01URF9OQU5EX1JJQ09IPW0KQ09ORklHX01URF9OQU5EX0RJ
U0tPTkNISVA9bQojIENPTkZJR19NVERfTkFORF9ESVNLT05DSElQX1BST0JFX0FEVkFOQ0VE
IGlzIG5vdCBzZXQKQ09ORklHX01URF9OQU5EX0RJU0tPTkNISVBfUFJPQkVfQUREUkVTUz0w
CiMgQ09ORklHX01URF9OQU5EX0RJU0tPTkNISVBfQkJUV1JJVEUgaXMgbm90IHNldApDT05G
SUdfTVREX05BTkRfRE9DRzQ9bQpDT05GSUdfTVREX05BTkRfQ0FGRT1tCkNPTkZJR19NVERf
TkFORF9OQU5EU0lNPW0KIyBDT05GSUdfTVREX05BTkRfUExBVEZPUk0gaXMgbm90IHNldAoj
IENPTkZJR19NVERfTkFORF9ISVNJNTA0IGlzIG5vdCBzZXQKIyBDT05GSUdfTVREX09ORU5B
TkQgaXMgbm90IHNldAoKIwojIExQRERSICYgTFBERFIyIFBDTSBtZW1vcnkgZHJpdmVycwoj
CkNPTkZJR19NVERfTFBERFI9bQpDT05GSUdfTVREX1FJTkZPX1BST0JFPW0KIyBDT05GSUdf
TVREX1NQSV9OT1IgaXMgbm90IHNldApDT05GSUdfTVREX1VCST1tCkNPTkZJR19NVERfVUJJ
X1dMX1RIUkVTSE9MRD00MDk2CkNPTkZJR19NVERfVUJJX0JFQl9MSU1JVD0yMAojIENPTkZJ
R19NVERfVUJJX0ZBU1RNQVAgaXMgbm90IHNldAojIENPTkZJR19NVERfVUJJX0dMVUVCSSBp
cyBub3Qgc2V0CiMgQ09ORklHX01URF9VQklfQkxPQ0sgaXMgbm90IHNldAojIENPTkZJR19P
RiBpcyBub3Qgc2V0CkNPTkZJR19BUkNIX01JR0hUX0hBVkVfUENfUEFSUE9SVD15CiMgQ09O
RklHX1BBUlBPUlQgaXMgbm90IHNldApDT05GSUdfUE5QPXkKIyBDT05GSUdfUE5QX0RFQlVH
X01FU1NBR0VTIGlzIG5vdCBzZXQKCiMKIyBQcm90b2NvbHMKIwpDT05GSUdfUE5QQUNQST15
CkNPTkZJR19CTEtfREVWPXkKIyBDT05GSUdfQkxLX0RFVl9OVUxMX0JMSyBpcyBub3Qgc2V0
CkNPTkZJR19CTEtfREVWX0ZEPW0KQ09ORklHX0JMS19ERVZfUENJRVNTRF9NVElQMzJYWD1t
CkNPTkZJR19aUkFNPW0KQ09ORklHX1pSQU1fTFo0X0NPTVBSRVNTPXkKQ09ORklHX0JMS19D
UFFfQ0lTU19EQT1tCiMgQ09ORklHX0NJU1NfU0NTSV9UQVBFIGlzIG5vdCBzZXQKQ09ORklH
X0JMS19ERVZfREFDOTYwPW0KIyBDT05GSUdfQkxLX0RFVl9VTUVNIGlzIG5vdCBzZXQKIyBD
T05GSUdfQkxLX0RFVl9DT1dfQ09NTU9OIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfTE9P
UD1tCkNPTkZJR19CTEtfREVWX0xPT1BfTUlOX0NPVU5UPTgKQ09ORklHX0JMS19ERVZfQ1JZ
UFRPTE9PUD1tCkNPTkZJR19CTEtfREVWX0RSQkQ9bQojIENPTkZJR19EUkJEX0ZBVUxUX0lO
SkVDVElPTiBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX05CRD1tCkNPTkZJR19CTEtfREVW
X05WTUU9bQpDT05GSUdfQkxLX0RFVl9TS0Q9bQpDT05GSUdfQkxLX0RFVl9TWDg9bQpDT05G
SUdfQkxLX0RFVl9SQU09bQpDT05GSUdfQkxLX0RFVl9SQU1fQ09VTlQ9MTYKQ09ORklHX0JM
S19ERVZfUkFNX1NJWkU9MTYzODQKQ09ORklHX0NEUk9NX1BLVENEVkQ9bQpDT05GSUdfQ0RS
T01fUEtUQ0RWRF9CVUZGRVJTPTgKIyBDT05GSUdfQ0RST01fUEtUQ0RWRF9XQ0FDSEUgaXMg
bm90IHNldApDT05GSUdfQVRBX09WRVJfRVRIPW0KIyBDT05GSUdfWEVOX0JMS0RFVl9GUk9O
VEVORCBpcyBub3Qgc2V0CkNPTkZJR19WSVJUSU9fQkxLPW0KIyBDT05GSUdfQkxLX0RFVl9I
RCBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX1JCRD1tCkNPTkZJR19CTEtfREVWX1JTWFg9
bQoKIwojIE1pc2MgZGV2aWNlcwojCiMgQ09ORklHX1NFTlNPUlNfTElTM0xWMDJEIGlzIG5v
dCBzZXQKIyBDT05GSUdfQUQ1MjVYX0RQT1QgaXMgbm90IHNldAojIENPTkZJR19EVU1NWV9J
UlEgaXMgbm90IHNldAojIENPTkZJR19JQk1fQVNNIGlzIG5vdCBzZXQKIyBDT05GSUdfUEhB
TlRPTSBpcyBub3Qgc2V0CiMgQ09ORklHX1NHSV9JT0M0IGlzIG5vdCBzZXQKIyBDT05GSUdf
VElGTV9DT1JFIGlzIG5vdCBzZXQKIyBDT05GSUdfSUNTOTMyUzQwMSBpcyBub3Qgc2V0CiMg
Q09ORklHX0VOQ0xPU1VSRV9TRVJWSUNFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0hQX0lMTyBp
cyBub3Qgc2V0CiMgQ09ORklHX0FQRFM5ODAyQUxTIGlzIG5vdCBzZXQKIyBDT05GSUdfSVNM
MjkwMDMgaXMgbm90IHNldAojIENPTkZJR19JU0wyOTAyMCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NFTlNPUlNfVFNMMjU1MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQkgxNzgwIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19CSDE3NzAgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0FQRFM5OTBYIGlzIG5vdCBzZXQKIyBDT05GSUdfSE1DNjM1MiBpcyBub3Qgc2V0
CiMgQ09ORklHX0RTMTY4MiBpcyBub3Qgc2V0CiMgQ09ORklHX1RJX0RBQzc1MTIgaXMgbm90
IHNldAojIENPTkZJR19WTVdBUkVfQkFMTE9PTiBpcyBub3Qgc2V0CiMgQ09ORklHX0JNUDA4
NV9JMkMgaXMgbm90IHNldAojIENPTkZJR19CTVAwODVfU1BJIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX1NXSVRDSF9GU0E5NDgwIGlzIG5vdCBzZXQKIyBDT05GSUdfTEFUVElDRV9FQ1Az
X0NPTkZJRyBpcyBub3Qgc2V0CiMgQ09ORklHX1NSQU0gaXMgbm90IHNldAojIENPTkZJR19D
MlBPUlQgaXMgbm90IHNldAoKIwojIEVFUFJPTSBzdXBwb3J0CiMKQ09ORklHX0VFUFJPTV9B
VDI0PW0KIyBDT05GSUdfRUVQUk9NX0FUMjUgaXMgbm90IHNldApDT05GSUdfRUVQUk9NX0xF
R0FDWT1tCkNPTkZJR19FRVBST01fTUFYNjg3NT1tCkNPTkZJR19FRVBST01fOTNDWDY9bQoj
IENPTkZJR19FRVBST01fOTNYWDQ2IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0I3MTBfQ09SRSBp
cyBub3Qgc2V0CgojCiMgVGV4YXMgSW5zdHJ1bWVudHMgc2hhcmVkIHRyYW5zcG9ydCBsaW5l
IGRpc2NpcGxpbmUKIwpDT05GSUdfVElfU1Q9bQojIENPTkZJR19TRU5TT1JTX0xJUzNfSTJD
IGlzIG5vdCBzZXQKCiMKIyBBbHRlcmEgRlBHQSBmaXJtd2FyZSBkb3dubG9hZCBtb2R1bGUK
IwojIENPTkZJR19BTFRFUkFfU1RBUEwgaXMgbm90IHNldApDT05GSUdfSU5URUxfTUVJPW0K
Q09ORklHX0lOVEVMX01FSV9NRT1tCkNPTkZJR19JTlRFTF9NRUlfVFhFPW0KIyBDT05GSUdf
Vk1XQVJFX1ZNQ0kgaXMgbm90IHNldAoKIwojIEludGVsIE1JQyBCdXMgRHJpdmVyCiMKQ09O
RklHX0lOVEVMX01JQ19CVVM9bQoKIwojIFNDSUYgQnVzIERyaXZlcgojCkNPTkZJR19TQ0lG
X0JVUz1tCgojCiMgSW50ZWwgTUlDIEhvc3QgRHJpdmVyCiMKQ09ORklHX0lOVEVMX01JQ19I
T1NUPW0KCiMKIyBJbnRlbCBNSUMgQ2FyZCBEcml2ZXIKIwpDT05GSUdfSU5URUxfTUlDX0NB
UkQ9bQoKIwojIFNDSUYgRHJpdmVyCiMKQ09ORklHX1NDSUY9bQpDT05GSUdfR0VOV1FFPW0K
Q09ORklHX0dFTldRRV9QTEFURk9STV9FUlJPUl9SRUNPVkVSWT0wCkNPTkZJR19FQ0hPPW0K
IyBDT05GSUdfQ1hMX0JBU0UgaXMgbm90IHNldAojIENPTkZJR19DWExfS0VSTkVMX0FQSSBp
cyBub3Qgc2V0CiMgQ09ORklHX0NYTF9FRUggaXMgbm90IHNldApDT05GSUdfSEFWRV9JREU9
eQojIENPTkZJR19JREUgaXMgbm90IHNldAoKIwojIFNDU0kgZGV2aWNlIHN1cHBvcnQKIwpD
T05GSUdfU0NTSV9NT0Q9bQojIENPTkZJR19SQUlEX0FUVFJTIGlzIG5vdCBzZXQKQ09ORklH
X1NDU0k9bQpDT05GSUdfU0NTSV9ETUE9eQpDT05GSUdfU0NTSV9ORVRMSU5LPXkKIyBDT05G
SUdfU0NTSV9NUV9ERUZBVUxUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9QUk9DX0ZTIGlz
IG5vdCBzZXQKCiMKIyBTQ1NJIHN1cHBvcnQgdHlwZSAoZGlzaywgdGFwZSwgQ0QtUk9NKQoj
CkNPTkZJR19CTEtfREVWX1NEPW0KIyBDT05GSUdfQ0hSX0RFVl9TVCBpcyBub3Qgc2V0CiMg
Q09ORklHX0NIUl9ERVZfT1NTVCBpcyBub3Qgc2V0CkNPTkZJR19CTEtfREVWX1NSPW0KIyBD
T05GSUdfQkxLX0RFVl9TUl9WRU5ET1IgaXMgbm90IHNldAojIENPTkZJR19DSFJfREVWX1NH
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hSX0RFVl9TQ0ggaXMgbm90IHNldAojIENPTkZJR19T
Q1NJX0NPTlNUQU5UUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfTE9HR0lORyBpcyBub3Qg
c2V0CiMgQ09ORklHX1NDU0lfU0NBTl9BU1lOQyBpcyBub3Qgc2V0CgojCiMgU0NTSSBUcmFu
c3BvcnRzCiMKQ09ORklHX1NDU0lfU1BJX0FUVFJTPW0KQ09ORklHX1NDU0lfRkNfQVRUUlM9
bQpDT05GSUdfU0NTSV9JU0NTSV9BVFRSUz1tCkNPTkZJR19TQ1NJX1NBU19BVFRSUz1tCkNP
TkZJR19TQ1NJX1NBU19MSUJTQVM9bQpDT05GSUdfU0NTSV9TQVNfQVRBPXkKQ09ORklHX1ND
U0lfU0FTX0hPU1RfU01QPXkKQ09ORklHX1NDU0lfU1JQX0FUVFJTPW0KIyBDT05GSUdfU0NT
SV9MT1dMRVZFTCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfREggaXMgbm90IHNldAojIENP
TkZJR19TQ1NJX09TRF9JTklUSUFUT1IgaXMgbm90IHNldApDT05GSUdfQVRBPW0KIyBDT05G
SUdfQVRBX05PTlNUQU5EQVJEIGlzIG5vdCBzZXQKQ09ORklHX0FUQV9WRVJCT1NFX0VSUk9S
PXkKQ09ORklHX0FUQV9BQ1BJPXkKQ09ORklHX1NBVEFfWlBPREQ9eQpDT05GSUdfU0FUQV9Q
TVA9eQoKIwojIENvbnRyb2xsZXJzIHdpdGggbm9uLVNGRiBuYXRpdmUgaW50ZXJmYWNlCiMK
Q09ORklHX1NBVEFfQUhDST1tCkNPTkZJR19TQVRBX0FIQ0lfUExBVEZPUk09bQpDT05GSUdf
U0FUQV9JTklDMTYyWD1tCkNPTkZJR19TQVRBX0FDQVJEX0FIQ0k9bQpDT05GSUdfU0FUQV9T
SUwyND1tCkNPTkZJR19BVEFfU0ZGPXkKCiMKIyBTRkYgY29udHJvbGxlcnMgd2l0aCBjdXN0
b20gRE1BIGludGVyZmFjZQojCkNPTkZJR19QRENfQURNQT1tCkNPTkZJR19TQVRBX1FTVE9S
PW0KQ09ORklHX1NBVEFfU1g0PW0KQ09ORklHX0FUQV9CTURNQT15CgojCiMgU0FUQSBTRkYg
Y29udHJvbGxlcnMgd2l0aCBCTURNQQojCkNPTkZJR19BVEFfUElJWD1tCkNPTkZJR19TQVRB
X01WPW0KQ09ORklHX1NBVEFfTlY9bQpDT05GSUdfU0FUQV9QUk9NSVNFPW0KQ09ORklHX1NB
VEFfU0lMPW0KQ09ORklHX1NBVEFfU0lTPW0KQ09ORklHX1NBVEFfU1ZXPW0KQ09ORklHX1NB
VEFfVUxJPW0KQ09ORklHX1NBVEFfVklBPW0KQ09ORklHX1NBVEFfVklURVNTRT1tCgojCiMg
UEFUQSBTRkYgY29udHJvbGxlcnMgd2l0aCBCTURNQQojCkNPTkZJR19QQVRBX0FMST1tCkNP
TkZJR19QQVRBX0FNRD1tCkNPTkZJR19QQVRBX0FSVE9QPW0KQ09ORklHX1BBVEFfQVRJSVhQ
PW0KQ09ORklHX1BBVEFfQVRQODY3WD1tCkNPTkZJR19QQVRBX0NNRDY0WD1tCkNPTkZJR19Q
QVRBX0NZUFJFU1M9bQpDT05GSUdfUEFUQV9FRkFSPW0KQ09ORklHX1BBVEFfSFBUMzY2PW0K
Q09ORklHX1BBVEFfSFBUMzdYPW0KQ09ORklHX1BBVEFfSFBUM1gyTj1tCkNPTkZJR19QQVRB
X0hQVDNYMz1tCiMgQ09ORklHX1BBVEFfSFBUM1gzX0RNQSBpcyBub3Qgc2V0CkNPTkZJR19Q
QVRBX0lUODIxMz1tCkNPTkZJR19QQVRBX0lUODIxWD1tCkNPTkZJR19QQVRBX0pNSUNST049
bQpDT05GSUdfUEFUQV9NQVJWRUxMPW0KQ09ORklHX1BBVEFfTkVUQ0VMTD1tCkNPTkZJR19Q
QVRBX05JTkpBMzI9bQpDT05GSUdfUEFUQV9OUzg3NDE1PW0KQ09ORklHX1BBVEFfT0xEUElJ
WD1tCkNPTkZJR19QQVRBX09QVElETUE9bQpDT05GSUdfUEFUQV9QREMyMDI3WD1tCkNPTkZJ
R19QQVRBX1BEQ19PTEQ9bQpDT05GSUdfUEFUQV9SQURJU1lTPW0KQ09ORklHX1BBVEFfUkRD
PW0KQ09ORklHX1BBVEFfU0NIPW0KQ09ORklHX1BBVEFfU0VSVkVSV09SS1M9bQpDT05GSUdf
UEFUQV9TSUw2ODA9bQpDT05GSUdfUEFUQV9TSVM9bQpDT05GSUdfUEFUQV9UT1NISUJBPW0K
Q09ORklHX1BBVEFfVFJJRkxFWD1tCkNPTkZJR19QQVRBX1ZJQT1tCkNPTkZJR19QQVRBX1dJ
TkJPTkQ9bQoKIwojIFBJTy1vbmx5IFNGRiBjb250cm9sbGVycwojCkNPTkZJR19QQVRBX0NN
RDY0MF9QQ0k9bQpDT05GSUdfUEFUQV9NUElJWD1tCkNPTkZJR19QQVRBX05TODc0MTA9bQpD
T05GSUdfUEFUQV9PUFRJPW0KQ09ORklHX1BBVEFfUloxMDAwPW0KCiMKIyBHZW5lcmljIGZh
bGxiYWNrIC8gbGVnYWN5IGRyaXZlcnMKIwpDT05GSUdfUEFUQV9BQ1BJPW0KQ09ORklHX0FU
QV9HRU5FUklDPW0KQ09ORklHX1BBVEFfTEVHQUNZPW0KQ09ORklHX01EPXkKQ09ORklHX0JM
S19ERVZfTUQ9bQpDT05GSUdfTURfTElORUFSPW0KQ09ORklHX01EX1JBSUQwPW0KQ09ORklH
X01EX1JBSUQxPW0KQ09ORklHX01EX1JBSUQxMD1tCkNPTkZJR19NRF9SQUlENDU2PW0KQ09O
RklHX01EX01VTFRJUEFUSD1tCkNPTkZJR19NRF9GQVVMVFk9bQojIENPTkZJR19NRF9DTFVT
VEVSIGlzIG5vdCBzZXQKQ09ORklHX0JDQUNIRT1tCiMgQ09ORklHX0JDQUNIRV9ERUJVRyBp
cyBub3Qgc2V0CiMgQ09ORklHX0JDQUNIRV9DTE9TVVJFU19ERUJVRyBpcyBub3Qgc2V0CkNP
TkZJR19CTEtfREVWX0RNX0JVSUxUSU49eQpDT05GSUdfQkxLX0RFVl9ETT1tCiMgQ09ORklH
X0RNX01RX0RFRkFVTFQgaXMgbm90IHNldAojIENPTkZJR19ETV9ERUJVRyBpcyBub3Qgc2V0
CkNPTkZJR19ETV9CVUZJTz1tCkNPTkZJR19ETV9CSU9fUFJJU09OPW0KQ09ORklHX0RNX1BF
UlNJU1RFTlRfREFUQT1tCiMgQ09ORklHX0RNX0RFQlVHX0JMT0NLX1NUQUNLX1RSQUNJTkcg
aXMgbm90IHNldApDT05GSUdfRE1fQ1JZUFQ9bQpDT05GSUdfRE1fU05BUFNIT1Q9bQpDT05G
SUdfRE1fVEhJTl9QUk9WSVNJT05JTkc9bQpDT05GSUdfRE1fQ0FDSEU9bQpDT05GSUdfRE1f
Q0FDSEVfTVE9bQpDT05GSUdfRE1fQ0FDSEVfU01RPW0KQ09ORklHX0RNX0NBQ0hFX0NMRUFO
RVI9bQpDT05GSUdfRE1fRVJBPW0KQ09ORklHX0RNX01JUlJPUj1tCkNPTkZJR19ETV9MT0df
VVNFUlNQQUNFPW0KQ09ORklHX0RNX1JBSUQ9bQpDT05GSUdfRE1fWkVSTz1tCkNPTkZJR19E
TV9NVUxUSVBBVEg9bQpDT05GSUdfRE1fTVVMVElQQVRIX1FMPW0KQ09ORklHX0RNX01VTFRJ
UEFUSF9TVD1tCkNPTkZJR19ETV9ERUxBWT1tCkNPTkZJR19ETV9VRVZFTlQ9eQpDT05GSUdf
RE1fRkxBS0VZPW0KQ09ORklHX0RNX1ZFUklUWT1tCkNPTkZJR19ETV9TV0lUQ0g9bQpDT05G
SUdfRE1fTE9HX1dSSVRFUz1tCkNPTkZJR19UQVJHRVRfQ09SRT1tCkNPTkZJR19UQ01fSUJM
T0NLPW0KQ09ORklHX1RDTV9GSUxFSU89bQpDT05GSUdfVENNX1BTQ1NJPW0KQ09ORklHX1RD
TV9VU0VSMj1tCkNPTkZJR19MT09QQkFDS19UQVJHRVQ9bQpDT05GSUdfSVNDU0lfVEFSR0VU
PW0KIyBDT05GSUdfRlVTSU9OIGlzIG5vdCBzZXQKCiMKIyBJRUVFIDEzOTQgKEZpcmVXaXJl
KSBzdXBwb3J0CiMKIyBDT05GSUdfRklSRVdJUkUgaXMgbm90IHNldApDT05GSUdfRklSRVdJ
UkVfTk9TWT15CkNPTkZJR19NQUNJTlRPU0hfRFJJVkVSUz15CkNPTkZJR19NQUNfRU1VTU9V
U0VCVE49bQpDT05GSUdfTkVUREVWSUNFUz15CkNPTkZJR19NSUk9bQpDT05GSUdfTkVUX0NP
UkU9eQpDT05GSUdfQk9ORElORz1tCkNPTkZJR19EVU1NWT1tCkNPTkZJR19FUVVBTElaRVI9
bQojIENPTkZJR19ORVRfRkMgaXMgbm90IHNldApDT05GSUdfSUZCPW0KQ09ORklHX05FVF9U
RUFNPW0KQ09ORklHX05FVF9URUFNX01PREVfQlJPQURDQVNUPW0KQ09ORklHX05FVF9URUFN
X01PREVfUk9VTkRST0JJTj1tCkNPTkZJR19ORVRfVEVBTV9NT0RFX1JBTkRPTT1tCkNPTkZJ
R19ORVRfVEVBTV9NT0RFX0FDVElWRUJBQ0tVUD1tCkNPTkZJR19ORVRfVEVBTV9NT0RFX0xP
QURCQUxBTkNFPW0KQ09ORklHX01BQ1ZMQU49bQpDT05GSUdfTUFDVlRBUD1tCkNPTkZJR19J
UFZMQU49bQpDT05GSUdfVlhMQU49bQpDT05GSUdfR0VORVZFPW0KQ09ORklHX05FVENPTlNP
TEU9bQpDT05GSUdfTkVUQ09OU09MRV9EWU5BTUlDPXkKQ09ORklHX05FVFBPTEw9eQpDT05G
SUdfTkVUX1BPTExfQ09OVFJPTExFUj15CkNPTkZJR19SSU9ORVQ9bQpDT05GSUdfUklPTkVU
X1RYX1NJWkU9MTI4CkNPTkZJR19SSU9ORVRfUlhfU0laRT0xMjgKQ09ORklHX1RVTj1tCiMg
Q09ORklHX1RVTl9WTkVUX0NST1NTX0xFIGlzIG5vdCBzZXQKQ09ORklHX1ZFVEg9bQojIENP
TkZJR19WSVJUSU9fTkVUIGlzIG5vdCBzZXQKQ09ORklHX05MTU9OPW0KIyBDT05GSUdfTkVU
X1ZSRiBpcyBub3Qgc2V0CiMgQ09ORklHX0FSQ05FVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FU
TV9EUklWRVJTIGlzIG5vdCBzZXQKCiMKIyBDQUlGIHRyYW5zcG9ydCBkcml2ZXJzCiMKQ09O
RklHX0NBSUZfVFRZPW0KQ09ORklHX0NBSUZfU1BJX1NMQVZFPW0KQ09ORklHX0NBSUZfU1BJ
X1NZTkM9eQpDT05GSUdfQ0FJRl9IU0k9bQpDT05GSUdfQ0FJRl9WSVJUSU89bQpDT05GSUdf
VkhPU1RfTkVUPW0KQ09ORklHX1ZIT1NUX1NDU0k9bQpDT05GSUdfVkhPU1RfUklORz1tCkNP
TkZJR19WSE9TVD1tCiMgQ09ORklHX1ZIT1NUX0NST1NTX0VORElBTl9MRUdBQ1kgaXMgbm90
IHNldAoKIwojIERpc3RyaWJ1dGVkIFN3aXRjaCBBcmNoaXRlY3R1cmUgZHJpdmVycwojCiMg
Q09ORklHX05FVF9EU0FfTVY4OEU2WFhYIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0RTQV9N
Vjg4RTYwNjAgaXMgbm90IHNldAojIENPTkZJR19ORVRfRFNBX01WODhFNlhYWF9ORUVEX1BQ
VSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9EU0FfTVY4OEU2MTMxIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkVUX0RTQV9NVjg4RTYxMjNfNjFfNjUgaXMgbm90IHNldAojIENPTkZJR19ORVRf
RFNBX01WODhFNjE3MSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9EU0FfTVY4OEU2MzUyIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX0RTQV9CQ01fU0YyIGlzIG5vdCBzZXQKQ09ORklHX0VU
SEVSTkVUPXkKQ09ORklHX01ESU89bQojIENPTkZJR19ORVRfVkVORE9SXzNDT00gaXMgbm90
IHNldAojIENPTkZJR19ORVRfVkVORE9SX0FEQVBURUMgaXMgbm90IHNldAojIENPTkZJR19O
RVRfVkVORE9SX0FHRVJFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9BTFRFT04g
aXMgbm90IHNldAojIENPTkZJR19BTFRFUkFfVFNFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVU
X1ZFTkRPUl9BTUQgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0FSQyBpcyBub3Qg
c2V0CiMgQ09ORklHX05FVF9WRU5ET1JfQVRIRVJPUyBpcyBub3Qgc2V0CiMgQ09ORklHX05F
VF9DQURFTkNFIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQlJPQURDT009eQpDT05G
SUdfQjQ0PW0KQ09ORklHX0I0NF9QQ0lfQVVUT1NFTEVDVD15CkNPTkZJR19CNDRfUENJQ09S
RV9BVVRPU0VMRUNUPXkKQ09ORklHX0I0NF9QQ0k9eQpDT05GSUdfQkNNR0VORVQ9bQpDT05G
SUdfQk5YMj1tCkNPTkZJR19DTklDPW0KQ09ORklHX1RJR09OMz1tCkNPTkZJR19CTlgyWD1t
CkNPTkZJR19CTlgyWF9TUklPVj15CiMgQ09ORklHX0JOWDJYX1ZYTEFOIGlzIG5vdCBzZXQK
Q09ORklHX05FVF9WRU5ET1JfQlJPQ0FERT15CkNPTkZJR19CTkE9bQojIENPTkZJR19ORVRf
VkVORE9SX0NBVklVTSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfQ0hFTFNJTyBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfQ0lTQ08gaXMgbm90IHNldAojIENPTkZJ
R19DWF9FQ0FUIGlzIG5vdCBzZXQKIyBDT05GSUdfRE5FVCBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9WRU5ET1JfREVDIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9ETElOSyBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfRU1VTEVYIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkVUX1ZFTkRPUl9FWkNISVAgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0VY
QVIgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0hQIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkVUX1ZFTkRPUl9JTlRFTCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQMTAwMCBpcyBub3Qg
c2V0CiMgQ09ORklHX0pNRSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfTUFSVkVM
TCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfTUVMTEFOT1ggaXMgbm90IHNldAoj
IENPTkZJR19ORVRfVkVORE9SX01JQ1JFTCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5E
T1JfTUlDUk9DSElQIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9NWVJJIGlzIG5v
dCBzZXQKIyBDT05GSUdfRkVBTE5YIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9O
QVRTRU1JIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9OVklESUEgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfVkVORE9SX09LSSBpcyBub3Qgc2V0CiMgQ09ORklHX0VUSE9DIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1BBQ0tFVF9FTkdJTkUgaXMgbm90IHNldAojIENPTkZJ
R19ORVRfVkVORE9SX1FMT0dJQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfUVVB
TENPTU0gaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX1JFQUxURUsgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfVkVORE9SX1JFTkVTQVMgaXMgbm90IHNldAojIENPTkZJR19ORVRf
VkVORE9SX1JEQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfUk9DS0VSIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9TQU1TVU5HIGlzIG5vdCBzZXQKIyBDT05GSUdf
TkVUX1ZFTkRPUl9TRUVRIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9TSUxBTiBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfU0lTIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0ZDIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9TTVNDIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkVUX1ZFTkRPUl9TVE1JQ1JPIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRP
Ul9TVU4gaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9TWU5PUFNZUz15CiMgQ09ORklH
X05FVF9WRU5ET1JfVEVIVVRJIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9USSBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfVklBIGlzIG5vdCBzZXQKIyBDT05GSUdf
TkVUX1ZFTkRPUl9XSVpORVQgaXMgbm90IHNldAojIENPTkZJR19GRERJIGlzIG5vdCBzZXQK
IyBDT05GSUdfSElQUEkgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0IxMDAwIGlzIG5vdCBz
ZXQKQ09ORklHX1BIWUxJQj1tCgojCiMgTUlJIFBIWSBkZXZpY2UgZHJpdmVycwojCiMgQ09O
RklHX0FRVUFOVElBX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0FUODAzWF9QSFkgaXMgbm90
IHNldAojIENPTkZJR19BTURfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFSVkVMTF9QSFkg
aXMgbm90IHNldAojIENPTkZJR19EQVZJQ09NX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX1FT
RU1JX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0xYVF9QSFkgaXMgbm90IHNldAojIENPTkZJ
R19DSUNBREFfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfVklURVNTRV9QSFkgaXMgbm90IHNl
dAojIENPTkZJR19URVJBTkVUSUNTX1BIWSBpcyBub3Qgc2V0CkNPTkZJR19TTVNDX1BIWT1t
CkNPTkZJR19CUk9BRENPTV9QSFk9bQpDT05GSUdfQkNNN1hYWF9QSFk9bQpDT05GSUdfQkNN
ODdYWF9QSFk9bQojIENPTkZJR19JQ1BMVVNfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfUkVB
TFRFS19QSFkgaXMgbm90IHNldAojIENPTkZJR19OQVRJT05BTF9QSFkgaXMgbm90IHNldAoj
IENPTkZJR19TVEUxMFhQIGlzIG5vdCBzZXQKIyBDT05GSUdfTFNJX0VUMTAxMUNfUEhZIGlz
IG5vdCBzZXQKIyBDT05GSUdfTUlDUkVMX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0RQODM4
NjdfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfTUlDUk9DSElQX1BIWSBpcyBub3Qgc2V0CkNP
TkZJR19GSVhFRF9QSFk9bQojIENPTkZJR19NRElPX0JJVEJBTkcgaXMgbm90IHNldAojIENP
TkZJR19NRElPX09DVEVPTiBpcyBub3Qgc2V0CkNPTkZJR19NRElPX0JDTV9VTklNQUM9bQoj
IENPTkZJR19NSUNSRUxfS1M4OTk1TUEgaXMgbm90IHNldApDT05GSUdfUFBQPW0KQ09ORklH
X1BQUF9CU0RDT01QPW0KQ09ORklHX1BQUF9ERUZMQVRFPW0KQ09ORklHX1BQUF9GSUxURVI9
eQpDT05GSUdfUFBQX01QUEU9bQpDT05GSUdfUFBQX01VTFRJTElOSz15CiMgQ09ORklHX1BQ
UE9BVE0gaXMgbm90IHNldApDT05GSUdfUFBQT0U9bQpDT05GSUdfUFBUUD1tCkNPTkZJR19Q
UFBPTDJUUD1tCkNPTkZJR19QUFBfQVNZTkM9bQpDT05GSUdfUFBQX1NZTkNfVFRZPW0KIyBD
T05GSUdfU0xJUCBpcyBub3Qgc2V0CkNPTkZJR19TTEhDPW0KCiMKIyBIb3N0LXNpZGUgVVNC
IHN1cHBvcnQgaXMgbmVlZGVkIGZvciBVU0IgTmV0d29yayBBZGFwdGVyIHN1cHBvcnQKIwpD
T05GSUdfVVNCX05FVF9EUklWRVJTPW0KQ09ORklHX1VTQl9DQVRDPW0KQ09ORklHX1VTQl9L
QVdFVEg9bQpDT05GSUdfVVNCX1BFR0FTVVM9bQpDT05GSUdfVVNCX1JUTDgxNTA9bQpDT05G
SUdfVVNCX1JUTDgxNTI9bQojIENPTkZJR19VU0JfTEFONzhYWCBpcyBub3Qgc2V0CkNPTkZJ
R19VU0JfVVNCTkVUPW0KIyBDT05GSUdfVVNCX05FVF9BWDg4MTdYIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX05FVF9BWDg4MTc5XzE3OEEgaXMgbm90IHNldAojIENPTkZJR19VU0JfTkVU
X0NEQ0VUSEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX05FVF9DRENfRUVNIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX05FVF9DRENfTkNNIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX05F
VF9IVUFXRUlfQ0RDX05DTSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9ORVRfQ0RDX01CSU0g
aXMgbm90IHNldAojIENPTkZJR19VU0JfTkVUX0RNOTYwMSBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9ORVRfU1I5NzAwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX05FVF9TUjk4MDAgaXMg
bm90IHNldAojIENPTkZJR19VU0JfTkVUX1NNU0M3NVhYIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX05FVF9TTVNDOTVYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9ORVRfR0w2MjBBIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX05FVF9ORVQxMDgwIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX05FVF9QTFVTQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9ORVRfTUNTNzgzMCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9ORVRfUk5ESVNfSE9TVCBpcyBub3Qgc2V0CkNPTkZJR19V
U0JfTkVUX0NEQ19TVUJTRVQ9bQpDT05GSUdfVVNCX0FMSV9NNTYzMj15CkNPTkZJR19VU0Jf
QU4yNzIwPXkKQ09ORklHX1VTQl9CRUxLSU49eQpDT05GSUdfVVNCX0FSTUxJTlVYPXkKQ09O
RklHX1VTQl9FUFNPTjI4ODg9eQpDT05GSUdfVVNCX0tDMjE5MD15CiMgQ09ORklHX1VTQl9O
RVRfWkFVUlVTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX05FVF9DWDgyMzEwX0VUSCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9ORVRfS0FMTUlBIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X05FVF9RTUlfV1dBTiBpcyBub3Qgc2V0CkNPTkZJR19VU0JfSFNPPW0KIyBDT05GSUdfVVNC
X05FVF9JTlQ1MVgxIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NEQ19QSE9ORVQgaXMgbm90
IHNldApDT05GSUdfVVNCX0lQSEVUSD1tCiMgQ09ORklHX1VTQl9TSUVSUkFfTkVUIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX05FVF9DSDkyMDAgaXMgbm90IHNldApDT05GSUdfV0xBTj15
CiMgQ09ORklHX0xJQkVSVEFTX1RISU5GSVJNIGlzIG5vdCBzZXQKIyBDT05GSUdfQUlSTyBp
cyBub3Qgc2V0CiMgQ09ORklHX0FUTUVMIGlzIG5vdCBzZXQKIyBDT05GSUdfQVQ3NkM1MFhf
VVNCIGlzIG5vdCBzZXQKIyBDT05GSUdfUFJJU001NCBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9aRDEyMDEgaXMgbm90IHNldAojIENPTkZJR19VU0JfTkVUX1JORElTX1dMQU4gaXMgbm90
IHNldAojIENPTkZJR19SVEw4MTgwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE4NyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FETTgyMTEgaXMgbm90IHNldAojIENPTkZJR19NQUM4MDIxMV9I
V1NJTSBpcyBub3Qgc2V0CiMgQ09ORklHX01XTDhLIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRI
X0NBUkRTIGlzIG5vdCBzZXQKQ09ORklHX0I0Mz1tCkNPTkZJR19CNDNfQkNNQT15CkNPTkZJ
R19CNDNfU1NCPXkKQ09ORklHX0I0M19CVVNFU19CQ01BX0FORF9TU0I9eQojIENPTkZJR19C
NDNfQlVTRVNfQkNNQSBpcyBub3Qgc2V0CiMgQ09ORklHX0I0M19CVVNFU19TU0IgaXMgbm90
IHNldApDT05GSUdfQjQzX1BDSV9BVVRPU0VMRUNUPXkKQ09ORklHX0I0M19QQ0lDT1JFX0FV
VE9TRUxFQ1Q9eQpDT05GSUdfQjQzX0JDTUFfUElPPXkKQ09ORklHX0I0M19QSU89eQpDT05G
SUdfQjQzX1BIWV9HPXkKQ09ORklHX0I0M19QSFlfTj15CkNPTkZJR19CNDNfUEhZX0xQPXkK
Q09ORklHX0I0M19QSFlfSFQ9eQpDT05GSUdfQjQzX0xFRFM9eQpDT05GSUdfQjQzX0hXUk5H
PXkKIyBDT05GSUdfQjQzX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfQjQzTEVHQUNZIGlz
IG5vdCBzZXQKIyBDT05GSUdfQlJDTVNNQUMgaXMgbm90IHNldAojIENPTkZJR19CUkNNRk1B
QyBpcyBub3Qgc2V0CkNPTkZJR19IT1NUQVA9bQpDT05GSUdfSE9TVEFQX0ZJUk1XQVJFPXkK
IyBDT05GSUdfSE9TVEFQX0ZJUk1XQVJFX05WUkFNIGlzIG5vdCBzZXQKQ09ORklHX0hPU1RB
UF9QTFg9bQpDT05GSUdfSE9TVEFQX1BDST1tCiMgQ09ORklHX0lQVzIxMDAgaXMgbm90IHNl
dAojIENPTkZJR19JUFcyMjAwIGlzIG5vdCBzZXQKIyBDT05GSUdfSVdMV0lGSSBpcyBub3Qg
c2V0CiMgQ09ORklHX0lXTDQ5NjUgaXMgbm90IHNldAojIENPTkZJR19JV0wzOTQ1IGlzIG5v
dCBzZXQKIyBDT05GSUdfTElCRVJUQVMgaXMgbm90IHNldAojIENPTkZJR19IRVJNRVMgaXMg
bm90IHNldAojIENPTkZJR19QNTRfQ09NTU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfUlQyWDAw
IGlzIG5vdCBzZXQKIyBDT05GSUdfV0xfTUVESUFURUsgaXMgbm90IHNldAojIENPTkZJR19S
VExfQ0FSRFMgaXMgbm90IHNldAojIENPTkZJR19XTF9USSBpcyBub3Qgc2V0CiMgQ09ORklH
X1pEMTIxMVJXIGlzIG5vdCBzZXQKIyBDT05GSUdfTVdJRklFWCBpcyBub3Qgc2V0CiMgQ09O
RklHX0NXMTIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1JTSV85MVggaXMgbm90IHNldAoKIwoj
IEVuYWJsZSBXaU1BWCAoTmV0d29ya2luZyBvcHRpb25zKSB0byBzZWUgdGhlIFdpTUFYIGRy
aXZlcnMKIwojIENPTkZJR19XQU4gaXMgbm90IHNldApDT05GSUdfSUVFRTgwMjE1NF9EUklW
RVJTPW0KQ09ORklHX0lFRUU4MDIxNTRfRkFLRUxCPW0KIyBDT05GSUdfSUVFRTgwMjE1NF9B
VDg2UkYyMzAgaXMgbm90IHNldAojIENPTkZJR19JRUVFODAyMTU0X01SRjI0SjQwIGlzIG5v
dCBzZXQKIyBDT05GSUdfSUVFRTgwMjE1NF9DQzI1MjAgaXMgbm90IHNldAojIENPTkZJR19J
RUVFODAyMTU0X0FUVVNCIGlzIG5vdCBzZXQKIyBDT05GSUdfWEVOX05FVERFVl9GUk9OVEVO
RCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZNWE5FVDMgaXMgbm90IHNldAojIENPTkZJR19GVUpJ
VFNVX0VTIGlzIG5vdCBzZXQKIyBDT05GSUdfSFlQRVJWX05FVCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lTRE4gaXMgbm90IHNldAoKIwojIElucHV0IGRldmljZSBzdXBwb3J0CiMKQ09ORklH
X0lOUFVUPXkKQ09ORklHX0lOUFVUX0xFRFM9bQpDT05GSUdfSU5QVVRfRkZfTUVNTEVTUz1t
CkNPTkZJR19JTlBVVF9QT0xMREVWPXkKQ09ORklHX0lOUFVUX1NQQVJTRUtNQVA9bQpDT05G
SUdfSU5QVVRfTUFUUklYS01BUD1tCgojCiMgVXNlcmxhbmQgaW50ZXJmYWNlcwojCkNPTkZJ
R19JTlBVVF9NT1VTRURFVj1tCkNPTkZJR19JTlBVVF9NT1VTRURFVl9QU0FVWD15CkNPTkZJ
R19JTlBVVF9NT1VTRURFVl9TQ1JFRU5fWD0xMDI0CkNPTkZJR19JTlBVVF9NT1VTRURFVl9T
Q1JFRU5fWT03NjgKIyBDT05GSUdfSU5QVVRfSk9ZREVWIGlzIG5vdCBzZXQKQ09ORklHX0lO
UFVUX0VWREVWPW0KIyBDT05GSUdfSU5QVVRfRVZCVUcgaXMgbm90IHNldAoKIwojIElucHV0
IERldmljZSBEcml2ZXJzCiMKQ09ORklHX0lOUFVUX0tFWUJPQVJEPXkKIyBDT05GSUdfS0VZ
Qk9BUkRfQURQNTU4OCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0FEUDU1ODkgaXMg
bm90IHNldAojIENPTkZJR19LRVlCT0FSRF9BVEtCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
WUJPQVJEX1FUMTA3MCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1FUMjE2MCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0xLS0JEIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZ
Qk9BUkRfR1BJTyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0dQSU9fUE9MTEVEIGlz
IG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfVENBNjQxNiBpcyBub3Qgc2V0CiMgQ09ORklH
X0tFWUJPQVJEX1RDQTg0MTggaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9NQVRSSVgg
aXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9MTTgzMjMgaXMgbm90IHNldAojIENPTkZJ
R19LRVlCT0FSRF9MTTgzMzMgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9NQVg3MzU5
IGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfTUNTIGlzIG5vdCBzZXQKIyBDT05GSUdf
S0VZQk9BUkRfTVBSMTIxIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfTkVXVE9OIGlz
IG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfT1BFTkNPUkVTIGlzIG5vdCBzZXQKIyBDT05G
SUdfS0VZQk9BUkRfU0FNU1VORyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1NUT1dB
V0FZIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfU1VOS0JEIGlzIG5vdCBzZXQKIyBD
T05GSUdfS0VZQk9BUkRfWFRLQkQgaXMgbm90IHNldApDT05GSUdfSU5QVVRfTU9VU0U9eQoj
IENPTkZJR19NT1VTRV9QUzIgaXMgbm90IHNldApDT05GSUdfTU9VU0VfU0VSSUFMPXkKQ09O
RklHX01PVVNFX0FQUExFVE9VQ0g9bQpDT05GSUdfTU9VU0VfQkNNNTk3ND1tCiMgQ09ORklH
X01PVVNFX0NZQVBBIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfRUxBTl9JMkMgaXMgbm90
IHNldAojIENPTkZJR19NT1VTRV9WU1hYWEFBIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0Vf
R1BJTyBpcyBub3Qgc2V0CkNPTkZJR19NT1VTRV9TWU5BUFRJQ1NfSTJDPW0KQ09ORklHX01P
VVNFX1NZTkFQVElDU19VU0I9bQojIENPTkZJR19JTlBVVF9KT1lTVElDSyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lOUFVUX1RBQkxFVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX1RPVUNI
U0NSRUVOIGlzIG5vdCBzZXQKQ09ORklHX0lOUFVUX01JU0M9eQojIENPTkZJR19JTlBVVF9B
RDcxNFggaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9CTUExNTAgaXMgbm90IHNldAojIENP
TkZJR19JTlBVVF9FM1gwX0JVVFRPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX1BDU1BL
UiBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX01NQTg0NTAgaXMgbm90IHNldAojIENPTkZJ
R19JTlBVVF9NUFUzMDUwIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfQVBBTkVMIGlzIG5v
dCBzZXQKIyBDT05GSUdfSU5QVVRfR1AyQSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX0dQ
SU9fQkVFUEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfR1BJT19USUxUX1BPTExFRCBp
cyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX0FUTEFTX0JUTlMgaXMgbm90IHNldAojIENPTkZJ
R19JTlBVVF9BVElfUkVNT1RFMiBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX0tFWVNQQU5f
UkVNT1RFIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfS1hUSjkgaXMgbm90IHNldAojIENP
TkZJR19JTlBVVF9QT1dFUk1BVEUgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9ZRUFMSU5L
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfQ00xMDkgaXMgbm90IHNldApDT05GSUdfSU5Q
VVRfVUlOUFVUPW0KIyBDT05GSUdfSU5QVVRfUENGODU3NCBpcyBub3Qgc2V0CiMgQ09ORklH
X0lOUFVUX0dQSU9fUk9UQVJZX0VOQ09ERVIgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9B
RFhMMzRYIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfSU1TX1BDVSBpcyBub3Qgc2V0CiMg
Q09ORklHX0lOUFVUX0NNQTMwMDAgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9YRU5fS0JE
REVWX0ZST05URU5EIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfSURFQVBBRF9TTElERUJB
UiBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX0RSVjI2MFhfSEFQVElDUyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lOUFVUX0RSVjI2NjVfSEFQVElDUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lO
UFVUX0RSVjI2NjdfSEFQVElDUyBpcyBub3Qgc2V0CgojCiMgSGFyZHdhcmUgSS9PIHBvcnRz
CiMKQ09ORklHX1NFUklPPXkKQ09ORklHX0FSQ0hfTUlHSFRfSEFWRV9QQ19TRVJJTz15CkNP
TkZJR19TRVJJT19JODA0Mj1tCkNPTkZJR19TRVJJT19TRVJQT1JUPW0KIyBDT05GSUdfU0VS
SU9fQ1Q4MkM3MTAgaXMgbm90IHNldAojIENPTkZJR19TRVJJT19QQ0lQUzIgaXMgbm90IHNl
dApDT05GSUdfU0VSSU9fTElCUFMyPW0KIyBDT05GSUdfU0VSSU9fUkFXIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VSSU9fQUxURVJBX1BTMiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklPX1BT
Mk1VTFQgaXMgbm90IHNldAojIENPTkZJR19TRVJJT19BUkNfUFMyIGlzIG5vdCBzZXQKIyBD
T05GSUdfSFlQRVJWX0tFWUJPQVJEIGlzIG5vdCBzZXQKQ09ORklHX0dBTUVQT1JUPW0KIyBD
T05GSUdfR0FNRVBPUlRfTlM1NTggaXMgbm90IHNldAojIENPTkZJR19HQU1FUE9SVF9MNCBp
cyBub3Qgc2V0CiMgQ09ORklHX0dBTUVQT1JUX0VNVTEwSzEgaXMgbm90IHNldAojIENPTkZJ
R19HQU1FUE9SVF9GTTgwMSBpcyBub3Qgc2V0CgojCiMgQ2hhcmFjdGVyIGRldmljZXMKIwpD
T05GSUdfVFRZPXkKQ09ORklHX1ZUPXkKQ09ORklHX0NPTlNPTEVfVFJBTlNMQVRJT05TPXkK
Q09ORklHX1ZUX0NPTlNPTEU9eQpDT05GSUdfVlRfQ09OU09MRV9TTEVFUD15CkNPTkZJR19I
V19DT05TT0xFPXkKQ09ORklHX1ZUX0hXX0NPTlNPTEVfQklORElORz15CkNPTkZJR19VTklY
OThfUFRZUz15CkNPTkZJR19ERVZQVFNfTVVMVElQTEVfSU5TVEFOQ0VTPXkKIyBDT05GSUdf
TEVHQUNZX1BUWVMgaXMgbm90IHNldApDT05GSUdfU0VSSUFMX05PTlNUQU5EQVJEPXkKQ09O
RklHX1JPQ0tFVFBPUlQ9bQpDT05GSUdfQ1lDTEFERVM9bQojIENPTkZJR19DWVpfSU5UUiBp
cyBub3Qgc2V0CiMgQ09ORklHX01PWEFfSU5URUxMSU8gaXMgbm90IHNldAojIENPTkZJR19N
T1hBX1NNQVJUSU8gaXMgbm90IHNldApDT05GSUdfU1lOQ0xJTks9bQpDT05GSUdfU1lOQ0xJ
TktNUD1tCiMgQ09ORklHX1NZTkNMSU5LX0dUIGlzIG5vdCBzZXQKQ09ORklHX05PWk9NST1t
CiMgQ09ORklHX0lTSSBpcyBub3Qgc2V0CkNPTkZJR19OX0hETEM9bQpDT05GSUdfTl9HU009
bQpDT05GSUdfVFJBQ0VfUk9VVEVSPW0KQ09ORklHX1RSQUNFX1NJTks9bQpDT05GSUdfREVW
TUVNPXkKIyBDT05GSUdfREVWS01FTSBpcyBub3Qgc2V0CgojCiMgU2VyaWFsIGRyaXZlcnMK
IwpDT05GSUdfU0VSSUFMX0VBUkxZQ09OPXkKQ09ORklHX1NFUklBTF84MjUwPXkKIyBDT05G
SUdfU0VSSUFMXzgyNTBfREVQUkVDQVRFRF9PUFRJT05TIGlzIG5vdCBzZXQKQ09ORklHX1NF
UklBTF84MjUwX1BOUD15CkNPTkZJR19TRVJJQUxfODI1MF9DT05TT0xFPXkKQ09ORklHX1NF
UklBTF84MjUwX0RNQT15CkNPTkZJR19TRVJJQUxfODI1MF9QQ0k9eQpDT05GSUdfU0VSSUFM
XzgyNTBfTlJfVUFSVFM9MzIKQ09ORklHX1NFUklBTF84MjUwX1JVTlRJTUVfVUFSVFM9NAoj
IENPTkZJR19TRVJJQUxfODI1MF9FWFRFTkRFRCBpcyBub3Qgc2V0CkNPTkZJR19TRVJJQUxf
ODI1MF9EVz1tCiMgQ09ORklHX1NFUklBTF84MjUwX0ZJTlRFSyBpcyBub3Qgc2V0CgojCiMg
Tm9uLTgyNTAgc2VyaWFsIHBvcnQgc3VwcG9ydAojCiMgQ09ORklHX1NFUklBTF9NQVgzMTAw
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX01BWDMxMFggaXMgbm90IHNldAojIENPTkZJ
R19TRVJJQUxfVUFSVExJVEUgaXMgbm90IHNldApDT05GSUdfU0VSSUFMX0NPUkU9eQpDT05G
SUdfU0VSSUFMX0NPUkVfQ09OU09MRT15CkNPTkZJR19TRVJJQUxfSlNNPW0KQ09ORklHX1NF
UklBTF9TQ0NOWFA9bQpDT05GSUdfU0VSSUFMX1NDMTZJUzdYWF9DT1JFPW0KQ09ORklHX1NF
UklBTF9TQzE2SVM3WFg9bQpDT05GSUdfU0VSSUFMX1NDMTZJUzdYWF9JMkM9eQojIENPTkZJ
R19TRVJJQUxfU0MxNklTN1hYX1NQSSBpcyBub3Qgc2V0CkNPTkZJR19TRVJJQUxfQUxURVJB
X0pUQUdVQVJUPW0KQ09ORklHX1NFUklBTF9BTFRFUkFfVUFSVD1tCkNPTkZJR19TRVJJQUxf
QUxURVJBX1VBUlRfTUFYUE9SVFM9NApDT05GSUdfU0VSSUFMX0FMVEVSQV9VQVJUX0JBVURS
QVRFPTExNTIwMAojIENPTkZJR19TRVJJQUxfSUZYNlg2MCBpcyBub3Qgc2V0CkNPTkZJR19T
RVJJQUxfQVJDPW0KQ09ORklHX1NFUklBTF9BUkNfTlJfUE9SVFM9MQpDT05GSUdfU0VSSUFM
X1JQMj1tCkNPTkZJR19TRVJJQUxfUlAyX05SX1VBUlRTPTMyCkNPTkZJR19TRVJJQUxfRlNM
X0xQVUFSVD1tCkNPTkZJR19IVkNfRFJJVkVSPXkKQ09ORklHX0hWQ19JUlE9eQpDT05GSUdf
SFZDX1hFTj15CkNPTkZJR19IVkNfWEVOX0ZST05URU5EPXkKQ09ORklHX1ZJUlRJT19DT05T
T0xFPW0KQ09ORklHX0lQTUlfSEFORExFUj1tCiMgQ09ORklHX0lQTUlfUEFOSUNfRVZFTlQg
aXMgbm90IHNldApDT05GSUdfSVBNSV9ERVZJQ0VfSU5URVJGQUNFPW0KQ09ORklHX0lQTUlf
U0k9bQojIENPTkZJR19JUE1JX1NJX1BST0JFX0RFRkFVTFRTIGlzIG5vdCBzZXQKQ09ORklH
X0lQTUlfU1NJRj1tCkNPTkZJR19JUE1JX1dBVENIRE9HPW0KQ09ORklHX0lQTUlfUE9XRVJP
RkY9bQpDT05GSUdfSFdfUkFORE9NPW0KQ09ORklHX0hXX1JBTkRPTV9USU1FUklPTUVNPW0K
Q09ORklHX0hXX1JBTkRPTV9JTlRFTD1tCkNPTkZJR19IV19SQU5ET01fQU1EPW0KQ09ORklH
X0hXX1JBTkRPTV9WSUE9bQpDT05GSUdfSFdfUkFORE9NX1ZJUlRJTz1tCkNPTkZJR19IV19S
QU5ET01fVFBNPW0KQ09ORklHX05WUkFNPW0KQ09ORklHX1IzOTY0PW0KQ09ORklHX0FQUExJ
Q09NPW0KQ09ORklHX01XQVZFPW0KQ09ORklHX1JBV19EUklWRVI9bQpDT05GSUdfTUFYX1JB
V19ERVZTPTI1NgpDT05GSUdfSFBFVD15CkNPTkZJR19IUEVUX01NQVA9eQpDT05GSUdfSFBF
VF9NTUFQX0RFRkFVTFQ9eQpDT05GSUdfSEFOR0NIRUNLX1RJTUVSPW0KQ09ORklHX1RDR19U
UE09bQpDT05GSUdfVENHX1RJUz1tCkNPTkZJR19UQ0dfVElTX0kyQ19BVE1FTD1tCkNPTkZJ
R19UQ0dfVElTX0kyQ19JTkZJTkVPTj1tCkNPTkZJR19UQ0dfVElTX0kyQ19OVVZPVE9OPW0K
Q09ORklHX1RDR19OU0M9bQpDT05GSUdfVENHX0FUTUVMPW0KQ09ORklHX1RDR19JTkZJTkVP
Tj1tCkNPTkZJR19UQ0dfWEVOPW0KQ09ORklHX1RDR19DUkI9bQojIENPTkZJR19UQ0dfVElT
X1NUMzNaUDI0IGlzIG5vdCBzZXQKQ09ORklHX1RFTENMT0NLPW0KQ09ORklHX0RFVlBPUlQ9
eQojIENPTkZJR19YSUxMWUJVUyBpcyBub3Qgc2V0CgojCiMgSTJDIHN1cHBvcnQKIwpDT05G
SUdfSTJDPXkKQ09ORklHX0FDUElfSTJDX09QUkVHSU9OPXkKQ09ORklHX0kyQ19CT0FSRElO
Rk89eQpDT05GSUdfSTJDX0NPTVBBVD15CkNPTkZJR19JMkNfQ0hBUkRFVj1tCkNPTkZJR19J
MkNfTVVYPW0KCiMKIyBNdWx0aXBsZXhlciBJMkMgQ2hpcCBzdXBwb3J0CiMKIyBDT05GSUdf
STJDX01VWF9HUElPIGlzIG5vdCBzZXQKQ09ORklHX0kyQ19NVVhfUENBOTU0MT1tCkNPTkZJ
R19JMkNfTVVYX1BDQTk1NHg9bQojIENPTkZJR19JMkNfTVVYX1BJTkNUUkwgaXMgbm90IHNl
dAojIENPTkZJR19JMkNfTVVYX1JFRyBpcyBub3Qgc2V0CkNPTkZJR19JMkNfSEVMUEVSX0FV
VE89eQpDT05GSUdfSTJDX1NNQlVTPW0KQ09ORklHX0kyQ19BTEdPQklUPXkKQ09ORklHX0ky
Q19BTEdPUENBPW0KCiMKIyBJMkMgSGFyZHdhcmUgQnVzIHN1cHBvcnQKIwoKIwojIFBDIFNN
QnVzIGhvc3QgY29udHJvbGxlciBkcml2ZXJzCiMKQ09ORklHX0kyQ19BTEkxNTM1PW0KQ09O
RklHX0kyQ19BTEkxNTYzPW0KQ09ORklHX0kyQ19BTEkxNVgzPW0KQ09ORklHX0kyQ19BTUQ3
NTY9bQpDT05GSUdfSTJDX0FNRDc1Nl9TNDg4Mj1tCkNPTkZJR19JMkNfQU1EODExMT1tCkNP
TkZJR19JMkNfSTgwMT1tCkNPTkZJR19JMkNfSVNDSD1tCkNPTkZJR19JMkNfSVNNVD1tCkNP
TkZJR19JMkNfUElJWDQ9bQpDT05GSUdfSTJDX05GT1JDRTI9bQpDT05GSUdfSTJDX05GT1JD
RTJfUzQ5ODU9bQpDT05GSUdfSTJDX1NJUzU1OTU9bQpDT05GSUdfSTJDX1NJUzYzMD1tCkNP
TkZJR19JMkNfU0lTOTZYPW0KQ09ORklHX0kyQ19WSUE9bQpDT05GSUdfSTJDX1ZJQVBSTz1t
CgojCiMgQUNQSSBkcml2ZXJzCiMKQ09ORklHX0kyQ19TQ01JPW0KCiMKIyBJMkMgc3lzdGVt
IGJ1cyBkcml2ZXJzIChtb3N0bHkgZW1iZWRkZWQgLyBzeXN0ZW0tb24tY2hpcCkKIwojIENP
TkZJR19JMkNfQ0JVU19HUElPIGlzIG5vdCBzZXQKQ09ORklHX0kyQ19ERVNJR05XQVJFX0NP
UkU9bQpDT05GSUdfSTJDX0RFU0lHTldBUkVfUExBVEZPUk09bQpDT05GSUdfSTJDX0RFU0lH
TldBUkVfUENJPW0KIyBDT05GSUdfSTJDX0VNRVYyIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJD
X0dQSU8gaXMgbm90IHNldApDT05GSUdfSTJDX09DT1JFUz1tCkNPTkZJR19JMkNfUENBX1BM
QVRGT1JNPW0KIyBDT05GSUdfSTJDX1BYQV9QQ0kgaXMgbm90IHNldApDT05GSUdfSTJDX1NJ
TVRFQz1tCkNPTkZJR19JMkNfWElMSU5YPW0KCiMKIyBFeHRlcm5hbCBJMkMvU01CdXMgYWRh
cHRlciBkcml2ZXJzCiMKQ09ORklHX0kyQ19ESU9MQU5fVTJDPW0KQ09ORklHX0kyQ19QQVJQ
T1JUX0xJR0hUPW0KQ09ORklHX0kyQ19ST0JPVEZVWlpfT1NJRj1tCkNPTkZJR19JMkNfVEFP
U19FVk09bQpDT05GSUdfSTJDX1RJTllfVVNCPW0KCiMKIyBPdGhlciBJMkMvU01CdXMgYnVz
IGRyaXZlcnMKIwojIENPTkZJR19JMkNfU1RVQiBpcyBub3Qgc2V0CkNPTkZJR19JMkNfU0xB
VkU9eQpDT05GSUdfSTJDX1NMQVZFX0VFUFJPTT1tCiMgQ09ORklHX0kyQ19ERUJVR19DT1JF
IGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0RFQlVHX0FMR08gaXMgbm90IHNldAojIENPTkZJ
R19JMkNfREVCVUdfQlVTIGlzIG5vdCBzZXQKQ09ORklHX1NQST15CiMgQ09ORklHX1NQSV9E
RUJVRyBpcyBub3Qgc2V0CkNPTkZJR19TUElfTUFTVEVSPXkKCiMKIyBTUEkgTWFzdGVyIENv
bnRyb2xsZXIgRHJpdmVycwojCkNPTkZJR19TUElfQUxURVJBPW0KQ09ORklHX1NQSV9CSVRC
QU5HPW0KIyBDT05GSUdfU1BJX0NBREVOQ0UgaXMgbm90IHNldApDT05GSUdfU1BJX0dQSU89
bQpDT05GSUdfU1BJX09DX1RJTlk9bQpDT05GSUdfU1BJX1BYQTJYWF9ETUE9eQpDT05GSUdf
U1BJX1BYQTJYWD1tCkNPTkZJR19TUElfUFhBMlhYX1BDST1tCkNPTkZJR19TUElfU0MxOElT
NjAyPW0KQ09ORklHX1NQSV9YQ09NTT1tCkNPTkZJR19TUElfWElMSU5YPW0KQ09ORklHX1NQ
SV9aWU5RTVBfR1FTUEk9bQpDT05GSUdfU1BJX0RFU0lHTldBUkU9bQpDT05GSUdfU1BJX0RX
X1BDST1tCiMgQ09ORklHX1NQSV9EV19NSURfRE1BIGlzIG5vdCBzZXQKQ09ORklHX1NQSV9E
V19NTUlPPW0KCiMKIyBTUEkgUHJvdG9jb2wgTWFzdGVycwojCkNPTkZJR19TUElfU1BJREVW
PW0KQ09ORklHX1NQSV9UTEU2MlgwPW0KQ09ORklHX1NQTUk9bQojIENPTkZJR19IU0kgaXMg
bm90IHNldAoKIwojIFBQUyBzdXBwb3J0CiMKQ09ORklHX1BQUz1tCiMgQ09ORklHX1BQU19E
RUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX05UUF9QUFMgaXMgbm90IHNldAoKIwojIFBQUyBj
bGllbnRzIHN1cHBvcnQKIwpDT05GSUdfUFBTX0NMSUVOVF9LVElNRVI9bQpDT05GSUdfUFBT
X0NMSUVOVF9MRElTQz1tCkNPTkZJR19QUFNfQ0xJRU5UX0dQSU89bQoKIwojIFBQUyBnZW5l
cmF0b3JzIHN1cHBvcnQKIwoKIwojIFBUUCBjbG9jayBzdXBwb3J0CiMKQ09ORklHX1BUUF8x
NTg4X0NMT0NLPW0KQ09ORklHX0RQODM2NDBfUEhZPW0KQ09ORklHX1BJTkNUUkw9eQoKIwoj
IFBpbiBjb250cm9sbGVycwojCkNPTkZJR19QSU5NVVg9eQpDT05GSUdfUElOQ09ORj15CkNP
TkZJR19HRU5FUklDX1BJTkNPTkY9eQojIENPTkZJR19ERUJVR19QSU5DVFJMIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUElOQ1RSTF9BTUQgaXMgbm90IHNldApDT05GSUdfUElOQ1RSTF9CQVlU
UkFJTD15CkNPTkZJR19QSU5DVFJMX0NIRVJSWVZJRVc9bQpDT05GSUdfUElOQ1RSTF9JTlRF
TD1tCkNPTkZJR19QSU5DVFJMX1NVTlJJU0VQT0lOVD1tCkNPTkZJR19BUkNIX1dBTlRfT1BU
SU9OQUxfR1BJT0xJQj15CkNPTkZJR19HUElPTElCPXkKQ09ORklHX0dQSU9fREVWUkVTPXkK
Q09ORklHX0dQSU9fQUNQST15CkNPTkZJR19HUElPTElCX0lSUUNISVA9eQojIENPTkZJR19E
RUJVR19HUElPIGlzIG5vdCBzZXQKQ09ORklHX0dQSU9fU1lTRlM9eQoKIwojIE1lbW9yeSBt
YXBwZWQgR1BJTyBkcml2ZXJzCiMKIyBDT05GSUdfR1BJT19EV0FQQiBpcyBub3Qgc2V0CiMg
Q09ORklHX0dQSU9fRjcxODhYIGlzIG5vdCBzZXQKIyBDT05GSUdfR1BJT19HRU5FUklDX1BM
QVRGT1JNIGlzIG5vdCBzZXQKQ09ORklHX0dQSU9fSUNIPW0KIyBDT05GSUdfR1BJT19JVDg3
NjFFIGlzIG5vdCBzZXQKQ09ORklHX0dQSU9fTFlOWFBPSU5UPW0KQ09ORklHX0dQSU9fU0NI
PW0KQ09ORklHX0dQSU9fU0NIMzExWD1tCiMgQ09ORklHX0dQSU9fVlg4NTUgaXMgbm90IHNl
dAoKIwojIEkyQyBHUElPIGV4cGFuZGVycwojCiMgQ09ORklHX0dQSU9fQURQNTU4OCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0dQSU9fTUFYNzMwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9f
TUFYNzMyWCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9fUENBOTUzWCBpcyBub3Qgc2V0CiMg
Q09ORklHX0dQSU9fUENGODU3WCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9fU1gxNTBYIGlz
IG5vdCBzZXQKCiMKIyBNRkQgR1BJTyBleHBhbmRlcnMKIwoKIwojIFBDSSBHUElPIGV4cGFu
ZGVycwojCkNPTkZJR19HUElPX0FNRDgxMTE9bQojIENPTkZJR19HUElPX0JUOFhYIGlzIG5v
dCBzZXQKIyBDT05GSUdfR1BJT19JTlRFTF9NSUQgaXMgbm90IHNldAojIENPTkZJR19HUElP
X01MX0lPSCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9fUkRDMzIxWCBpcyBub3Qgc2V0Cgoj
CiMgU1BJIEdQSU8gZXhwYW5kZXJzCiMKIyBDT05GSUdfR1BJT19NQVg3MzAxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfR1BJT19NQ1AyM1MwOCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9fTUMz
Mzg4MCBpcyBub3Qgc2V0CiMgQ09ORklHX0dQSU9fWlggaXMgbm90IHNldAoKIwojIFVTQiBH
UElPIGV4cGFuZGVycwojCiMgQ09ORklHX1cxIGlzIG5vdCBzZXQKQ09ORklHX1BPV0VSX1NV
UFBMWT15CiMgQ09ORklHX1BPV0VSX1NVUFBMWV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19Q
REFfUE9XRVI9bQojIENPTkZJR19HRU5FUklDX0FEQ19CQVRURVJZIGlzIG5vdCBzZXQKQ09O
RklHX1RFU1RfUE9XRVI9bQojIENPTkZJR19CQVRURVJZX0RTMjc4MCBpcyBub3Qgc2V0CiMg
Q09ORklHX0JBVFRFUllfRFMyNzgxIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFUVEVSWV9EUzI3
ODIgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX1NCUyBpcyBub3Qgc2V0CiMgQ09ORklH
X0JBVFRFUllfQlEyN3gwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0JBVFRFUllfTUFYMTcwNDAg
aXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX01BWDE3MDQyIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ0hBUkdFUl9JU1AxNzA0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hBUkdFUl9NQVg4OTAz
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hBUkdFUl9MUDg3MjcgaXMgbm90IHNldAojIENPTkZJ
R19DSEFSR0VSX0dQSU8gaXMgbm90IHNldAojIENPTkZJR19DSEFSR0VSX0JRMjQxNVggaXMg
bm90IHNldAojIENPTkZJR19DSEFSR0VSX0JRMjQxOTAgaXMgbm90IHNldAojIENPTkZJR19D
SEFSR0VSX0JRMjQyNTcgaXMgbm90IHNldApDT05GSUdfQ0hBUkdFUl9CUTI0NzM1PW0KIyBD
T05GSUdfQ0hBUkdFUl9CUTI1ODkwIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hBUkdFUl9TTUIz
NDcgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX0dBVUdFX0xUQzI5NDEgaXMgbm90IHNl
dAojIENPTkZJR19DSEFSR0VSX1JUOTQ1NSBpcyBub3Qgc2V0CkNPTkZJR19QT1dFUl9SRVNF
VD15CiMgQ09ORklHX1BPV0VSX1JFU0VUX1JFU1RBUlQgaXMgbm90IHNldApDT05GSUdfUE9X
RVJfQVZTPXkKQ09ORklHX0hXTU9OPXkKQ09ORklHX0hXTU9OX1ZJRD1tCiMgQ09ORklHX0hX
TU9OX0RFQlVHX0NISVAgaXMgbm90IHNldAoKIwojIE5hdGl2ZSBkcml2ZXJzCiMKQ09ORklH
X1NFTlNPUlNfQUJJVFVHVVJVPW0KQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJVMz1tCkNPTkZJ
R19TRU5TT1JTX0FENzMxND1tCkNPTkZJR19TRU5TT1JTX0FENzQxND1tCkNPTkZJR19TRU5T
T1JTX0FENzQxOD1tCkNPTkZJR19TRU5TT1JTX0FETTEwMjE9bQpDT05GSUdfU0VOU09SU19B
RE0xMDI1PW0KQ09ORklHX1NFTlNPUlNfQURNMTAyNj1tCkNPTkZJR19TRU5TT1JTX0FETTEw
Mjk9bQpDT05GSUdfU0VOU09SU19BRE0xMDMxPW0KQ09ORklHX1NFTlNPUlNfQURNOTI0MD1t
CkNPTkZJR19TRU5TT1JTX0FEVDdYMTA9bQpDT05GSUdfU0VOU09SU19BRFQ3MzEwPW0KQ09O
RklHX1NFTlNPUlNfQURUNzQxMD1tCkNPTkZJR19TRU5TT1JTX0FEVDc0MTE9bQpDT05GSUdf
U0VOU09SU19BRFQ3NDYyPW0KQ09ORklHX1NFTlNPUlNfQURUNzQ3MD1tCkNPTkZJR19TRU5T
T1JTX0FEVDc0NzU9bQpDT05GSUdfU0VOU09SU19BU0M3NjIxPW0KQ09ORklHX1NFTlNPUlNf
SzhURU1QPW0KQ09ORklHX1NFTlNPUlNfSzEwVEVNUD1tCkNPTkZJR19TRU5TT1JTX0ZBTTE1
SF9QT1dFUj1tCkNPTkZJR19TRU5TT1JTX0FQUExFU01DPW0KQ09ORklHX1NFTlNPUlNfQVNC
MTAwPW0KQ09ORklHX1NFTlNPUlNfQVRYUDE9bQpDT05GSUdfU0VOU09SU19EUzYyMD1tCkNP
TkZJR19TRU5TT1JTX0RTMTYyMT1tCkNPTkZJR19TRU5TT1JTX0RFTExfU01NPW0KQ09ORklH
X1NFTlNPUlNfSTVLX0FNQj1tCkNPTkZJR19TRU5TT1JTX0Y3MTgwNUY9bQpDT05GSUdfU0VO
U09SU19GNzE4ODJGRz1tCkNPTkZJR19TRU5TT1JTX0Y3NTM3NVM9bQpDT05GSUdfU0VOU09S
U19GU0NITUQ9bQpDT05GSUdfU0VOU09SU19HTDUxOFNNPW0KQ09ORklHX1NFTlNPUlNfR0w1
MjBTTT1tCkNPTkZJR19TRU5TT1JTX0c3NjBBPW0KQ09ORklHX1NFTlNPUlNfRzc2Mj1tCkNP
TkZJR19TRU5TT1JTX0dQSU9fRkFOPW0KQ09ORklHX1NFTlNPUlNfSElINjEzMD1tCkNPTkZJ
R19TRU5TT1JTX0lCTUFFTT1tCkNPTkZJR19TRU5TT1JTX0lCTVBFWD1tCiMgQ09ORklHX1NF
TlNPUlNfSUlPX0hXTU9OIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfSTU1MDA9bQpDT05G
SUdfU0VOU09SU19DT1JFVEVNUD1tCkNPTkZJR19TRU5TT1JTX0lUODc9bQpDT05GSUdfU0VO
U09SU19KQzQyPW0KQ09ORklHX1NFTlNPUlNfUE9XUjEyMjA9bQpDT05GSUdfU0VOU09SU19M
SU5FQUdFPW0KQ09ORklHX1NFTlNPUlNfTFRDMjk0NT1tCkNPTkZJR19TRU5TT1JTX0xUQzQx
NTE9bQpDT05GSUdfU0VOU09SU19MVEM0MjE1PW0KQ09ORklHX1NFTlNPUlNfTFRDNDIyMj1t
CkNPTkZJR19TRU5TT1JTX0xUQzQyNDU9bQpDT05GSUdfU0VOU09SU19MVEM0MjYwPW0KQ09O
RklHX1NFTlNPUlNfTFRDNDI2MT1tCkNPTkZJR19TRU5TT1JTX01BWDExMTE9bQpDT05GSUdf
U0VOU09SU19NQVgxNjA2NT1tCkNPTkZJR19TRU5TT1JTX01BWDE2MTk9bQpDT05GSUdfU0VO
U09SU19NQVgxNjY4PW0KQ09ORklHX1NFTlNPUlNfTUFYMTk3PW0KQ09ORklHX1NFTlNPUlNf
TUFYNjYzOT1tCkNPTkZJR19TRU5TT1JTX01BWDY2NDI9bQpDT05GSUdfU0VOU09SU19NQVg2
NjUwPW0KQ09ORklHX1NFTlNPUlNfTUFYNjY5Nz1tCkNPTkZJR19TRU5TT1JTX0hUVTIxPW0K
Q09ORklHX1NFTlNPUlNfTUNQMzAyMT1tCkNPTkZJR19TRU5TT1JTX0FEQ1hYPW0KQ09ORklH
X1NFTlNPUlNfTE02Mz1tCkNPTkZJR19TRU5TT1JTX0xNNzA9bQpDT05GSUdfU0VOU09SU19M
TTczPW0KQ09ORklHX1NFTlNPUlNfTE03NT1tCkNPTkZJR19TRU5TT1JTX0xNNzc9bQpDT05G
SUdfU0VOU09SU19MTTc4PW0KQ09ORklHX1NFTlNPUlNfTE04MD1tCkNPTkZJR19TRU5TT1JT
X0xNODM9bQpDT05GSUdfU0VOU09SU19MTTg1PW0KQ09ORklHX1NFTlNPUlNfTE04Nz1tCkNP
TkZJR19TRU5TT1JTX0xNOTA9bQpDT05GSUdfU0VOU09SU19MTTkyPW0KQ09ORklHX1NFTlNP
UlNfTE05Mz1tCkNPTkZJR19TRU5TT1JTX0xNOTUyMzQ9bQpDT05GSUdfU0VOU09SU19MTTk1
MjQxPW0KQ09ORklHX1NFTlNPUlNfTE05NTI0NT1tCkNPTkZJR19TRU5TT1JTX1BDODczNjA9
bQpDT05GSUdfU0VOU09SU19QQzg3NDI3PW0KQ09ORklHX1NFTlNPUlNfTlRDX1RIRVJNSVNU
T1I9bQpDT05GSUdfU0VOU09SU19OQ1Q2NjgzPW0KQ09ORklHX1NFTlNPUlNfTkNUNjc3NT1t
CkNPTkZJR19TRU5TT1JTX05DVDc4MDI9bQojIENPTkZJR19TRU5TT1JTX05DVDc5MDQgaXMg
bm90IHNldApDT05GSUdfU0VOU09SU19QQ0Y4NTkxPW0KQ09ORklHX1BNQlVTPW0KQ09ORklH
X1NFTlNPUlNfUE1CVVM9bQpDT05GSUdfU0VOU09SU19BRE0xMjc1PW0KQ09ORklHX1NFTlNP
UlNfTE0yNTA2Nj1tCkNPTkZJR19TRU5TT1JTX0xUQzI5Nzg9bQpDT05GSUdfU0VOU09SU19N
QVgxNjA2ND1tCiMgQ09ORklHX1NFTlNPUlNfTUFYMjA3NTEgaXMgbm90IHNldApDT05GSUdf
U0VOU09SU19NQVgzNDQ0MD1tCkNPTkZJR19TRU5TT1JTX01BWDg2ODg9bQpDT05GSUdfU0VO
U09SU19UUFM0MDQyMj1tCkNPTkZJR19TRU5TT1JTX1VDRDkwMDA9bQpDT05GSUdfU0VOU09S
U19VQ0Q5MjAwPW0KQ09ORklHX1NFTlNPUlNfWkw2MTAwPW0KQ09ORklHX1NFTlNPUlNfU0hU
MTU9bQpDT05GSUdfU0VOU09SU19TSFQyMT1tCkNPTkZJR19TRU5TT1JTX1NIVEMxPW0KQ09O
RklHX1NFTlNPUlNfU0lTNTU5NT1tCkNPTkZJR19TRU5TT1JTX0RNRTE3Mzc9bQpDT05GSUdf
U0VOU09SU19FTUMxNDAzPW0KQ09ORklHX1NFTlNPUlNfRU1DMjEwMz1tCkNPTkZJR19TRU5T
T1JTX0VNQzZXMjAxPW0KQ09ORklHX1NFTlNPUlNfU01TQzQ3TTE9bQpDT05GSUdfU0VOU09S
U19TTVNDNDdNMTkyPW0KQ09ORklHX1NFTlNPUlNfU01TQzQ3QjM5Nz1tCkNPTkZJR19TRU5T
T1JTX1NDSDU2WFhfQ09NTU9OPW0KQ09ORklHX1NFTlNPUlNfU0NINTYyNz1tCkNPTkZJR19T
RU5TT1JTX1NDSDU2MzY9bQpDT05GSUdfU0VOU09SU19TTU02NjU9bQpDT05GSUdfU0VOU09S
U19BREMxMjhEODE4PW0KQ09ORklHX1NFTlNPUlNfQURTMTAxNT1tCkNPTkZJR19TRU5TT1JT
X0FEUzc4Mjg9bQpDT05GSUdfU0VOU09SU19BRFM3ODcxPW0KQ09ORklHX1NFTlNPUlNfQU1D
NjgyMT1tCkNPTkZJR19TRU5TT1JTX0lOQTIwOT1tCkNPTkZJR19TRU5TT1JTX0lOQTJYWD1t
CkNPTkZJR19TRU5TT1JTX1RDNzQ9bQpDT05GSUdfU0VOU09SU19USE1DNTA9bQpDT05GSUdf
U0VOU09SU19UTVAxMDI9bQpDT05GSUdfU0VOU09SU19UTVAxMDM9bQpDT05GSUdfU0VOU09S
U19UTVA0MDE9bQpDT05GSUdfU0VOU09SU19UTVA0MjE9bQpDT05GSUdfU0VOU09SU19WSUFf
Q1BVVEVNUD1tCkNPTkZJR19TRU5TT1JTX1ZJQTY4NkE9bQpDT05GSUdfU0VOU09SU19WVDEy
MTE9bQpDT05GSUdfU0VOU09SU19WVDgyMzE9bQpDT05GSUdfU0VOU09SU19XODM3ODFEPW0K
Q09ORklHX1NFTlNPUlNfVzgzNzkxRD1tCkNPTkZJR19TRU5TT1JTX1c4Mzc5MkQ9bQpDT05G
SUdfU0VOU09SU19XODM3OTM9bQpDT05GSUdfU0VOU09SU19XODM3OTU9bQojIENPTkZJR19T
RU5TT1JTX1c4Mzc5NV9GQU5DVFJMIGlzIG5vdCBzZXQKQ09ORklHX1NFTlNPUlNfVzgzTDc4
NVRTPW0KQ09ORklHX1NFTlNPUlNfVzgzTDc4Nk5HPW0KQ09ORklHX1NFTlNPUlNfVzgzNjI3
SEY9bQpDT05GSUdfU0VOU09SU19XODM2MjdFSEY9bQoKIwojIEFDUEkgZHJpdmVycwojCkNP
TkZJR19TRU5TT1JTX0FDUElfUE9XRVI9bQpDT05GSUdfU0VOU09SU19BVEswMTEwPW0KQ09O
RklHX1RIRVJNQUw9eQpDT05GSUdfVEhFUk1BTF9IV01PTj15CkNPTkZJR19USEVSTUFMX1dS
SVRBQkxFX1RSSVBTPXkKQ09ORklHX1RIRVJNQUxfREVGQVVMVF9HT1ZfU1RFUF9XSVNFPXkK
IyBDT05GSUdfVEhFUk1BTF9ERUZBVUxUX0dPVl9GQUlSX1NIQVJFIGlzIG5vdCBzZXQKIyBD
T05GSUdfVEhFUk1BTF9ERUZBVUxUX0dPVl9VU0VSX1NQQUNFIGlzIG5vdCBzZXQKIyBDT05G
SUdfVEhFUk1BTF9ERUZBVUxUX0dPVl9QT1dFUl9BTExPQ0FUT1IgaXMgbm90IHNldApDT05G
SUdfVEhFUk1BTF9HT1ZfRkFJUl9TSEFSRT15CkNPTkZJR19USEVSTUFMX0dPVl9TVEVQX1dJ
U0U9eQpDT05GSUdfVEhFUk1BTF9HT1ZfQkFOR19CQU5HPXkKQ09ORklHX1RIRVJNQUxfR09W
X1VTRVJfU1BBQ0U9eQojIENPTkZJR19USEVSTUFMX0dPVl9QT1dFUl9BTExPQ0FUT1IgaXMg
bm90IHNldAojIENPTkZJR19USEVSTUFMX0VNVUxBVElPTiBpcyBub3Qgc2V0CkNPTkZJR19J
TlRFTF9QT1dFUkNMQU1QPW0KQ09ORklHX1g4Nl9QS0dfVEVNUF9USEVSTUFMPW0KQ09ORklH
X0lOVEVMX1NPQ19EVFNfSU9TRl9DT1JFPW0KQ09ORklHX0lOVEVMX1NPQ19EVFNfVEhFUk1B
TD1tCkNPTkZJR19JTlQzNDBYX1RIRVJNQUw9bQpDT05GSUdfQUNQSV9USEVSTUFMX1JFTD1t
CiMgQ09ORklHX0lOVEVMX1BDSF9USEVSTUFMIGlzIG5vdCBzZXQKQ09ORklHX1dBVENIRE9H
PXkKQ09ORklHX1dBVENIRE9HX0NPUkU9eQojIENPTkZJR19XQVRDSERPR19OT1dBWU9VVCBp
cyBub3Qgc2V0CgojCiMgV2F0Y2hkb2cgRGV2aWNlIERyaXZlcnMKIwpDT05GSUdfU09GVF9X
QVRDSERPRz1tCkNPTkZJR19YSUxJTlhfV0FUQ0hET0c9bQojIENPTkZJR19DQURFTkNFX1dB
VENIRE9HIGlzIG5vdCBzZXQKQ09ORklHX0RXX1dBVENIRE9HPW0KIyBDT05GSUdfUk41VDYx
OF9XQVRDSERPRyBpcyBub3Qgc2V0CiMgQ09ORklHX01BWDYzWFhfV0FUQ0hET0cgaXMgbm90
IHNldApDT05GSUdfQUNRVUlSRV9XRFQ9bQpDT05GSUdfQURWQU5URUNIX1dEVD1tCkNPTkZJ
R19BTElNMTUzNV9XRFQ9bQpDT05GSUdfQUxJTTcxMDFfV0RUPW0KQ09ORklHX0Y3MTgwOEVf
V0RUPW0KQ09ORklHX1NQNTEwMF9UQ089bQpDT05GSUdfU0JDX0ZJVFBDMl9XQVRDSERPRz1t
CkNPTkZJR19FVVJPVEVDSF9XRFQ9bQpDT05GSUdfSUI3MDBfV0RUPW0KQ09ORklHX0lCTUFT
Uj1tCkNPTkZJR19XQUZFUl9XRFQ9bQpDT05GSUdfSTYzMDBFU0JfV0RUPW0KQ09ORklHX0lF
NlhYX1dEVD1tCkNPTkZJR19JVENPX1dEVD1tCkNPTkZJR19JVENPX1ZFTkRPUl9TVVBQT1JU
PXkKQ09ORklHX0lUODcxMkZfV0RUPW0KQ09ORklHX0lUODdfV0RUPW0KQ09ORklHX0hQX1dB
VENIRE9HPW0KQ09ORklHX0hQV0RUX05NSV9ERUNPRElORz15CkNPTkZJR19TQzEyMDBfV0RU
PW0KQ09ORklHX1BDODc0MTNfV0RUPW0KQ09ORklHX05WX1RDTz1tCkNPTkZJR182MFhYX1dE
VD1tCkNPTkZJR19DUFU1X1dEVD1tCkNPTkZJR19TTVNDX1NDSDMxMVhfV0RUPW0KQ09ORklH
X1NNU0MzN0I3ODdfV0RUPW0KQ09ORklHX1ZJQV9XRFQ9bQpDT05GSUdfVzgzNjI3SEZfV0RU
PW0KQ09ORklHX1c4Mzg3N0ZfV0RUPW0KQ09ORklHX1c4Mzk3N0ZfV0RUPW0KQ09ORklHX01B
Q0haX1dEVD1tCkNPTkZJR19TQkNfRVBYX0MzX1dBVENIRE9HPW0KQ09ORklHX01FTl9BMjFf
V0RUPW0KQ09ORklHX1hFTl9XRFQ9bQoKIwojIFBDSS1iYXNlZCBXYXRjaGRvZyBDYXJkcwoj
CkNPTkZJR19QQ0lQQ1dBVENIRE9HPW0KQ09ORklHX1dEVFBDST1tCgojCiMgVVNCLWJhc2Vk
IFdhdGNoZG9nIENhcmRzCiMKQ09ORklHX1VTQlBDV0FUQ0hET0c9bQpDT05GSUdfU1NCX1BP
U1NJQkxFPXkKCiMKIyBTb25pY3MgU2lsaWNvbiBCYWNrcGxhbmUKIwpDT05GSUdfU1NCPW0K
Q09ORklHX1NTQl9TUFJPTT15CkNPTkZJR19TU0JfQkxPQ0tJTz15CkNPTkZJR19TU0JfUENJ
SE9TVF9QT1NTSUJMRT15CkNPTkZJR19TU0JfUENJSE9TVD15CkNPTkZJR19TU0JfQjQzX1BD
SV9CUklER0U9eQojIENPTkZJR19TU0JfREVCVUcgaXMgbm90IHNldApDT05GSUdfU1NCX0RS
SVZFUl9QQ0lDT1JFX1BPU1NJQkxFPXkKQ09ORklHX1NTQl9EUklWRVJfUENJQ09SRT15CkNP
TkZJR19TU0JfRFJJVkVSX0dQSU89eQpDT05GSUdfQkNNQV9QT1NTSUJMRT15CgojCiMgQnJv
YWRjb20gc3BlY2lmaWMgQU1CQQojCkNPTkZJR19CQ01BPW0KQ09ORklHX0JDTUFfQkxPQ0tJ
Tz15CkNPTkZJR19CQ01BX0hPU1RfUENJX1BPU1NJQkxFPXkKQ09ORklHX0JDTUFfSE9TVF9Q
Q0k9eQojIENPTkZJR19CQ01BX0hPU1RfU09DIGlzIG5vdCBzZXQKQ09ORklHX0JDTUFfRFJJ
VkVSX1BDST15CkNPTkZJR19CQ01BX0RSSVZFUl9HTUFDX0NNTj15CkNPTkZJR19CQ01BX0RS
SVZFUl9HUElPPXkKIyBDT05GSUdfQkNNQV9ERUJVRyBpcyBub3Qgc2V0CgojCiMgTXVsdGlm
dW5jdGlvbiBkZXZpY2UgZHJpdmVycwojCkNPTkZJR19NRkRfQ09SRT1tCiMgQ09ORklHX01G
RF9BUzM3MTEgaXMgbm90IHNldAojIENPTkZJR19QTUlDX0FEUDU1MjAgaXMgbm90IHNldAoj
IENPTkZJR19NRkRfQUFUMjg3MF9DT1JFIGlzIG5vdCBzZXQKQ09ORklHX01GRF9CQ001OTBY
WD1tCiMgQ09ORklHX01GRF9BWFAyMFggaXMgbm90IHNldAojIENPTkZJR19NRkRfQ1JPU19F
QyBpcyBub3Qgc2V0CiMgQ09ORklHX1BNSUNfREE5MDNYIGlzIG5vdCBzZXQKIyBDT05GSUdf
TUZEX0RBOTA1Ml9TUEkgaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5MDUyX0kyQyBpcyBu
b3Qgc2V0CiMgQ09ORklHX01GRF9EQTkwNTUgaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5
MDYyIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0RBOTA2MyBpcyBub3Qgc2V0CiMgQ09ORklH
X01GRF9EQTkxNTAgaXMgbm90IHNldAojIENPTkZJR19NRkRfRExOMiBpcyBub3Qgc2V0CiMg
Q09ORklHX01GRF9NQzEzWFhYX1NQSSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQzEzWFhY
X0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX0hUQ19QQVNJQzMgaXMgbm90IHNldAojIENPTkZJ
R19IVENfSTJDUExEIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0lOVEVMX1FVQVJLX0kyQ19H
UElPIGlzIG5vdCBzZXQKQ09ORklHX0xQQ19JQ0g9bQpDT05GSUdfTFBDX1NDSD1tCiMgQ09O
RklHX0lOVEVMX1NPQ19QTUlDIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0lOVEVMX0xQU1Nf
QUNQSSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9JTlRFTF9MUFNTX1BDSSBpcyBub3Qgc2V0
CiMgQ09ORklHX01GRF9KQU5aX0NNT0RJTyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9LRU1Q
TEQgaXMgbm90IHNldAojIENPTkZJR19NRkRfODhQTTgwMCBpcyBub3Qgc2V0CiMgQ09ORklH
X01GRF84OFBNODA1IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEXzg4UE04NjBYIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTUZEX01BWDE0NTc3IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01BWDc3
NjkzIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01BWDc3ODQzIGlzIG5vdCBzZXQKIyBDT05G
SUdfTUZEX01BWDg5MDcgaXMgbm90IHNldAojIENPTkZJR19NRkRfTUFYODkyNSBpcyBub3Qg
c2V0CiMgQ09ORklHX01GRF9NQVg4OTk3IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01BWDg5
OTggaXMgbm90IHNldAojIENPTkZJR19NRkRfTVQ2Mzk3IGlzIG5vdCBzZXQKIyBDT05GSUdf
TUZEX01FTkYyMUJNQyBpcyBub3Qgc2V0CiMgQ09ORklHX0VaWF9QQ0FQIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUZEX1ZJUEVSQk9BUkQgaXMgbm90IHNldAojIENPTkZJR19NRkRfUkVUVSBp
cyBub3Qgc2V0CiMgQ09ORklHX01GRF9QQ0Y1MDYzMyBpcyBub3Qgc2V0CiMgQ09ORklHX1VD
QjE0MDBfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9SREMzMjFYIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUZEX1JUU1hfUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1JUNTAzMyBp
cyBub3Qgc2V0CkNPTkZJR19NRkRfUlRTWF9VU0I9bQojIENPTkZJR19NRkRfUkM1VDU4MyBp
cyBub3Qgc2V0CkNPTkZJR19NRkRfUk41VDYxOD1tCiMgQ09ORklHX01GRF9TRUNfQ09SRSBp
cyBub3Qgc2V0CkNPTkZJR19NRkRfU0k0NzZYX0NPUkU9bQpDT05GSUdfTUZEX1NNNTAxPW0K
Q09ORklHX01GRF9TTTUwMV9HUElPPXkKIyBDT05GSUdfTUZEX1NLWTgxNDUyIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTUZEX1NNU0MgaXMgbm90IHNldApDT05GSUdfQUJYNTAwX0NPUkU9eQoj
IENPTkZJR19BQjMxMDBfQ09SRSBpcyBub3Qgc2V0CkNPTkZJR19NRkRfU1lTQ09OPXkKIyBD
T05GSUdfTUZEX1RJX0FNMzM1WF9UU0NBREMgaXMgbm90IHNldAojIENPTkZJR19NRkRfTFAz
OTQzIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0xQODc4OCBpcyBub3Qgc2V0CiMgQ09ORklH
X01GRF9QQUxNQVMgaXMgbm90IHNldAojIENPTkZJR19UUFM2MTA1WCBpcyBub3Qgc2V0CiMg
Q09ORklHX1RQUzY1MDEwIGlzIG5vdCBzZXQKIyBDT05GSUdfVFBTNjUwN1ggaXMgbm90IHNl
dAojIENPTkZJR19NRkRfVFBTNjUwOTAgaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjUy
MTcgaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjUyMTggaXMgbm90IHNldAojIENPTkZJ
R19NRkRfVFBTNjU4NlggaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjU5MTAgaXMgbm90
IHNldAojIENPTkZJR19NRkRfVFBTNjU5MTIgaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBT
NjU5MTJfSTJDIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1RQUzY1OTEyX1NQSSBpcyBub3Qg
c2V0CiMgQ09ORklHX01GRF9UUFM4MDAzMSBpcyBub3Qgc2V0CiMgQ09ORklHX1RXTDQwMzBf
Q09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX1RXTDYwNDBfQ09SRSBpcyBub3Qgc2V0CiMgQ09O
RklHX01GRF9XTDEyNzNfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9MTTM1MzMgaXMg
bm90IHNldAojIENPTkZJR19NRkRfVE1JTyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9WWDg1
NSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9BUklaT05BX0kyQyBpcyBub3Qgc2V0CiMgQ09O
RklHX01GRF9BUklaT05BX1NQSSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9XTTg0MDAgaXMg
bm90IHNldAojIENPTkZJR19NRkRfV004MzFYX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX01G
RF9XTTgzMVhfU1BJIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1dNODM1MF9JMkMgaXMgbm90
IHNldAojIENPTkZJR19NRkRfV004OTk0IGlzIG5vdCBzZXQKIyBDT05GSUdfUkVHVUxBVE9S
IGlzIG5vdCBzZXQKQ09ORklHX01FRElBX1NVUFBPUlQ9bQoKIwojIE11bHRpbWVkaWEgY29y
ZSBzdXBwb3J0CiMKQ09ORklHX01FRElBX0NBTUVSQV9TVVBQT1JUPXkKIyBDT05GSUdfTUVE
SUFfQU5BTE9HX1RWX1NVUFBPUlQgaXMgbm90IHNldApDT05GSUdfTUVESUFfRElHSVRBTF9U
Vl9TVVBQT1JUPXkKIyBDT05GSUdfTUVESUFfUkFESU9fU1VQUE9SVCBpcyBub3Qgc2V0CkNP
TkZJR19NRURJQV9TRFJfU1VQUE9SVD15CiMgQ09ORklHX01FRElBX1JDX1NVUFBPUlQgaXMg
bm90IHNldApDT05GSUdfTUVESUFfQ09OVFJPTExFUj15CkNPTkZJR19WSURFT19ERVY9bQoj
IENPTkZJR19WSURFT19WNEwyX1NVQkRFVl9BUEkgaXMgbm90IHNldApDT05GSUdfVklERU9f
VjRMMj1tCiMgQ09ORklHX1ZJREVPX0FEVl9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJ
REVPX0ZJWEVEX01JTk9SX1JBTkdFUyBpcyBub3Qgc2V0CkNPTkZJR19WNEwyX01FTTJNRU1f
REVWPW0KQ09ORklHX1ZJREVPQlVGMl9DT1JFPW0KQ09ORklHX1ZJREVPQlVGMl9NRU1PUFM9
bQpDT05GSUdfVklERU9CVUYyX0RNQV9DT05USUc9bQpDT05GSUdfVklERU9CVUYyX1ZNQUxM
T0M9bQpDT05GSUdfRFZCX0NPUkU9bQojIENPTkZJR19EVkJfTkVUIGlzIG5vdCBzZXQKIyBD
T05GSUdfVFRQQ0lfRUVQUk9NIGlzIG5vdCBzZXQKQ09ORklHX0RWQl9NQVhfQURBUFRFUlM9
OAojIENPTkZJR19EVkJfRFlOQU1JQ19NSU5PUlMgaXMgbm90IHNldAoKIwojIE1lZGlhIGRy
aXZlcnMKIwojIENPTkZJR19NRURJQV9VU0JfU1VQUE9SVCBpcyBub3Qgc2V0CiMgQ09ORklH
X01FRElBX1BDSV9TVVBQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfVjRMX1BMQVRGT1JNX0RS
SVZFUlMgaXMgbm90IHNldApDT05GSUdfVjRMX01FTTJNRU1fRFJJVkVSUz15CkNPTkZJR19W
SURFT19NRU0yTUVNX0RFSU5URVJMQUNFPW0KQ09ORklHX1ZJREVPX1NIX1ZFVT1tCkNPTkZJ
R19WNExfVEVTVF9EUklWRVJTPXkKIyBDT05GSUdfVklERU9fVklWSUQgaXMgbm90IHNldAoj
IENPTkZJR19WSURFT19WSU0yTSBpcyBub3Qgc2V0CiMgQ09ORklHX0RWQl9QTEFURk9STV9E
UklWRVJTIGlzIG5vdCBzZXQKCiMKIyBTdXBwb3J0ZWQgTU1DL1NESU8gYWRhcHRlcnMKIwoj
IENPTkZJR19DWVBSRVNTX0ZJUk1XQVJFIGlzIG5vdCBzZXQKCiMKIyBNZWRpYSBhbmNpbGxh
cnkgZHJpdmVycyAodHVuZXJzLCBzZW5zb3JzLCBpMmMsIGZyb250ZW5kcykKIwpDT05GSUdf
TUVESUFfU1VCRFJWX0FVVE9TRUxFQ1Q9eQpDT05GSUdfTUVESUFfQVRUQUNIPXkKCiMKIyBB
dWRpbyBkZWNvZGVycywgcHJvY2Vzc29ycyBhbmQgbWl4ZXJzCiMKCiMKIyBSRFMgZGVjb2Rl
cnMKIwoKIwojIFZpZGVvIGRlY29kZXJzCiMKCiMKIyBWaWRlbyBhbmQgYXVkaW8gZGVjb2Rl
cnMKIwoKIwojIFZpZGVvIGVuY29kZXJzCiMKCiMKIyBDYW1lcmEgc2Vuc29yIGRldmljZXMK
IwoKIwojIEZsYXNoIGRldmljZXMKIwoKIwojIFZpZGVvIGltcHJvdmVtZW50IGNoaXBzCiMK
CiMKIyBBdWRpby9WaWRlbyBjb21wcmVzc2lvbiBjaGlwcwojCgojCiMgTWlzY2VsbGFuZW91
cyBoZWxwZXIgY2hpcHMKIwoKIwojIFNlbnNvcnMgdXNlZCBvbiBzb2NfY2FtZXJhIGRyaXZl
cgojCkNPTkZJR19NRURJQV9UVU5FUj1tCkNPTkZJR19NRURJQV9UVU5FUl9TSU1QTEU9bQpD
T05GSUdfTUVESUFfVFVORVJfVERBODI5MD1tCkNPTkZJR19NRURJQV9UVU5FUl9UREE4MjdY
PW0KQ09ORklHX01FRElBX1RVTkVSX1REQTE4MjcxPW0KQ09ORklHX01FRElBX1RVTkVSX1RE
QTk4ODc9bQpDT05GSUdfTUVESUFfVFVORVJfTVQyMFhYPW0KQ09ORklHX01FRElBX1RVTkVS
X1hDMjAyOD1tCkNPTkZJR19NRURJQV9UVU5FUl9YQzUwMDA9bQpDT05GSUdfTUVESUFfVFVO
RVJfWEM0MDAwPW0KQ09ORklHX01FRElBX1RVTkVSX01DNDRTODAzPW0KCiMKIyBNdWx0aXN0
YW5kYXJkIChzYXRlbGxpdGUpIGZyb250ZW5kcwojCgojCiMgTXVsdGlzdGFuZGFyZCAoY2Fi
bGUgKyB0ZXJyZXN0cmlhbCkgZnJvbnRlbmRzCiMKCiMKIyBEVkItUyAoc2F0ZWxsaXRlKSBm
cm9udGVuZHMKIwoKIwojIERWQi1UICh0ZXJyZXN0cmlhbCkgZnJvbnRlbmRzCiMKIyBDT05G
SUdfRFZCX0FTMTAyX0ZFIGlzIG5vdCBzZXQKCiMKIyBEVkItQyAoY2FibGUpIGZyb250ZW5k
cwojCgojCiMgQVRTQyAoTm9ydGggQW1lcmljYW4vS29yZWFuIFRlcnJlc3RyaWFsL0NhYmxl
IERUVikgZnJvbnRlbmRzCiMKCiMKIyBJU0RCLVQgKHRlcnJlc3RyaWFsKSBmcm9udGVuZHMK
IwoKIwojIElTREItUyAoc2F0ZWxsaXRlKSAmIElTREItVCAodGVycmVzdHJpYWwpIGZyb250
ZW5kcwojCgojCiMgRGlnaXRhbCB0ZXJyZXN0cmlhbCBvbmx5IHR1bmVycy9QTEwKIwoKIwoj
IFNFQyBjb250cm9sIGRldmljZXMgZm9yIERWQi1TCiMKCiMKIyBUb29scyB0byBkZXZlbG9w
IG5ldyBmcm9udGVuZHMKIwojIENPTkZJR19EVkJfRFVNTVlfRkUgaXMgbm90IHNldAoKIwoj
IEdyYXBoaWNzIHN1cHBvcnQKIwpDT05GSUdfQUdQPXkKIyBDT05GSUdfQUdQX0FNRDY0IGlz
IG5vdCBzZXQKQ09ORklHX0FHUF9JTlRFTD15CiMgQ09ORklHX0FHUF9TSVMgaXMgbm90IHNl
dAojIENPTkZJR19BR1BfVklBIGlzIG5vdCBzZXQKQ09ORklHX0lOVEVMX0dUVD15CkNPTkZJ
R19WR0FfQVJCPXkKQ09ORklHX1ZHQV9BUkJfTUFYX0dQVVM9MTYKQ09ORklHX1ZHQV9TV0lU
Q0hFUk9PPXkKQ09ORklHX0RSTT15CkNPTkZJR19EUk1fTUlQSV9EU0k9eQpDT05GSUdfRFJN
X0tNU19IRUxQRVI9eQpDT05GSUdfRFJNX0tNU19GQl9IRUxQRVI9eQpDT05GSUdfRFJNX0ZC
REVWX0VNVUxBVElPTj15CkNPTkZJR19EUk1fTE9BRF9FRElEX0ZJUk1XQVJFPXkKQ09ORklH
X0RSTV9UVE09bQoKIwojIEkyQyBlbmNvZGVyIG9yIGhlbHBlciBjaGlwcwojCkNPTkZJR19E
Uk1fSTJDX0FEVjc1MTE9bQpDT05GSUdfRFJNX0kyQ19DSDcwMDY9bQpDT05GSUdfRFJNX0ky
Q19TSUwxNjQ9bQpDT05GSUdfRFJNX0kyQ19OWFBfVERBOTk4WD1tCiMgQ09ORklHX0RSTV9U
REZYIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1IxMjggaXMgbm90IHNldAojIENPTkZJR19E
Uk1fUkFERU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX0FNREdQVSBpcyBub3Qgc2V0CkNP
TkZJR19EUk1fTk9VVkVBVT1tCkNPTkZJR19OT1VWRUFVX0RFQlVHPTUKQ09ORklHX05PVVZF
QVVfREVCVUdfREVGQVVMVD0zCkNPTkZJR19EUk1fTk9VVkVBVV9CQUNLTElHSFQ9eQpDT05G
SUdfRFJNX0k5MTU9bQojIENPTkZJR19EUk1fSTkxNV9QUkVMSU1JTkFSWV9IV19TVVBQT1JU
IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX01HQSBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9T
SVMgaXMgbm90IHNldAojIENPTkZJR19EUk1fVklBIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJN
X1NBVkFHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9WR0VNIGlzIG5vdCBzZXQKIyBDT05G
SUdfRFJNX1ZNV0dGWCBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9HTUE1MDAgaXMgbm90IHNl
dApDT05GSUdfRFJNX1VETD1tCiMgQ09ORklHX0RSTV9BU1QgaXMgbm90IHNldAojIENPTkZJ
R19EUk1fTUdBRzIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9DSVJSVVNfUUVNVSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RSTV9RWEwgaXMgbm90IHNldAojIENPTkZJR19EUk1fQk9DSFMg
aXMgbm90IHNldAojIENPTkZJR19EUk1fVklSVElPX0dQVSBpcyBub3Qgc2V0CkNPTkZJR19E
Uk1fUEFORUw9eQoKIwojIERpc3BsYXkgUGFuZWxzCiMKQ09ORklHX0RSTV9CUklER0U9eQoK
IwojIERpc3BsYXkgSW50ZXJmYWNlIEJyaWRnZXMKIwoKIwojIEZyYW1lIGJ1ZmZlciBEZXZp
Y2VzCiMKQ09ORklHX0ZCPXkKQ09ORklHX0ZJUk1XQVJFX0VESUQ9eQpDT05GSUdfRkJfQ01E
TElORT15CiMgQ09ORklHX0ZCX0REQyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0JPT1RfVkVT
QV9TVVBQT1JUIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0NGQl9GSUxMUkVDVD15CkNPTkZJR19G
Ql9DRkJfQ09QWUFSRUE9eQpDT05GSUdfRkJfQ0ZCX0lNQUdFQkxJVD15CiMgQ09ORklHX0ZC
X0NGQl9SRVZfUElYRUxTX0lOX0JZVEUgaXMgbm90IHNldApDT05GSUdfRkJfU1lTX0ZJTExS
RUNUPXkKQ09ORklHX0ZCX1NZU19DT1BZQVJFQT15CkNPTkZJR19GQl9TWVNfSU1BR0VCTElU
PXkKIyBDT05GSUdfRkJfRk9SRUlHTl9FTkRJQU4gaXMgbm90IHNldApDT05GSUdfRkJfU1lT
X0ZPUFM9eQpDT05GSUdfRkJfREVGRVJSRURfSU89eQojIENPTkZJR19GQl9TVkdBTElCIGlz
IG5vdCBzZXQKIyBDT05GSUdfRkJfTUFDTU9ERVMgaXMgbm90IHNldApDT05GSUdfRkJfQkFD
S0xJR0hUPXkKQ09ORklHX0ZCX01PREVfSEVMUEVSUz15CkNPTkZJR19GQl9USUxFQkxJVFRJ
Tkc9eQoKIwojIEZyYW1lIGJ1ZmZlciBoYXJkd2FyZSBkcml2ZXJzCiMKIyBDT05GSUdfRkJf
Q0lSUlVTIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfUE0yIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkJfQ1lCRVIyMDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQVJDIGlzIG5vdCBzZXQKIyBD
T05GSUdfRkJfQVNJTElBTlQgaXMgbm90IHNldAojIENPTkZJR19GQl9JTVNUVCBpcyBub3Qg
c2V0CiMgQ09ORklHX0ZCX1ZHQTE2IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVVZFU0EgaXMg
bm90IHNldAojIENPTkZJR19GQl9WRVNBIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0VGST15CiMg
Q09ORklHX0ZCX040MTEgaXMgbm90IHNldAojIENPTkZJR19GQl9IR0EgaXMgbm90IHNldAoj
IENPTkZJR19GQl9PUEVOQ09SRVMgaXMgbm90IHNldAojIENPTkZJR19GQl9TMUQxM1hYWCBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX05WSURJQSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1JJ
VkEgaXMgbm90IHNldAojIENPTkZJR19GQl9JNzQwIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJf
TEU4MDU3OCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX01BVFJPWCBpcyBub3Qgc2V0CiMgQ09O
RklHX0ZCX1JBREVPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0FUWTEyOCBpcyBub3Qgc2V0
CiMgQ09ORklHX0ZCX0FUWSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1MzIGlzIG5vdCBzZXQK
IyBDT05GSUdfRkJfU0FWQUdFIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfU0lTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRkJfVklBIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfTkVPTUFHSUMgaXMg
bm90IHNldAojIENPTkZJR19GQl9LWVJPIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfM0RGWCBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX1ZPT0RPTzEgaXMgbm90IHNldAojIENPTkZJR19GQl9W
VDg2MjMgaXMgbm90IHNldAojIENPTkZJR19GQl9UUklERU5UIGlzIG5vdCBzZXQKIyBDT05G
SUdfRkJfQVJLIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfUE0zIGlzIG5vdCBzZXQKIyBDT05G
SUdfRkJfQ0FSTUlORSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NNNTAxIGlzIG5vdCBzZXQK
IyBDT05GSUdfRkJfU01TQ1VGWCBpcyBub3Qgc2V0CkNPTkZJR19GQl9VREw9bQojIENPTkZJ
R19GQl9WSVJUVUFMIGlzIG5vdCBzZXQKIyBDT05GSUdfWEVOX0ZCREVWX0ZST05URU5EIGlz
IG5vdCBzZXQKIyBDT05GSUdfRkJfTUVUUk9OT01FIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJf
TUI4NjJYWCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0JST0FEU0hFRVQgaXMgbm90IHNldAoj
IENPTkZJR19GQl9BVU9fSzE5MFggaXMgbm90IHNldAojIENPTkZJR19GQl9IWVBFUlYgaXMg
bm90IHNldAojIENPTkZJR19GQl9TSU1QTEUgaXMgbm90IHNldAojIENPTkZJR19GQl9TTTcx
MiBpcyBub3Qgc2V0CkNPTkZJR19CQUNLTElHSFRfTENEX1NVUFBPUlQ9eQpDT05GSUdfTENE
X0NMQVNTX0RFVklDRT1tCiMgQ09ORklHX0xDRF9MNEYwMDI0MlQwMyBpcyBub3Qgc2V0CiMg
Q09ORklHX0xDRF9MTVMyODNHRjA1IGlzIG5vdCBzZXQKIyBDT05GSUdfTENEX0xUVjM1MFFW
IGlzIG5vdCBzZXQKIyBDT05GSUdfTENEX0lMSTkyMlggaXMgbm90IHNldAojIENPTkZJR19M
Q0RfSUxJOTMyMCBpcyBub3Qgc2V0CiMgQ09ORklHX0xDRF9URE8yNE0gaXMgbm90IHNldAoj
IENPTkZJR19MQ0RfVkdHMjQzMkE0IGlzIG5vdCBzZXQKQ09ORklHX0xDRF9QTEFURk9STT1t
CiMgQ09ORklHX0xDRF9TNkU2M00wIGlzIG5vdCBzZXQKIyBDT05GSUdfTENEX0xEOTA0MCBp
cyBub3Qgc2V0CiMgQ09ORklHX0xDRF9BTVMzNjlGRzA2IGlzIG5vdCBzZXQKIyBDT05GSUdf
TENEX0xNUzUwMUtGMDMgaXMgbm90IHNldAojIENPTkZJR19MQ0RfSFg4MzU3IGlzIG5vdCBz
ZXQKQ09ORklHX0JBQ0tMSUdIVF9DTEFTU19ERVZJQ0U9eQojIENPTkZJR19CQUNLTElHSFRf
R0VORVJJQyBpcyBub3Qgc2V0CkNPTkZJR19CQUNLTElHSFRfQVBQTEU9bQojIENPTkZJR19C
QUNLTElHSFRfUE04OTQxX1dMRUQgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfU0FI
QVJBIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFDS0xJR0hUX0FEUDg4NjAgaXMgbm90IHNldAoj
IENPTkZJR19CQUNLTElHSFRfQURQODg3MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JBQ0tMSUdI
VF9MTTM2MzkgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfR1BJTyBpcyBub3Qgc2V0
CiMgQ09ORklHX0JBQ0tMSUdIVF9MVjUyMDdMUCBpcyBub3Qgc2V0CiMgQ09ORklHX0JBQ0tM
SUdIVF9CRDYxMDcgaXMgbm90IHNldAojIENPTkZJR19WR0FTVEFURSBpcyBub3Qgc2V0CkNP
TkZJR19IRE1JPXkKCiMKIyBDb25zb2xlIGRpc3BsYXkgZHJpdmVyIHN1cHBvcnQKIwpDT05G
SUdfVkdBX0NPTlNPTEU9eQojIENPTkZJR19WR0FDT05fU09GVF9TQ1JPTExCQUNLIGlzIG5v
dCBzZXQKQ09ORklHX0RVTU1ZX0NPTlNPTEU9eQpDT05GSUdfRFVNTVlfQ09OU09MRV9DT0xV
TU5TPTgwCkNPTkZJR19EVU1NWV9DT05TT0xFX1JPV1M9MjUKQ09ORklHX0ZSQU1FQlVGRkVS
X0NPTlNPTEU9eQpDT05GSUdfRlJBTUVCVUZGRVJfQ09OU09MRV9ERVRFQ1RfUFJJTUFSWT15
CkNPTkZJR19GUkFNRUJVRkZFUl9DT05TT0xFX1JPVEFUSU9OPXkKIyBDT05GSUdfTE9HTyBp
cyBub3Qgc2V0CkNPTkZJR19TT1VORD1tCkNPTkZJR19TT1VORF9PU1NfQ09SRT15CiMgQ09O
RklHX1NPVU5EX09TU19DT1JFX1BSRUNMQUlNIGlzIG5vdCBzZXQKQ09ORklHX1NORD1tCkNP
TkZJR19TTkRfVElNRVI9bQpDT05GSUdfU05EX1BDTT1tCkNPTkZJR19TTkRfSFdERVA9bQpD
T05GSUdfU05EX1JBV01JREk9bQpDT05GSUdfU05EX0pBQ0s9eQpDT05GSUdfU05EX1NFUVVF
TkNFUj1tCkNPTkZJR19TTkRfU0VRX0RVTU1ZPW0KQ09ORklHX1NORF9PU1NFTVVMPXkKQ09O
RklHX1NORF9NSVhFUl9PU1M9bQpDT05GSUdfU05EX1BDTV9PU1M9bQpDT05GSUdfU05EX1BD
TV9PU1NfUExVR0lOUz15CkNPTkZJR19TTkRfU0VRVUVOQ0VSX09TUz15CkNPTkZJR19TTkRf
SFJUSU1FUj1tCkNPTkZJR19TTkRfU0VRX0hSVElNRVJfREVGQVVMVD15CkNPTkZJR19TTkRf
RFlOQU1JQ19NSU5PUlM9eQpDT05GSUdfU05EX01BWF9DQVJEUz0zMgojIENPTkZJR19TTkRf
U1VQUE9SVF9PTERfQVBJIGlzIG5vdCBzZXQKQ09ORklHX1NORF9QUk9DX0ZTPXkKQ09ORklH
X1NORF9WRVJCT1NFX1BST0NGUz15CiMgQ09ORklHX1NORF9WRVJCT1NFX1BSSU5USyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19TTkRfVk1BU1RF
Uj15CkNPTkZJR19TTkRfRE1BX1NHQlVGPXkKQ09ORklHX1NORF9SQVdNSURJX1NFUT1tCkNP
TkZJR19TTkRfT1BMM19MSUJfU0VRPW0KIyBDT05GSUdfU05EX09QTDRfTElCX1NFUSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9TQkFXRV9TRVEgaXMgbm90IHNldApDT05GSUdfU05EX0VN
VTEwSzFfU0VRPW0KQ09ORklHX1NORF9NUFU0MDFfVUFSVD1tCkNPTkZJR19TTkRfT1BMM19M
SUI9bQpDT05GSUdfU05EX1ZYX0xJQj1tCkNPTkZJR19TTkRfQUM5N19DT0RFQz1tCkNPTkZJ
R19TTkRfRFJJVkVSUz15CiMgQ09ORklHX1NORF9QQ1NQIGlzIG5vdCBzZXQKQ09ORklHX1NO
RF9EVU1NWT1tCkNPTkZJR19TTkRfQUxPT1A9bQpDT05GSUdfU05EX1ZJUk1JREk9bQpDT05G
SUdfU05EX01UUEFWPW0KQ09ORklHX1NORF9TRVJJQUxfVTE2NTUwPW0KQ09ORklHX1NORF9N
UFU0MDE9bQpDT05GSUdfU05EX0FDOTdfUE9XRVJfU0FWRT15CkNPTkZJR19TTkRfQUM5N19Q
T1dFUl9TQVZFX0RFRkFVTFQ9MApDT05GSUdfU05EX1NCX0NPTU1PTj1tCkNPTkZJR19TTkRf
UENJPXkKQ09ORklHX1NORF9BRDE4ODk9bQpDT05GSUdfU05EX0FMUzMwMD1tCkNPTkZJR19T
TkRfQUxTNDAwMD1tCkNPTkZJR19TTkRfQUxJNTQ1MT1tCkNPTkZJR19TTkRfQVNJSFBJPW0K
Q09ORklHX1NORF9BVElJWFA9bQpDT05GSUdfU05EX0FUSUlYUF9NT0RFTT1tCkNPTkZJR19T
TkRfQVU4ODEwPW0KQ09ORklHX1NORF9BVTg4MjA9bQpDT05GSUdfU05EX0FVODgzMD1tCkNP
TkZJR19TTkRfQVcyPW0KQ09ORklHX1NORF9BWlQzMzI4PW0KQ09ORklHX1NORF9CVDg3WD1t
CiMgQ09ORklHX1NORF9CVDg3WF9PVkVSQ0xPQ0sgaXMgbm90IHNldApDT05GSUdfU05EX0NB
MDEwNj1tCkNPTkZJR19TTkRfQ01JUENJPW0KQ09ORklHX1NORF9PWFlHRU5fTElCPW0KQ09O
RklHX1NORF9PWFlHRU49bQpDT05GSUdfU05EX0NTNDI4MT1tCkNPTkZJR19TTkRfQ1M0NlhY
PW0KQ09ORklHX1NORF9DUzQ2WFhfTkVXX0RTUD15CkNPTkZJR19TTkRfQ1RYRkk9bQpDT05G
SUdfU05EX0RBUkxBMjA9bQpDT05GSUdfU05EX0dJTkEyMD1tCkNPTkZJR19TTkRfTEFZTEEy
MD1tCkNPTkZJR19TTkRfREFSTEEyND1tCkNPTkZJR19TTkRfR0lOQTI0PW0KQ09ORklHX1NO
RF9MQVlMQTI0PW0KQ09ORklHX1NORF9NT05BPW0KQ09ORklHX1NORF9NSUE9bQpDT05GSUdf
U05EX0VDSE8zRz1tCkNPTkZJR19TTkRfSU5ESUdPPW0KQ09ORklHX1NORF9JTkRJR09JTz1t
CkNPTkZJR19TTkRfSU5ESUdPREo9bQpDT05GSUdfU05EX0lORElHT0lPWD1tCkNPTkZJR19T
TkRfSU5ESUdPREpYPW0KQ09ORklHX1NORF9FTVUxMEsxPW0KQ09ORklHX1NORF9FTVUxMEsx
WD1tCkNPTkZJR19TTkRfRU5TMTM3MD1tCkNPTkZJR19TTkRfRU5TMTM3MT1tCkNPTkZJR19T
TkRfRVMxOTM4PW0KQ09ORklHX1NORF9FUzE5Njg9bQpDT05GSUdfU05EX0VTMTk2OF9JTlBV
VD15CkNPTkZJR19TTkRfRk04MDE9bQpDT05GSUdfU05EX0hEU1A9bQpDT05GSUdfU05EX0hE
U1BNPW0KQ09ORklHX1NORF9JQ0UxNzEyPW0KQ09ORklHX1NORF9JQ0UxNzI0PW0KQ09ORklH
X1NORF9JTlRFTDhYMD1tCkNPTkZJR19TTkRfSU5URUw4WDBNPW0KQ09ORklHX1NORF9LT1JH
MTIxMj1tCkNPTkZJR19TTkRfTE9MQT1tCkNPTkZJR19TTkRfTFg2NDY0RVM9bQpDT05GSUdf
U05EX01BRVNUUk8zPW0KQ09ORklHX1NORF9NQUVTVFJPM19JTlBVVD15CkNPTkZJR19TTkRf
TUlYQVJUPW0KQ09ORklHX1NORF9OTTI1Nj1tCkNPTkZJR19TTkRfUENYSFI9bQpDT05GSUdf
U05EX1JJUFRJREU9bQpDT05GSUdfU05EX1JNRTMyPW0KQ09ORklHX1NORF9STUU5Nj1tCkNP
TkZJR19TTkRfUk1FOTY1Mj1tCkNPTkZJR19TTkRfU09OSUNWSUJFUz1tCkNPTkZJR19TTkRf
VFJJREVOVD1tCkNPTkZJR19TTkRfVklBODJYWD1tCkNPTkZJR19TTkRfVklBODJYWF9NT0RF
TT1tCkNPTkZJR19TTkRfVklSVFVPU089bQpDT05GSUdfU05EX1ZYMjIyPW0KQ09ORklHX1NO
RF9ZTUZQQ0k9bQoKIwojIEhELUF1ZGlvCiMKQ09ORklHX1NORF9IREE9bQpDT05GSUdfU05E
X0hEQV9JTlRFTD1tCkNPTkZJR19TTkRfSERBX0hXREVQPXkKQ09ORklHX1NORF9IREFfUkVD
T05GSUc9eQpDT05GSUdfU05EX0hEQV9JTlBVVF9CRUVQPXkKQ09ORklHX1NORF9IREFfSU5Q
VVRfQkVFUF9NT0RFPTEKQ09ORklHX1NORF9IREFfUEFUQ0hfTE9BREVSPXkKQ09ORklHX1NO
RF9IREFfQ09ERUNfUkVBTFRFSz1tCkNPTkZJR19TTkRfSERBX0NPREVDX0FOQUxPRz1tCkNP
TkZJR19TTkRfSERBX0NPREVDX1NJR01BVEVMPW0KQ09ORklHX1NORF9IREFfQ09ERUNfVklB
PW0KQ09ORklHX1NORF9IREFfQ09ERUNfSERNST1tCkNPTkZJR19TTkRfSERBX0NPREVDX0NJ
UlJVUz1tCkNPTkZJR19TTkRfSERBX0NPREVDX0NPTkVYQU5UPW0KQ09ORklHX1NORF9IREFf
Q09ERUNfQ0EwMTEwPW0KQ09ORklHX1NORF9IREFfQ09ERUNfQ0EwMTMyPW0KQ09ORklHX1NO
RF9IREFfQ09ERUNfQ0EwMTMyX0RTUD15CkNPTkZJR19TTkRfSERBX0NPREVDX0NNRURJQT1t
CkNPTkZJR19TTkRfSERBX0NPREVDX1NJMzA1ND1tCkNPTkZJR19TTkRfSERBX0dFTkVSSUM9
bQpDT05GSUdfU05EX0hEQV9QT1dFUl9TQVZFX0RFRkFVTFQ9MApDT05GSUdfU05EX0hEQV9D
T1JFPW0KQ09ORklHX1NORF9IREFfRFNQX0xPQURFUj15CkNPTkZJR19TTkRfSERBX0k5MTU9
eQpDT05GSUdfU05EX0hEQV9QUkVBTExPQ19TSVpFPTQwOTYKQ09ORklHX1NORF9TUEk9eQpD
T05GSUdfU05EX1VTQj15CkNPTkZJR19TTkRfVVNCX0FVRElPPW0KIyBDT05GSUdfU05EX1VT
Ql9VQTEwMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfVVNYMlkgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfVVNCX0NBSUFRIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1VTQl9VUzEy
MkwgaXMgbm90IHNldAojIENPTkZJR19TTkRfVVNCXzZGSVJFIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX1VTQl9ISUZBQ0UgaXMgbm90IHNldAojIENPTkZJR19TTkRfQkNEMjAwMCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfUE9EIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1VT
Ql9QT0RIRCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfVE9ORVBPUlQgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfVVNCX1ZBUklBWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9TT0Mg
aXMgbm90IHNldAojIENPTkZJR19TT1VORF9QUklNRSBpcyBub3Qgc2V0CkNPTkZJR19BQzk3
X0JVUz1tCgojCiMgSElEIHN1cHBvcnQKIwpDT05GSUdfSElEPW0KQ09ORklHX0hJRF9CQVRU
RVJZX1NUUkVOR1RIPXkKQ09ORklHX0hJRFJBVz15CkNPTkZJR19VSElEPW0KQ09ORklHX0hJ
RF9HRU5FUklDPW0KCiMKIyBTcGVjaWFsIEhJRCBkcml2ZXJzCiMKIyBDT05GSUdfSElEX0E0
VEVDSCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9BQ1JVWCBpcyBub3Qgc2V0CkNPTkZJR19I
SURfQVBQTEU9bQpDT05GSUdfSElEX0FQUExFSVI9bQojIENPTkZJR19ISURfQVVSRUFMIGlz
IG5vdCBzZXQKIyBDT05GSUdfSElEX0JFTEtJTiBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9C
RVRPUF9GRiBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9DSEVSUlkgaXMgbm90IHNldAojIENP
TkZJR19ISURfQ0hJQ09OWSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9QUk9ESUtFWVMgaXMg
bm90IHNldAojIENPTkZJR19ISURfQ1AyMTEyIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0NZ
UFJFU1MgaXMgbm90IHNldAojIENPTkZJR19ISURfRFJBR09OUklTRSBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9FTVNfRkYgaXMgbm90IHNldAojIENPTkZJR19ISURfRUxFQ09NIGlzIG5v
dCBzZXQKIyBDT05GSUdfSElEX0VMTyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9FWktFWSBp
cyBub3Qgc2V0CiMgQ09ORklHX0hJRF9HRU1CSVJEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElE
X0hPTFRFSyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9HVDY4M1IgaXMgbm90IHNldAojIENP
TkZJR19ISURfS0VZVE9VQ0ggaXMgbm90IHNldAojIENPTkZJR19ISURfS1lFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSElEX1VDTE9HSUMgaXMgbm90IHNldAojIENPTkZJR19ISURfV0FMVE9Q
IGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0dZUkFUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdf
SElEX0lDQURFIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1RXSU5IQU4gaXMgbm90IHNldAoj
IENPTkZJR19ISURfS0VOU0lOR1RPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9MQ1BPV0VS
IGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0xFTk9WTyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJ
RF9MT0dJVEVDSCBpcyBub3Qgc2V0CkNPTkZJR19ISURfTUFHSUNNT1VTRT1tCiMgQ09ORklH
X0hJRF9NSUNST1NPRlQgaXMgbm90IHNldAojIENPTkZJR19ISURfTU9OVEVSRVkgaXMgbm90
IHNldAojIENPTkZJR19ISURfTVVMVElUT1VDSCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9O
VFJJRyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9PUlRFSyBpcyBub3Qgc2V0CiMgQ09ORklH
X0hJRF9QQU5USEVSTE9SRCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9QRU5NT1VOVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0hJRF9QRVRBTFlOWCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9Q
SUNPTENEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1BMQU5UUk9OSUNTIGlzIG5vdCBzZXQK
IyBDT05GSUdfSElEX1BSSU1BWCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9ST0NDQVQgaXMg
bm90IHNldAojIENPTkZJR19ISURfU0FJVEVLIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1NB
TVNVTkcgaXMgbm90IHNldAojIENPTkZJR19ISURfU09OWSBpcyBub3Qgc2V0CiMgQ09ORklH
X0hJRF9TUEVFRExJTksgaXMgbm90IHNldAojIENPTkZJR19ISURfU1RFRUxTRVJJRVMgaXMg
bm90IHNldAojIENPTkZJR19ISURfU1VOUExVUyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9S
TUkgaXMgbm90IHNldAojIENPTkZJR19ISURfR1JFRU5BU0lBIGlzIG5vdCBzZXQKIyBDT05G
SUdfSElEX0hZUEVSVl9NT1VTRSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9TTUFSVEpPWVBM
VVMgaXMgbm90IHNldAojIENPTkZJR19ISURfVElWTyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJ
RF9UT1BTRUVEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1RISU5HTSBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9USFJVU1RNQVNURVIgaXMgbm90IHNldAojIENPTkZJR19ISURfV0FDT00g
aXMgbm90IHNldAojIENPTkZJR19ISURfV0lJTU9URSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJ
RF9YSU5NTyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9aRVJPUExVUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9aWURBQ1JPTiBpcyBub3Qgc2V0CkNPTkZJR19ISURfU0VOU09SX0hVQj1t
CiMgQ09ORklHX0hJRF9TRU5TT1JfQ1VTVE9NX1NFTlNPUiBpcyBub3Qgc2V0CgojCiMgVVNC
IEhJRCBzdXBwb3J0CiMKQ09ORklHX1VTQl9ISUQ9bQpDT05GSUdfSElEX1BJRD15CkNPTkZJ
R19VU0JfSElEREVWPXkKCiMKIyBJMkMgSElEIHN1cHBvcnQKIwpDT05GSUdfSTJDX0hJRD1t
CkNPTkZJR19VU0JfT0hDSV9MSVRUTEVfRU5ESUFOPXkKQ09ORklHX1VTQl9TVVBQT1JUPXkK
Q09ORklHX1VTQl9DT01NT049bQpDT05GSUdfVVNCX0FSQ0hfSEFTX0hDRD15CkNPTkZJR19V
U0I9bQojIENPTkZJR19VU0JfQU5OT1VOQ0VfTkVXX0RFVklDRVMgaXMgbm90IHNldAoKIwoj
IE1pc2NlbGxhbmVvdXMgVVNCIG9wdGlvbnMKIwpDT05GSUdfVVNCX0RFRkFVTFRfUEVSU0lT
VD15CkNPTkZJR19VU0JfRFlOQU1JQ19NSU5PUlM9eQojIENPTkZJR19VU0JfT1RHIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX09UR19XSElURUxJU1QgaXMgbm90IHNldAojIENPTkZJR19V
U0JfT1RHX0ZTTSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9VTFBJX0JVUyBpcyBub3Qgc2V0
CkNPTkZJR19VU0JfTU9OPW0KQ09ORklHX1VTQl9XVVNCX0NCQUY9bQojIENPTkZJR19VU0Jf
V1VTQl9DQkFGX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBVU0IgSG9zdCBDb250cm9sbGVyIERy
aXZlcnMKIwojIENPTkZJR19VU0JfQzY3WDAwX0hDRCBpcyBub3Qgc2V0CkNPTkZJR19VU0Jf
WEhDSV9IQ0Q9bQpDT05GSUdfVVNCX1hIQ0lfUENJPW0KIyBDT05GSUdfVVNCX1hIQ0lfUExB
VEZPUk0gaXMgbm90IHNldApDT05GSUdfVVNCX0VIQ0lfSENEPW0KQ09ORklHX1VTQl9FSENJ
X1JPT1RfSFVCX1RUPXkKQ09ORklHX1VTQl9FSENJX1RUX05FV1NDSEVEPXkKQ09ORklHX1VT
Ql9FSENJX1BDST1tCiMgQ09ORklHX1VTQl9FSENJX0hDRF9QTEFURk9STSBpcyBub3Qgc2V0
CkNPTkZJR19VU0JfT1hVMjEwSFBfSENEPW0KQ09ORklHX1VTQl9JU1AxMTZYX0hDRD1tCkNP
TkZJR19VU0JfSVNQMTM2Ml9IQ0Q9bQpDT05GSUdfVVNCX0ZVU0JIMjAwX0hDRD1tCiMgQ09O
RklHX1VTQl9GT1RHMjEwX0hDRCBpcyBub3Qgc2V0CkNPTkZJR19VU0JfTUFYMzQyMV9IQ0Q9
bQpDT05GSUdfVVNCX09IQ0lfSENEPW0KQ09ORklHX1VTQl9PSENJX0hDRF9QQ0k9bQojIENP
TkZJR19VU0JfT0hDSV9IQ0RfU1NCIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX09IQ0lfSENE
X1BMQVRGT1JNIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9VSENJX0hDRD1tCkNPTkZJR19VU0Jf
U0w4MTFfSENEPW0KIyBDT05GSUdfVVNCX1NMODExX0hDRF9JU08gaXMgbm90IHNldApDT05G
SUdfVVNCX1I4QTY2NTk3X0hDRD1tCiMgQ09ORklHX1VTQl9IQ0RfQkNNQSBpcyBub3Qgc2V0
CiMgQ09ORklHX1VTQl9IQ0RfU1NCIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0hDRF9URVNU
X01PREUgaXMgbm90IHNldAoKIwojIFVTQiBEZXZpY2UgQ2xhc3MgZHJpdmVycwojCkNPTkZJ
R19VU0JfQUNNPW0KQ09ORklHX1VTQl9QUklOVEVSPW0KQ09ORklHX1VTQl9XRE09bQpDT05G
SUdfVVNCX1RNQz1tCgojCiMgTk9URTogVVNCX1NUT1JBR0UgZGVwZW5kcyBvbiBTQ1NJIGJ1
dCBCTEtfREVWX1NEIG1heQojCgojCiMgYWxzbyBiZSBuZWVkZWQ7IHNlZSBVU0JfU1RPUkFH
RSBIZWxwIGZvciBtb3JlIGluZm8KIwpDT05GSUdfVVNCX1NUT1JBR0U9bQojIENPTkZJR19V
U0JfU1RPUkFHRV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19VU0JfU1RPUkFHRV9SRUFMVEVL
PW0KQ09ORklHX1JFQUxURUtfQVVUT1BNPXkKQ09ORklHX1VTQl9TVE9SQUdFX0RBVEFGQUI9
bQpDT05GSUdfVVNCX1NUT1JBR0VfRlJFRUNPTT1tCkNPTkZJR19VU0JfU1RPUkFHRV9JU0Qy
MDA9bQpDT05GSUdfVVNCX1NUT1JBR0VfVVNCQVQ9bQpDT05GSUdfVVNCX1NUT1JBR0VfU0RE
UjA5PW0KQ09ORklHX1VTQl9TVE9SQUdFX1NERFI1NT1tCkNPTkZJR19VU0JfU1RPUkFHRV9K
VU1QU0hPVD1tCkNPTkZJR19VU0JfU1RPUkFHRV9BTEFVREE9bQpDT05GSUdfVVNCX1NUT1JB
R0VfT05FVE9VQ0g9bQpDT05GSUdfVVNCX1NUT1JBR0VfS0FSTUE9bQpDT05GSUdfVVNCX1NU
T1JBR0VfQ1lQUkVTU19BVEFDQj1tCkNPTkZJR19VU0JfU1RPUkFHRV9FTkVfVUI2MjUwPW0K
Q09ORklHX1VTQl9VQVM9bQoKIwojIFVTQiBJbWFnaW5nIGRldmljZXMKIwojIENPTkZJR19V
U0JfTURDODAwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX01JQ1JPVEVLIGlzIG5vdCBzZXQK
Q09ORklHX1VTQklQX0NPUkU9bQpDT05GSUdfVVNCSVBfVkhDSV9IQ0Q9bQpDT05GSUdfVVNC
SVBfSE9TVD1tCiMgQ09ORklHX1VTQklQX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X01VU0JfSERSQyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9EV0MzIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX0RXQzIgaXMgbm90IHNldAojIENPTkZJR19VU0JfQ0hJUElERUEgaXMgbm90
IHNldAojIENPTkZJR19VU0JfSVNQMTc2MCBpcyBub3Qgc2V0CgojCiMgVVNCIHBvcnQgZHJp
dmVycwojCkNPTkZJR19VU0JfU0VSSUFMPW0KQ09ORklHX1VTQl9TRVJJQUxfR0VORVJJQz15
CkNPTkZJR19VU0JfU0VSSUFMX1NJTVBMRT1tCkNPTkZJR19VU0JfU0VSSUFMX0FJUkNBQkxF
PW0KQ09ORklHX1VTQl9TRVJJQUxfQVJLMzExNj1tCkNPTkZJR19VU0JfU0VSSUFMX0JFTEtJ
Tj1tCkNPTkZJR19VU0JfU0VSSUFMX0NIMzQxPW0KQ09ORklHX1VTQl9TRVJJQUxfV0hJVEVI
RUFUPW0KQ09ORklHX1VTQl9TRVJJQUxfRElHSV9BQ0NFTEVQT1JUPW0KQ09ORklHX1VTQl9T
RVJJQUxfQ1AyMTBYPW0KQ09ORklHX1VTQl9TRVJJQUxfQ1lQUkVTU19NOD1tCkNPTkZJR19V
U0JfU0VSSUFMX0VNUEVHPW0KQ09ORklHX1VTQl9TRVJJQUxfRlRESV9TSU89bQpDT05GSUdf
VVNCX1NFUklBTF9WSVNPUj1tCkNPTkZJR19VU0JfU0VSSUFMX0lQQVE9bQpDT05GSUdfVVNC
X1NFUklBTF9JUj1tCkNPTkZJR19VU0JfU0VSSUFMX0VER0VQT1JUPW0KQ09ORklHX1VTQl9T
RVJJQUxfRURHRVBPUlRfVEk9bQpDT05GSUdfVVNCX1NFUklBTF9GODEyMzI9bQpDT05GSUdf
VVNCX1NFUklBTF9HQVJNSU49bQpDT05GSUdfVVNCX1NFUklBTF9JUFc9bQpDT05GSUdfVVNC
X1NFUklBTF9JVVU9bQpDT05GSUdfVVNCX1NFUklBTF9LRVlTUEFOX1BEQT1tCkNPTkZJR19V
U0JfU0VSSUFMX0tFWVNQQU49bQpDT05GSUdfVVNCX1NFUklBTF9LTFNJPW0KQ09ORklHX1VT
Ql9TRVJJQUxfS09CSUxfU0NUPW0KQ09ORklHX1VTQl9TRVJJQUxfTUNUX1UyMzI9bQpDT05G
SUdfVVNCX1NFUklBTF9NRVRSTz1tCkNPTkZJR19VU0JfU0VSSUFMX01PUzc3MjA9bQpDT05G
SUdfVVNCX1NFUklBTF9NT1M3ODQwPW0KQ09ORklHX1VTQl9TRVJJQUxfTVhVUE9SVD1tCkNP
TkZJR19VU0JfU0VSSUFMX05BVk1BTj1tCkNPTkZJR19VU0JfU0VSSUFMX1BMMjMwMz1tCkNP
TkZJR19VU0JfU0VSSUFMX09USTY4NTg9bQpDT05GSUdfVVNCX1NFUklBTF9RQ0FVWD1tCkNP
TkZJR19VU0JfU0VSSUFMX1FVQUxDT01NPW0KQ09ORklHX1VTQl9TRVJJQUxfU1BDUDhYNT1t
CkNPTkZJR19VU0JfU0VSSUFMX1NBRkU9bQojIENPTkZJR19VU0JfU0VSSUFMX1NBRkVfUEFE
REVEIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9TRVJJQUxfU0lFUlJBV0lSRUxFU1M9bQpDT05G
SUdfVVNCX1NFUklBTF9TWU1CT0w9bQpDT05GSUdfVVNCX1NFUklBTF9UST1tCkNPTkZJR19V
U0JfU0VSSUFMX0NZQkVSSkFDSz1tCkNPTkZJR19VU0JfU0VSSUFMX1hJUkNPTT1tCkNPTkZJ
R19VU0JfU0VSSUFMX1dXQU49bQpDT05GSUdfVVNCX1NFUklBTF9PUFRJT049bQpDT05GSUdf
VVNCX1NFUklBTF9PTU5JTkVUPW0KQ09ORklHX1VTQl9TRVJJQUxfT1BUSUNPTj1tCkNPTkZJ
R19VU0JfU0VSSUFMX1hTRU5TX01UPW0KQ09ORklHX1VTQl9TRVJJQUxfV0lTSEJPTkU9bQpD
T05GSUdfVVNCX1NFUklBTF9TU1UxMDA9bQpDT05GSUdfVVNCX1NFUklBTF9RVDI9bQojIENP
TkZJR19VU0JfU0VSSUFMX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBVU0IgTWlzY2VsbGFuZW91
cyBkcml2ZXJzCiMKIyBDT05GSUdfVVNCX0VNSTYyIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X0VNSTI2IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0FEVVRVWCBpcyBub3Qgc2V0CiMgQ09O
RklHX1VTQl9TRVZTRUcgaXMgbm90IHNldAojIENPTkZJR19VU0JfUklPNTAwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0xFR09UT1dFUiBpcyBub3Qgc2V0CkNPTkZJR19VU0JfTENEPW0K
Q09ORklHX1VTQl9MRUQ9bQojIENPTkZJR19VU0JfQ1lQUkVTU19DWTdDNjMgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfQ1lUSEVSTSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JRE1PVVNF
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0ZURElfRUxBTiBpcyBub3Qgc2V0CkNPTkZJR19V
U0JfQVBQTEVESVNQTEFZPW0KIyBDT05GSUdfVVNCX1NJU1VTQlZHQSBpcyBub3Qgc2V0CiMg
Q09ORklHX1VTQl9MRCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9UUkFOQ0VWSUJSQVRPUiBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JT1dBUlJJT1IgaXMgbm90IHNldApDT05GSUdfVVNC
X1RFU1Q9bQojIENPTkZJR19VU0JfRUhTRVRfVEVTVF9GSVhUVVJFIGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9JU0lHSFRGVz1tCiMgQ09ORklHX1VTQl9ZVVJFWCBpcyBub3Qgc2V0CkNPTkZJ
R19VU0JfRVpVU0JfRlgyPW0KQ09ORklHX1VTQl9IU0lDX1VTQjM1MDM9bQpDT05GSUdfVVNC
X0xJTktfTEFZRVJfVEVTVD1tCkNPTkZJR19VU0JfQ0hBT1NLRVk9bQojIENPTkZJR19VU0Jf
QVRNIGlzIG5vdCBzZXQKCiMKIyBVU0IgUGh5c2ljYWwgTGF5ZXIgZHJpdmVycwojCkNPTkZJ
R19VU0JfUEhZPXkKQ09ORklHX05PUF9VU0JfWENFSVY9bQojIENPTkZJR19VU0JfR1BJT19W
QlVTIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9JU1AxMzAxPW0KQ09ORklHX1VTQl9HQURHRVQ9
bQojIENPTkZJR19VU0JfR0FER0VUX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dB
REdFVF9ERUJVR19GSUxFUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9HQURHRVRfREVCVUdf
RlMgaXMgbm90IHNldApDT05GSUdfVVNCX0dBREdFVF9WQlVTX0RSQVc9MgpDT05GSUdfVVNC
X0dBREdFVF9TVE9SQUdFX05VTV9CVUZGRVJTPTIKCiMKIyBVU0IgUGVyaXBoZXJhbCBDb250
cm9sbGVyCiMKIyBDT05GSUdfVVNCX0ZPVEcyMTBfVURDIGlzIG5vdCBzZXQKQ09ORklHX1VT
Ql9HUl9VREM9bQpDT05GSUdfVVNCX1I4QTY2NTk3PW0KQ09ORklHX1VTQl9QWEEyN1g9bQpD
T05GSUdfVVNCX01WX1VEQz1tCkNPTkZJR19VU0JfTVZfVTNEPW0KQ09ORklHX1VTQl9NNjY1
OTI9bQpDT05GSUdfVVNCX0JEQ19VREM9bQoKIwojIFBsYXRmb3JtIFN1cHBvcnQKIwpDT05G
SUdfVVNCX0JEQ19QQ0k9bQpDT05GSUdfVVNCX0FNRDU1MzZVREM9bQpDT05GSUdfVVNCX05F
VDIyNzI9bQpDT05GSUdfVVNCX05FVDIyNzJfRE1BPXkKQ09ORklHX1VTQl9ORVQyMjgwPW0K
Q09ORklHX1VTQl9HT0tVPW0KQ09ORklHX1VTQl9FRzIwVD1tCkNPTkZJR19VU0JfRFVNTVlf
SENEPW0KQ09ORklHX1VTQl9MSUJDT01QT1NJVEU9bQpDT05GSUdfVVNCX0ZfQUNNPW0KQ09O
RklHX1VTQl9VX1NFUklBTD1tCkNPTkZJR19VU0JfVV9FVEhFUj1tCkNPTkZJR19VU0JfRl9T
RVJJQUw9bQpDT05GSUdfVVNCX0ZfT0JFWD1tCkNPTkZJR19VU0JfRl9OQ009bQpDT05GSUdf
VVNCX0ZfRUNNPW0KQ09ORklHX1VTQl9GX1NVQlNFVD1tCkNPTkZJR19VU0JfRl9STkRJUz1t
CkNPTkZJR19VU0JfRl9NQVNTX1NUT1JBR0U9bQpDT05GSUdfVVNCX0ZfRlM9bQpDT05GSUdf
VVNCX0ZfVUFDMj1tCkNPTkZJR19VU0JfRl9VVkM9bQpDT05GSUdfVVNCX0ZfTUlEST1tCkNP
TkZJR19VU0JfRl9ISUQ9bQpDT05GSUdfVVNCX0ZfUFJJTlRFUj1tCiMgQ09ORklHX1VTQl9D
T05GSUdGUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9aRVJPIGlzIG5vdCBzZXQKQ09ORklH
X1VTQl9BVURJTz1tCiMgQ09ORklHX0dBREdFVF9VQUMxIGlzIG5vdCBzZXQKQ09ORklHX1VT
Ql9FVEg9bQpDT05GSUdfVVNCX0VUSF9STkRJUz15CiMgQ09ORklHX1VTQl9FVEhfRUVNIGlz
IG5vdCBzZXQKQ09ORklHX1VTQl9HX05DTT1tCkNPTkZJR19VU0JfR0FER0VURlM9bQpDT05G
SUdfVVNCX0ZVTkNUSU9ORlM9bQpDT05GSUdfVVNCX0ZVTkNUSU9ORlNfRVRIPXkKQ09ORklH
X1VTQl9GVU5DVElPTkZTX1JORElTPXkKQ09ORklHX1VTQl9GVU5DVElPTkZTX0dFTkVSSUM9
eQpDT05GSUdfVVNCX01BU1NfU1RPUkFHRT1tCkNPTkZJR19VU0JfR0FER0VUX1RBUkdFVD1t
CkNPTkZJR19VU0JfR19TRVJJQUw9bQpDT05GSUdfVVNCX01JRElfR0FER0VUPW0KQ09ORklH
X1VTQl9HX1BSSU5URVI9bQojIENPTkZJR19VU0JfQ0RDX0NPTVBPU0lURSBpcyBub3Qgc2V0
CiMgQ09ORklHX1VTQl9HX05PS0lBIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dfQUNNX01T
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0dfTVVMVEkgaXMgbm90IHNldApDT05GSUdfVVNC
X0dfSElEPW0KQ09ORklHX1VTQl9HX0RCR1A9bQojIENPTkZJR19VU0JfR19EQkdQX1BSSU5U
SyBpcyBub3Qgc2V0CkNPTkZJR19VU0JfR19EQkdQX1NFUklBTD15CkNPTkZJR19VU0JfR19X
RUJDQU09bQpDT05GSUdfVVNCX0xFRF9UUklHPXkKIyBDT05GSUdfVVdCIGlzIG5vdCBzZXQK
IyBDT05GSUdfTU1DIGlzIG5vdCBzZXQKIyBDT05GSUdfTUVNU1RJQ0sgaXMgbm90IHNldApD
T05GSUdfTkVXX0xFRFM9eQpDT05GSUdfTEVEU19DTEFTUz1tCkNPTkZJR19MRURTX0NMQVNT
X0ZMQVNIPW0KCiMKIyBMRUQgZHJpdmVycwojCkNPTkZJR19MRURTX0xNMzUzMD1tCkNPTkZJ
R19MRURTX0xNMzY0Mj1tCkNPTkZJR19MRURTX1BDQTk1MzI9bQojIENPTkZJR19MRURTX1BD
QTk1MzJfR1BJTyBpcyBub3Qgc2V0CkNPTkZJR19MRURTX0dQSU89bQpDT05GSUdfTEVEU19M
UDM5NDQ9bQojIENPTkZJR19MRURTX0xQNTUyMSBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNf
TFA1NTIzIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19MUDU1NjIgaXMgbm90IHNldAojIENP
TkZJR19MRURTX0xQODUwMSBpcyBub3Qgc2V0CkNPTkZJR19MRURTX0xQODg2MD1tCkNPTkZJ
R19MRURTX0NMRVZPX01BSUw9bQpDT05GSUdfTEVEU19QQ0E5NTVYPW0KQ09ORklHX0xFRFNf
UENBOTYzWD1tCkNPTkZJR19MRURTX0RBQzEyNFMwODU9bQpDT05GSUdfTEVEU19CRDI4MDI9
bQpDT05GSUdfTEVEU19JTlRFTF9TUzQyMDA9bQpDT05GSUdfTEVEU19MVDM1OTM9bQpDT05G
SUdfTEVEU19ERUxMX05FVEJPT0tTPW0KQ09ORklHX0xFRFNfVENBNjUwNz1tCkNPTkZJR19M
RURTX1RMQzU5MVhYPW0KQ09ORklHX0xFRFNfTE0zNTV4PW0KCiMKIyBMRUQgZHJpdmVyIGZv
ciBibGluaygxKSBVU0IgUkdCIExFRCBpcyB1bmRlciBTcGVjaWFsIEhJRCBkcml2ZXJzIChI
SURfVEhJTkdNKQojCkNPTkZJR19MRURTX0JMSU5LTT1tCgojCiMgTEVEIFRyaWdnZXJzCiMK
Q09ORklHX0xFRFNfVFJJR0dFUlM9eQpDT05GSUdfTEVEU19UUklHR0VSX1RJTUVSPW0KQ09O
RklHX0xFRFNfVFJJR0dFUl9PTkVTSE9UPW0KQ09ORklHX0xFRFNfVFJJR0dFUl9IRUFSVEJF
QVQ9bQpDT05GSUdfTEVEU19UUklHR0VSX0JBQ0tMSUdIVD1tCkNPTkZJR19MRURTX1RSSUdH
RVJfQ1BVPXkKQ09ORklHX0xFRFNfVFJJR0dFUl9HUElPPW0KQ09ORklHX0xFRFNfVFJJR0dF
Ul9ERUZBVUxUX09OPW0KCiMKIyBpcHRhYmxlcyB0cmlnZ2VyIGlzIHVuZGVyIE5ldGZpbHRl
ciBjb25maWcgKExFRCB0YXJnZXQpCiMKQ09ORklHX0xFRFNfVFJJR0dFUl9UUkFOU0lFTlQ9
bQpDT05GSUdfTEVEU19UUklHR0VSX0NBTUVSQT1tCkNPTkZJR19BQ0NFU1NJQklMSVRZPXkK
Q09ORklHX0ExMVlfQlJBSUxMRV9DT05TT0xFPXkKIyBDT05GSUdfSU5GSU5JQkFORCBpcyBu
b3Qgc2V0CkNPTkZJR19FREFDX0FUT01JQ19TQ1JVQj15CkNPTkZJR19FREFDX1NVUFBPUlQ9
eQpDT05GSUdfRURBQz15CkNPTkZJR19FREFDX0xFR0FDWV9TWVNGUz15CiMgQ09ORklHX0VE
QUNfREVCVUcgaXMgbm90IHNldApDT05GSUdfRURBQ19NTV9FREFDPW0KQ09ORklHX0VEQUNf
RTc1Mlg9bQpDT05GSUdfRURBQ19JODI5NzVYPW0KQ09ORklHX0VEQUNfSTMwMDA9bQpDT05G
SUdfRURBQ19JMzIwMD1tCkNPTkZJR19FREFDX0lFMzEyMDA9bQpDT05GSUdfRURBQ19YMzg9
bQpDT05GSUdfRURBQ19JNTQwMD1tCkNPTkZJR19FREFDX0k3Q09SRT1tCkNPTkZJR19FREFD
X0k1MDAwPW0KQ09ORklHX0VEQUNfSTUxMDA9bQpDT05GSUdfRURBQ19JNzMwMD1tCkNPTkZJ
R19FREFDX1NCUklER0U9bQpDT05GSUdfUlRDX0xJQj15CkNPTkZJR19SVENfQ0xBU1M9eQpD
T05GSUdfUlRDX0hDVE9TWVM9eQpDT05GSUdfUlRDX0hDVE9TWVNfREVWSUNFPSJydGMwIgpD
T05GSUdfUlRDX1NZU1RPSEM9eQpDT05GSUdfUlRDX1NZU1RPSENfREVWSUNFPSJydGMwIgoj
IENPTkZJR19SVENfREVCVUcgaXMgbm90IHNldAoKIwojIFJUQyBpbnRlcmZhY2VzCiMKQ09O
RklHX1JUQ19JTlRGX1NZU0ZTPXkKQ09ORklHX1JUQ19JTlRGX1BST0M9eQpDT05GSUdfUlRD
X0lOVEZfREVWPXkKQ09ORklHX1JUQ19JTlRGX0RFVl9VSUVfRU1VTD15CkNPTkZJR19SVENf
RFJWX1RFU1Q9bQoKIwojIEkyQyBSVEMgZHJpdmVycwojCiMgQ09ORklHX1JUQ19EUlZfQUJC
NVpFUzMgaXMgbm90IHNldApDT05GSUdfUlRDX0RSVl9BQlg4MFg9bQpDT05GSUdfUlRDX0RS
Vl9EUzEzMDc9bQpDT05GSUdfUlRDX0RSVl9EUzEzNzQ9bQpDT05GSUdfUlRDX0RSVl9EUzEz
NzRfV0RUPXkKQ09ORklHX1JUQ19EUlZfRFMxNjcyPW0KQ09ORklHX1JUQ19EUlZfRFMzMjMy
PW0KQ09ORklHX1JUQ19EUlZfTUFYNjkwMD1tCkNPTkZJR19SVENfRFJWX1JTNUMzNzI9bQpD
T05GSUdfUlRDX0RSVl9JU0wxMjA4PW0KQ09ORklHX1JUQ19EUlZfSVNMMTIwMjI9bQpDT05G
SUdfUlRDX0RSVl9JU0wxMjA1Nz1tCkNPTkZJR19SVENfRFJWX1gxMjA1PW0KQ09ORklHX1JU
Q19EUlZfUENGMjEyNz1tCkNPTkZJR19SVENfRFJWX1BDRjg1MjM9bQpDT05GSUdfUlRDX0RS
Vl9QQ0Y4NTYzPW0KQ09ORklHX1JUQ19EUlZfUENGODUwNjM9bQpDT05GSUdfUlRDX0RSVl9Q
Q0Y4NTgzPW0KQ09ORklHX1JUQ19EUlZfTTQxVDgwPW0KQ09ORklHX1JUQ19EUlZfTTQxVDgw
X1dEVD15CkNPTkZJR19SVENfRFJWX0JRMzJLPW0KQ09ORklHX1JUQ19EUlZfUzM1MzkwQT1t
CkNPTkZJR19SVENfRFJWX0ZNMzEzMD1tCkNPTkZJR19SVENfRFJWX1JYODU4MT1tCkNPTkZJ
R19SVENfRFJWX1JYODAyNT1tCkNPTkZJR19SVENfRFJWX0VNMzAyNz1tCkNPTkZJR19SVENf
RFJWX1JWMzAyOUMyPW0KCiMKIyBTUEkgUlRDIGRyaXZlcnMKIwojIENPTkZJR19SVENfRFJW
X000MVQ5MyBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTTQxVDk0IGlzIG5vdCBzZXQK
IyBDT05GSUdfUlRDX0RSVl9EUzEzMDUgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0RT
MTM0MyBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfRFMxMzQ3IGlzIG5vdCBzZXQKIyBD
T05GSUdfUlRDX0RSVl9EUzEzOTAgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX01BWDY5
MDIgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1I5NzAxIGlzIG5vdCBzZXQKIyBDT05G
SUdfUlRDX0RSVl9SUzVDMzQ4IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9EUzMyMzQg
aXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1BDRjIxMjMgaXMgbm90IHNldAojIENPTkZJ
R19SVENfRFJWX1JYNDU4MSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTUNQNzk1IGlz
IG5vdCBzZXQKCiMKIyBQbGF0Zm9ybSBSVEMgZHJpdmVycwojCkNPTkZJR19SVENfRFJWX0NN
T1M9eQpDT05GSUdfUlRDX0RSVl9EUzEyODY9bQpDT05GSUdfUlRDX0RSVl9EUzE1MTE9bQpD
T05GSUdfUlRDX0RSVl9EUzE1NTM9bQpDT05GSUdfUlRDX0RSVl9EUzE2ODVfRkFNSUxZPW0K
Q09ORklHX1JUQ19EUlZfRFMxNjg1PXkKIyBDT05GSUdfUlRDX0RSVl9EUzE2ODkgaXMgbm90
IHNldAojIENPTkZJR19SVENfRFJWX0RTMTcyODUgaXMgbm90IHNldAojIENPTkZJR19SVENf
RFJWX0RTMTc0ODUgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0RTMTc4ODUgaXMgbm90
IHNldAojIENPTkZJR19SVENfRFMxNjg1X1BST0NfUkVHUyBpcyBub3Qgc2V0CkNPTkZJR19S
VENfRFMxNjg1X1NZU0ZTX1JFR1M9eQpDT05GSUdfUlRDX0RSVl9EUzE3NDI9bQpDT05GSUdf
UlRDX0RSVl9EUzI0MDQ9bQpDT05GSUdfUlRDX0RSVl9TVEsxN1RBOD1tCkNPTkZJR19SVENf
RFJWX000OFQ4Nj1tCkNPTkZJR19SVENfRFJWX000OFQzNT1tCkNPTkZJR19SVENfRFJWX000
OFQ1OT1tCkNPTkZJR19SVENfRFJWX01TTTYyNDI9bQpDT05GSUdfUlRDX0RSVl9CUTQ4MDI9
bQpDT05GSUdfUlRDX0RSVl9SUDVDMDE9bQpDT05GSUdfUlRDX0RSVl9WMzAyMD1tCgojCiMg
b24tQ1BVIFJUQyBkcml2ZXJzCiMKCiMKIyBISUQgU2Vuc29yIFJUQyBkcml2ZXJzCiMKIyBD
T05GSUdfUlRDX0RSVl9ISURfU0VOU09SX1RJTUUgaXMgbm90IHNldApDT05GSUdfRE1BREVW
SUNFUz15CiMgQ09ORklHX0RNQURFVklDRVNfREVCVUcgaXMgbm90IHNldAoKIwojIERNQSBE
ZXZpY2VzCiMKQ09ORklHX0RNQV9FTkdJTkU9eQpDT05GSUdfRE1BX0FDUEk9eQojIENPTkZJ
R19JRE1BNjQgaXMgbm90IHNldApDT05GSUdfSU5URUxfSU9BVERNQT1tCkNPTkZJR19JTlRF
TF9NSUNfWDEwMF9ETUE9bQpDT05GSUdfRFdfRE1BQ19DT1JFPW0KQ09ORklHX0RXX0RNQUM9
bQpDT05GSUdfRFdfRE1BQ19QQ0k9bQojIENPTkZJR19IU1VfRE1BX1BDSSBpcyBub3Qgc2V0
CgojCiMgRE1BIENsaWVudHMKIwpDT05GSUdfQVNZTkNfVFhfRE1BPXkKIyBDT05GSUdfRE1B
VEVTVCBpcyBub3Qgc2V0CkNPTkZJR19ETUFfRU5HSU5FX1JBSUQ9eQpDT05GSUdfRENBPW0K
Q09ORklHX0FVWERJU1BMQVk9eQpDT05GSUdfVUlPPW0KQ09ORklHX1VJT19DSUY9bQpDT05G
SUdfVUlPX1BEUlZfR0VOSVJRPW0KIyBDT05GSUdfVUlPX0RNRU1fR0VOSVJRIGlzIG5vdCBz
ZXQKQ09ORklHX1VJT19BRUM9bQpDT05GSUdfVUlPX1NFUkNPUzM9bQpDT05GSUdfVUlPX1BD
SV9HRU5FUklDPW0KIyBDT05GSUdfVUlPX05FVFggaXMgbm90IHNldAojIENPTkZJR19VSU9f
UFJVU1MgaXMgbm90IHNldAojIENPTkZJR19VSU9fTUY2MjQgaXMgbm90IHNldApDT05GSUdf
VkZJT19JT01NVV9UWVBFMT1tCkNPTkZJR19WRklPX1ZJUlFGRD1tCkNPTkZJR19WRklPPW0K
Q09ORklHX1ZGSU9fUENJPW0KQ09ORklHX1ZGSU9fUENJX1ZHQT15CkNPTkZJR19WRklPX1BD
SV9NTUFQPXkKQ09ORklHX1ZGSU9fUENJX0lOVFg9eQpDT05GSUdfVklSVF9EUklWRVJTPXkK
Q09ORklHX1ZJUlRJTz1tCgojCiMgVmlydGlvIGRyaXZlcnMKIwpDT05GSUdfVklSVElPX1BD
ST1tCkNPTkZJR19WSVJUSU9fUENJX0xFR0FDWT15CkNPTkZJR19WSVJUSU9fQkFMTE9PTj1t
CkNPTkZJR19WSVJUSU9fSU5QVVQ9bQpDT05GSUdfVklSVElPX01NSU89bQpDT05GSUdfVklS
VElPX01NSU9fQ01ETElORV9ERVZJQ0VTPXkKCiMKIyBNaWNyb3NvZnQgSHlwZXItViBndWVz
dCBzdXBwb3J0CiMKQ09ORklHX0hZUEVSVj1tCkNPTkZJR19IWVBFUlZfVVRJTFM9bQpDT05G
SUdfSFlQRVJWX0JBTExPT049bQoKIwojIFhlbiBkcml2ZXIgc3VwcG9ydAojCiMgQ09ORklH
X1hFTl9CQUxMT09OIGlzIG5vdCBzZXQKIyBDT05GSUdfWEVOX0RFVl9FVlRDSE4gaXMgbm90
IHNldAojIENPTkZJR19YRU5fQkFDS0VORCBpcyBub3Qgc2V0CiMgQ09ORklHX1hFTkZTIGlz
IG5vdCBzZXQKIyBDT05GSUdfWEVOX1NZU19IWVBFUlZJU09SIGlzIG5vdCBzZXQKQ09ORklH
X1hFTl9YRU5CVVNfRlJPTlRFTkQ9eQojIENPTkZJR19YRU5fR05UREVWIGlzIG5vdCBzZXQK
IyBDT05GSUdfWEVOX0dSQU5UX0RFVl9BTExPQyBpcyBub3Qgc2V0CkNPTkZJR19TV0lPVExC
X1hFTj15CkNPTkZJR19YRU5fVE1FTT1tCkNPTkZJR19YRU5fUFJJVkNNRD1tCiMgQ09ORklH
X1hFTl9BQ1BJX1BST0NFU1NPUiBpcyBub3Qgc2V0CiMgQ09ORklHX1hFTl9NQ0VfTE9HIGlz
IG5vdCBzZXQKQ09ORklHX1hFTl9IQVZFX1BWTU1VPXkKQ09ORklHX1hFTl9FRkk9eQpDT05G
SUdfWEVOX0FVVE9fWExBVEU9eQpDT05GSUdfWEVOX0FDUEk9eQpDT05GSUdfWEVOX0hBVkVf
VlBNVT15CkNPTkZJR19TVEFHSU5HPXkKIyBDT05GSUdfU0xJQ09TUyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BSSVNNMl9VU0IgaXMgbm90IHNldAojIENPTkZJR19DT01FREkgaXMgbm90IHNl
dAojIENPTkZJR19SVEw4MTkyVSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTExJQiBpcyBub3Qg
c2V0CiMgQ09ORklHX1I4NzEyVSBpcyBub3Qgc2V0CiMgQ09ORklHX1I4MTg4RVUgaXMgbm90
IHNldAojIENPTkZJR19SODcyM0FVIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRTNTIwOCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1ZUNjY1NSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZUNjY1NiBpcyBu
b3Qgc2V0CgojCiMgSUlPIHN0YWdpbmcgZHJpdmVycwojCgojCiMgQWNjZWxlcm9tZXRlcnMK
IwojIENPTkZJR19BRElTMTYyMDEgaXMgbm90IHNldAojIENPTkZJR19BRElTMTYyMDMgaXMg
bm90IHNldAojIENPTkZJR19BRElTMTYyMDQgaXMgbm90IHNldAojIENPTkZJR19BRElTMTYy
MDkgaXMgbm90IHNldAojIENPTkZJR19BRElTMTYyMjAgaXMgbm90IHNldAojIENPTkZJR19B
RElTMTYyNDAgaXMgbm90IHNldAojIENPTkZJR19MSVMzTDAyRFEgaXMgbm90IHNldAojIENP
TkZJR19TQ0EzMDAwIGlzIG5vdCBzZXQKCiMKIyBBbmFsb2cgdG8gZGlnaXRhbCBjb252ZXJ0
ZXJzCiMKIyBDT05GSUdfQUQ3NjA2IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ3NzgwIGlzIG5v
dCBzZXQKIyBDT05GSUdfQUQ3ODE2IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ3MTkyIGlzIG5v
dCBzZXQKIyBDT05GSUdfQUQ3MjgwIGlzIG5vdCBzZXQKCiMKIyBBbmFsb2cgZGlnaXRhbCBi
aS1kaXJlY3Rpb24gY29udmVydGVycwojCiMgQ09ORklHX0FEVDczMTYgaXMgbm90IHNldAoK
IwojIENhcGFjaXRhbmNlIHRvIGRpZ2l0YWwgY29udmVydGVycwojCiMgQ09ORklHX0FENzE1
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0FENzE1MiBpcyBub3Qgc2V0CiMgQ09ORklHX0FENzc0
NiBpcyBub3Qgc2V0CgojCiMgRGlyZWN0IERpZ2l0YWwgU3ludGhlc2lzCiMKIyBDT05GSUdf
QUQ5ODMyIGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ5ODM0IGlzIG5vdCBzZXQKCiMKIyBEaWdp
dGFsIGd5cm9zY29wZSBzZW5zb3JzCiMKIyBDT05GSUdfQURJUzE2MDYwIGlzIG5vdCBzZXQK
CiMKIyBOZXR3b3JrIEFuYWx5emVyLCBJbXBlZGFuY2UgQ29udmVydGVycwojCiMgQ09ORklH
X0FENTkzMyBpcyBub3Qgc2V0CgojCiMgTGlnaHQgc2Vuc29ycwojCiMgQ09ORklHX1NFTlNP
UlNfSVNMMjkwMTggaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0lTTDI5MDI4IGlzIG5v
dCBzZXQKIyBDT05GSUdfVFNMMjU4MyBpcyBub3Qgc2V0CiMgQ09ORklHX1RTTDJ4N3ggaXMg
bm90IHNldAoKIwojIE1hZ25ldG9tZXRlciBzZW5zb3JzCiMKQ09ORklHX1NFTlNPUlNfSE1D
NTg0Mz1tCkNPTkZJR19TRU5TT1JTX0hNQzU4NDNfSTJDPW0KQ09ORklHX1NFTlNPUlNfSE1D
NTg0M19TUEk9bQoKIwojIEFjdGl2ZSBlbmVyZ3kgbWV0ZXJpbmcgSUMKIwojIENPTkZJR19B
REU3NzUzIGlzIG5vdCBzZXQKIyBDT05GSUdfQURFNzc1NCBpcyBub3Qgc2V0CiMgQ09ORklH
X0FERTc3NTggaXMgbm90IHNldAojIENPTkZJR19BREU3NzU5IGlzIG5vdCBzZXQKIyBDT05G
SUdfQURFNzg1NCBpcyBub3Qgc2V0CgojCiMgUmVzb2x2ZXIgdG8gZGlnaXRhbCBjb252ZXJ0
ZXJzCiMKIyBDT05GSUdfQUQyUzkwIGlzIG5vdCBzZXQKIyBDT05GSUdfQUQyUzEyMDAgaXMg
bm90IHNldAojIENPTkZJR19BRDJTMTIxMCBpcyBub3Qgc2V0CgojCiMgVHJpZ2dlcnMgLSBz
dGFuZGFsb25lCiMKIyBDT05GSUdfSUlPX1BFUklPRElDX1JUQ19UUklHR0VSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSUlPX1NJTVBMRV9EVU1NWSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NN
NzUwIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfWEdJIGlzIG5vdCBzZXQKIyBDT05GSUdfRlQx
MDAwIGlzIG5vdCBzZXQKCiMKIyBTcGVha3VwIGNvbnNvbGUgc3BlZWNoCiMKQ09ORklHX1NQ
RUFLVVA9bQpDT05GSUdfU1BFQUtVUF9TWU5USF9BQ05UU0E9bQpDT05GSUdfU1BFQUtVUF9T
WU5USF9BUE9MTE89bQpDT05GSUdfU1BFQUtVUF9TWU5USF9BVURQVFI9bQpDT05GSUdfU1BF
QUtVUF9TWU5USF9CTlM9bQpDT05GSUdfU1BFQUtVUF9TWU5USF9ERUNUTEs9bQpDT05GSUdf
U1BFQUtVUF9TWU5USF9ERUNFWFQ9bQpDT05GSUdfU1BFQUtVUF9TWU5USF9MVExLPW0KQ09O
RklHX1NQRUFLVVBfU1lOVEhfU09GVD1tCkNPTkZJR19TUEVBS1VQX1NZTlRIX1NQS09VVD1t
CkNPTkZJR19TUEVBS1VQX1NZTlRIX1RYUFJUPW0KQ09ORklHX1NQRUFLVVBfU1lOVEhfRFVN
TVk9bQojIENPTkZJR19UT1VDSFNDUkVFTl9TWU5BUFRJQ1NfSTJDX1JNSTQgaXMgbm90IHNl
dAojIENPTkZJR19TVEFHSU5HX01FRElBIGlzIG5vdCBzZXQKCiMKIyBBbmRyb2lkCiMKIyBD
T05GSUdfV0lNQVhfR0RNNzJYWCBpcyBub3Qgc2V0CiMgQ09ORklHX0xURV9HRE03MjRYIGlz
IG5vdCBzZXQKIyBDT05GSUdfTVREX1NQSU5BTkRfTVQyOUYgaXMgbm90IHNldAojIENPTkZJ
R19MVVNUUkVfRlMgaXMgbm90IHNldAojIENPTkZJR19ER05DIGlzIG5vdCBzZXQKIyBDT05G
SUdfREdBUCBpcyBub3Qgc2V0CiMgQ09ORklHX0dTX0ZQR0FCT09UIGlzIG5vdCBzZXQKIyBD
T05GSUdfQ1JZUFRPX1NLRUlOIGlzIG5vdCBzZXQKIyBDT05GSUdfVU5JU1lTU1BBUiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0ZCX1RGVCBpcyBub3Qgc2V0CiMgQ09ORklHX01PU1QgaXMgbm90
IHNldApDT05GSUdfWDg2X1BMQVRGT1JNX0RFVklDRVM9eQojIENPTkZJR19BQ0VSX1dNSSBp
cyBub3Qgc2V0CiMgQ09ORklHX0FDRVJIREYgaXMgbm90IHNldAojIENPTkZJR19BTElFTldB
UkVfV01JIGlzIG5vdCBzZXQKIyBDT05GSUdfQVNVU19MQVBUT1AgaXMgbm90IHNldAojIENP
TkZJR19ERUxMX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFTExfV01JIGlzIG5vdCBz
ZXQKIyBDT05GSUdfREVMTF9XTUlfQUlPIGlzIG5vdCBzZXQKIyBDT05GSUdfREVMTF9TTU84
ODAwIGlzIG5vdCBzZXQKIyBDT05GSUdfREVMTF9SQlROIGlzIG5vdCBzZXQKIyBDT05GSUdf
RlVKSVRTVV9MQVBUT1AgaXMgbm90IHNldAojIENPTkZJR19GVUpJVFNVX1RBQkxFVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FNSUxPX1JGS0lMTCBpcyBub3Qgc2V0CiMgQ09ORklHX0hQX0FD
Q0VMIGlzIG5vdCBzZXQKIyBDT05GSUdfSFBfV0lSRUxFU1MgaXMgbm90IHNldAojIENPTkZJ
R19IUF9XTUkgaXMgbm90IHNldAojIENPTkZJR19NU0lfTEFQVE9QIGlzIG5vdCBzZXQKIyBD
T05GSUdfUEFOQVNPTklDX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0NPTVBBTF9MQVBU
T1AgaXMgbm90IHNldAojIENPTkZJR19TT05ZX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklH
X0lERUFQQURfTEFQVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfVEhJTktQQURfQUNQSSBpcyBu
b3Qgc2V0CkNPTkZJR19TRU5TT1JTX0hEQVBTPXkKQ09ORklHX0lOVEVMX01FTkxPVz1tCiMg
Q09ORklHX0VFRVBDX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0FTVVNfV01JIGlzIG5v
dCBzZXQKQ09ORklHX0FDUElfV01JPW0KIyBDT05GSUdfTVNJX1dNSSBpcyBub3Qgc2V0CiMg
Q09ORklHX1RPUFNUQVJfTEFQVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9UT1NISUJB
IGlzIG5vdCBzZXQKIyBDT05GSUdfVE9TSElCQV9CVF9SRktJTEwgaXMgbm90IHNldAojIENP
TkZJR19UT1NISUJBX0hBUFMgaXMgbm90IHNldAojIENPTkZJR19BQ1BJX0NNUEMgaXMgbm90
IHNldApDT05GSUdfSU5URUxfSVBTPW0KQ09ORklHX0lCTV9SVEw9bQojIENPTkZJR19TQU1T
VU5HX0xBUFRPUCBpcyBub3Qgc2V0CkNPTkZJR19NWE1fV01JPW0KIyBDT05GSUdfSU5URUxf
T0FLVFJBSUwgaXMgbm90IHNldAojIENPTkZJR19TQU1TVU5HX1ExMCBpcyBub3Qgc2V0CkNP
TkZJR19BUFBMRV9HTVVYPW0KQ09ORklHX0lOVEVMX1JTVD1tCkNPTkZJR19JTlRFTF9TTUFS
VENPTk5FQ1Q9eQpDT05GSUdfUFZQQU5JQz1tCkNPTkZJR19JTlRFTF9QTUNfSVBDPW0KIyBD
T05GSUdfU1VSRkFDRV9QUk8zX0JVVFRPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0NIUk9NRV9Q
TEFURk9STVMgaXMgbm90IHNldApDT05GSUdfQ0xLREVWX0xPT0tVUD15CkNPTkZJR19IQVZF
X0NMS19QUkVQQVJFPXkKQ09ORklHX0NPTU1PTl9DTEs9eQoKIwojIENvbW1vbiBDbG9jayBG
cmFtZXdvcmsKIwojIENPTkZJR19DT01NT05fQ0xLX1NJNTM1MSBpcyBub3Qgc2V0CiMgQ09O
RklHX0NPTU1PTl9DTEtfUFhBIGlzIG5vdCBzZXQKIyBDT05GSUdfQ09NTU9OX0NMS19DRENF
NzA2IGlzIG5vdCBzZXQKCiMKIyBIYXJkd2FyZSBTcGlubG9jayBkcml2ZXJzCiMKCiMKIyBD
bG9jayBTb3VyY2UgZHJpdmVycwojCkNPTkZJR19DTEtFVlRfSTgyNTM9eQpDT05GSUdfSTgy
NTNfTE9DSz15CkNPTkZJR19DTEtCTERfSTgyNTM9eQojIENPTkZJR19BVE1FTF9QSVQgaXMg
bm90IHNldAojIENPTkZJR19TSF9USU1FUl9DTVQgaXMgbm90IHNldAojIENPTkZJR19TSF9U
SU1FUl9NVFUyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0hfVElNRVJfVE1VIGlzIG5vdCBzZXQK
IyBDT05GSUdfRU1fVElNRVJfU1RJIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFJTEJPWCBpcyBu
b3Qgc2V0CkNPTkZJR19JT01NVV9BUEk9eQpDT05GSUdfSU9NTVVfU1VQUE9SVD15CgojCiMg
R2VuZXJpYyBJT01NVSBQYWdldGFibGUgU3VwcG9ydAojCkNPTkZJR19JT01NVV9JT1ZBPXkK
Q09ORklHX0FNRF9JT01NVT15CiMgQ09ORklHX0FNRF9JT01NVV9TVEFUUyBpcyBub3Qgc2V0
CkNPTkZJR19BTURfSU9NTVVfVjI9bQpDT05GSUdfRE1BUl9UQUJMRT15CkNPTkZJR19JTlRF
TF9JT01NVT15CiMgQ09ORklHX0lOVEVMX0lPTU1VX0RFRkFVTFRfT04gaXMgbm90IHNldApD
T05GSUdfSU5URUxfSU9NTVVfRkxPUFBZX1dBPXkKQ09ORklHX0lSUV9SRU1BUD15CgojCiMg
UmVtb3RlcHJvYyBkcml2ZXJzCiMKIyBDT05GSUdfU1RFX01PREVNX1JQUk9DIGlzIG5vdCBz
ZXQKCiMKIyBScG1zZyBkcml2ZXJzCiMKCiMKIyBTT0MgKFN5c3RlbSBPbiBDaGlwKSBzcGVj
aWZpYyBEcml2ZXJzCiMKIyBDT05GSUdfU1VOWElfU1JBTSBpcyBub3Qgc2V0CiMgQ09ORklH
X1NPQ19USSBpcyBub3Qgc2V0CkNPTkZJR19QTV9ERVZGUkVRPXkKCiMKIyBERVZGUkVRIEdv
dmVybm9ycwojCkNPTkZJR19ERVZGUkVRX0dPVl9TSU1QTEVfT05ERU1BTkQ9bQpDT05GSUdf
REVWRlJFUV9HT1ZfUEVSRk9STUFOQ0U9bQpDT05GSUdfREVWRlJFUV9HT1ZfUE9XRVJTQVZF
PW0KQ09ORklHX0RFVkZSRVFfR09WX1VTRVJTUEFDRT1tCgojCiMgREVWRlJFUSBEcml2ZXJz
CiMKIyBDT05GSUdfUE1fREVWRlJFUV9FVkVOVCBpcyBub3Qgc2V0CkNPTkZJR19FWFRDT049
bQoKIwojIEV4dGNvbiBEZXZpY2UgRHJpdmVycwojCiMgQ09ORklHX0VYVENPTl9BRENfSkFD
SyBpcyBub3Qgc2V0CkNPTkZJR19FWFRDT05fR1BJTz1tCiMgQ09ORklHX0VYVENPTl9SVDg5
NzNBIGlzIG5vdCBzZXQKQ09ORklHX0VYVENPTl9TTTU1MDI9bQojIENPTkZJR19FWFRDT05f
VVNCX0dQSU8gaXMgbm90IHNldApDT05GSUdfTUVNT1JZPXkKQ09ORklHX0lJTz1tCkNPTkZJ
R19JSU9fQlVGRkVSPXkKQ09ORklHX0lJT19CVUZGRVJfQ0I9eQpDT05GSUdfSUlPX0tGSUZP
X0JVRj1tCkNPTkZJR19JSU9fVFJJR0dFUkVEX0JVRkZFUj1tCkNPTkZJR19JSU9fVFJJR0dF
Uj15CkNPTkZJR19JSU9fQ09OU1VNRVJTX1BFUl9UUklHR0VSPTIKCiMKIyBBY2NlbGVyb21l
dGVycwojCiMgQ09ORklHX0JNQTE4MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JNQzE1MF9BQ0NF
TCBpcyBub3Qgc2V0CkNPTkZJR19ISURfU0VOU09SX0FDQ0VMXzNEPW0KQ09ORklHX0lJT19T
VF9BQ0NFTF8zQVhJUz1tCkNPTkZJR19JSU9fU1RfQUNDRUxfSTJDXzNBWElTPW0KQ09ORklH
X0lJT19TVF9BQ0NFTF9TUElfM0FYSVM9bQojIENPTkZJR19LWFNEOSBpcyBub3Qgc2V0CkNP
TkZJR19LWENKSzEwMTM9bQojIENPTkZJR19NTUE4NDUyIGlzIG5vdCBzZXQKIyBDT05GSUdf
TU1BOTU1MSBpcyBub3Qgc2V0CiMgQ09ORklHX01NQTk1NTMgaXMgbm90IHNldAojIENPTkZJ
R19TVEs4MzEyIGlzIG5vdCBzZXQKIyBDT05GSUdfU1RLOEJBNTAgaXMgbm90IHNldAoKIwoj
IEFuYWxvZyB0byBkaWdpdGFsIGNvbnZlcnRlcnMKIwojIENPTkZJR19BRDcyNjYgaXMgbm90
IHNldAojIENPTkZJR19BRDcyOTEgaXMgbm90IHNldAojIENPTkZJR19BRDcyOTggaXMgbm90
IHNldAojIENPTkZJR19BRDc0NzYgaXMgbm90IHNldAojIENPTkZJR19BRDc3OTEgaXMgbm90
IHNldAojIENPTkZJR19BRDc3OTMgaXMgbm90IHNldAojIENPTkZJR19BRDc4ODcgaXMgbm90
IHNldAojIENPTkZJR19BRDc5MjMgaXMgbm90IHNldAojIENPTkZJR19BRDc5OVggaXMgbm90
IHNldAojIENPTkZJR19NQVgxMDI3IGlzIG5vdCBzZXQKIyBDT05GSUdfTUFYMTM2MyBpcyBu
b3Qgc2V0CiMgQ09ORklHX01DUDMyMFggaXMgbm90IHNldAojIENPTkZJR19NQ1AzNDIyIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkFVNzgwMiBpcyBub3Qgc2V0CiMgQ09ORklHX1FDT01fU1BN
SV9JQURDIGlzIG5vdCBzZXQKIyBDT05GSUdfUUNPTV9TUE1JX1ZBREMgaXMgbm90IHNldAoj
IENPTkZJR19USV9BREMwODFDIGlzIG5vdCBzZXQKIyBDT05GSUdfVElfQURDMTI4UzA1MiBp
cyBub3Qgc2V0CgojCiMgQW1wbGlmaWVycwojCiMgQ09ORklHX0FEODM2NiBpcyBub3Qgc2V0
CgojCiMgSGlkIFNlbnNvciBJSU8gQ29tbW9uCiMKQ09ORklHX0hJRF9TRU5TT1JfSUlPX0NP
TU1PTj1tCkNPTkZJR19ISURfU0VOU09SX0lJT19UUklHR0VSPW0KCiMKIyBTU1AgU2Vuc29y
IENvbW1vbgojCiMgQ09ORklHX0lJT19TU1BfU0VOU09SSFVCIGlzIG5vdCBzZXQKQ09ORklH
X0lJT19TVF9TRU5TT1JTX0kyQz1tCkNPTkZJR19JSU9fU1RfU0VOU09SU19TUEk9bQpDT05G
SUdfSUlPX1NUX1NFTlNPUlNfQ09SRT1tCgojCiMgRGlnaXRhbCB0byBhbmFsb2cgY29udmVy
dGVycwojCiMgQ09ORklHX0FENTA2NCBpcyBub3Qgc2V0CiMgQ09ORklHX0FENTM2MCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FENTM4MCBpcyBub3Qgc2V0CiMgQ09ORklHX0FENTQyMSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FENTQ0NiBpcyBub3Qgc2V0CiMgQ09ORklHX0FENTQ0OSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FENTUwNCBpcyBub3Qgc2V0CiMgQ09ORklHX0FENTYyNFJfU1BJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ1Njg2IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ1NzU1
IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ1NzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ1Nzkx
IGlzIG5vdCBzZXQKIyBDT05GSUdfQUQ3MzAzIGlzIG5vdCBzZXQKIyBDT05GSUdfTTYyMzMy
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUFYNTE3IGlzIG5vdCBzZXQKIyBDT05GSUdfTUNQNDcy
NSBpcyBub3Qgc2V0CiMgQ09ORklHX01DUDQ5MjIgaXMgbm90IHNldAoKIwojIEZyZXF1ZW5j
eSBTeW50aGVzaXplcnMgRERTL1BMTAojCgojCiMgQ2xvY2sgR2VuZXJhdG9yL0Rpc3RyaWJ1
dGlvbgojCiMgQ09ORklHX0FEOTUyMyBpcyBub3Qgc2V0CgojCiMgUGhhc2UtTG9ja2VkIExv
b3AgKFBMTCkgZnJlcXVlbmN5IHN5bnRoZXNpemVycwojCiMgQ09ORklHX0FERjQzNTAgaXMg
bm90IHNldAoKIwojIERpZ2l0YWwgZ3lyb3Njb3BlIHNlbnNvcnMKIwojIENPTkZJR19BRElT
MTYwODAgaXMgbm90IHNldAojIENPTkZJR19BRElTMTYxMzAgaXMgbm90IHNldAojIENPTkZJ
R19BRElTMTYxMzYgaXMgbm90IHNldAojIENPTkZJR19BRElTMTYyNjAgaXMgbm90IHNldAoj
IENPTkZJR19BRFhSUzQ1MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JNRzE2MCBpcyBub3Qgc2V0
CkNPTkZJR19ISURfU0VOU09SX0dZUk9fM0Q9bQpDT05GSUdfSUlPX1NUX0dZUk9fM0FYSVM9
bQpDT05GSUdfSUlPX1NUX0dZUk9fSTJDXzNBWElTPW0KQ09ORklHX0lJT19TVF9HWVJPX1NQ
SV8zQVhJUz1tCiMgQ09ORklHX0lURzMyMDAgaXMgbm90IHNldAoKIwojIEh1bWlkaXR5IHNl
bnNvcnMKIwojIENPTkZJR19ESFQxMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NJNzAwNSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NJNzAyMCBpcyBub3Qgc2V0CgojCiMgSW5lcnRpYWwgbWVhc3Vy
ZW1lbnQgdW5pdHMKIwojIENPTkZJR19BRElTMTY0MDAgaXMgbm90IHNldAojIENPTkZJR19B
RElTMTY0ODAgaXMgbm90IHNldAojIENPTkZJR19LTVg2MSBpcyBub3Qgc2V0CiMgQ09ORklH
X0lOVl9NUFU2MDUwX0lJTyBpcyBub3Qgc2V0CgojCiMgTGlnaHQgc2Vuc29ycwojCkNPTkZJ
R19BQ1BJX0FMUz1tCiMgQ09ORklHX0FESkRfUzMxMSBpcyBub3Qgc2V0CiMgQ09ORklHX0FM
MzMyMEEgaXMgbm90IHNldAojIENPTkZJR19BUERTOTMwMCBpcyBub3Qgc2V0CkNPTkZJR19C
SDE3NTA9bQojIENPTkZJR19DTTMyMTgxIGlzIG5vdCBzZXQKIyBDT05GSUdfQ00zMjMyIGlz
IG5vdCBzZXQKIyBDT05GSUdfQ00zMzIzIGlzIG5vdCBzZXQKIyBDT05GSUdfQ00zNjY1MSBp
cyBub3Qgc2V0CiMgQ09ORklHX0dQMkFQMDIwQTAwRiBpcyBub3Qgc2V0CiMgQ09ORklHX0lT
TDI5MTI1IGlzIG5vdCBzZXQKQ09ORklHX0hJRF9TRU5TT1JfQUxTPW0KIyBDT05GSUdfSElE
X1NFTlNPUl9QUk9YIGlzIG5vdCBzZXQKIyBDT05GSUdfSlNBMTIxMiBpcyBub3Qgc2V0CiMg
Q09ORklHX1JQUjA1MjEgaXMgbm90IHNldAojIENPTkZJR19MVFI1MDEgaXMgbm90IHNldAoj
IENPTkZJR19PUFQzMDAxIGlzIG5vdCBzZXQKIyBDT05GSUdfUEExMjIwMzAwMSBpcyBub3Qg
c2V0CkNPTkZJR19TVEszMzEwPW0KIyBDT05GSUdfVENTMzQxNCBpcyBub3Qgc2V0CiMgQ09O
RklHX1RDUzM0NzIgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1RTTDI1NjMgaXMgbm90
IHNldAojIENPTkZJR19UU0w0NTMxIGlzIG5vdCBzZXQKIyBDT05GSUdfVkNOTDQwMDAgaXMg
bm90IHNldAoKIwojIE1hZ25ldG9tZXRlciBzZW5zb3JzCiMKIyBDT05GSUdfQUs4OTc1IGlz
IG5vdCBzZXQKIyBDT05GSUdfQUswOTkxMSBpcyBub3Qgc2V0CiMgQ09ORklHX01BRzMxMTAg
aXMgbm90IHNldApDT05GSUdfSElEX1NFTlNPUl9NQUdORVRPTUVURVJfM0Q9bQojIENPTkZJ
R19NTUMzNTI0MCBpcyBub3Qgc2V0CkNPTkZJR19JSU9fU1RfTUFHTl8zQVhJUz1tCkNPTkZJ
R19JSU9fU1RfTUFHTl9JMkNfM0FYSVM9bQpDT05GSUdfSUlPX1NUX01BR05fU1BJXzNBWElT
PW0KIyBDT05GSUdfQk1DMTUwX01BR04gaXMgbm90IHNldAoKIwojIEluY2xpbm9tZXRlciBz
ZW5zb3JzCiMKQ09ORklHX0hJRF9TRU5TT1JfSU5DTElOT01FVEVSXzNEPW0KQ09ORklHX0hJ
RF9TRU5TT1JfREVWSUNFX1JPVEFUSU9OPW0KCiMKIyBUcmlnZ2VycyAtIHN0YW5kYWxvbmUK
IwpDT05GSUdfSUlPX0lOVEVSUlVQVF9UUklHR0VSPW0KIyBDT05GSUdfSUlPX1NZU0ZTX1RS
SUdHRVIgaXMgbm90IHNldAoKIwojIFByZXNzdXJlIHNlbnNvcnMKIwojIENPTkZJR19CTVAy
ODAgaXMgbm90IHNldAojIENPTkZJR19ISURfU0VOU09SX1BSRVNTIGlzIG5vdCBzZXQKIyBD
T05GSUdfTVBMMTE1IGlzIG5vdCBzZXQKIyBDT05GSUdfTVBMMzExNSBpcyBub3Qgc2V0CiMg
Q09ORklHX01TNTYxMSBpcyBub3Qgc2V0CiMgQ09ORklHX0lJT19TVF9QUkVTUyBpcyBub3Qg
c2V0CiMgQ09ORklHX1Q1NDAzIGlzIG5vdCBzZXQKCiMKIyBMaWdodG5pbmcgc2Vuc29ycwoj
CiMgQ09ORklHX0FTMzkzNSBpcyBub3Qgc2V0CgojCiMgUHJveGltaXR5IHNlbnNvcnMKIwoj
IENPTkZJR19TWDk1MDAgaXMgbm90IHNldAoKIwojIFRlbXBlcmF0dXJlIHNlbnNvcnMKIwoj
IENPTkZJR19NTFg5MDYxNCBpcyBub3Qgc2V0CiMgQ09ORklHX1RNUDAwNiBpcyBub3Qgc2V0
CiMgQ09ORklHX05UQiBpcyBub3Qgc2V0CiMgQ09ORklHX1ZNRV9CVVMgaXMgbm90IHNldAoj
IENPTkZJR19QV00gaXMgbm90IHNldApDT05GSUdfSVBBQ0tfQlVTPW0KQ09ORklHX0JPQVJE
X1RQQ0kyMDA9bQpDT05GSUdfU0VSSUFMX0lQT0NUQUw9bQpDT05GSUdfUkVTRVRfQ09OVFJP
TExFUj15CiMgQ09ORklHX0ZNQyBpcyBub3Qgc2V0CgojCiMgUEhZIFN1YnN5c3RlbQojCkNP
TkZJR19HRU5FUklDX1BIWT15CiMgQ09ORklHX1BIWV9QWEFfMjhOTV9IU0lDIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUEhZX1BYQV8yOE5NX1VTQjIgaXMgbm90IHNldApDT05GSUdfQkNNX0tP
TkFfVVNCMl9QSFk9bQpDT05GSUdfUE9XRVJDQVA9eQpDT05GSUdfSU5URUxfUkFQTD1tCiMg
Q09ORklHX01DQiBpcyBub3Qgc2V0CgojCiMgUGVyZm9ybWFuY2UgbW9uaXRvciBzdXBwb3J0
CiMKQ09ORklHX1JBUz15CkNPTkZJR19USFVOREVSQk9MVD1tCgojCiMgQW5kcm9pZAojCiMg
Q09ORklHX0FORFJPSUQgaXMgbm90IHNldApDT05GSUdfTElCTlZESU1NPXkKQ09ORklHX0JM
S19ERVZfUE1FTT1tCkNPTkZJR19ORF9CTEs9bQpDT05GSUdfTkRfQ0xBSU09eQpDT05GSUdf
TkRfQlRUPW0KQ09ORklHX0JUVD15CiMgQ09ORklHX05WTUVNIGlzIG5vdCBzZXQKCiMKIyBG
aXJtd2FyZSBEcml2ZXJzCiMKQ09ORklHX0VERD1tCiMgQ09ORklHX0VERF9PRkYgaXMgbm90
IHNldApDT05GSUdfRklSTVdBUkVfTUVNTUFQPXkKQ09ORklHX0RFTExfUkJVPW0KQ09ORklH
X0RDREJBUz1tCkNPTkZJR19ETUlJRD15CkNPTkZJR19ETUlfU1lTRlM9bQpDT05GSUdfRE1J
X1NDQU5fTUFDSElORV9OT05fRUZJX0ZBTExCQUNLPXkKQ09ORklHX0lTQ1NJX0lCRlRfRklO
RD15CiMgQ09ORklHX0dPT0dMRV9GSVJNV0FSRSBpcyBub3Qgc2V0CgojCiMgRUZJIChFeHRl
bnNpYmxlIEZpcm13YXJlIEludGVyZmFjZSkgU3VwcG9ydAojCiMgQ09ORklHX0VGSV9WQVJT
IGlzIG5vdCBzZXQKQ09ORklHX0VGSV9FU1JUPXkKQ09ORklHX0VGSV9SVU5USU1FX01BUD15
CkNPTkZJR19FRklfUlVOVElNRV9XUkFQUEVSUz15CkNPTkZJR19VRUZJX0NQRVI9eQoKIwoj
IEZpbGUgc3lzdGVtcwojCkNPTkZJR19EQ0FDSEVfV09SRF9BQ0NFU1M9eQojIENPTkZJR19F
WFQyX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfRVhUM19GUyBpcyBub3Qgc2V0CkNPTkZJR19F
WFQ0X0ZTPW0KQ09ORklHX0VYVDRfVVNFX0ZPUl9FWFQyPXkKQ09ORklHX0VYVDRfRlNfUE9T
SVhfQUNMPXkKQ09ORklHX0VYVDRfRlNfU0VDVVJJVFk9eQojIENPTkZJR19FWFQ0X0VOQ1JZ
UFRJT04gaXMgbm90IHNldAojIENPTkZJR19FWFQ0X0RFQlVHIGlzIG5vdCBzZXQKQ09ORklH
X0pCRDI9bQojIENPTkZJR19KQkQyX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX0ZTX01CQ0FD
SEU9bQojIENPTkZJR19SRUlTRVJGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0pGU19GUyBp
cyBub3Qgc2V0CiMgQ09ORklHX1hGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0dGUzJfRlMg
aXMgbm90IHNldAojIENPTkZJR19PQ0ZTMl9GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0JUUkZT
X0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfTklMRlMyX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdf
RjJGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZTX0RBWCBpcyBub3Qgc2V0CkNPTkZJR19G
U19QT1NJWF9BQ0w9eQpDT05GSUdfRVhQT1JURlM9eQpDT05GSUdfRklMRV9MT0NLSU5HPXkK
Q09ORklHX0ZTTk9USUZZPXkKQ09ORklHX0ROT1RJRlk9eQpDT05GSUdfSU5PVElGWV9VU0VS
PXkKQ09ORklHX0ZBTk9USUZZPXkKQ09ORklHX0ZBTk9USUZZX0FDQ0VTU19QRVJNSVNTSU9O
Uz15CkNPTkZJR19RVU9UQT15CkNPTkZJR19RVU9UQV9ORVRMSU5LX0lOVEVSRkFDRT15CiMg
Q09ORklHX1BSSU5UX1FVT1RBX1dBUk5JTkcgaXMgbm90IHNldAojIENPTkZJR19RVU9UQV9E
RUJVRyBpcyBub3Qgc2V0CkNPTkZJR19RVU9UQV9UUkVFPW0KQ09ORklHX1FGTVRfVjE9bQpD
T05GSUdfUUZNVF9WMj1tCkNPTkZJR19RVU9UQUNUTD15CkNPTkZJR19RVU9UQUNUTF9DT01Q
QVQ9eQpDT05GSUdfQVVUT0ZTNF9GUz15CkNPTkZJR19GVVNFX0ZTPW0KQ09ORklHX0NVU0U9
bQpDT05GSUdfT1ZFUkxBWV9GUz1tCgojCiMgQ2FjaGVzCiMKQ09ORklHX0ZTQ0FDSEU9bQpD
T05GSUdfRlNDQUNIRV9TVEFUUz15CkNPTkZJR19GU0NBQ0hFX0hJU1RPR1JBTT15CiMgQ09O
RklHX0ZTQ0FDSEVfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19GU0NBQ0hFX09CSkVDVF9M
SVNUIGlzIG5vdCBzZXQKQ09ORklHX0NBQ0hFRklMRVM9bQojIENPTkZJR19DQUNIRUZJTEVT
X0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0FDSEVGSUxFU19ISVNUT0dSQU0gaXMgbm90
IHNldAoKIwojIENELVJPTS9EVkQgRmlsZXN5c3RlbXMKIwpDT05GSUdfSVNPOTY2MF9GUz1t
CkNPTkZJR19KT0xJRVQ9eQpDT05GSUdfWklTT0ZTPXkKQ09ORklHX1VERl9GUz1tCkNPTkZJ
R19VREZfTkxTPXkKCiMKIyBET1MvRkFUL05UIEZpbGVzeXN0ZW1zCiMKQ09ORklHX0ZBVF9G
Uz1tCkNPTkZJR19NU0RPU19GUz1tCkNPTkZJR19WRkFUX0ZTPW0KQ09ORklHX0ZBVF9ERUZB
VUxUX0NPREVQQUdFPTQzNwpDT05GSUdfRkFUX0RFRkFVTFRfSU9DSEFSU0VUPSJpc284ODU5
LTEiCkNPTkZJR19OVEZTX0ZTPW0KIyBDT05GSUdfTlRGU19ERUJVRyBpcyBub3Qgc2V0CkNP
TkZJR19OVEZTX1JXPXkKCiMKIyBQc2V1ZG8gZmlsZXN5c3RlbXMKIwpDT05GSUdfUFJPQ19G
Uz15CkNPTkZJR19QUk9DX0tDT1JFPXkKQ09ORklHX1BST0NfVk1DT1JFPXkKQ09ORklHX1BS
T0NfU1lTQ1RMPXkKQ09ORklHX1BST0NfUEFHRV9NT05JVE9SPXkKQ09ORklHX1BST0NfQ0hJ
TERSRU49eQpDT05GSUdfS0VSTkZTPXkKQ09ORklHX1NZU0ZTPXkKQ09ORklHX1RNUEZTPXkK
Q09ORklHX1RNUEZTX1BPU0lYX0FDTD15CkNPTkZJR19UTVBGU19YQVRUUj15CkNPTkZJR19I
VUdFVExCRlM9eQpDT05GSUdfSFVHRVRMQl9QQUdFPXkKQ09ORklHX0NPTkZJR0ZTX0ZTPXkK
Q09ORklHX0VGSVZBUl9GUz15CkNPTkZJR19NSVNDX0ZJTEVTWVNURU1TPXkKIyBDT05GSUdf
QURGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0FGRlNfRlMgaXMgbm90IHNldApDT05GSUdf
RUNSWVBUX0ZTPW0KIyBDT05GSUdfRUNSWVBUX0ZTX01FU1NBR0lORyBpcyBub3Qgc2V0CkNP
TkZJR19IRlNfRlM9bQpDT05GSUdfSEZTUExVU19GUz1tCkNPTkZJR19IRlNQTFVTX0ZTX1BP
U0lYX0FDTD15CkNPTkZJR19CRUZTX0ZTPW0KIyBDT05GSUdfQkVGU19ERUJVRyBpcyBub3Qg
c2V0CiMgQ09ORklHX0JGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0VGU19GUyBpcyBub3Qg
c2V0CkNPTkZJR19KRkZTMl9GUz1tCkNPTkZJR19KRkZTMl9GU19ERUJVRz0wCkNPTkZJR19K
RkZTMl9GU19XUklURUJVRkZFUj15CiMgQ09ORklHX0pGRlMyX0ZTX1dCVUZfVkVSSUZZIGlz
IG5vdCBzZXQKIyBDT05GSUdfSkZGUzJfU1VNTUFSWSBpcyBub3Qgc2V0CiMgQ09ORklHX0pG
RlMyX0ZTX1hBVFRSIGlzIG5vdCBzZXQKIyBDT05GSUdfSkZGUzJfQ09NUFJFU1NJT05fT1BU
SU9OUyBpcyBub3Qgc2V0CkNPTkZJR19KRkZTMl9aTElCPXkKIyBDT05GSUdfSkZGUzJfTFpP
IGlzIG5vdCBzZXQKQ09ORklHX0pGRlMyX1JUSU1FPXkKIyBDT05GSUdfSkZGUzJfUlVCSU4g
aXMgbm90IHNldApDT05GSUdfVUJJRlNfRlM9bQojIENPTkZJR19VQklGU19GU19BRFZBTkNF
RF9DT01QUiBpcyBub3Qgc2V0CkNPTkZJR19VQklGU19GU19MWk89eQpDT05GSUdfVUJJRlNf
RlNfWkxJQj15CkNPTkZJR19MT0dGUz1tCkNPTkZJR19DUkFNRlM9bQpDT05GSUdfU1FVQVNI
RlM9bQojIENPTkZJR19TUVVBU0hGU19GSUxFX0NBQ0hFIGlzIG5vdCBzZXQKQ09ORklHX1NR
VUFTSEZTX0ZJTEVfRElSRUNUPXkKIyBDT05GSUdfU1FVQVNIRlNfREVDT01QX1NJTkdMRSBp
cyBub3Qgc2V0CiMgQ09ORklHX1NRVUFTSEZTX0RFQ09NUF9NVUxUSSBpcyBub3Qgc2V0CkNP
TkZJR19TUVVBU0hGU19ERUNPTVBfTVVMVElfUEVSQ1BVPXkKQ09ORklHX1NRVUFTSEZTX1hB
VFRSPXkKQ09ORklHX1NRVUFTSEZTX1pMSUI9eQpDT05GSUdfU1FVQVNIRlNfTFo0PXkKQ09O
RklHX1NRVUFTSEZTX0xaTz15CkNPTkZJR19TUVVBU0hGU19YWj15CiMgQ09ORklHX1NRVUFT
SEZTXzRLX0RFVkJMS19TSVpFIGlzIG5vdCBzZXQKIyBDT05GSUdfU1FVQVNIRlNfRU1CRURE
RUQgaXMgbm90IHNldApDT05GSUdfU1FVQVNIRlNfRlJBR01FTlRfQ0FDSEVfU0laRT0zCiMg
Q09ORklHX1ZYRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19NSU5JWF9GUyBpcyBub3Qgc2V0
CkNPTkZJR19PTUZTX0ZTPW0KIyBDT05GSUdfSFBGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklH
X1FOWDRGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1FOWDZGU19GUyBpcyBub3Qgc2V0CkNP
TkZJR19ST01GU19GUz1tCkNPTkZJR19ST01GU19CQUNLRURfQllfQkxPQ0s9eQojIENPTkZJ
R19ST01GU19CQUNLRURfQllfTVREIGlzIG5vdCBzZXQKIyBDT05GSUdfUk9NRlNfQkFDS0VE
X0JZX0JPVEggaXMgbm90IHNldApDT05GSUdfUk9NRlNfT05fQkxPQ0s9eQpDT05GSUdfUFNU
T1JFPXkKIyBDT05GSUdfUFNUT1JFX0NPTlNPTEUgaXMgbm90IHNldAojIENPTkZJR19QU1RP
UkVfUE1TRyBpcyBub3Qgc2V0CiMgQ09ORklHX1BTVE9SRV9GVFJBQ0UgaXMgbm90IHNldApD
T05GSUdfUFNUT1JFX1JBTT1tCiMgQ09ORklHX1NZU1ZfRlMgaXMgbm90IHNldApDT05GSUdf
VUZTX0ZTPW0KIyBDT05GSUdfVUZTX0ZTX1dSSVRFIGlzIG5vdCBzZXQKIyBDT05GSUdfVUZT
X0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX05FVFdPUktfRklMRVNZU1RFTVM9eQpDT05GSUdf
TkZTX0ZTPW0KQ09ORklHX05GU19WMj1tCkNPTkZJR19ORlNfVjM9bQpDT05GSUdfTkZTX1Yz
X0FDTD15CkNPTkZJR19ORlNfVjQ9bQpDT05GSUdfTkZTX1NXQVA9eQpDT05GSUdfTkZTX1Y0
XzE9eQpDT05GSUdfTkZTX1Y0XzI9eQpDT05GSUdfUE5GU19GSUxFX0xBWU9VVD1tCkNPTkZJ
R19QTkZTX0JMT0NLPW0KQ09ORklHX1BORlNfRkxFWEZJTEVfTEFZT1VUPW0KQ09ORklHX05G
U19WNF8xX0lNUExFTUVOVEFUSU9OX0lEX0RPTUFJTj0ia2VybmVsLm9yZyIKQ09ORklHX05G
U19WNF8xX01JR1JBVElPTj15CkNPTkZJR19ORlNfVjRfU0VDVVJJVFlfTEFCRUw9eQpDT05G
SUdfTkZTX0ZTQ0FDSEU9eQojIENPTkZJR19ORlNfVVNFX0xFR0FDWV9ETlMgaXMgbm90IHNl
dApDT05GSUdfTkZTX1VTRV9LRVJORUxfRE5TPXkKQ09ORklHX05GU19ERUJVRz15CkNPTkZJ
R19ORlNEPW0KQ09ORklHX05GU0RfVjJfQUNMPXkKQ09ORklHX05GU0RfVjM9eQpDT05GSUdf
TkZTRF9WM19BQ0w9eQpDT05GSUdfTkZTRF9WND15CkNPTkZJR19ORlNEX1BORlM9eQpDT05G
SUdfTkZTRF9WNF9TRUNVUklUWV9MQUJFTD15CiMgQ09ORklHX05GU0RfRkFVTFRfSU5KRUNU
SU9OIGlzIG5vdCBzZXQKQ09ORklHX0dSQUNFX1BFUklPRD1tCkNPTkZJR19MT0NLRD1tCkNP
TkZJR19MT0NLRF9WND15CkNPTkZJR19ORlNfQUNMX1NVUFBPUlQ9bQpDT05GSUdfTkZTX0NP
TU1PTj15CkNPTkZJR19TVU5SUEM9bQpDT05GSUdfU1VOUlBDX0dTUz1tCkNPTkZJR19TVU5S
UENfQkFDS0NIQU5ORUw9eQpDT05GSUdfU1VOUlBDX1NXQVA9eQpDT05GSUdfUlBDU0VDX0dT
U19LUkI1PW0KQ09ORklHX1NVTlJQQ19ERUJVRz15CkNPTkZJR19DRVBIX0ZTPW0KQ09ORklH
X0NFUEhfRlNDQUNIRT15CkNPTkZJR19DRVBIX0ZTX1BPU0lYX0FDTD15CkNPTkZJR19DSUZT
PW0KQ09ORklHX0NJRlNfU1RBVFM9eQojIENPTkZJR19DSUZTX1NUQVRTMiBpcyBub3Qgc2V0
CkNPTkZJR19DSUZTX1dFQUtfUFdfSEFTSD15CkNPTkZJR19DSUZTX1VQQ0FMTD15CkNPTkZJ
R19DSUZTX1hBVFRSPXkKQ09ORklHX0NJRlNfUE9TSVg9eQpDT05GSUdfQ0lGU19BQ0w9eQoj
IENPTkZJR19DSUZTX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX0NJRlNfREZTX1VQQ0FMTD15
CkNPTkZJR19DSUZTX1NNQjI9eQpDT05GSUdfQ0lGU19TTUIzMTE9eQpDT05GSUdfQ0lGU19G
U0NBQ0hFPXkKQ09ORklHX05DUF9GUz1tCiMgQ09ORklHX05DUEZTX1BBQ0tFVF9TSUdOSU5H
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkNQRlNfSU9DVExfTE9DS0lORyBpcyBub3Qgc2V0CiMg
Q09ORklHX05DUEZTX1NUUk9ORyBpcyBub3Qgc2V0CkNPTkZJR19OQ1BGU19ORlNfTlM9eQpD
T05GSUdfTkNQRlNfT1MyX05TPXkKQ09ORklHX05DUEZTX1NNQUxMRE9TPXkKQ09ORklHX05D
UEZTX05MUz15CiMgQ09ORklHX05DUEZTX0VYVFJBUyBpcyBub3Qgc2V0CkNPTkZJR19DT0RB
X0ZTPW0KQ09ORklHX0FGU19GUz1tCiMgQ09ORklHX0FGU19ERUJVRyBpcyBub3Qgc2V0CkNP
TkZJR19BRlNfRlNDQUNIRT15CkNPTkZJR185UF9GUz1tCkNPTkZJR185UF9GU0NBQ0hFPXkK
Q09ORklHXzlQX0ZTX1BPU0lYX0FDTD15CkNPTkZJR185UF9GU19TRUNVUklUWT15CkNPTkZJ
R19OTFM9eQpDT05GSUdfTkxTX0RFRkFVTFQ9InV0ZjgiCkNPTkZJR19OTFNfQ09ERVBBR0Vf
NDM3PW0KQ09ORklHX05MU19DT0RFUEFHRV83Mzc9bQpDT05GSUdfTkxTX0NPREVQQUdFXzc3
NT1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODUwPW0KQ09ORklHX05MU19DT0RFUEFHRV84NTI9
bQpDT05GSUdfTkxTX0NPREVQQUdFXzg1NT1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODU3PW0K
Q09ORklHX05MU19DT0RFUEFHRV84NjA9bQpDT05GSUdfTkxTX0NPREVQQUdFXzg2MT1tCkNP
TkZJR19OTFNfQ09ERVBBR0VfODYyPW0KQ09ORklHX05MU19DT0RFUEFHRV84NjM9bQpDT05G
SUdfTkxTX0NPREVQQUdFXzg2ND1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODY1PW0KQ09ORklH
X05MU19DT0RFUEFHRV84NjY9bQpDT05GSUdfTkxTX0NPREVQQUdFXzg2OT1tCkNPTkZJR19O
TFNfQ09ERVBBR0VfOTM2PW0KQ09ORklHX05MU19DT0RFUEFHRV85NTA9bQpDT05GSUdfTkxT
X0NPREVQQUdFXzkzMj1tCkNPTkZJR19OTFNfQ09ERVBBR0VfOTQ5PW0KQ09ORklHX05MU19D
T0RFUEFHRV84NzQ9bQpDT05GSUdfTkxTX0lTTzg4NTlfOD1tCkNPTkZJR19OTFNfQ09ERVBB
R0VfMTI1MD1tCkNPTkZJR19OTFNfQ09ERVBBR0VfMTI1MT1tCkNPTkZJR19OTFNfQVNDSUk9
bQpDT05GSUdfTkxTX0lTTzg4NTlfMT1tCkNPTkZJR19OTFNfSVNPODg1OV8yPW0KQ09ORklH
X05MU19JU084ODU5XzM9bQpDT05GSUdfTkxTX0lTTzg4NTlfND1tCkNPTkZJR19OTFNfSVNP
ODg1OV81PW0KQ09ORklHX05MU19JU084ODU5XzY9bQpDT05GSUdfTkxTX0lTTzg4NTlfNz1t
CkNPTkZJR19OTFNfSVNPODg1OV85PW0KQ09ORklHX05MU19JU084ODU5XzEzPW0KQ09ORklH
X05MU19JU084ODU5XzE0PW0KQ09ORklHX05MU19JU084ODU5XzE1PW0KQ09ORklHX05MU19L
T0k4X1I9bQpDT05GSUdfTkxTX0tPSThfVT1tCkNPTkZJR19OTFNfTUFDX1JPTUFOPW0KQ09O
RklHX05MU19NQUNfQ0VMVElDPW0KQ09ORklHX05MU19NQUNfQ0VOVEVVUk89bQpDT05GSUdf
TkxTX01BQ19DUk9BVElBTj1tCkNPTkZJR19OTFNfTUFDX0NZUklMTElDPW0KQ09ORklHX05M
U19NQUNfR0FFTElDPW0KQ09ORklHX05MU19NQUNfR1JFRUs9bQpDT05GSUdfTkxTX01BQ19J
Q0VMQU5EPW0KQ09ORklHX05MU19NQUNfSU5VSVQ9bQpDT05GSUdfTkxTX01BQ19ST01BTklB
Tj1tCkNPTkZJR19OTFNfTUFDX1RVUktJU0g9bQpDT05GSUdfTkxTX1VURjg9bQpDT05GSUdf
RExNPW0KIyBDT05GSUdfRExNX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBLZXJuZWwgaGFja2lu
ZwojCkNPTkZJR19UUkFDRV9JUlFGTEFHU19TVVBQT1JUPXkKCiMKIyBwcmludGsgYW5kIGRt
ZXNnIG9wdGlvbnMKIwpDT05GSUdfUFJJTlRLX1RJTUU9eQpDT05GSUdfTUVTU0FHRV9MT0dM
RVZFTF9ERUZBVUxUPTQKIyBDT05GSUdfQk9PVF9QUklOVEtfREVMQVkgaXMgbm90IHNldApD
T05GSUdfRFlOQU1JQ19ERUJVRz15CgojCiMgQ29tcGlsZS10aW1lIGNoZWNrcyBhbmQgY29t
cGlsZXIgb3B0aW9ucwojCiMgQ09ORklHX0RFQlVHX0lORk8gaXMgbm90IHNldApDT05GSUdf
RU5BQkxFX1dBUk5fREVQUkVDQVRFRD15CiMgQ09ORklHX0VOQUJMRV9NVVNUX0NIRUNLIGlz
IG5vdCBzZXQKQ09ORklHX0ZSQU1FX1dBUk49MjA0OApDT05GSUdfU1RSSVBfQVNNX1NZTVM9
eQojIENPTkZJR19SRUFEQUJMRV9BU00gaXMgbm90IHNldApDT05GSUdfVU5VU0VEX1NZTUJP
TFM9eQojIENPTkZJR19QQUdFX09XTkVSIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX0ZTPXkK
IyBDT05GSUdfSEVBREVSU19DSEVDSyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX1NFQ1RJ
T05fTUlTTUFUQ0ggaXMgbm90IHNldApDT05GSUdfQVJDSF9XQU5UX0ZSQU1FX1BPSU5URVJT
PXkKQ09ORklHX0ZSQU1FX1BPSU5URVI9eQojIENPTkZJR19ERUJVR19GT1JDRV9XRUFLX1BF
Ul9DUFUgaXMgbm90IHNldApDT05GSUdfTUFHSUNfU1lTUlE9eQpDT05GSUdfTUFHSUNfU1lT
UlFfREVGQVVMVF9FTkFCTEU9MHgwCkNPTkZJR19ERUJVR19LRVJORUw9eQoKIwojIE1lbW9y
eSBEZWJ1Z2dpbmcKIwojIENPTkZJR19QQUdFX0VYVEVOU0lPTiBpcyBub3Qgc2V0CiMgQ09O
RklHX0RFQlVHX1BBR0VBTExPQyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX09CSkVDVFMg
aXMgbm90IHNldAojIENPTkZJR19TTFVCX0RFQlVHX09OIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0xVQl9TVEFUUyBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0RFQlVHX0tNRU1MRUFLPXkKIyBD
T05GSUdfREVCVUdfS01FTUxFQUsgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19TVEFDS19V
U0FHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX1ZNIGlzIG5vdCBzZXQKIyBDT05GSUdf
REVCVUdfVklSVFVBTCBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19NRU1PUllfSU5JVD15CiMg
Q09ORklHX0RFQlVHX1BFUl9DUFVfTUFQUyBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0RFQlVH
X1NUQUNLT1ZFUkZMT1c9eQojIENPTkZJR19ERUJVR19TVEFDS09WRVJGTE9XIGlzIG5vdCBz
ZXQKQ09ORklHX0hBVkVfQVJDSF9LTUVNQ0hFQ0s9eQpDT05GSUdfSEFWRV9BUkNIX0tBU0FO
PXkKIyBDT05GSUdfS0FTQU4gaXMgbm90IHNldAojIENPTkZJR19ERUJVR19TSElSUSBpcyBu
b3Qgc2V0CgojCiMgRGVidWcgTG9ja3VwcyBhbmQgSGFuZ3MKIwpDT05GSUdfTE9DS1VQX0RF
VEVDVE9SPXkKQ09ORklHX0hBUkRMT0NLVVBfREVURUNUT1I9eQojIENPTkZJR19CT09UUEFS
QU1fSEFSRExPQ0tVUF9QQU5JQyBpcyBub3Qgc2V0CkNPTkZJR19CT09UUEFSQU1fSEFSRExP
Q0tVUF9QQU5JQ19WQUxVRT0wCiMgQ09ORklHX0JPT1RQQVJBTV9TT0ZUTE9DS1VQX1BBTklD
IGlzIG5vdCBzZXQKQ09ORklHX0JPT1RQQVJBTV9TT0ZUTE9DS1VQX1BBTklDX1ZBTFVFPTAK
Q09ORklHX0RFVEVDVF9IVU5HX1RBU0s9eQpDT05GSUdfREVGQVVMVF9IVU5HX1RBU0tfVElN
RU9VVD0xMjAKIyBDT05GSUdfQk9PVFBBUkFNX0hVTkdfVEFTS19QQU5JQyBpcyBub3Qgc2V0
CkNPTkZJR19CT09UUEFSQU1fSFVOR19UQVNLX1BBTklDX1ZBTFVFPTAKIyBDT05GSUdfUEFO
SUNfT05fT09QUyBpcyBub3Qgc2V0CkNPTkZJR19QQU5JQ19PTl9PT1BTX1ZBTFVFPTAKQ09O
RklHX1BBTklDX1RJTUVPVVQ9MApDT05GSUdfU0NIRURfREVCVUc9eQpDT05GSUdfU0NIRURf
SU5GTz15CkNPTkZJR19TQ0hFRFNUQVRTPXkKIyBDT05GSUdfU0NIRURfU1RBQ0tfRU5EX0NI
RUNLIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfVElNRUtFRVBJTkcgaXMgbm90IHNldApD
T05GSUdfVElNRVJfU1RBVFM9eQojIENPTkZJR19ERUJVR19QUkVFTVBUIGlzIG5vdCBzZXQK
CiMKIyBMb2NrIERlYnVnZ2luZyAoc3BpbmxvY2tzLCBtdXRleGVzLCBldGMuLi4pCiMKIyBD
T05GSUdfREVCVUdfUlRfTVVURVhFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX1NQSU5M
T0NLIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTVVURVhFUyBpcyBub3Qgc2V0CiMgQ09O
RklHX0RFQlVHX1dXX01VVEVYX1NMT1dQQVRIIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdf
TE9DS19BTExPQyBpcyBub3Qgc2V0CiMgQ09ORklHX1BST1ZFX0xPQ0tJTkcgaXMgbm90IHNl
dAojIENPTkZJR19MT0NLX1NUQVQgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19BVE9NSUNf
U0xFRVAgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19MT0NLSU5HX0FQSV9TRUxGVEVTVFMg
aXMgbm90IHNldAojIENPTkZJR19MT0NLX1RPUlRVUkVfVEVTVCBpcyBub3Qgc2V0CkNPTkZJ
R19TVEFDS1RSQUNFPXkKIyBDT05GSUdfREVCVUdfS09CSkVDVCBpcyBub3Qgc2V0CkNPTkZJ
R19ERUJVR19CVUdWRVJCT1NFPXkKIyBDT05GSUdfREVCVUdfTElTVCBpcyBub3Qgc2V0CiMg
Q09ORklHX0RFQlVHX1BJX0xJU1QgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19TRyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RFQlVHX05PVElGSUVSUyBpcyBub3Qgc2V0CiMgQ09ORklHX0RF
QlVHX0NSRURFTlRJQUxTIGlzIG5vdCBzZXQKCiMKIyBSQ1UgRGVidWdnaW5nCiMKIyBDT05G
SUdfUFJPVkVfUkNVIGlzIG5vdCBzZXQKIyBDT05GSUdfU1BBUlNFX1JDVV9QT0lOVEVSIGlz
IG5vdCBzZXQKIyBDT05GSUdfVE9SVFVSRV9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNV
X1RPUlRVUkVfVEVTVCBpcyBub3Qgc2V0CkNPTkZJR19SQ1VfQ1BVX1NUQUxMX1RJTUVPVVQ9
NjAKIyBDT05GSUdfUkNVX1RSQUNFIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNVX0VRU19ERUJV
RyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX0JMT0NLX0VYVF9ERVZUIGlzIG5vdCBzZXQK
IyBDT05GSUdfTk9USUZJRVJfRVJST1JfSU5KRUNUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkFVTFRfSU5KRUNUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfTEFURU5DWVRPUCBpcyBub3Qg
c2V0CkNPTkZJR19BUkNIX0hBU19ERUJVR19TVFJJQ1RfVVNFUl9DT1BZX0NIRUNLUz15CiMg
Q09ORklHX0RFQlVHX1NUUklDVF9VU0VSX0NPUFlfQ0hFQ0tTIGlzIG5vdCBzZXQKQ09ORklH
X1VTRVJfU1RBQ0tUUkFDRV9TVVBQT1JUPXkKQ09ORklHX05PUF9UUkFDRVI9eQpDT05GSUdf
SEFWRV9GVU5DVElPTl9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQSF9UUkFD
RVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQSF9GUF9URVNUPXkKQ09ORklHX0hBVkVf
RFlOQU1JQ19GVFJBQ0U9eQpDT05GSUdfSEFWRV9EWU5BTUlDX0ZUUkFDRV9XSVRIX1JFR1M9
eQpDT05GSUdfSEFWRV9GVFJBQ0VfTUNPVU5UX1JFQ09SRD15CkNPTkZJR19IQVZFX1NZU0NB
TExfVFJBQ0VQT0lOVFM9eQpDT05GSUdfSEFWRV9GRU5UUlk9eQpDT05GSUdfSEFWRV9DX1JF
Q09SRE1DT1VOVD15CkNPTkZJR19UUkFDRVJfTUFYX1RSQUNFPXkKQ09ORklHX1RSQUNFX0NM
T0NLPXkKQ09ORklHX1JJTkdfQlVGRkVSPXkKQ09ORklHX0VWRU5UX1RSQUNJTkc9eQpDT05G
SUdfQ09OVEVYVF9TV0lUQ0hfVFJBQ0VSPXkKQ09ORklHX1JJTkdfQlVGRkVSX0FMTE9XX1NX
QVA9eQpDT05GSUdfVFJBQ0lORz15CkNPTkZJR19HRU5FUklDX1RSQUNFUj15CkNPTkZJR19U
UkFDSU5HX1NVUFBPUlQ9eQpDT05GSUdfRlRSQUNFPXkKQ09ORklHX0ZVTkNUSU9OX1RSQUNF
Uj15CkNPTkZJR19GVU5DVElPTl9HUkFQSF9UUkFDRVI9eQojIENPTkZJR19JUlFTT0ZGX1RS
QUNFUiBpcyBub3Qgc2V0CiMgQ09ORklHX1BSRUVNUFRfVFJBQ0VSIGlzIG5vdCBzZXQKQ09O
RklHX1NDSEVEX1RSQUNFUj15CkNPTkZJR19GVFJBQ0VfU1lTQ0FMTFM9eQpDT05GSUdfVFJB
Q0VSX1NOQVBTSE9UPXkKIyBDT05GSUdfVFJBQ0VSX1NOQVBTSE9UX1BFUl9DUFVfU1dBUCBp
cyBub3Qgc2V0CkNPTkZJR19CUkFOQ0hfUFJPRklMRV9OT05FPXkKIyBDT05GSUdfUFJPRklM
RV9BTk5PVEFURURfQlJBTkNIRVMgaXMgbm90IHNldAojIENPTkZJR19QUk9GSUxFX0FMTF9C
UkFOQ0hFUyBpcyBub3Qgc2V0CkNPTkZJR19TVEFDS19UUkFDRVI9eQpDT05GSUdfQkxLX0RF
Vl9JT19UUkFDRT15CkNPTkZJR19LUFJPQkVfRVZFTlQ9eQpDT05GSUdfVVBST0JFX0VWRU5U
PXkKQ09ORklHX1BST0JFX0VWRU5UUz15CkNPTkZJR19EWU5BTUlDX0ZUUkFDRT15CkNPTkZJ
R19EWU5BTUlDX0ZUUkFDRV9XSVRIX1JFR1M9eQpDT05GSUdfRlVOQ1RJT05fUFJPRklMRVI9
eQpDT05GSUdfRlRSQUNFX01DT1VOVF9SRUNPUkQ9eQojIENPTkZJR19GVFJBQ0VfU1RBUlRV
UF9URVNUIGlzIG5vdCBzZXQKQ09ORklHX01NSU9UUkFDRT15CiMgQ09ORklHX01NSU9UUkFD
RV9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfVFJBQ0VQT0lOVF9CRU5DSE1BUksgaXMgbm90
IHNldApDT05GSUdfUklOR19CVUZGRVJfQkVOQ0hNQVJLPW0KIyBDT05GSUdfUklOR19CVUZG
RVJfU1RBUlRVUF9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfVFJBQ0VfRU5VTV9NQVBfRklM
RSBpcyBub3Qgc2V0CgojCiMgUnVudGltZSBUZXN0aW5nCiMKQ09ORklHX0xLRFRNPW0KIyBD
T05GSUdfVEVTVF9MSVNUX1NPUlQgaXMgbm90IHNldAojIENPTkZJR19LUFJPQkVTX1NBTklU
WV9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFDS1RSQUNFX1NFTEZfVEVTVCBpcyBub3Qg
c2V0CiMgQ09ORklHX1JCVFJFRV9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5URVJWQUxf
VFJFRV9URVNUIGlzIG5vdCBzZXQKQ09ORklHX1BFUkNQVV9URVNUPW0KIyBDT05GSUdfQVRP
TUlDNjRfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfQVNZTkNfUkFJRDZfVEVTVD1tCiMg
Q09ORklHX1RFU1RfSEVYRFVNUCBpcyBub3Qgc2V0CiMgQ09ORklHX1RFU1RfU1RSSU5HX0hF
TFBFUlMgaXMgbm90IHNldApDT05GSUdfVEVTVF9LU1RSVE9YPW0KIyBDT05GSUdfVEVTVF9S
SEFTSFRBQkxFIGlzIG5vdCBzZXQKIyBDT05GSUdfUFJPVklERV9PSENJMTM5NF9ETUFfSU5J
VCBpcyBub3Qgc2V0CiMgQ09ORklHX0RNQV9BUElfREVCVUcgaXMgbm90IHNldAojIENPTkZJ
R19URVNUX0xLTSBpcyBub3Qgc2V0CiMgQ09ORklHX1RFU1RfVVNFUl9DT1BZIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVEVTVF9CUEYgaXMgbm90IHNldAojIENPTkZJR19URVNUX0ZJUk1XQVJF
IGlzIG5vdCBzZXQKIyBDT05GSUdfVEVTVF9VREVMQVkgaXMgbm90IHNldAojIENPTkZJR19N
RU1URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfVEVTVF9TVEFUSUNfS0VZUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NBTVBMRVMgaXMgbm90IHNldApDT05GSUdfSEFWRV9BUkNIX0tHREI9eQoj
IENPTkZJR19LR0RCIGlzIG5vdCBzZXQKQ09ORklHX1NUUklDVF9ERVZNRU09eQpDT05GSUdf
WDg2X1ZFUkJPU0VfQk9PVFVQPXkKQ09ORklHX0VBUkxZX1BSSU5USz15CiMgQ09ORklHX0VB
UkxZX1BSSU5US19EQkdQIGlzIG5vdCBzZXQKQ09ORklHX0VBUkxZX1BSSU5US19FRkk9eQoj
IENPTkZJR19YODZfUFREVU1QIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX1JPREFUQT15CiMg
Q09ORklHX0RFQlVHX1JPREFUQV9URVNUIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX1NFVF9N
T0RVTEVfUk9OWD15CiMgQ09ORklHX0RFQlVHX05YX1RFU1QgaXMgbm90IHNldApDT05GSUdf
RE9VQkxFRkFVTFQ9eQojIENPTkZJR19ERUJVR19UTEJGTFVTSCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lPTU1VX1NUUkVTUyBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX01NSU9UUkFDRV9TVVBQ
T1JUPXkKIyBDT05GSUdfWDg2X0RFQ09ERVJfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdf
SU9fREVMQVlfVFlQRV8wWDgwPTAKQ09ORklHX0lPX0RFTEFZX1RZUEVfMFhFRD0xCkNPTkZJ
R19JT19ERUxBWV9UWVBFX1VERUxBWT0yCkNPTkZJR19JT19ERUxBWV9UWVBFX05PTkU9MwpD
T05GSUdfSU9fREVMQVlfMFg4MD15CiMgQ09ORklHX0lPX0RFTEFZXzBYRUQgaXMgbm90IHNl
dAojIENPTkZJR19JT19ERUxBWV9VREVMQVkgaXMgbm90IHNldAojIENPTkZJR19JT19ERUxB
WV9OT05FIGlzIG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfSU9fREVMQVlfVFlQRT0wCiMgQ09O
RklHX0RFQlVHX0JPT1RfUEFSQU1TIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BBX0RFQlVHIGlz
IG5vdCBzZXQKIyBDT05GSUdfT1BUSU1JWkVfSU5MSU5JTkcgaXMgbm90IHNldAojIENPTkZJ
R19ERUJVR19FTlRSWSBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX05NSV9TRUxGVEVTVCBp
cyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9ERUJVR19TVEFUSUNfQ1BVX0hBUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1g4Nl9ERUJVR19GUFUgaXMgbm90IHNldAojIENPTkZJR19QVU5JVF9BVE9N
X0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBTZWN1cml0eSBvcHRpb25zCiMKQ09ORklHX0tFWVM9
eQpDT05GSUdfUEVSU0lTVEVOVF9LRVlSSU5HUz15CkNPTkZJR19CSUdfS0VZUz15CkNPTkZJ
R19UUlVTVEVEX0tFWVM9bQpDT05GSUdfRU5DUllQVEVEX0tFWVM9bQojIENPTkZJR19TRUNV
UklUWV9ETUVTR19SRVNUUklDVCBpcyBub3Qgc2V0CkNPTkZJR19TRUNVUklUWT15CkNPTkZJ
R19TRUNVUklUWUZTPXkKIyBDT05GSUdfU0VDVVJJVFlfTkVUV09SSyBpcyBub3Qgc2V0CkNP
TkZJR19TRUNVUklUWV9QQVRIPXkKIyBDT05GSUdfSU5URUxfVFhUIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VDVVJJVFlfU01BQ0sgaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9UT01P
WU8gaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9BUFBBUk1PUiBpcyBub3Qgc2V0CkNP
TkZJR19TRUNVUklUWV9ZQU1BPXkKQ09ORklHX0lOVEVHUklUWT15CiMgQ09ORklHX0lOVEVH
UklUWV9TSUdOQVRVUkUgaXMgbm90IHNldAojIENPTkZJR19JTUEgaXMgbm90IHNldAojIENP
TkZJR19FVk0gaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9TRUNVUklUWV9EQUM9eQpDT05G
SUdfREVGQVVMVF9TRUNVUklUWT0iIgpDT05GSUdfWE9SX0JMT0NLUz1tCkNPTkZJR19BU1lO
Q19DT1JFPW0KQ09ORklHX0FTWU5DX01FTUNQWT1tCkNPTkZJR19BU1lOQ19YT1I9bQpDT05G
SUdfQVNZTkNfUFE9bQpDT05GSUdfQVNZTkNfUkFJRDZfUkVDT1Y9bQpDT05GSUdfQ1JZUFRP
PXkKCiMKIyBDcnlwdG8gY29yZSBvciBoZWxwZXIKIwpDT05GSUdfQ1JZUFRPX0FMR0FQST15
CkNPTkZJR19DUllQVE9fQUxHQVBJMj15CkNPTkZJR19DUllQVE9fQUVBRD1tCkNPTkZJR19D
UllQVE9fQUVBRDI9eQpDT05GSUdfQ1JZUFRPX0JMS0NJUEhFUj1tCkNPTkZJR19DUllQVE9f
QkxLQ0lQSEVSMj15CkNPTkZJR19DUllQVE9fSEFTSD15CkNPTkZJR19DUllQVE9fSEFTSDI9
eQpDT05GSUdfQ1JZUFRPX1JORz1tCkNPTkZJR19DUllQVE9fUk5HMj15CkNPTkZJR19DUllQ
VE9fUk5HX0RFRkFVTFQ9bQpDT05GSUdfQ1JZUFRPX1BDT01QPW0KQ09ORklHX0NSWVBUT19Q
Q09NUDI9eQpDT05GSUdfQ1JZUFRPX0FLQ0lQSEVSMj15CkNPTkZJR19DUllQVE9fQUtDSVBI
RVI9bQpDT05GSUdfQ1JZUFRPX1JTQT1tCkNPTkZJR19DUllQVE9fTUFOQUdFUj1tCkNPTkZJ
R19DUllQVE9fTUFOQUdFUjI9eQpDT05GSUdfQ1JZUFRPX1VTRVI9bQpDT05GSUdfQ1JZUFRP
X01BTkFHRVJfRElTQUJMRV9URVNUUz15CkNPTkZJR19DUllQVE9fR0YxMjhNVUw9bQpDT05G
SUdfQ1JZUFRPX05VTEw9bQpDT05GSUdfQ1JZUFRPX05VTEwyPXkKQ09ORklHX0NSWVBUT19Q
Q1JZUFQ9bQpDT05GSUdfQ1JZUFRPX1dPUktRVUVVRT15CkNPTkZJR19DUllQVE9fQ1JZUFRE
PW0KQ09ORklHX0NSWVBUT19NQ1JZUFREPW0KQ09ORklHX0NSWVBUT19BVVRIRU5DPW0KQ09O
RklHX0NSWVBUT19URVNUPW0KQ09ORklHX0NSWVBUT19BQkxLX0hFTFBFUj1tCkNPTkZJR19D
UllQVE9fR0xVRV9IRUxQRVJfWDg2PW0KCiMKIyBBdXRoZW50aWNhdGVkIEVuY3J5cHRpb24g
d2l0aCBBc3NvY2lhdGVkIERhdGEKIwpDT05GSUdfQ1JZUFRPX0NDTT1tCkNPTkZJR19DUllQ
VE9fR0NNPW0KQ09ORklHX0NSWVBUT19DSEFDSEEyMFBPTFkxMzA1PW0KQ09ORklHX0NSWVBU
T19TRVFJVj1tCkNPTkZJR19DUllQVE9fRUNIQUlOSVY9bQoKIwojIEJsb2NrIG1vZGVzCiMK
Q09ORklHX0NSWVBUT19DQkM9bQpDT05GSUdfQ1JZUFRPX0NUUj1tCkNPTkZJR19DUllQVE9f
Q1RTPW0KQ09ORklHX0NSWVBUT19FQ0I9bQpDT05GSUdfQ1JZUFRPX0xSVz1tCkNPTkZJR19D
UllQVE9fUENCQz1tCkNPTkZJR19DUllQVE9fWFRTPW0KCiMKIyBIYXNoIG1vZGVzCiMKQ09O
RklHX0NSWVBUT19DTUFDPW0KQ09ORklHX0NSWVBUT19ITUFDPW0KQ09ORklHX0NSWVBUT19Y
Q0JDPW0KQ09ORklHX0NSWVBUT19WTUFDPW0KCiMKIyBEaWdlc3QKIwpDT05GSUdfQ1JZUFRP
X0NSQzMyQz1tCkNPTkZJR19DUllQVE9fQ1JDMzJDX0lOVEVMPW0KQ09ORklHX0NSWVBUT19D
UkMzMj1tCkNPTkZJR19DUllQVE9fQ1JDMzJfUENMTVVMPW0KQ09ORklHX0NSWVBUT19DUkNU
MTBESUY9eQpDT05GSUdfQ1JZUFRPX0NSQ1QxMERJRl9QQ0xNVUw9bQpDT05GSUdfQ1JZUFRP
X0dIQVNIPW0KQ09ORklHX0NSWVBUT19QT0xZMTMwNT1tCiMgQ09ORklHX0NSWVBUT19QT0xZ
MTMwNV9YODZfNjQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX01END1tCkNPTkZJR19DUllQ
VE9fTUQ1PXkKQ09ORklHX0NSWVBUT19NSUNIQUVMX01JQz1tCkNPTkZJR19DUllQVE9fUk1E
MTI4PW0KQ09ORklHX0NSWVBUT19STUQxNjA9bQpDT05GSUdfQ1JZUFRPX1JNRDI1Nj1tCkNP
TkZJR19DUllQVE9fUk1EMzIwPW0KQ09ORklHX0NSWVBUT19TSEExPW0KQ09ORklHX0NSWVBU
T19TSEExX1NTU0UzPW0KQ09ORklHX0NSWVBUT19TSEEyNTZfU1NTRTM9bQpDT05GSUdfQ1JZ
UFRPX1NIQTUxMl9TU1NFMz1tCkNPTkZJR19DUllQVE9fU0hBMV9NQj1tCkNPTkZJR19DUllQ
VE9fU0hBMjU2PW0KQ09ORklHX0NSWVBUT19TSEE1MTI9bQpDT05GSUdfQ1JZUFRPX1RHUjE5
Mj1tCkNPTkZJR19DUllQVE9fV1A1MTI9bQpDT05GSUdfQ1JZUFRPX0dIQVNIX0NMTVVMX05J
X0lOVEVMPW0KCiMKIyBDaXBoZXJzCiMKQ09ORklHX0NSWVBUT19BRVM9eQpDT05GSUdfQ1JZ
UFRPX0FFU19YODZfNjQ9bQpDT05GSUdfQ1JZUFRPX0FFU19OSV9JTlRFTD1tCkNPTkZJR19D
UllQVE9fQU5VQklTPW0KQ09ORklHX0NSWVBUT19BUkM0PW0KQ09ORklHX0NSWVBUT19CTE9X
RklTSD1tCkNPTkZJR19DUllQVE9fQkxPV0ZJU0hfQ09NTU9OPW0KQ09ORklHX0NSWVBUT19C
TE9XRklTSF9YODZfNjQ9bQpDT05GSUdfQ1JZUFRPX0NBTUVMTElBPW0KQ09ORklHX0NSWVBU
T19DQU1FTExJQV9YODZfNjQ9bQpDT05GSUdfQ1JZUFRPX0NBTUVMTElBX0FFU05JX0FWWF9Y
ODZfNjQ9bQpDT05GSUdfQ1JZUFRPX0NBTUVMTElBX0FFU05JX0FWWDJfWDg2XzY0PW0KQ09O
RklHX0NSWVBUT19DQVNUX0NPTU1PTj1tCkNPTkZJR19DUllQVE9fQ0FTVDU9bQpDT05GSUdf
Q1JZUFRPX0NBU1Q1X0FWWF9YODZfNjQ9bQpDT05GSUdfQ1JZUFRPX0NBU1Q2PW0KQ09ORklH
X0NSWVBUT19DQVNUNl9BVlhfWDg2XzY0PW0KQ09ORklHX0NSWVBUT19ERVM9bQpDT05GSUdf
Q1JZUFRPX0RFUzNfRURFX1g4Nl82ND1tCkNPTkZJR19DUllQVE9fRkNSWVBUPW0KQ09ORklH
X0NSWVBUT19LSEFaQUQ9bQpDT05GSUdfQ1JZUFRPX1NBTFNBMjA9bQpDT05GSUdfQ1JZUFRP
X1NBTFNBMjBfWDg2XzY0PW0KQ09ORklHX0NSWVBUT19DSEFDSEEyMD1tCiMgQ09ORklHX0NS
WVBUT19DSEFDSEEyMF9YODZfNjQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX1NFRUQ9bQpD
T05GSUdfQ1JZUFRPX1NFUlBFTlQ9bQpDT05GSUdfQ1JZUFRPX1NFUlBFTlRfU1NFMl9YODZf
NjQ9bQpDT05GSUdfQ1JZUFRPX1NFUlBFTlRfQVZYX1g4Nl82ND1tCkNPTkZJR19DUllQVE9f
U0VSUEVOVF9BVlgyX1g4Nl82ND1tCkNPTkZJR19DUllQVE9fVEVBPW0KQ09ORklHX0NSWVBU
T19UV09GSVNIPW0KQ09ORklHX0NSWVBUT19UV09GSVNIX0NPTU1PTj1tCkNPTkZJR19DUllQ
VE9fVFdPRklTSF9YODZfNjQ9bQpDT05GSUdfQ1JZUFRPX1RXT0ZJU0hfWDg2XzY0XzNXQVk9
bQpDT05GSUdfQ1JZUFRPX1RXT0ZJU0hfQVZYX1g4Nl82ND1tCgojCiMgQ29tcHJlc3Npb24K
IwpDT05GSUdfQ1JZUFRPX0RFRkxBVEU9bQpDT05GSUdfQ1JZUFRPX1pMSUI9bQpDT05GSUdf
Q1JZUFRPX0xaTz15CkNPTkZJR19DUllQVE9fODQyPW0KQ09ORklHX0NSWVBUT19MWjQ9bQpD
T05GSUdfQ1JZUFRPX0xaNEhDPW0KCiMKIyBSYW5kb20gTnVtYmVyIEdlbmVyYXRpb24KIwpD
T05GSUdfQ1JZUFRPX0FOU0lfQ1BSTkc9bQpDT05GSUdfQ1JZUFRPX0RSQkdfTUVOVT1tCkNP
TkZJR19DUllQVE9fRFJCR19ITUFDPXkKQ09ORklHX0NSWVBUT19EUkJHX0hBU0g9eQpDT05G
SUdfQ1JZUFRPX0RSQkdfQ1RSPXkKQ09ORklHX0NSWVBUT19EUkJHPW0KQ09ORklHX0NSWVBU
T19KSVRURVJFTlRST1BZPW0KQ09ORklHX0NSWVBUT19VU0VSX0FQST1tCkNPTkZJR19DUllQ
VE9fVVNFUl9BUElfSEFTSD1tCkNPTkZJR19DUllQVE9fVVNFUl9BUElfU0tDSVBIRVI9bQpD
T05GSUdfQ1JZUFRPX1VTRVJfQVBJX1JORz1tCkNPTkZJR19DUllQVE9fVVNFUl9BUElfQUVB
RD1tCkNPTkZJR19DUllQVE9fSEFTSF9JTkZPPXkKQ09ORklHX0NSWVBUT19IVz15CkNPTkZJ
R19DUllQVE9fREVWX1BBRExPQ0s9bQpDT05GSUdfQ1JZUFRPX0RFVl9QQURMT0NLX0FFUz1t
CkNPTkZJR19DUllQVE9fREVWX1BBRExPQ0tfU0hBPW0KQ09ORklHX0NSWVBUT19ERVZfQ0NQ
PXkKQ09ORklHX0NSWVBUT19ERVZfQ0NQX0REPW0KQ09ORklHX0NSWVBUT19ERVZfQ0NQX0NS
WVBUTz1tCkNPTkZJR19DUllQVE9fREVWX1FBVD1tCkNPTkZJR19DUllQVE9fREVWX1FBVF9E
SDg5NXhDQz1tCiMgQ09ORklHX0NSWVBUT19ERVZfUUFUX0RIODk1eENDVkYgaXMgbm90IHNl
dApDT05GSUdfQVNZTU1FVFJJQ19LRVlfVFlQRT1tCkNPTkZJR19BU1lNTUVUUklDX1BVQkxJ
Q19LRVlfU1VCVFlQRT1tCkNPTkZJR19QVUJMSUNfS0VZX0FMR09fUlNBPW0KQ09ORklHX1g1
MDlfQ0VSVElGSUNBVEVfUEFSU0VSPW0KQ09ORklHX1BLQ1M3X01FU1NBR0VfUEFSU0VSPW0K
Q09ORklHX1BLQ1M3X1RFU1RfS0VZPW0KCiMKIyBDZXJ0aWZpY2F0ZXMgZm9yIHNpZ25hdHVy
ZSBjaGVja2luZwojCkNPTkZJR19TWVNURU1fVFJVU1RFRF9LRVlSSU5HPXkKQ09ORklHX1NZ
U1RFTV9UUlVTVEVEX0tFWVM9IiIKQ09ORklHX0hBVkVfS1ZNPXkKQ09ORklHX0hBVkVfS1ZN
X0lSUUNISVA9eQpDT05GSUdfSEFWRV9LVk1fSVJRRkQ9eQpDT05GSUdfSEFWRV9LVk1fSVJR
X1JPVVRJTkc9eQpDT05GSUdfSEFWRV9LVk1fRVZFTlRGRD15CkNPTkZJR19LVk1fQVBJQ19B
UkNISVRFQ1RVUkU9eQpDT05GSUdfS1ZNX01NSU89eQpDT05GSUdfS1ZNX0FTWU5DX1BGPXkK
Q09ORklHX0hBVkVfS1ZNX01TST15CkNPTkZJR19IQVZFX0tWTV9DUFVfUkVMQVhfSU5URVJD
RVBUPXkKQ09ORklHX0tWTV9WRklPPXkKQ09ORklHX0tWTV9HRU5FUklDX0RJUlRZTE9HX1JF
QURfUFJPVEVDVD15CkNPTkZJR19LVk1fQ09NUEFUPXkKQ09ORklHX1ZJUlRVQUxJWkFUSU9O
PXkKQ09ORklHX0tWTT1tCkNPTkZJR19LVk1fSU5URUw9bQpDT05GSUdfS1ZNX0FNRD1tCkNP
TkZJR19LVk1fTU1VX0FVRElUPXkKQ09ORklHX0tWTV9ERVZJQ0VfQVNTSUdOTUVOVD15CkNP
TkZJR19CSU5BUllfUFJJTlRGPXkKCiMKIyBMaWJyYXJ5IHJvdXRpbmVzCiMKQ09ORklHX1JB
SUQ2X1BRPW0KQ09ORklHX0JJVFJFVkVSU0U9eQojIENPTkZJR19IQVZFX0FSQ0hfQklUUkVW
RVJTRSBpcyBub3Qgc2V0CkNPTkZJR19SQVRJT05BTD15CkNPTkZJR19HRU5FUklDX1NUUk5D
UFlfRlJPTV9VU0VSPXkKQ09ORklHX0dFTkVSSUNfU1RSTkxFTl9VU0VSPXkKQ09ORklHX0dF
TkVSSUNfTkVUX1VUSUxTPXkKQ09ORklHX0dFTkVSSUNfRklORF9GSVJTVF9CSVQ9eQpDT05G
SUdfR0VORVJJQ19QQ0lfSU9NQVA9eQpDT05GSUdfR0VORVJJQ19JT01BUD15CkNPTkZJR19H
RU5FUklDX0lPPXkKQ09ORklHX0FSQ0hfVVNFX0NNUFhDSEdfTE9DS1JFRj15CkNPTkZJR19B
UkNIX0hBU19GQVNUX01VTFRJUExJRVI9eQpDT05GSUdfQ1JDX0NDSVRUPW0KQ09ORklHX0NS
QzE2PW0KQ09ORklHX0NSQ19UMTBESUY9eQpDT05GSUdfQ1JDX0lUVV9UPW0KQ09ORklHX0NS
QzMyPXkKIyBDT05GSUdfQ1JDMzJfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfQ1JDMzJf
U0xJQ0VCWTg9eQojIENPTkZJR19DUkMzMl9TTElDRUJZNCBpcyBub3Qgc2V0CiMgQ09ORklH
X0NSQzMyX1NBUldBVEUgaXMgbm90IHNldAojIENPTkZJR19DUkMzMl9CSVQgaXMgbm90IHNl
dApDT05GSUdfQ1JDNz1tCkNPTkZJR19MSUJDUkMzMkM9bQpDT05GSUdfQ1JDOD1tCiMgQ09O
RklHX0FVRElUX0FSQ0hfQ09NUEFUX0dFTkVSSUMgaXMgbm90IHNldAojIENPTkZJR19SQU5E
T00zMl9TRUxGVEVTVCBpcyBub3Qgc2V0CkNPTkZJR184NDJfQ09NUFJFU1M9bQpDT05GSUdf
ODQyX0RFQ09NUFJFU1M9bQpDT05GSUdfWkxJQl9JTkZMQVRFPXkKQ09ORklHX1pMSUJfREVG
TEFURT15CkNPTkZJR19MWk9fQ09NUFJFU1M9eQpDT05GSUdfTFpPX0RFQ09NUFJFU1M9eQpD
T05GSUdfTFo0X0NPTVBSRVNTPW0KQ09ORklHX0xaNEhDX0NPTVBSRVNTPW0KQ09ORklHX0xa
NF9ERUNPTVBSRVNTPXkKQ09ORklHX1haX0RFQz15CkNPTkZJR19YWl9ERUNfWDg2PXkKQ09O
RklHX1haX0RFQ19QT1dFUlBDPXkKQ09ORklHX1haX0RFQ19JQTY0PXkKQ09ORklHX1haX0RF
Q19BUk09eQpDT05GSUdfWFpfREVDX0FSTVRIVU1CPXkKQ09ORklHX1haX0RFQ19TUEFSQz15
CkNPTkZJR19YWl9ERUNfQkNKPXkKIyBDT05GSUdfWFpfREVDX1RFU1QgaXMgbm90IHNldApD
T05GSUdfREVDT01QUkVTU19HWklQPXkKQ09ORklHX0RFQ09NUFJFU1NfQlpJUDI9eQpDT05G
SUdfREVDT01QUkVTU19MWk1BPXkKQ09ORklHX0RFQ09NUFJFU1NfWFo9eQpDT05GSUdfREVD
T01QUkVTU19MWk89eQpDT05GSUdfREVDT01QUkVTU19MWjQ9eQpDT05GSUdfR0VORVJJQ19B
TExPQ0FUT1I9eQpDT05GSUdfUkVFRF9TT0xPTU9OPW0KQ09ORklHX1JFRURfU09MT01PTl9F
TkM4PXkKQ09ORklHX1JFRURfU09MT01PTl9ERUM4PXkKQ09ORklHX1JFRURfU09MT01PTl9E
RUMxNj15CkNPTkZJR19CQ0g9bQpDT05GSUdfQkNIX0NPTlNUX1BBUkFNUz15CkNPTkZJR19U
RVhUU0VBUkNIPXkKQ09ORklHX1RFWFRTRUFSQ0hfS01QPW0KQ09ORklHX1RFWFRTRUFSQ0hf
Qk09bQpDT05GSUdfVEVYVFNFQVJDSF9GU009bQpDT05GSUdfQlRSRUU9eQpDT05GSUdfSU5U
RVJWQUxfVFJFRT15CkNPTkZJR19BU1NPQ0lBVElWRV9BUlJBWT15CkNPTkZJR19IQVNfSU9N
RU09eQpDT05GSUdfSEFTX0lPUE9SVF9NQVA9eQpDT05GSUdfSEFTX0RNQT15CkNPTkZJR19D
SEVDS19TSUdOQVRVUkU9eQpDT05GSUdfQ1BVX1JNQVA9eQpDT05GSUdfRFFMPXkKQ09ORklH
X0dMT0I9eQojIENPTkZJR19HTE9CX1NFTEZURVNUIGlzIG5vdCBzZXQKQ09ORklHX05MQVRU
Uj15CkNPTkZJR19BUkNIX0hBU19BVE9NSUM2NF9ERUNfSUZfUE9TSVRJVkU9eQpDT05GSUdf
TFJVX0NBQ0hFPW0KQ09ORklHX0NMWl9UQUI9eQpDT05GSUdfQ09SRElDPW0KQ09ORklHX0RE
Uj15CkNPTkZJR19NUElMSUI9bQpDT05GSUdfT0lEX1JFR0lTVFJZPW0KQ09ORklHX1VDUzJf
U1RSSU5HPXkKQ09ORklHX0ZPTlRfU1VQUE9SVD15CkNPTkZJR19GT05UUz15CiMgQ09ORklH
X0ZPTlRfOHg4IGlzIG5vdCBzZXQKQ09ORklHX0ZPTlRfOHgxNj15CiMgQ09ORklHX0ZPTlRf
NngxMSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZPTlRfN3gxNCBpcyBub3Qgc2V0CiMgQ09ORklH
X0ZPTlRfUEVBUkxfOHg4IGlzIG5vdCBzZXQKIyBDT05GSUdfRk9OVF9BQ09STl84eDggaXMg
bm90IHNldAojIENPTkZJR19GT05UX01JTklfNHg2IGlzIG5vdCBzZXQKIyBDT05GSUdfRk9O
VF82eDEwIGlzIG5vdCBzZXQKIyBDT05GSUdfRk9OVF9TVU44eDE2IGlzIG5vdCBzZXQKIyBD
T05GSUdfRk9OVF9TVU4xMngyMiBpcyBub3Qgc2V0CiMgQ09ORklHX0ZPTlRfMTB4MTggaXMg
bm90IHNldApDT05GSUdfRk9OVF9BVVRPU0VMRUNUPXkKIyBDT05GSUdfU0dfU1BMSVQgaXMg
bm90IHNldApDT05GSUdfQVJDSF9IQVNfU0dfQ0hBSU49eQpDT05GSUdfQVJDSF9IQVNfUE1F
TV9BUEk9eQpDT05GSUdfQVJDSF9IQVNfTU1JT19GTFVTSD15Cg==
--------------070502040401080406030802
Content-Type: text/plain; charset=UTF-8;
 name="thunderbolt_ethernet_lspci_after_resume.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="thunderbolt_ethernet_lspci_after_resume.txt"

MDg6MDAuMCBTeXN0ZW0gcGVyaXBoZXJhbDogSW50ZWwgQ29ycG9yYXRpb24gRGV2aWNlIDE1
NmMKCVN1YnN5c3RlbTogRGV2aWNlIDIyMjI6MTExMQoJS2VybmVsIGRyaXZlciBpbiB1c2U6
IHRodW5kZXJib2x0CglLZXJuZWwgbW9kdWxlczogdGh1bmRlcmJvbHQKMDk6MDAuMCBQQ0kg
YnJpZGdlOiBJbnRlbCBDb3Jwb3JhdGlvbiBEU0wzNTEwIFRodW5kZXJib2x0IENvbnRyb2xs
ZXIgW0NhY3R1cyBSaWRnZV0gKHJldiBmZikKCUtlcm5lbCBkcml2ZXIgaW4gdXNlOiBwY2ll
cG9ydAoJS2VybmVsIG1vZHVsZXM6IHNocGNocAowYTowMC4wIFBDSSBicmlkZ2U6IEludGVs
IENvcnBvcmF0aW9uIERTTDM1MTAgVGh1bmRlcmJvbHQgQ29udHJvbGxlciBbQ2FjdHVzIFJp
ZGdlXSAocmV2IGZmKQoJS2VybmVsIGRyaXZlciBpbiB1c2U6IHBjaWVwb3J0CglLZXJuZWwg
bW9kdWxlczogc2hwY2hwCjBiOjAwLjAgRXRoZXJuZXQgY29udHJvbGxlcjogQnJvYWRjb20g
Q29ycG9yYXRpb24gTmV0WHRyZW1lIEJDTTU3NzYyIEdpZ2FiaXQgRXRoZXJuZXQgUENJZSAo
cmV2IGZmKQoJS2VybmVsIGRyaXZlciBpbiB1c2U6IHRnMwoJS2VybmVsIG1vZHVsZXM6IHRn
Mwo=
--------------070502040401080406030802
Content-Type: text/x-log;
 name="thunderbolt_ethernet_after_resume.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="thunderbolt_ethernet_after_resume.log"

Okt 27 10:09:24 csarch kernel: ACPI: Waking up from system sleep state S3
Okt 27 10:09:24 csarch kernel: pcieport 0000:07:03.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 10:09:24 csarch kernel: pcieport 0000:07:04.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 10:09:24 csarch kernel: pcieport 0000:07:05.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 10:09:24 csarch kernel: pcieport 0000:07:06.0: quirk: waiting for thunderbolt to reestablish PCI tunnels...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: resuming...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: control channel starting...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: starting TX ring 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: enabling interrupt at register 0x38200 bit 0 (0x0 -> 0x1)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: starting RX ring 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: enabling interrupt at register 0x38200 bit 12 (0x1 -> 0x1001)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: resetting switch at 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0: resuming switch
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is unplugged (state: 7), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:c.
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is unplugged (state: 7), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is unplugged (state: 7), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is not up (state: 1), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is not up (state: 1), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is not up (state: 1), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is not up (state: 1), retrying...
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: resetting error on 0:3.
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: is connected, link is up (state: 2)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3: resuming switch
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6 <-> 3:2 (PCI): activating
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: activating path from 0:6 to 3:2
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1: Writing hop 1, index 8
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1:  Hop through port 2 to hop 8 (enabled)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1:    Counter enabled: 0 Counter index: 2047
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:1:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6: Writing hop 0, index 8
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6:  Hop through port 3 to hop 8 (enabled)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6:    Counter enabled: 0 Counter index: 2047
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:6:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: activating path from 3:2 to 0:6
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: Writing hop 1, index 8
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3:  Hop through port 6 to hop 8 (enabled)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Weight: 1 Priority: 3 Credits: 16 Drop: 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3:    Counter enabled: 0 Counter index: 2047
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Flow Control (In/Eg): 1/0 Shared Buffer (In/Eg): 0/0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2: Writing hop 0, index 8
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2:  Hop through port 1 to hop 8 (enabled)
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Weight: 1 Priority: 3 Credits: 7 Drop: 0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2:    Counter enabled: 0 Counter index: 2047
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Flow Control (In/Eg): 1/1 Shared Buffer (In/Eg): 0/0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 3:2:   Unknown1: 0x0 Unknown2: 0x0 Unknown3: 0x0
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: path activation complete
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: tunnels restarted, sleeping for 100ms
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: resume finished
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:c: hotplug: scanning
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:c: hotplug: no switch found
Okt 27 10:09:24 csarch kernel: thunderbolt 0000:08:00.0: 0:3: got plug event for connected port, ignoring
Okt 27 10:09:24 csarch kernel: pcieport 0000:09:00.0: Refused to change power state, currently in D3
Okt 27 10:09:24 csarch kernel: pcieport 0000:0a:00.0: Refused to change power state, currently in D3
Okt 27 10:09:24 csarch kernel: tg3 0000:0b:00.0: Refused to change power state, currently in D3
Okt 27 10:09:24 csarch kernel: PM: noirq resume of devices complete after 927.398 msecs
Okt 27 10:09:24 csarch kernel: PM: early resume of devices complete after 31.055 msecs
Okt 27 10:09:24 csarch kernel: wl_resume: PCI Resume handler
Okt 27 10:09:24 csarch kernel: sd 0:0:0:0: [sda] Starting disk
Okt 27 10:09:24 csarch kernel: pciehp 0000:07:00.0:pcie24: Device 0000:08:00.0 already exists at 0000:08:00, cannot hot-add
Okt 27 10:09:24 csarch kernel: pciehp 0000:07:00.0:pcie24: Cannot add device at 0000:08:00
Okt 27 10:09:24 csarch kernel: wl0: link down (wlan0)
Okt 27 10:09:24 csarch kernel: ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
Okt 27 10:09:24 csarch kernel: ata1.00: unexpected _GTF length (8)
Okt 27 10:09:24 csarch kernel: ata1.00: unexpected _GTF length (8)
Okt 27 10:09:24 csarch kernel: ata1.00: configured for UDMA/133
Okt 27 10:09:24 csarch kernel: pciehp 0000:00:1c.0:pcie04: link training error: status 0x1001
Okt 27 10:09:24 csarch kernel: pciehp 0000:00:1c.0:pcie04: Failed to check link status
Okt 27 10:09:24 csarch kernel: pciehp 0000:07:03.0:pcie24: Failed to check link status
Okt 27 10:09:24 csarch kernel: rtc_cmos 00:02: System wakeup disabled by ACPI
Okt 27 10:09:24 csarch kernel: pciehp 0000:0a:00.0:pcie24: Timeout on hotplug command 0x1038 (issued 56200 msec ago)
Okt 27 10:09:24 csarch kernel: pciehp 0000:0a:00.0:pcie24: pcie_do_write_cmd: no response from device
Okt 27 10:09:24 csarch kernel: pciehp 0000:0a:00.0:pcie24: link training error: status 0xffff
Okt 27 10:09:24 csarch kernel: pciehp 0000:0a:00.0:pcie24: Failed to check link status
Okt 27 10:09:24 csarch kernel: PM: resume of devices complete after 3884.703 msecs
Okt 27 10:09:24 csarch kernel: PM: Finishing wakeup.
Okt 27 10:09:24 csarch kernel: Restarting tasks ... done.
Okt 27 10:09:24 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
Okt 27 10:09:24 csarch kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Okt 27 10:09:24 csarch kernel: tg3 0000:0b:00.0: Refused to change power state, currently in D3
Okt 27 10:09:24 csarch systemd[1]: Time has been changed
Okt 27 10:09:24 csarch rtkit-daemon[992]: The canary thread is apparently starving. Taking action.
Okt 27 10:09:24 csarch systemd-logind[688]: Lid opened.
Okt 27 10:09:24 csarch rtkit-daemon[992]: Demoting known real-time threads.
Okt 27 10:09:24 csarch systemd-sleep[11921]: System resumed.
Okt 27 10:09:24 csarch systemd[983]: Time has been changed
Okt 27 10:09:24 csarch rtkit-daemon[992]: Demoted 1 threads.
Okt 27 10:09:24 csarch NetworkManager[703]: <info>  (eth0): device state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
Okt 27 10:09:25 csarch kernel: tg3 0000:0b:00.0 eth0: No firmware running
Okt 27 10:09:27 csarch kernel: tg3 0000:0b:00.0: tg3_abort_hw timed out, TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff


--------------070502040401080406030802--
