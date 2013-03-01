From: Dave Jones <davej@redhat.com>
Subject: e1000e failed to check map error
Date: Fri, 1 Mar 2013 00:30:07 -0500
Message-ID: <20130301053007.GA14474@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696Ab3CAGX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 01:23:58 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r216Nw9W006307
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 1 Mar 2013 01:23:58 -0500
Received: from gelk.kernelslacker.org (ovpn-113-87.phx2.redhat.com [10.3.113.87])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r215U9Xf015800
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 1 Mar 2013 00:30:14 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r215U8aq018353
	for <netdev@vger.kernel.org>; Fri, 1 Mar 2013 00:30:08 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r215U7FA018349
	for netdev@vger.kernel.org; Fri, 1 Mar 2013 00:30:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus' current tree shows this shortly after boot for me..

WARNING: at lib/dma-debug.c:933 check_unmap+0x407/0x8a0()
Hardware name:         
e1000e 0000:05:00.0: DMA-API: device driver failed to check map error[device address=0x000000005bd70000] [size=1376 bytes] [mapped as page]
Modules linked in:
 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables snd_emu10k1 coretemp snd_hwdep snd_util_mem snd_ac97_codec ac97_bus snd_rawmidi snd_seq snd_seq_device microcode snd_pcm pcspkr snd_page_alloc e1000e snd_timer snd soundcore ptp pps_core vhost_net tun macvtap macvlan kvm_intel kvm nfsd binfmt_misc auth_rpcgss nfs_acl lockd sunrpc btrfs libcrc32c lzo_compress zlib_deflate firewire_ohci ata_piix firewire_core sata_sil crc_itu_t radeon i2c_algo_bit hwmon drm_kms_helper ttm drm i2c_core floppy
Pid: 9, comm: rcuc/0 Not tainted 3.8.0+ #75
Call Trace:
 <IRQ>  [<ffffffff8104abe5>] warn_slowpath_common+0x75/0xa0
 [<ffffffff8104acc6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff8135caf7>] check_unmap+0x407/0x8a0
 [<ffffffff8110457d>] ? call_rcu+0x1d/0x20
 [<ffffffff8135d1ae>] debug_dma_unmap_page+0x5e/0x70
 [<ffffffffa04552f1>] e1000_put_txbuf.isra.33+0x91/0x130 [e1000e]
 [<ffffffffa045546b>] e1000_clean_tx_irq+0xdb/0x320 [e1000e]
 [<ffffffffa045dbe1>] e1000e_poll+0x61/0x320 [e1000e]
 [<ffffffff815677aa>] net_rx_action+0x16a/0x370
 [<ffffffff81054780>] __do_softirq+0xf0/0x410
 [<ffffffff816b3b3c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8100480d>] do_softirq+0x8d/0xc0
 [<ffffffff81102555>] ? rcu_cpu_kthread+0x135/0x5f0
 [<ffffffff81054045>] local_bh_enable+0x105/0x110
 [<ffffffff81102555>] rcu_cpu_kthread+0x135/0x5f0
 [<ffffffff81084730>] smpboot_thread_fn+0x170/0x2e0
 [<ffffffff810845c0>] ? __smpboot_create_thread.part.2+0xe0/0xe0
 [<ffffffff8107a62d>] kthread+0xed/0x100
 [<ffffffff816a7062>] ? wait_for_completion+0xe2/0x110
 [<ffffffff8107a540>] ? kthread_create_on_node+0x160/0x160
 [<ffffffff816b279c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8107a540>] ? kthread_create_on_node+0x160/0x160
---[ end trace 3d84e8d9b678cf33 ]---
Mapped at:
 [<ffffffff8135d269>] debug_dma_map_page+0xa9/0x150
 [<ffffffffa045791c>] e1000_xmit_frame+0x69c/0xf10 [e1000e]
 [<ffffffff81568cf0>] dev_hard_start_xmit+0x260/0x700
 [<ffffffff8158b90e>] sch_direct_xmit+0xfe/0x2a0
 [<ffffffff815693d6>] dev_queue_xmit+0x246/0x970
