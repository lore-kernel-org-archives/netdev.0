From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 23:38:21 +0200
Message-ID: <20080616213821.GA8844@orion.carnet.hr>
References: <20080616140454.GD5350@solarflare.com> <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com> <20080616191354.GA11760@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	mirrors@debian.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:34736 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbYFPViZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 17:38:25 -0400
Content-Disposition: inline
In-Reply-To: <20080616191354.GA11760@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 09:13:54PM +0200, joy wrote:
> On Mon, Jun 16, 2008 at 08:52:13AM -0700, Michael Chan wrote:
> > Josip, please provide more information such as driver version from
> > ethtool -i, lspci, which version did you first see the problem, and
> > whether the latest in 2.6.25 has the same problem.  Thanks.
> 
> The version with the problem is 2.6.22.18. The machine is fairly new
> (HP DL360 G5), it only ever ran the .22 kernel. It was running this kernel
> just fine for 112 days prior to the first incident on 2008-06-03, and since
> then, the crash happened a total of 17 times. Our big rsync runs happen
> twice a day, so it's a pretty bad record.
> 
> I can't verify that the crash was caused by the same thing every time
> because I don't have console logs, but the symptoms are always the same - a
> few minutes into the rsync run, it goes down, logging nothing in syslog.
> 
> I'll be rebooting into 2.6.25.6 shortly, and then I'll have information
> relevant to that in about a day or two.

Crap, it just crashed again, with 2.6.25.6.

BUG: unable to handle kernel NULL pointer dereference at 00000000000000b8
IP: [<ffffffff88084c9a>] :bnx2:bnx2_tx_int+0x6a/0x330
PGD 22e8c2067 PUD 1bfa48067 PMD 0 
Oops: 0000 [1] SMP 
CPU 2 
Modules linked in: ipmi_devintf nfs lockd nfs_acl sunrpc fan ac battery cls_u32 sch_sfq sch_htb ip6t_REJECT ip6t_LOG ip6table_filter ip6_tables ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables ipv6 dm_snapshot dm_mirror dm_mod usbhid bnx2 zlib_inflate container ehci_hcd ipmi_si crc32 thermal uhci_hcd ipmi_msghandler button usbcore processor shpchp
Pid: 0, comm: swapper Not tainted 2.6.25.6 #1
RIP: 0010:[<ffffffff88084c9a>]  [<ffffffff88084c9a>] :bnx2:bnx2_tx_int+0x6a/0x330
RSP: 0018:ffff81022f8cfd00  EFLAGS: 00010286
RAX: 00000000000005ba RBX: ffff81022f9faaf0 RCX: 00000000000000af
RDX: 00000000000005ba RSI: ffff8100865f85bf RDI: ffff8100cf974198
RBP: 0000000005a505af R08: ffff8100867e2100 R09: ffff8101bf8019a8
R10: 0000000000000000 R11: ffffffff80419a50 R12: 00000000000000ae
R13: 0000000000000001 R14: 0000000000000000 R15: ffff81022f92a700
FS:  0000000000000000(0000) GS:ffff81022f875940(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000b8 CR3: 00000001756e1000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff81022f8ca000, task ffff81022f8837d0)
Stack:  ffff81022e97f000 000000002eb51600 ffff81022f92a800 05baffff880d9767
 0000000100000004 ffff81022f92a800 0000000000000040 0000000000000000
 ffff810001016ac0 ffff81022f92a700 000000000000012c ffffffff88085422
Call Trace:
 <IRQ>  [<ffffffff88085422>] ? :bnx2:bnx2_poll+0xd2/0x12d0
 [<ffffffff8022d7e4>] ? run_rebalance_domains+0x194/0x4c0
 [<ffffffff803edaa8>] ? net_rx_action+0xf8/0x200
 [<ffffffff8023a5b9>] ? __do_softirq+0x69/0xe0
 [<ffffffff8020c4ac>] ? call_softirq+0x1c/0x30
 [<ffffffff8020e995>] ? do_softirq+0x35/0x70
 [<ffffffff8020ec10>] ? do_IRQ+0x80/0x100
 [<ffffffff8020a410>] ? mwait_idle+0x0/0x50
 [<ffffffff8020b831>] ? ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff80419a50>] ? tcp_poll+0x0/0x180
 [<ffffffff8020a451>] ? mwait_idle+0x41/0x50
 [<ffffffff8020a378>] ? cpu_idle+0x48/0x90


Code: 24 1e 8b 69 68 c7 44 24 20 00 00 00 00 66 39 ea 0f 84 6c 01 00 00 40 0f b6 cd 0f b7 d9 48 c1 e3 04 49 03 9f e0 02 00 00 4c 8b 33 <41> 8b 86 b8 00 00 00 49 03 86 c0 00 00 00 66 83 78 06 00 0f 85 
RIP  [<ffffffff88084c9a>] :bnx2:bnx2_tx_int+0x6a/0x330
 RSP <ffff81022f8cfd00>
CR2: 00000000000000b8
---[ end trace 7fde2b18cd9ffdbf ]---
Kernel panic - not syncing: Aiee, killing interrupt handler!

-- 
     2. That which causes joy or happiness.
