From: Jamie Lenehan <lenehan@twibble.org>
Subject: Re: [Ubuntu PATCH] Make tulip driver not handle Davicom NICs
Date: Sat, 17 Jun 2006 15:43:23 +1000
Message-ID: <20060617054323.GA31636@twibble.org>
References: <44909A78.4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, akpm <akpm@osdl.org>,
	val_henson@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from birgitte.twibble.org ([202.173.155.195]:48035 "EHLO
	birgitte.twibble.org") by vger.kernel.org with ESMTP
	id S1750954AbWFQFnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 01:43:31 -0400
To: Randy Dunlap <randy.dunlap@oracle.com>
Content-Disposition: inline
In-Reply-To: <44909A78.4@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 04:23:36PM -0700, Randy Dunlap wrote:
> Make tulip driver not handle Davicom NICs, let dmfe take over"
> 
> Reference: https://launchpad.net/bugs/48287
> Source URL of Patch:
> http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=1804482911a71bee9114cae1c2079507a38e9e7f

The dmfe driver doesn't work on sparc64. My sparc64 Sun Netra X1's have
Davicom NICs and they work fine with the tulip driver. It'd be nice to have
only one driver handling these things that works for both. I'll see if I
fugure out why dmfe doesn't work on sparc64.

 aviendha:~# /sbin/modprobe dmfe
 dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
 eth0: Davicom DM9102 at pci0000:00:05.0, 00:00:00:00:00:00, irq 7098496.
 eth1: Davicom DM9102 at pci0000:00:0c.0, 00:00:00:00:00:00, irq 7097792.
 aviendha:~# /sbin/ifup eth0
 SABRE0: PCI SERR signal asserted.
 SABRE0: PCI bus error, PCI_STATUS[caa0]
 eth0: Tx timeout - resetting
 SABRE0: PCI SERR signal asserted.
 SABRE0: PCI bus error, PCI_STATUS[caa0]
 eth0: Tx timeout - resetting
 SABRE0: PCI SERR signal asserted.
 SABRE0: PCI bus error, PCI_STATUS[caa0]
 eth0: Tx timeout - resetting
 aviendha:~# /sbin/ifdown eth0
 aviendha:~# /sbin/rmmod dmfe
 aviendha:~# /sbin/modprobe tulip
 Linux Tulip driver version 1.1.13 (May 11, 2002)
 tulip0: Old style EEPROM with no media selection information.
 tulip0:  MII transceiver #1 config 3100 status 7829 advertising 01e1.
 eth0: Davicom DM9102/DM9102A rev 49 at 000001fe02010100, EEPROM not present, 00:03:BA:06:30:E1, IRQ 7098496.
 tulip1: Old style EEPROM with no media selection information.
 tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
 eth1: Davicom DM9102/DM9102A rev 49 at 000001fe02010000, EEPROM not present, 00:03:BA:06:30:E0, IRQ 7097792.
 aviendha:~# /sbin/ifup eth0
 aviendha:~# ping -c 1 172.20.0.1
 PING 172.20.0.1 (172.20.0.1) 56(84) bytes of data.
 64 bytes from 172.20.0.1: icmp_seq=1 ttl=64 time=3.02 ms

 --- 172.20.0.1 ping statistics ---
 1 packets transmitted, 1 received, 0% packet loss, time 0ms
 rtt min/avg/max/mdev = 3.021/3.021/3.021/0.000 ms
 aviendha:~# uname -a
 Linux aviendha.twibble.org 2.6.15-rc4 #12 Sat Dec 3 21:44:21 EST 2005 sparc64 GNU/Linux
 aviendha:~# lspci -vxns 00:0c.0
 0000:00:0c.0 0200: 1282:9102 (rev 31)
         Flags: bus master, medium devsel, latency 160, IRQ 006c4dc0
         I/O ports at 0000000002010000 [size=256]
         [virtual] Memory at 000001ff00000000 (32-bit, non-prefetchable) [size=256]
         Expansion ROM at 0000000000040000 [disabled] [size=256K]
         Capabilities: [50] Power Management version 2
 00: 82 12 02 91 47 01 10 02 31 00 00 02 00 a0 00 00
 10: 01 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 30: 00 00 04 00 50 00 00 00 00 00 00 00 00 01 14 28
 
 aviendha:~#
 ...

-- 
 Jamie Lenehan <lenehan@twibble.org>
