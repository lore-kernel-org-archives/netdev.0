From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6378] New: bonding mode=1 does not always pick
 right primary interface
Date: Wed, 12 Apr 2006 12:45:02 -0700
Message-ID: <20060412124502.6bf136d4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux@hrunting.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54943 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932168AbWDLTpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 15:45:11 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 12 Apr 2006 05:57:27 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6378] New: bonding mode=1 does not always pick right primary interface


http://bugzilla.kernel.org/show_bug.cgi?id=6378

           Summary: bonding mode=1 does not always pick right primary
                    interface
    Kernel Version: 2.6.16
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: linux@hrunting.org


Most recent kernel where this bug did not occur: 2.6.10
Distribution: Fedora Core 4
Hardware Environment: Dual P4 2.4GHz, dual onboard e1000 NICs, one unused e100
management NIC
Software Environment: FC4, 2.6.16-1.2069_FC4
Problem Description: Picking a primary interface does not always work

Steps to reproduce:
Configure /etc/modprobe.conf with lines like such:

alias eth0 e1000
alias eth1 e1000
alias bond0 bonding
options bond0 miimon=100 mode=1 primary=eth1

Reboot the box.

When the box comes up, it's using eth0 as the primary NIC and eth1 as a backup.
 If you drop the connection on eth0 (I do this by shutting down a port on the
router), it fails over properly to eth1.  If I then bring back up eth0, it stays
on eth0 correctly.  Shutting down the port to eth1 fails over to eth0 properly.
 Bringing back up the port for eth1 causes it to fail back over to eth1 properly.

So it looks like the primary mode is being set right, but isn't being
acknowledged or handled properly when the bond is first brought up.

I also have Opteron servers running this config and they do not seem to be
affected by this bug.  It might be a timing issue on boot that affects Intel
systems more than Opterons, though.  I've seen it once or twice on Opteron with
kernel 2.6.15.  It's regularly reproducible with the Intel systems, though, with
both 2.6.15 and 2.6.16 FC4 kernels.

The relevant portions of lspci -v:

03:01.0 Ethernet controller: Intel Corporation 82541EI Gigabit Ethernet
Controller (Copper)
        Subsystem: Intel Corporation: Unknown device 1213
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 28
        Memory at fd8c0000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at c400 [size=64]
        Capabilities: [dc] Power Management version 2
        Capabilities: [e4] PCI-X non-bridge device.

03:02.0 Ethernet controller: Intel Corporation 82541EI Gigabit Ethernet
Controller (Copper)
        Subsystem: Intel Corporation: Unknown device 1213
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 29
        Memory at fd8e0000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at c800 [size=64]
        Capabilities: [dc] Power Management version 2
        Capabilities: [e4] PCI-X non-bridge device.

Relevant lines from dmesg (boot):

Ethernet Channel Bonding Driver: v3.0.1 (January 9, 2006)
bonding: MII link monitoring set to 100 ms
e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
bonding: bond0: making interface eth0 the new active one.
bonding: bond0: enslaving eth0 as an active interface with an up link.
e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
bonding: bond0: enslaving eth1 as a backup interface with an up link.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
