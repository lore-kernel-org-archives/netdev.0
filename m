From: Dave Jones <davej@redhat.com>
Subject: e1000e DMA map error [3.8.6]
Date: Fri, 12 Apr 2013 16:33:17 -0400
Message-ID: <20130412203317.GC19797@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755504Ab3DLUdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 16:33:20 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3CKXJBQ004009
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 16:33:19 -0400
Received: from gelk.kernelslacker.org (ovpn-113-30.phx2.redhat.com [10.3.113.30])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r3CKXIgB011853
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 16:33:19 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r3CKXIWK020727
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 16:33:18 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r3CKXHjI020726
	for netdev@vger.kernel.org; Fri, 12 Apr 2013 16:33:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: at lib/dma-debug.c:933 check_unmap+0x407/0x8a0()
e1000e 0000:05:00.0: DMA-API: device driver failed to check map error[device address=0x000000002dcb8530] [size=24 bytes] [mapped as page]
Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_CHECKSUM iptable_mangle tun bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables coretemp kvm_intel snd_emu10k1 kvm snd_util_mem snd_hwdep snd_rawmidi snd_ac97_codec iTCO_wdt ac97_bus iTCO_vendor_support snd_seq snd_seq_device snd_pcm microcode snd_page_alloc snd_timer snd i82975x_edac lpc_ich soundcore emu10k1_gp gameport i2c_i801 e1000e mfd_core edac_core binfmt_misc nfsd auth_rpcgss nfs_acl lockd sunrpc btrfs zlib_deflate libcrc32c firewire_ohci firewire_core sata_sil crc_itu_t radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core
Pid: 0, comm: swapper/0 Not tainted 3.8.6-203.fc18.x86_64.debug #1
Call Trace:
 <IRQ>  [<ffffffff81069a5f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff81069b56>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff81380f67>] check_unmap+0x407/0x8a0
 [<ffffffff8138161e>] debug_dma_unmap_page+0x5e/0x70
 [<ffffffffa0382971>] e1000_put_txbuf.isra.34+0x91/0x130 [e1000e]
 [<ffffffffa0382aeb>] e1000_clean_tx_irq+0xdb/0x320 [e1000e]
 [<ffffffffa0387b31>] e1000e_poll+0x61/0x430 [e1000e]
 [<ffffffff81419145>] ? dma_issue_pending_all+0x5/0x200
 [<ffffffff815dad32>] net_rx_action+0x172/0x380
 [<ffffffff81073720>] __do_softirq+0xf0/0x3d0
 [<ffffffff817272fc>] call_softirq+0x1c/0x30
 [<ffffffff8101c445>] do_softirq+0xa5/0xe0
 [<ffffffff81073bf5>] irq_exit+0xd5/0xe0
 [<ffffffff81727bb3>] do_IRQ+0x63/0xe0
 [<ffffffff8171ce32>] common_interrupt+0x72/0x72
 <EOI>  [<ffffffff810d4b7c>] ? tick_nohz_idle_exit+0x14c/0x1c0
 [<ffffffff810d4b80>] ? tick_nohz_idle_exit+0x150/0x1c0
 [<ffffffff810d4b7c>] ? tick_nohz_idle_exit+0x14c/0x1c0
 [<ffffffff81024525>] cpu_idle+0x125/0x140
 [<ffffffff816fcc59>] rest_init+0x149/0x150
 [<ffffffff816fcb15>] ? rest_init+0x5/0x150
 [<ffffffff81ee3c77>] start_kernel+0x408/0x415
 [<ffffffff81ee366e>] ? repair_env_string+0x5e/0x5e
 [<ffffffff81ee3356>] x86_64_start_reservations+0x131/0x135
 [<ffffffff81ee345a>] x86_64_start_kernel+0x100/0x10f
---[ end trace e302d171bf270f8f ]---
Mapped at:
 [<ffffffff813816d9>] debug_dma_map_page+0xa9/0x150
 [<ffffffffa0384dac>] e1000_xmit_frame+0x69c/0xeb0 [e1000e]
 [<ffffffff815db9e0>] dev_hard_start_xmit+0x250/0x6e0
 [<ffffffff815fd8fe>] sch_direct_xmit+0xfe/0x2a0
 [<ffffffff815dc5d0>] dev_queue_xmit+0x1f0/0x920
