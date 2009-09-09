From: Sachin Sant <sachinp@in.ibm.com>
Subject: Re: Next Sept 7: Bug : skb_release_head_state on x86
Date: Wed, 09 Sep 2009 16:43:24 +0530
Message-ID: <4AA78DD4.60003@in.ibm.com>
References: <20090907210206.7830ba68.sfr@canb.auug.org.au> <4AA5399A.405@in.ibm.com> <4AA5400E.9010108@gmail.com> <4AA5E717.1050002@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, David Miller <davem@davemloft.net>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:47596 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbZIILN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 07:13:26 -0400
In-Reply-To: <4AA5E717.1050002@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sachin Sant wrote:
> Will try to boot 0904 and will check if the same problem can be 
> recreated.
I still have this problem with next-20090908.Although the trace
looks a bit different.

Haven't checked today's next.

BUG: unable to handle kernel paging request at 00008c90
IP: [<c0349399>] skb_dma_unmap+0x15/0x91
*pdpt = 0000000035445001 *pde = 0000000000000000
Oops: 0000 [#2] SMP
last sysfs file: /sys/devices/system/cpu/cpu3/topology/core_siblings
Modules linked in: ipv6 microcode fuse loop dm_mod i2c_piix4 tg3 i2c_core pcspkr ppdev button libphy sworks_agp rtc_cmos rtc_core parport_pc sr_mod rtc_lib sg parport agpgart cdrom floppy ohci_hcd ehci_hcd sd_mod crc_t10dif usbcore edd fan ide_pci_generic serverworks ide_core ata_generic pata_serverworks libata ips scsi_mod thermal processor thermal_sys hwmon [last unloaded: speedstep_lib]

Pid: 6, comm: ksoftirqd/1 Tainted: G      D    (2.6.31-rc9-autotest-next-20090908-5-pae #1) eserver xSeries 235 -[86717AX]-
EIP: 0060:[<c0349399>] EFLAGS: 00010296 CPU: 1
EIP is at skb_dma_unmap+0x15/0x91
EAX: f5d3dc5c EBX: c056bba0 ECX: 00000001 EDX: 00008be8
ESI: f4d3b2f0 EDI: 00008be8 EBP: f5c69ec4 ESP: f5c69eac
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process ksoftirqd/1 (pid: 6, ti=f5c68000 task=f5c4f280 task.ti=f5c68000)
Stack:
 00000001 f5d3dc5c f5c69ec4 0000005f f4d3b2f0 00008be8 f5c69f3c f8d191a1
<0> c148347c 00000040 f4900380 f4900340 00000000 f55b2000 f4900340 00000064
<0> f553aa00 00000000 f4900340 00000000 f49006b8 d0622200 0000059a f4d377c0
Call Trace:
 [<f8d191a1>] ? tg3_poll+0x10f/0x802 [tg3]
 [<c034c151>] ? net_rx_action+0x93/0x173
 [<c01376b8>] ? __do_softirq+0xa7/0x144
 [<c013777b>] ? do_softirq+0x26/0x2b
 [<c01377ca>] ? ksoftirqd+0x4a/0xae
 [<c0137780>] ? ksoftirqd+0x0/0xae
 [<c0146a56>] ? kthread+0x61/0x66
 [<c01469f5>] ? kthread+0x0/0x66
 [<c0103507>] ? kernel_thread_helper+0x7/0x10
Code: 5a c0 74 07 89 d8 e8 f3 7b e6 ff ba f4 ff ff ff 89 d0 5b 5e 5d c3 55 89 e5 57 56 53 83 ec 0c 8b 1d c0 07 61 c0 89 4d e8 89 45 ec <8b> ba a8 00 00 00 83 7d e8 02 8b 42 50 8b 72 54 8b 4f 0c 8b 57
EIP: [<c0349399>] skb_dma_unmap+0x15/0x91 SS:ESP 0068:f5c69eac
CR2: 0000000000008c90
---[ end trace 9239788a6557ba57 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 6, comm: ksoftirqd/1 Tainted: G      D    2.6.31-rc9-autotest-next-20090908-5-pae #1

I went back and tried out some old next versions. Seems like
the problem was introduced in next-20090903. next-20090902
worked fine.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

