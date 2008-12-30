From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.28] NULL pointer dereference at get_stats()
Date: Tue, 30 Dec 2008 23:38:53 +0900
Message-ID: <200812302338.GDF34307.JOOMSFVQHFLFOt@I-love.SAKURA.ne.jp>
References: <200812302153.ECH86976.MFLOQFJHtSOOFV@I-love.SAKURA.ne.jp>
	<2f11576a0812300528t6ed12fccg8698d33dc778b9c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: kosaki.motohiro@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:57223 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbYL3Oiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 09:38:55 -0500
In-Reply-To: <2f11576a0812300528t6ed12fccg8698d33dc778b9c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

KOSAKI Motohiro wrote:
> it doesn't have any network card initialization log, but kernel
> crashed in network driver.
> in addition, loaded module list indicate your network card is pcnet32,
> but pcnet32 doesn't have
> get_stats() function. (instead, it has pcnet32_get_stats() )

I think pcnet32 is unrelated.
It seems to me that the problem is loopback device.

I added "init=/bin/bash" and tried below commands.
----------------------------------------
# lsmod
Module                  Size  Used by
mptspi                 19208  1 
mptscsih               33152  1 mptspi
mptbase                74084  2 mptspi,mptscsih
scsi_transport_spi     23296  1 mptspi
sd_mod                 27416  2 
scsi_mod              138260  4 mptspi,mptscsih,scsi_transport_spi,sd_mod
ext3                  109576  1 
jbd                    43924  1 ext3
uhci_hcd               22800  0 
ohci_hcd               23696  0 
ehci_hcd               33036  0 
# ls -1 /sys/class/net/
lo
# cat /sys/class/net/lo/statistics/rx_packets
BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c055f2f5>] get_stats+0x1d/0x48
*pde = 00000000 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/class/net/lo/statistics/rx_packets
Modules linked in: mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd

Pid: 597, comm: cat Not tainted (2.6.28 #1) VMware Virtual Platform
EIP: 0060:[<c055f2f5>] EFLAGS: 00010297 CPU: 0
EIP is at get_stats+0x1d/0x48
EAX: 00000000 EBX: df956858 ECX: 00000001 EDX: 00000001
ESI: 00000000 EDI: 00000000 EBP: 2069abbf ESP: df89af24
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process cat (pid: 597, ti=df89a000 task=df8c8db0 task.ti=df89a000)
Stack:
 df956800 00000000 dedb9000 c0732a00 c05c82fa c073a0ac fffffffb c05c83dc
 c05c83e3 00000000 c0559190 dedaaa00 ffffffed df959718 c04a8da6 00001000
 0804f000 dedaaa14 df956bf4 df8a5840 0804f000 c04a8d1d 00001000 c0470444
Call Trace:
 [<c05c82fa>] netstat_show+0x48/0x64
 [<c05c83dc>] show_rx_packets+0x0/0x9
 [<c05c83e3>] show_rx_packets+0x7/0x9
 [<c0559190>] dev_attr_show+0x16/0x32
 [<c04a8da6>] sysfs_read_file+0x89/0xe8
 [<c04a8d1d>] sysfs_read_file+0x0/0xe8
 [<c0470444>] vfs_read+0x81/0xf4
 [<c0470720>] sys_read+0x3c/0x63
 [<c0403841>] sysenter_do_call+0x12/0x21
Code: ff 00 89 d8 e8 28 e6 05 00 31 c0 5b 5e c3 55 83 c9 ff 57 31 ff 56 31 f6 53 8b a8 6c 03 00 00 8d 58 58 eb 0c 89 e8 f7 d0 8b 04 88 <03> 78 04 03 30 89 c8 ba a0 9c 81 c0 e8 66 a1 f8 ff 83 f8 1f 89 
EIP: [<c055f2f5>] get_stats+0x1d/0x48 SS:ESP 0068:df89af24
---[ end trace e9672264d489cc49 ]---
----------------------------------------

Regards.
