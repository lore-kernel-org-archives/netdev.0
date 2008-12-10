From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: stability problems with ixgb
Date: Wed, 10 Dec 2008 12:48:39 -0800
Message-ID: <20081210124839.645dd994.akpm@linux-foundation.org>
References: <20081208205250.GH29279@cacr.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jan Lindheim <lindheim@cacr.caltech.edu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081208205250.GH29279@cacr.caltech.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

(cc's added)

On Mon, 8 Dec 2008 12:52:51 -0800
Jan Lindheim <lindheim@cacr.caltech.edu> wrote:

> We have a few large linux file servers, where we have tried to use
> the Intel 10 GigE (PCI-X version) without much success.  We can easily stress
> the network in a way that makes the adapter die in less than an hour.
> Here's the kernel trace from when the adapter dies, using kernel 2.6.27.8:
> 
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950053] WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x1f8/0x210()
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950055] NETDEV WATCHDOG: eth2 (ixgb): transmit timed out
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950057] Modules linked in: nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ppdev video output pci_slot ac sbs sbshc battery ipv6 xfs sbp2 lp cfi_cmdset_0002 cfi_util jedec_probe cfi_probe i2c_nforce2 gen_probe i2c_core psmouse ixgb parport_pc pcspkr k8temp parport ck804xrom shpchp pci_hotplug mtd chipreg map_funcs container button evdev ext3 jbd mbcache sg ide_cd_mod sr_mod cdrom sd_mod sata_nv pata_amd pata_acpi floppy arcmsr ata_generic tg3 libphy libata amd74xx scsi_mod ide_core ohci1394 dock ieee1394 ehci_hcd ohci_hcd usbcore dm_mirror dm_log dm_snapshot dm_mod thermal processor fan fuse
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950106] Pid: 0, comm: swapper Not tainted 2.6.27.8 #2
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950108] 
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950108] Call Trace:
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950111]  <IRQ>  [<ffffffff8023beec>] warn_slowpath+0xbc/0xf0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950120]  [<ffffffff8022d397>] ? source_load+0x37/0x70
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950124]  [<ffffffff80367a69>] ? __next_cpu+0x19/0x30
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950128]  [<ffffffff80230e1a>] ? find_busiest_group+0x19a/0x850
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950131]  [<ffffffff8036d4df>] ? strlcpy+0x4f/0x70
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950135]  [<ffffffff80427670>] ? dev_watchdog+0x0/0x210
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950138]  [<ffffffff80427868>] dev_watchdog+0x1f8/0x210
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950142]  [<ffffffff802467a8>] run_timer_softirq+0x1a8/0x220
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950146]  [<ffffffff8021db39>] ? lapic_next_event+0x9/0x20
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950149]  [<ffffffff80241ce4>] __do_softirq+0x84/0x110
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950153]  [<ffffffff8020d76c>] call_softirq+0x1c/0x30
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950156]  [<ffffffff8020f2ba>] do_softirq+0x6a/0xb0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950158]  [<ffffffff80241c48>] irq_exit+0x98/0xb0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950161]  [<ffffffff8021dfa7>] smp_apic_timer_interrupt+0x87/0xc0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950164]  [<ffffffff8020d1bb>] apic_timer_interrupt+0x6b/0x70
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950166]  <EOI>  [<ffffffff80213a45>] ? default_idle+0x35/0x50
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950173]  [<ffffffff80213a43>] ? default_idle+0x33/0x50
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950175]  [<ffffffff8020aeaf>] ? cpu_idle+0x5f/0xe0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950180]  [<ffffffff8049a885>] ? start_secondary+0x145/0x1a0
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950182] 
> Dec  8 11:48:54 shc-storage02 kernel: [ 3106.950183] ---[ end trace 6be5d7707d0de713 ]---
> 
> Once the adapter stops to respond, the only way to bring it back,
> is to reboot.  Unloading and restarting the kernel module and/or network
> does not help.
> 
> One of the most reliable ways to bring it down, is to run a bonnie++ test from
> 6 clients to the server, over NFS.  Each client has gigabit network.
> 
> This is not a new problem with the latest kernel.  We have also tested with
> 2.6.25.6, which fails the same way.
> 
> Any insight and suggestions to the problem is much appreciated.
> 


------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
