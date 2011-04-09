From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Sat, 9 Apr 2011 16:19:08 +0900
Message-ID: <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
References: <4D9E62D9.5010400@scotdoyle.com>
	<20110408121700.0aad53fe@nehalam>
	<4D9FE5BE.6060600@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Scot Doyle <lkml@scotdoyle.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:47915 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab1DIHTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2011 03:19:17 -0400
Received: by iwn34 with SMTP id 34so4071833iwn.19
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2011 00:19:17 -0700 (PDT)
In-Reply-To: <4D9FE5BE.6060600@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Apr 2011 23:51:10 -0500
Scot Doyle <lkml@scotdoyle.com> wrote:

> On 04/08/2011 02:17 PM, Stephen Hemminger wrote:
> > Please reproduce with exactly 2.6.39-rc2 there were some bug fixes
> > to make sure that header was initialized.
> 
> Hi Stephen, here's another panic with 2.6.39-rc2 (git commit 
> bb3c90f0de7b34995b5e35cf5dc97a3d428b3761) using default kernel config 
> options.
> 
> # sysctl -a | grep bridge
> net.bridge.bridge-nf-call-arptables = 1
> net.bridge.bridge-nf-call-iptables = 1
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-filter-vlan-tagged = 0
> net.bridge.bridge-nf-filter-pppoe-tagged = 0
> 
> # /etc/network/interfaces
> auto lo
> iface lo inet loopback
> auto br0
> iface br0 inet static
>      address x.y.z.237
>      netmask 255.255.255.224
>      gateway x.y.z.225
>      bridge_ports    eth3
>      bridge_stp    off
>      bridge_maxwait    0
>      bridge_fd    0
> auto br0:1
> iface br0:1 inet static
>      address 10.0.0.1
>      netmask 255.255.255.0
> auto br0:2
> iface br0:2 inet static
>      address 10.0.1.1
>      netmask 255.255.255.0
> 
> ------
> 
> [ 1691.681069] BUG: unable to handle kernel NULL pointer dereference at 
> 00000000000000cc
> [ 1691.688879] IP: [<ffffffff8129fb8d>] ip_options_compile+0x1c1/0x435
> [ 1691.695126] PGD 0
> [ 1691.697131] Oops: 0000 [#1] SMP
> [ 1691.700357] last sysfs file: /sys/devices/virtual/misc/kvm/uevent
> [ 1691.706418] CPU 0
> [ 1691.708241] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm 
> snd_timer snd soundcore snd_page_alloc tpm_tis i7core_edac psmouse ghes 
> tpm evdev edac_core pcspkr serio_raw processor tpm_bios button dcdbas 
> thermal_sys hed power_meter ext2 mbcache dm_mod raid1 md_mod sd_mod 
> crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas 
> raid_class ehci_hcd igb scsi_mod usbcore dca bnx2 [last unloaded: 
> scsi_wait_scan]
> [ 1691.745849]
> [ 1691.747330] Pid: 0, comm: swapper Not tainted 2.6.39-rc2+ #3 Dell 
> Inc. PowerEdge R510/0DPRKF
> [ 1691.755752] RIP: 0010:[<ffffffff8129fb8d>]  [<ffffffff8129fb8d>] 
> ip_options_compile+0x1c1/0x435
> [ 1691.764418] RSP: 0018:ffff88042f203af0  EFLAGS: 00010286
> [ 1691.769702] RAX: 0000000000000024 RBX: ffff88041c9fa900 RCX: 
> ffff880403466865
> [ 1691.776800] RDX: 0000000000000027 RSI: 0000000000000000 RDI: 
> ffffffff817e6100
> [ 1691.783899] RBP: ffff880403466863 R08: ffffffffa01ade89 R09: 
> ffff88042f203c58
> [ 1691.790997] R10: ffffe1c4ff103b40 R11: 0000000000000004 R12: 
> ffff88041c9fa928
> [ 1691.798095] R13: 0000000000000027 R14: ffff88040346684e R15: 
> 0000000000000027
> [ 1691.805194] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
> knlGS:0000000000000000
> [ 1691.813245] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1691.818960] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
> 00000000000006f0
> [ 1691.826058] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
> 0000000000000000
> [ 1691.833156] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
> 0000000000000400
> [ 1691.840254] Process swapper (pid: 0, threadinfo ffffffff81600000, 
> task ffffffff8160b020)
> [ 1691.848303] Stack:
> [ 1691.850300]  ffff88042ec02900 ffff8804051ac740 0000000000000000 
> ffffffff817e6100
> [ 1691.857693]  0000000000000282 ffffffff810ec848 0000000000000282 
> ffff88041c9fa928
> [ 1691.865085]  ffff88041c9fa900 ffff8804038e8000 ffff88040346684e 
> ffff8804038e8000
> [ 1691.872480] Call Trace:
> [ 1691.874910] <IRQ>
> [ 1691.877005]  [<ffffffff810ec848>] ? __slab_free+0x80/0x14a
> [ 1691.882465]  [<ffffffffa01b1e3a>] ? br_parse_ip_options+0x133/0x1a0 
> [bridge]
> [ 1691.889480]  [<ffffffffa01b2bd8>] ? br_nf_pre_routing+0x348/0x3cb 
> [bridge]
> [ 1691.896324]  [<ffffffff8119d88f>] ? cpumask_next_and+0x2b/0x3a
> [ 1691.902127]  [<ffffffff81298517>] ? nf_iterate+0x41/0x7e
> [ 1691.907413]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
> [ 1691.913908]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
> [ 1691.920402]  [<ffffffff812985c7>] ? nf_hook_slow+0x73/0x114
> [ 1691.925947]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
> [ 1691.932442]  [<ffffffffa01ade89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
> [ 1691.938937]  [<ffffffffa01ade6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
> [ 1691.945432]  [<ffffffff810ee373>] ? 
> __kmalloc_node_track_caller+0xd4/0x10d
> [ 1691.952274]  [<ffffffffa01ae1e5>] ? br_handle_frame+0x195/0x1ac [bridge]
> [ 1691.958942]  [<ffffffffa01ae050>] ? 
> br_handle_frame_finish+0x1c7/0x1c7 [bridge]
> [ 1691.966217]  [<ffffffff812764df>] ? __netif_receive_skb+0x2a7/0x450
> [ 1691.972452]  [<ffffffff81276918>] ? netif_receive_skb+0x52/0x58
> [ 1691.978340]  [<ffffffff81276e1a>] ? napi_gro_receive+0x1f/0x2f
> [ 1691.984143]  [<ffffffff812769ef>] ? napi_skb_finish+0x1c/0x31
> [ 1691.989862]  [<ffffffffa0226fcd>] ? igb_poll+0x6d9/0x9ee [igb]
> [ 1691.995666]  [<ffffffff8103eb92>] ? try_to_wake_up+0x16a/0x17c
> [ 1692.001470]  [<ffffffff8109034f>] ? handle_irq_event+0x40/0x55
> [ 1692.007275]  [<ffffffff8106fc3c>] ? arch_local_irq_save+0x14/0x1d
> [ 1692.013338]  [<ffffffff81276f45>] ? net_rx_action+0xa4/0x1b1
> [ 1692.018971]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
> [ 1692.024516]  [<ffffffff81333b5c>] ? call_softirq+0x1c/0x30
> [ 1692.029973]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
> [ 1692.035257]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
> [ 1692.040368]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
> [ 1692.045308]  [<ffffffff8132cad3>] ? common_interrupt+0x13/0x13
> [ 1692.051110] <EOI>
> [ 1692.053204]  [<ffffffff81061348>] ? enqueue_hrtimer+0x3f/0x53
> [ 1692.058922]  [<ffffffffa032c417>] ? arch_local_irq_enable+0x7/0x8 
> [processor]
> [ 1692.066021]  [<ffffffffa032cfdf>] ? acpi_idle_enter_bm+0x218/0x250 
> [processor]
> [ 1692.073208]  [<ffffffff8125df49>] ? menu_select+0x169/0x296
> [ 1692.078752]  [<ffffffff8125d059>] ? cpuidle_idle_call+0xf4/0x17e
> [ 1692.084727]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
> [ 1692.089838]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
> [ 1692.095469]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
> [ 1692.101703] Code: 4d 02 3c 03 0f 86 59 02 00 00 0f b6 d0 44 39 ea 7f 
> 32 83 c2 03 44 39 ea 0f 8f 45 02 00 00 48 85 db 74 18 48 8b 74 24 10 0f 
> b6 c0 <8b> 96 cc 00 00 00 89 54 05 ff 41 80 4c 24 08 04 80 01 04 41 80
> [ 1692.121051] RIP  [<ffffffff8129fb8d>] ip_options_compile+0x1c1/0x435
> [ 1692.127382]  RSP <ffff88042f203af0>
> [ 1692.130850] CR2: 00000000000000cc
> [ 1692.134470] ---[ end trace 0afda543b32ed72b ]---

It seems that the bug trap is occurred in ip_options_compile() due to
rt is NULL.

	8b 96 cc 00 00 00       mov    0xcc(%rsi),%edx
rsi is rt, and 0xcc means rt->rt_spec_dst. So I think below code hit
the bug trap.

332	if (skb) {
333		memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4); <- here
334		opt->is_changed = 1;
335	}

And call trace seems as follows. 
  __netif_receive_skb()
    -> br_handle_frame()
         -> NF_HOOK()
              -> br_nf_pre_routing()
                   -> br_parse_ip_options()
                        -> ip_options_compile()

br_parse_ip_options() was introduced at 462fb2a (bridge : Sanitize
skb before it enters the IP stack) but ip_options_compile() or
ip_options_rcv_srr() seems to be called with no rt info.

Thanks.
