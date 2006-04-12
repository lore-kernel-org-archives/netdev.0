From: Guenther Thomsen <gthomsen@bluearc.com>
Subject: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Wed, 12 Apr 2006 14:42:56 -0700
Message-ID: <200604121442.56750.gthomsen@bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmimesweeper.bluearc.com ([63.203.197.133]:64779 "EHLO
	us-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S932321AbWDLVol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 17:44:41 -0400
To: shemminger@osdl.org, "John W. Linville" <linville@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm happy to report, that the version of the sky2 driver in 2.6.17-rc1 
yields line rate at low CPU utilization (as determined using ttcp).

Unfortunately, it's not quite bug-free yet ;-} 

When enabling the second interface (of the same network controller) the 
kernel panics (perhaps during DHCP discovery?):

--8<--
[root@penguin1 ~]# ifup eth1

Determining IP information for eth1...Unable to handle kernel paging 
request at ffffc20000014000 RIP:
<ffffffff811a3329>{sky2_mac_init+522}
PGD 13fc49067 PUD 13fc4a067 PMD 13fc4b067 PTE 0
Oops: 0000 [1] SMP
CPU 3os linked in: autofs4 sr_mod cdrom dm_mod button usb_storage 
uhci_hcd 11BladeRunner_sk98lin #1
RIP: 0010:[<ffffffff811a3329>] <ffffffff811a68 RCX: 000000000000001e
RDX: 0000000000004008 RSI: ffffc20000010000 11 0000000000000fe0 R12: 
0000000000001000
R13: ffff81013fae61a8 R14:
                           S: 010 DS: 0000 ES: 0000 CR0: 
000000008005003b
CR2: ffffc20000014000fe40)
Stack: 0000000000001000 ffff81013fae6000 ffff81013fae6500 
00000f1013fae6000
Call Trace: <ffffffff811a3e0c>{sky2_up+334} <ffffffff81
       <ffffffff81144cf4>{sprintf+144} 
<ffffffff8123b616>{inet_ioctl{s_ioctl+44} 
<ffffffff81085703>{sys_ioctl+107}
       <ffffffff81009a2ac_init+522} RSP <ffff81013487fd28>
CR2: ffffc20000014000
 <0>Kerne
-->8--

or (2nd try): 

--8<--
[root@penguin1 ~]# Unable to handle kernel paging request at 
ffffc20000014000 RIP:
<ffffffff811a3329>{sky2_mac_init+522}
PGD 13fc49067 PUD 13fc4a067 PMD 13fc4b067 PTE 0
Oops: 0000 [1] SMP
CPU 2
Modules linked in: autofs4 sr_mod cdrom dm_mod button usb_storage 
uhci_hcd ehci_hcd e752x_edac edac_mc shpcR: 00:[<ffffffff811a3329>] 
<ffffffff811a3329>{sky2_mac_init+522}
RDX: 0000000000004008 RSI: ffffc20000010000 RDI: 0000000000000000
R1 0000000001000
R13: ffff81013f0511a8 R14: 0000000000000001 R15: 0000S0000 CR0: 
000000008005003b
CR2: ffffc20000014000 CR3: 000000013425b000000000001000 ffff81013f051000 
ffff81013f051500 0000000000000000
   Call Trace: <ffffffff811a3e0c>{sky2_up+334} 
<ffffffff811fea04>{dev_op844cf4>{sprintf+144} 
<ffffffff8123b616>{inet_ioctl+74}
       <fffffffff81085703>{ys_ioctl+107}
       <ffffffff81009ac8>{tracesys+209}
+} RSP <ffff81013534fd28>
CR2: ffffc20000014000
 <0>Kernel panic - n
-->8--

The kernel is vanilla 2.6.17-rc1, the sky2 driver was compiled into the 
kernel. OS is RedHat Fedora Core 4. The kernel was compiled using 
gcc32.

The system is a Blade of a BladeRunner 4130 of Penguincomputing, it 
contains two Xeon CPU (+ HT enabled) and an on-board 8062 network 
controller of Marvell (88E8062 is stamped on the chip).

The hardware seems to work fine using 2.6.15(.7) with the sk98lin driver 
version 8.31 of Syskonnect (skd.de).

Please let me know, if I can provide further information or assist in 
any other way.

best regards
	Guenther
