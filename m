From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Wed, 22 Dec 2010 00:22:15 -0800
Message-ID: <20101222002215.fb0bfe95.akpm@linux-foundation.org>
References: <4D0C9BFA.4080003@scarlet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Joel Soete <soete.joel@scarlet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D0C9BFA.4080003@scarlet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc netdev)

The bug is still present in 2.6.37-rc6.

On Sat, 18 Dec 2010 11:33:14 +0000 Joel Soete <soete.joel@scarlet.be> wrote:

> Hello all,
> 
> Since a year now, I installed my favorite Debian testing on my new X86_64 platform on which I like to run my personal kernel 
> config. And all was working fine since 2.6.35 was released.
> 
> The first time I experiment this issue, it was during a test of Ubuntu upgrade to the latest release 10.10 against which I 
> open this bug report <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/618636>: in short the system panicing on first 
> connection to my ISP.
> 
> This still occurs to me on the latest ubuntu stock linux image 2.6.35 as well as on my personal config from vanilla sources.
> 
> As in general this kind of problem is quickly identified and solved, I do some more test with 2.6.36 and even 2.6.37-rc? 
> releases, in smp or up config, with or without netfilter, with or without foreign nvidia graphical driver but this issue is 
> still there for me?
> 
> Obviously, I also do some researches with google but without a lot of success. So I try to figure out when this pb appears 
> in the development history and find out that it was already in 2.6.35-rc1. So I do more kind of rewind in time and all was 
> working fine since 2.6.34-git5 but problems appears in 2.6.34-git[67]. For my pppoe issue, there are few changes that I 
> tried to revert without success?
> 
> The latest related stuff I can discovered is this regression report 2.6.35 -> 2.6.36 
> <http://www.spinics.net/lists/netdev/msg145824.html> and the debugging patch proposed by Jarek Poplawski effectively drops 
> the ppp interface but the system doesn't panic any more, so can I get following kernel log:
> Dec 17 17:26:53 sidh2 kernel: [   25.941424] eth1: Link up
> Dec 17 17:26:53 sidh2 kernel: [   25.941736] eth1: Link changed: 10Mbps, half duplex
> Dec 17 17:26:53 sidh2 kernel: [   26.266657] r8169 0000:08:00.0: eth0: link up
> Dec 17 17:26:53 sidh2 kernel: [   26.266662] r8169 0000:08:00.0: eth0: link up
> Dec 17 17:26:53 sidh2 kernel: [   26.829432] ip_tables: (C) 2000-2006 Netfilter Core Team
> Dec 17 17:26:58 sidh2 kernel: [   33.017352] ppdev: user-space parallel port driver
> Dec 17 17:27:04 sidh2 kernel: [   36.357885] eth0: no IPv6 routers present
> Dec 17 17:27:04 sidh2 kernel: [   36.517833] eth1: no IPv6 routers present
> Dec 17 17:28:12 sidh2 kernel: [  106.511762] BUG: unable to handle kernel NULL pointer dereference at (null)
> Dec 17 17:28:12 sidh2 kernel: [  106.511952] IP: [<ffffffff810e405b>] put_page+0x1b/0x180
> Dec 17 17:28:12 sidh2 kernel: [  106.512078] PGD 13c6f0067 PUD 134283067 PMD 0
> Dec 17 17:28:12 sidh2 kernel: [  106.512293] Oops: 0000 [#1] SMP
> Dec 17 17:28:12 sidh2 kernel: [  106.512456] last sysfs file: /sys/devices/virtual/sound/timer/uevent
> Dec 17 17:28:12 sidh2 kernel: [  106.512533] CPU 4
> Dec 17 17:28:12 sidh2 kernel: [  106.512584] Modules linked in: ppdev xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle ip_tables 
> x_tables lp nvidia(P) parport_pc parport agpgart i7core_edac edac_core tpm_tis tpm tpm_bios [last unloaded: scsi_wait_scan]
> Dec 17 17:28:12 sidh2 kernel: [  106.513674]
> Dec 17 17:28:12 sidh2 kernel: [  106.513742] Pid: 1821, comm: pppd Tainted: P            2.6.35-amd64-t3 #5 EX58-UD3R/EX58-UD3R
> Dec 17 17:28:12 sidh2 kernel: [  106.513838] RIP: 0010:[<ffffffff810e405b>]  [<ffffffff810e405b>] put_page+0x1b/0x180
> Dec 17 17:28:12 sidh2 kernel: [  106.513982] RSP: 0018:ffff88013cecfe08  EFLAGS: 00010292
> Dec 17 17:28:12 sidh2 kernel: [  106.514056] RAX: 0000000000000030 RBX: 0000000000000000 RCX: 0000000000001733
> Dec 17 17:28:12 sidh2 kernel: [  106.514134] RDX: ffff88013c906640 RSI: ffff88013c906060 RDI: 0000000000000000
> Dec 17 17:28:12 sidh2 kernel: [  106.514211] RBP: ffff88013c86e900 R08: ffffffff81342b90 R09: 00000000ffe22e08
> Dec 17 17:28:12 sidh2 kernel: [  106.514288] R10: ffff88013cece000 R11: 0000000000000000 R12: 00000000080d5f42
> Dec 17 17:28:12 sidh2 kernel: [  106.514366] R13: ffff88013c86f400 R14: 000000000000000a R15: 00000000000005de
> Dec 17 17:28:12 sidh2 kernel: [  106.514444] FS:  0000000000000000(0000) GS:ffff880001f00000(0063) knlGS:00000000f75f5b20
> Dec 17 17:28:12 sidh2 kernel: [  106.514539] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> Dec 17 17:28:12 sidh2 kernel: [  106.514614] CR2: 0000000000000000 CR3: 000000013c758000 CR4: 00000000000006e0
> Dec 17 17:28:12 sidh2 kernel: [  106.514692] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Dec 17 17:28:12 sidh2 kernel: [  106.514769] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Dec 17 17:28:12 sidh2 kernel: [  106.514847] Process pppd (pid: 1821, threadinfo ffff88013cece000, task ffff88013c7ea120)
> Dec 17 17:28:12 sidh2 kernel: [  106.514941] Stack:
> Dec 17 17:28:12 sidh2 kernel: [  106.515008]  0000000000000000 0000000000000001 ffff88013c86e900 00000000080d5f42
> Dec 17 17:28:12 sidh2 kernel: [  106.515227] <0> ffff88013c86f400 ffffffff814288b7 ffff88013c523c00 ffff88013c86e900
> Dec 17 17:28:12 sidh2 kernel: [  106.515556] <0> ffff88013c523c00 ffffffff814283c1 ffff88013c86e900 ffffffff81342d1c
> Dec 17 17:28:12 sidh2 kernel: [  106.515948] Call Trace:
> Dec 17 17:28:12 sidh2 kernel: [  106.516022]  [<ffffffff814288b7>] ? skb_release_data+0x77/0xd0
> Dec 17 17:28:12 sidh2 kernel: [  106.516099]  [<ffffffff814283c1>] ? __kfree_skb+0x11/0x90
> Dec 17 17:28:12 sidh2 kernel: [  106.516176]  [<ffffffff81342d1c>] ? ppp_read+0x18c/0x210
> Dec 17 17:28:12 sidh2 kernel: [  106.516252]  [<ffffffff8104df70>] ? default_wake_function+0x0/0x20
> Dec 17 17:28:12 sidh2 kernel: [  106.516329]  [<ffffffff8111f905>] ? vfs_read+0xb5/0x1a0
> Dec 17 17:28:12 sidh2 kernel: [  106.516404]  [<ffffffff8111fa3e>] ? sys_read+0x4e/0x90
> Dec 17 17:28:12 sidh2 kernel: [  106.516479]  [<ffffffff810996ff>] ? compat_sys_gettimeofday+0x9f/0xb0
> Dec 17 17:28:12 sidh2 kernel: [  106.516558]  [<ffffffff8103eb8f>] ? sysenter_dispatch+0x7/0x2e
> Dec 17 17:28:12 sidh2 kernel: [  106.516632] Code: cc bb f8 ff 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 28 48 89 5c 24 
> 08 48 89 6c 24 10 48 89 fb 4c 89 64 24 18 4c 89 6c 24 20 <48> 8b 07 66 a9 00 c0 0f 85 13 01 00 00 f0 ff 4f 08 0f 94 c0 84
> Dec 17 17:28:12 sidh2 kernel: [  106.519823] RIP  [<ffffffff810e405b>] put_page+0x1b/0x180
> Dec 17 17:28:12 sidh2 kernel: [  106.519945]  RSP <ffff88013cecfe08>
> Dec 17 17:28:12 sidh2 kernel: [  106.520015] CR2: 0000000000000000
> Dec 17 17:28:12 sidh2 kernel: [  106.520093] ---[ end trace bac76655d5f488ec ]---
> 
> 
> Sorry but I don't have enough knowledge to understand this pb, so all help will be appreciated.
> 
> Tia,
> 	J.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
