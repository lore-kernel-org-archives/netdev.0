From: David Miller <davem@davemloft.net>
Subject: Re: kernel oops when system under network stress
Date: Wed, 15 Oct 2008 21:55:36 -0700 (PDT)
Message-ID: <20081015.215536.242281148.davem@davemloft.net>
References: <20081016030416.GA5551@samad.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: alex@samad.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40860
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbYJPE4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 00:56:00 -0400
In-Reply-To: <20081016030416.GA5551@samad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Samad <alex@samad.com.au>
Date: Thu, 16 Oct 2008 14:04:16 +1100

[ Kernel network developers don't read linux-net, which is for
  user discussion.  They read netdev@vger.kernel.org instead
  which I've added to the CC:, please maintain this in all
  follow ups and replys. ]

> I seems to be getting lots of crashes when my system is under network
> load, I was moving 1/4T of data over a 1G link and I got lots and lots
> of these

What kernel version?

How is your system configured?

Otherwise it is harder for us to analyze this report.

Thanks.

[ Herbert, this looks like another case like that ebtables+tg3 one,
  where the checksum field is not set properly. ]

> [16877.745063] ------------[ cut here ]------------
> [16877.745070] WARNING: at net/core/dev.c:1451 skb_gso_segment+0x88/0x1af()
>
> [16877.745076] Modules linked in: forcedeth vboxdrv nfsd lockd
> nfs_acl auth_rpcgss sunrpc exportfs ip6table_mangle ip6t_frag
> ip6t_LOG ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
> iptable_mangle iptable_nat nf_nat xt_pkttype ipt_ULOG ipt_REJECT
> xt_limit xt_tcpudp nf_conntrack_ipv4 xt_state nf_conntrack
> iptable_filter ip_tables x_tables ppdev parport_pc lp parport video
> output ac battery powernow_k8 cpufreq_powersave cpufreq_conservative
> cpufreq_ondemand cpufreq_stats freq_table cpufreq_userspace bridge
> xfs ext2 fuse ipv6 sbp2 loop serio_raw pcspkr snd_hda_intel psmouse
> snd_pcm snd_timer snd soundcore snd_page_alloc shpchp pci_hotplug
> wmi button evdev ext3 jbd mbcache dm_mirror dm_log dm_snapshot
> dm_mod raid456 async_xor async_memcpy async_tx xor raid1 md_mod sg
> sr_mod cdrom sd_mod ata_generic amd74xx ohci1394 sata_sil ieee1394
> ahci sata_mv libata scsi_mod dock ide_pci_generic ide_core ohci_hcd
> ehci_hcd thermal processor fan thermal_sys [last unloaded:
> forcedeth]
>
> [16877.745371] Pid: 9602, comm: apache2 Tainted: G        W 2.6.26-1-amd64 #1
> [16877.745377] 
> [16877.745378] Call Trace:
> [16877.745383]  <IRQ>  [<ffffffff80234878>] warn_on_slowpath+0x51/0x7a
> [16877.745429]  [<ffffffffa0406d1c>] :nf_conntrack:nf_ct_deliver_cached_events+0x4c/0x7c
> [16877.745444]  [<ffffffffa044753f>] :nf_conntrack_ipv6:ipv6_confirm+0xd9/0xee
> [16877.745463]  [<ffffffff804192c1>] packet_rcv+0x31a/0x32b
> [16877.745472]  [<ffffffff803ba77e>] skb_gso_segment+0x88/0x1af
> [16877.745483]  [<ffffffff803baa24>] dev_hard_start_xmit+0x17f/0x24e
> [16877.745495]  [<ffffffff803bcfdd>] dev_queue_xmit+0x1f0/0x2b3
> [16877.745539]  [<ffffffffa02b6d58>] :ipv6:ip6_output+0xc11/0xc37
> [16877.745579]  [<ffffffffa02b5838>] :ipv6:dst_output+0x0/0xb
> [16877.745591]  [<ffffffff803d420d>] nf_hook_slow+0x5d/0xbe
> [16877.745631]  [<ffffffffa02b5838>] :ipv6:dst_output+0x0/0xb
> [16877.745684]  [<ffffffffa02b8905>] :ipv6:ip6_xmit+0x35c/0x44f
> [16877.745742]  [<ffffffffa02d964c>] :ipv6:inet6_csk_xmit+0x219/0x235
> [16877.745776]  [<ffffffff803edb30>] tcp_transmit_skb+0x731/0x76e
> [16877.745793]  [<ffffffff803eed27>] tso_fragment+0xef/0x13b
> [16877.745808]  [<ffffffff803ef449>] __tcp_push_pending_frames+0x6d6/0x7a9
> [16877.745827]  [<ffffffff803ecb0f>] tcp_rcv_established+0x80f/0x8b4
> [16877.745878]  [<ffffffffa02d332d>] :ipv6:tcp_v6_do_rcv+0x626/0x8ff
> [16877.745916]  [<ffffffffa0406d1c>] :nf_conntrack:nf_ct_deliver_cached_events+0x4c/0x7c
> [16877.745933]  [<ffffffffa044753f>] :nf_conntrack_ipv6:ipv6_confirm+0xd9/0xee
> [16877.745947]  [<ffffffff803d4174>] nf_iterate+0x41/0x7d
> [16877.745957]  [<ffffffff80416b6c>] __inet6_lookup_established+0xed/0x258
> [16877.746008]  [<ffffffffa02d5b37>] :ipv6:tcp_v6_rcv+0x638/0x685
> [16877.746059]  [<ffffffffa02b8bcd>] :ipv6:ip6_input_finish+0x1d5/0x34c
> [16877.746107]  [<ffffffffa02b929b>] :ipv6:ipv6_rcv+0x32d/0x38e
> [16877.746135]  [<ffffffffa0393808>] :bridge:br_handle_frame_finish+0x107/0x13e
> [16877.746160]  [<ffffffffa0396ff0>] :bridge:br_nf_pre_routing_finish_ipv6+0xaa/0xb0
> [16877.746183]  [<ffffffffa0397c6f>] :bridge:br_nf_pre_routing+0x38a/0x617
> [16877.746197]  [<ffffffff803d4174>] nf_iterate+0x41/0x7d
> [16877.746217]  [<ffffffffa0393701>] :bridge:br_handle_frame_finish+0x0/0x13e
> [16877.746229]  [<ffffffff803d420d>] nf_hook_slow+0x5d/0xbe
> [16877.746245]  [<ffffffffa0393701>] :bridge:br_handle_frame_finish+0x0/0x13e
> [16877.746272]  [<ffffffffa03939e3>] :bridge:br_handle_frame+0x1a4/0x1c9
> [16877.746288]  [<ffffffff803ba364>] netif_receive_skb+0x29f/0x3b8
> [16877.746294]  [<ffffffff803b5b44>] __alloc_skb+0x7f/0x12d
> [16877.746308]  [<ffffffff803bcb3a>] process_backlog+0x86/0xef
> [16877.746314]  [<ffffffff803b5ea6>] dev_alloc_skb+0x16/0x2d
> [16877.746328]  [<ffffffff803bc3a7>] net_rx_action+0xab/0x1da
> [16877.746343]  [<ffffffff8023922f>] __do_softirq+0x5c/0xd1
> [16877.746355]  [<ffffffff8020d29c>] call_softirq+0x1c/0x28
> [16877.746366]  [<ffffffff8020f37c>] do_softirq+0x3c/0x81
> [16877.746374]  [<ffffffff8023918f>] irq_exit+0x3f/0x83
> [16877.746382]  [<ffffffff8020f5dc>] do_IRQ+0xb9/0xd9
> [16877.746392]  [<ffffffff8020c43d>] ret_from_intr+0x0/0x19
> [16877.746398]  <EOI> 
> [16877.746421] ---[ end trace 690e809cf8d0fba8 ]---
> [16877.746835] ------------[ cut here ]------------
> [16877.746842] WARNING: at net/core/dev.c:1451 skb_gso_segment+0x88/0x1af()
>
> [16877.746848] Modules linked in: forcedeth vboxdrv nfsd lockd
nfs_acl auth_rpcgss sunrpc exportfs ip6table_mangle ip6t_frag ip6t_LOG
ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
iptable_mangle iptable_nat nf_nat xt_pkttype ipt_ULOG ipt_REJECT
xt_limit xt_tcpudp nf_conntrack_ipv4 xt_state nf_conntrack
iptable_filter ip_tables x_tables ppdev parport_pc lp parport video
output ac battery powernow_k8 cpufreq_powersave cpufreq_conservative
cpufreq_ondemand cpufreq_stats freq_table cpufreq_userspace bridge xfs
ext2 fuse ipv6 sbp2 loop serio_raw pcspkr snd_hda_intel psmouse
snd_pcm snd_timer snd soundcore snd_page_alloc shpchp pci_hotplug wmi
button evdev ext3 jbd mbcache dm_mirror dm_log dm_snapshot dm_mod
raid456 async_xor async_memcpy async_tx xor raid1 md_mod sg sr_mod
cdrom sd_mod ata_generic amd74xx ohci1394 sata_sil ieee1394 ahci
sata_mv libata scsi_mod dock ide_pci_generic ide_core ohci_hcd
ehci_hcd thermal processor fan thermal_sys [last unloaded: forcedeth]
>
> [16877.747144] Pid: 9602, comm: apache2 Tainted: G        W 2.6.26-1-amd64 #1
> [16877.747150] 
> [16877.747151] Call Trace:
> [16877.747162]  [<ffffffff80234878>] warn_on_slowpath+0x51/0x7a
> [16877.747199]  [<ffffffffa0406d1c>] :nf_conntrack:nf_ct_deliver_cached_events+0x4c/0x7c
> [16877.747213]  [<ffffffffa044753f>] :nf_conntrack_ipv6:ipv6_confirm+0xd9/0xee
> [16877.747232]  [<ffffffff804192c1>] packet_rcv+0x31a/0x32b
> [16877.747240]  [<ffffffff803ba77e>] skb_gso_segment+0x88/0x1af
> [16877.747251]  [<ffffffff803baa24>] dev_hard_start_xmit+0x17f/0x24e
> [16877.747263]  [<ffffffff803bcfdd>] dev_queue_xmit+0x1f0/0x2b3
> [16877.747307]  [<ffffffffa02b6d58>] :ipv6:ip6_output+0xc11/0xc37
> [16877.747345]  [<ffffffffa02b5838>] :ipv6:dst_output+0x0/0xb
> [16877.747358]  [<ffffffff803d420d>] nf_hook_slow+0x5d/0xbe
> [16877.747397]  [<ffffffffa02b5838>] :ipv6:dst_output+0x0/0xb
> [16877.747450]  [<ffffffffa02b8905>] :ipv6:ip6_xmit+0x35c/0x44f
> [16877.748991]  [<ffffffffa02d964c>] :ipv6:inet6_csk_xmit+0x219/0x235
> [16877.748991]  [<ffffffff803edb30>] tcp_transmit_skb+0x731/0x76e
> [16877.748991]  [<ffffffff803eed27>] tso_fragment+0xef/0x13b
> [16877.748991]  [<ffffffff803ef449>] __tcp_push_pending_frames+0x6d6/0x7a9
> [16877.748991]  [<ffffffff803e4b56>] tcp_sendmsg+0x8bb/0x9d3
> [16877.748991]  [<ffffffff803af30f>] sock_aio_write+0xf8/0x110
> [16877.748991]  [<ffffffff803af217>] sock_aio_write+0x0/0x110
> [16877.748991]  [<ffffffff8029a923>] do_sync_readv_writev+0xc0/0x107
> [16877.748991]  [<ffffffff80246021>] autoremove_wake_function+0x0/0x2e
> [16877.748991]  [<ffffffff80281613>] handle_mm_fault+0x3f4/0x867
> [16877.748991]  [<ffffffff8029a7b9>] rw_copy_check_uvector+0x6c/0xdc
> [16877.748991]  [<ffffffff8029afd6>] do_readv_writev+0xb2/0x18b
> [16877.748991]  [<ffffffff80221f78>] do_page_fault+0x5d8/0x9c8
> [16877.748991]  [<ffffffff80285652>] do_mmap_pgoff+0x2ff/0x364
> [16877.748991]  [<ffffffff8029b50b>] sys_writev+0x45/0x93
> [16877.748991]  [<ffffffff8020be9a>] system_call_after_swapgs+0x8a/0x8f
> [16877.748991] 
> [16877.748991] ---[ end trace 690e809cf8d0fba8 ]---
> 
> 
> These are just 2, I have a file with lots more that i can send to
> somebody if it would help.
> 
> Is this a bug or ?
> 
> I am running debian 2.6.26-8 
> Linux max 2.6.26-1-amd64 #1 SMP Thu Oct 9 14:16:53 UTC 2008 x86_64
> GNU/Linux
> 
> 
> I have eth0 bridges to brhme1 (so that I can attach virtual box machines
> there - none attached currently)
> 
> and I have some firewall rules as well.  That really about it to the
> changes I have made
> 
> 
> 
> Thanks
> Alex 
> 
> PS can you cc me on the replay, in the process of registering
> 
> 
> -- 
> "Columbia carried in its payroll classroom experiments from some of our students in America."
> 
> 	- George W. Bush
> 02/03/2003
> Bethesda, MD
