From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6401] New: tg3 hardware address issue
Date: Mon, 17 Apr 2006 14:17:15 -0700
Message-ID: <20060417141715.30afbdd8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zef@cektek.net,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22716 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751309AbWDQVSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 17:18:41 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 17 Apr 2006 13:39:47 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6401] New: tg3 hardware address issue


http://bugzilla.kernel.org/show_bug.cgi?id=6401

           Summary: tg3 hardware address issue
    Kernel Version: > 2.6.14
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: zef@cektek.net


Most recent kernel where this bug did not occur: Havent tried anything older 
than 2.6.14 and it was also affected.
Distribution: Fedora Core 4
Hardware Environment: Dual Core Opteron on Nforce Professional Mobo
Software Environment: Minimal FC4 Install
Problem Description: 
Onboard Broadcom BCM5721 dual port gigabit ethernet (pci express) is not 
functioning, have tried reverting all the way back to 2.6.14 based on this 
thread suggesting it was not an issue in earlier versions: http://www.spinics.
net/lists/netdev/msg01858.html.

Right now I am using the tg3.c contained in linus's git tree with a 2.6.15 
kernel because this driver version (3.56) seems to be least broken, or atleast 
hides it best.

dmesg upon loading (modprobe):

tg3.c:v3.56 (Apr 1, 2006)
ACPI: PCI Interrupt 0000:04:00.0[A] -> Link [LNKB] -> GSI 19 (level, low) -> IRQ 
50
PCI: Setting latency timer of device 0000:04:00.0 to 64
eth1: Tigon3 [partno(none) rev 4101 PHY(5750)] (PCI Express) 10/100/1000BaseT 
Ethernet ff:ff:ff:ff:ff:ff
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth1: dma_rwctrl[76180000] dma_mask[64-bit]
ACPI: PCI Interrupt 0000:03:00.0[A] -> Link [LNKA] -> GSI 18 (level, low) -> IRQ
58
PCI: Setting latency timer of device 0000:03:00.0 to 64
eth2: Tigon3 [partno(none) rev 4101 PHY(5750)] (PCI Express) 10/100/1000BaseT 
Ethernet ff:ff:ff:ff:ff:ff
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth2: dma_rwctrl[76180000] dma_mask[64-bit]
ADDRCONF(NETDEV_UP): eth0: link is not ready

dmesg after `ifconfig eth1 up 192.168.2.122'

tg3: tg3_reset_hw timed out for eth1, firmwared will not restart magic=4b657654
tg3: tg3_reset_hw timed out for eth1, firmwared will not restart magic=4b657654
tg3: tg3_reset_hw timed out for eth1, firmwared will not restart magic=4b657654
tg3: tg3_reset_hw timed out for eth1, firmwared will not restart magic=4b657654



Note: this is my relevant dmesg from any older version of tg3.c I have tried:

PCI: Enabling device 0000:04:00.0
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 18 (level, low) -> IRQ 50
tg3: Could not obtain valid ethernet address, aborting.
ACPI: PCI interrupt for device 0000:04:00.0 disabled
tg3: probe of 0000:04:00.0 failed with error -22

Neither of the nic's dual interfaces show up when doing `ifconfig -a' after 
this.

Steps to reproduce:
Load module, attempt to bring up interface.

I am willing to grant access to this machine if i can figure out how since it 
doesnt really have networking abilities atm.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
