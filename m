From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7198] New: balance-alb bonding oops when
 disconnecting primary slave interface
Date: Sun, 24 Sep 2006 22:08:32 -0700
Message-ID: <20060924220832.62281e07.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: galagoda@ccgs.wa.edu.au,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32492 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751375AbWIYFJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 01:09:13 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 24 Sep 2006 19:58:03 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7198] New: balance-alb bonding oops when disconnecting primary slave interface


http://bugzilla.kernel.org/show_bug.cgi?id=7198

           Summary: balance-alb bonding oops when disconnecting primary
                    slave interface
    Kernel Version: 2.6.18
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: galagoda@ccgs.wa.edu.au


Most recent kernel where this bug did not occur: 2.6.8 (Debian release kernel)
Distribution: Debian
Hardware Environment: IBM eServer xSeries 336, e1000 and/or broadcom BCM5721  
Software Environment: Debian Linux Kernel 
Problem Description: When bonding is enabled in balance-alb mode on several
gigabit interfaces, when the primary slave device is unplugged it always
displays this...

e1000: eth2: e1000_watchdog: NIC Link is Down
bonding: bond0: link status down for idle  interface eth2, disabling it in 100 ms.
bonding: bond0: link status definitely down for interface eth2, disabling it
bonding: bond0: making interface eth3 the new active one.
device eth2 left promiscuous mode
RTNL: assertion failed at net/ipv4/devinet.c (984)
 [<c03b0884>] inetdev_event+0x273/0x2d5
 [<c03885ca>] rt_run_flush+0x68/0x94
 [<c0127aae>] notifier_call_chain+0x1d/0x2d
 [<c036ead9>] dev_set_mac_address+0x4a/0x4f
 [<f9d6807e>] alb_set_slave_mac_addr+0x64/0x88 [bonding]
 [<f9d6967d>] alb_swap_mac_addr+0x6c/0x15a [bonding]
 [<f9d63a1c>] bond_change_active_slave+0x2e8/0x348 [bonding]
 [<f9d64617>] bond_select_active_slave+0xa5/0x129 [bonding]
 [<f9d64eeb>] bond_mii_monitor+0x1a6/0x4c1 [bonding]
 [<f9d64d45>] bond_mii_monitor+0x0/0x4c1 [bonding]
 [<c01236f1>] run_timer_softirq+0xc6/0x19b
 [<c01200f2>] __do_softirq+0x75/0xe1
 [<c0120192>] do_softirq+0x34/0x36
 [<c0120310>] irq_exit+0x41/0x43
 [<c0103733>] apic_timer_interrupt+0x1f/0x24
 [<c0101ae6>] mwait_idle+0x2a/0x34
 [<c0101a97>] cpu_idle+0x63/0x88
RTNL: assertion failed at net/ipv4/devinet.c (984)
 [<c03b0884>] inetdev_event+0x273/0x2d5
 [<c03885ca>] rt_run_flush+0x68/0x94
 [<c0127aae>] notifier_call_chain+0x1d/0x2d
 [<c036ead9>] dev_set_mac_address+0x4a/0x4f
 [<f9d6807e>] alb_set_slave_mac_addr+0x64/0x88 [bonding]
 [<f9d6968c>] alb_swap_mac_addr+0x7b/0x15a [bonding]
 [<f9d63a1c>] bond_change_active_slave+0x2e8/0x348 [bonding]
 [<f9d64617>] bond_select_active_slave+0xa5/0x129 [bonding]
 [<f9d64eeb>] bond_mii_monitor+0x1a6/0x4c1 [bonding]
 [<f9d64d45>] bond_mii_monitor+0x0/0x4c1 [bonding]
 [<c01236f1>] run_timer_softirq+0xc6/0x19b
 [<c01200f2>] __do_softirq+0x75/0xe1
 [<c0120192>] do_softirq+0x34/0x36
 [<c0120310>] irq_exit+0x41/0x43
 [<c0103733>] apic_timer_interrupt+0x1f/0x24
 [<c0101ae6>] mwait_idle+0x2a/0x34
 [<c0101a97>] cpu_idle+0x63/0x88
device eth3 entered promiscuous mode
e1000: eth2: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
bonding: bond0: link status up for interface eth2, enabling it in 100 ms.
bonding: bond0: link status definitely up for interface eth2.
device eth3 left promiscuous mode

and intermittently causes a segmentation fault.

This does not happen in balance-tlb mode.

Steps to reproduce:
1. Use kernel 2.6.10-2.6.18 (tried all of these)
2. Using generic i386 or P4-Xeon compile target 
3. Setup balance-alb on 4 e1000 or BCM5721, with each interface in slave mode
without IP.  
4. When all ports are connected to a gigabit switch, in-turn disconnect and
re-connect each interface.  When the primary is unplugged this message is displayed.

Hope this info was enough.  I apologize if this has been fixed before.  

I would greatly appreciate a fix for this.

Thanks in advance 
Geoff

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
