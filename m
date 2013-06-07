From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Fri, 7 Jun 2013 17:46:35 +0200
Message-ID: <20130607154634.GA7529@uio.no>
References: <20130606221656.GA11475@uio.no>
 <20130607030648.GA28618@home.goodmis.org>
 <20130607085421.GF15083@uio.no>
 <1370612441.24311.411.camel@edumazet-glaptop>
 <1370618100.9844.73.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370618100.9844.73.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 11:15:00AM -0400, Steven Rostedt wrote:
> net: Remove __net_init/exit from exported functions
> 
> If CONFIG_NET_NS is not set then __net_init is the same as __init and
> __net_exit is the same as __exit. These functions will be removed from
> memory after the module loads or is removed. Functions that are exported
> for use by other functions should never be labeled for removal.

That didn't help much, I'm afraid:

[   18.005451] BUG: unable to handle kernel NULL pointer dereference at 0000000000000003
[   18.013853] IP: [<ffffffffa0e76002>] 0xffffffffa0e76001
[   18.019380] PGD 0 
[   18.021695] Oops: 0000 [#1] SMP 
[   18.025285] Modules linked in: ip_gre(+) gre ip_tunnel psmouse ide_generic ide_gd_mod ide_cd_mod cdrom acpi_cpufreq mperf coretemp kvm_intel kvm iTCO_wdt iTCO_vendor_support lpc_ich microcode mfd_core i2c_i801 pcspkr i2c_core ehci_pci evbug evdev ext4 crc16 jbd2 mbcache dm_mod raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq raid1 md_mod sg sd_mod usbhid ide_pci_generic ide_core crc32c_intel e1000e ata_piix ptp pps_core uhci_hcd ehci_hcd mpt2sas raid_class unix
[   18.073543] CPU: 0 PID: 3263 Comm: modprobe Not tainted 3.10.0-rc4 #2
[   18.080237] Hardware name: Supermicro X8DTL/X8DTL, BIOS 2.1a       12/30/2011
[   18.087634] task: ffff88061ecfad60 ti: ffff8806212f0000 task.ti: ffff8806212f0000
[   18.095571] RIP: 0010:[<ffffffffa0e76002>]  [<ffffffffa0e76002>] 0xffffffffa0e76001
[   18.103745] RSP: 0018:ffff8806212f1ca8  EFLAGS: 00010246
[   18.109301] RAX: ffffffffa0e81000 RBX: ffff880623ebe280 RCX: 0000000000000000
[   18.116682] RDX: ffffffffa0e7ea40 RSI: 0000000000000003 RDI: ffffffffa0e81018
[   18.124063] RBP: ffff8806212f1ca8 R08: 0000000000000cf8 R09: ffffffff812bae96
[   18.131441] R10: ffffea0018852c00 R11: 0000000000000000 R12: ffff880621678290
[   18.138829] R13: ffffffffa0e7e9c0 R14: ffff8806212f1ef8 R15: 0000000000000002
[   18.146210] FS:  00007f2e37fd1700(0000) GS:ffff880627200000(0000) knlGS:0000000000000000
[   18.154747] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   18.160742] CR2: 0000000000000003 CR3: 0000000622a5e000 CR4: 00000000000007f0
[   18.168131] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   18.175510] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   18.182890] Stack:
[   18.185143]  ffff8806212f1cf8 ffffffff812baf26 2222222222222222 2222222222222222
[   18.193235]  2222222222222222 ffffffffa0e7e9c0 0000000000000000 0000000000000000
[   18.201313]  ffff8806212f1ef8 ffffffffa0e7eb60 ffff8806212f1d28 ffffffff812bafb6
[   18.209389] Call Trace:
[   18.212084]  [<ffffffff812baf26>] ops_init.constprop.7+0xc6/0xf5
[   18.218339]  [<ffffffff812bafb6>] register_pernet_operations.isra.4+0x61/0x91
[   18.225720]  [<ffffffff8138486f>] ? mutex_lock+0xf/0x20
[   18.231189]  [<ffffffff812bb006>] register_pernet_device+0x20/0x51
[   18.237621]  [<ffffffffa0e81034>] ? ipgre_tap_init_net+0x1a/0x1a [ip_gre]
[   18.244661]  [<ffffffffa0e81055>] ipgre_init+0x21/0xc9 [ip_gre]
[   18.250831]  [<ffffffffa0e81034>] ? ipgre_tap_init_net+0x1a/0x1a [ip_gre]
[   18.257866]  [<ffffffff81000263>] do_one_initcall+0x7b/0x10c
[   18.263780]  [<ffffffff8107e5db>] load_module+0x1b1f/0x1e19
[   18.269594]  [<ffffffff8107a4f8>] ? sys_getegid16+0x44/0x44
[   18.275416]  [<ffffffff81386cf2>] ? page_fault+0x22/0x30
[   18.280972]  [<ffffffff8107e969>] SyS_init_module+0x94/0xa1
[   18.286795]  [<ffffffff8138cf12>] system_call_fastpath+0x16/0x1b
[   18.293051] Code: <6e> 65 77 6c 69 6e 6b 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
[   18.302807] RIP  [<ffffffffa0e76002>] 0xffffffffa0e76001
[   18.308429]  RSP <ffff8806212f1ca8>
[   18.312163] CR2: 0000000000000003
[   18.316021] ---[ end trace 839c6b43b00f02f5 ]---

and still:

Ffffffffa0e76000 u ip_tunnel_init_net   [ip_gre]

I've checked that ip_tunnel.ko and ip_gre.ko was indeed rebuilt (new timestamps),
and that my patching (I had to resolve manually due to fuzz) really removed __net_init.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
