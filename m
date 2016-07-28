From: "Alex Lyakas" <alex@zadarastorage.com>
Subject: skb_release_data causes "BUG: Bad page state"
Date: Thu, 28 Jul 2016 13:59:29 +0300
Message-ID: <F75E6D6D22CC4A2993CC5B3BBCA9A9B4@alyakaslap>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38844 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241AbcG1K7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 06:59:33 -0400
Received: by mail-wm0-f46.google.com with SMTP id o80so102094618wme.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 03:59:32 -0700 (PDT)
Received: from alyakaslap (bzq-169-168-31-234.red.bezeqint.net. [31.168.169.234])
        by smtp.gmail.com with ESMTPSA id n131sm39830242wmd.3.2016.07.28.03.59.30
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 03:59:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

We had this warning[1] on long-term mainline kernel 3.18.19. Can anybody 
please advise on what might be causing it.

Thanks,
Alex.

[1]
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.538709] BUG: Bad page state 
in process kworker/0:1H  pfn:4b317
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.539555] 
page:ffffea00012cc5c0 count:0 mapcount:-1 mapping:          (null) index:0x0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.540541] flags: 
0x1ffff0000008000(tail)
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541087] page dumped 
because: nonzero mapcount
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541664] Modules linked in: 
dm_crypt(OE) xfrm_user(E) xfrm4_tunnel(E) tunnel4(E) ipcomp(E) 
xfrm_ipcomp(E) esp4(E) ah4(E) xt_multiport(E) dm_queue_length(E) sd_mod(E) 
bonding(E) ib_iser(OE) rdma_cm(OE) iw_cm(OE) ib_cm(OE) ib_sa(OE) ib_mad(OE) 
ib_core(OE) ib_addr(OE) compat(OE) iscsi_tcp(OE) libiscsi_tcp(OE) 
libiscsi(OE) scsi_transport_iscsi(OE) ipt_MASQUERADE(E) 
nf_nat_masquerade_ipv4(E) iptable_nat(E) nf_nat_ipv4(E) nf_nat(E) 
nf_conntrack_ipv4(E) nf_defrag_ipv4(E) xt_conntrack(E) nf_conntrack(E) 
ipt_REJECT(E) nf_reject_ipv4(E) xt_CHECKSUM(E) iptable_mangle(E) 
xt_tcpudp(E) dm_zcache(OE) bridge(E) stp(E) llc(E) xfs(OE) btrfs(OE) 
ip6table_filter(E) ip6_tables(E) raid456(OE) iptable_filter(E) 
async_raid6_recov(E) async_memcpy(E) async_pq(E) async_xor(E) ip_tables(E) 
x_tables(E) xor(E) async_tx(E) raid6_pq(E) raid1(OE) md_mod(OE) deflate(E) 
ctr(E) twofish_generic(E) twofish_x86_64_3way(E) twofish_x86_64(E) 
twofish_common(E) camellia_generic(E) camellia_x86_64(E) 
serpent_sse2_x86_64(E) xts(E) serpent_generic(E) lrw(E) gf128mul(E) 
glue_helper(E) blowfish_generic(E) blowfish_x86_64(E) blowfish_common(E) 
cast5_generic(E) cast_common(E) ablk_helper(E) cryptd(E) des3_ede_x86_64(E) 
des_generic(E) cmac(E) xcbc(E) rmd160(E) crypto_null(E) af_key(E) 
xfrm_algo(E) iscsi_scst(OE) scst_utgt(OE) scst_vdisk(OE) libcrc32c(E) 
scst(OE) ppdev(E) nls_iso8859_1(E) dm_multipath(OE) kvm(E) scsi_dh(E) 
serio_raw(E) ttm(E) drm_kms_helper(E) drm(E) nfsd(OE) syscopyarea(E) 
auth_rpcgss(E) nfs_acl(E) sysfillrect(E) 8250_fintek(E) sysimgblt(E) nfs(E) 
parport_pc(E) lockd(E) grace(E) i2c_piix4(E) sunrpc(E) fscache(E) 
i6300esb(E) mac_hid(E) lp(E) parport(E) ata_generic(E) pata_acpi(E) 
ata_piix(E) psmouse(E) floppy(E) libata(E) scsi_mod(OE) ixgbevf(OE)
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541736] CPU: 0 PID: 3885 
Comm: kworker/0:1H Tainted: G           OE  3.18.19-zadara05 #1
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541738] Hardware name: 
Bochs Bochs, BIOS Bochs 01/01/2007
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541743] Workqueue: kblockd 
blk_delay_work
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541744]  ffffffff81a79568 
ffff88008fa03c88 ffffffff81710c85 0000000000001fcc
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541747]  ffffea00012cc5c0 
ffff88008fa03cb8 ffffffff8170d7d7 ff0000ffffffffff
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541749]  ffffea00012cc5c0 
0000000000000000 00ffff0000000000 ffff88008fa03d08
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541751] Call Trace:
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541753]  <IRQ> 
[<ffffffff81710c85>] dump_stack+0x4e/0x71
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541759] 
[<ffffffff8170d7d7>] bad_page.part.50+0xe0/0xfe
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541764] 
[<ffffffff81176989>] free_pages_prepare+0x199/0x1b0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541766] 
[<ffffffff81178b0b>] __free_pages_ok+0x1b/0xd0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541768] 
[<ffffffff81178bdb>] free_compound_page+0x1b/0x20
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541770] 
[<ffffffff8170dca7>] __put_compound_page+0x19/0x1d
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541773] 
[<ffffffff8117fdcf>] put_compound_page+0x1bf/0x1e0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541776] 
[<ffffffff8117fe3b>] put_page+0x4b/0x50
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541779] 
[<ffffffff81718fed>] ? reschedule_interrupt+0x6d/0x80
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541782] 
[<ffffffff815fcae7>] skb_release_data+0x87/0xd0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541784] 
[<ffffffff815fcb58>] skb_release_all+0x28/0x30
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541786] 
[<ffffffff815fcf8c>] consume_skb+0x2c/0xa0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541789] 
[<ffffffff8160cfc5>] __dev_kfree_skb_any+0x35/0x40
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541797] 
[<ffffffffc039a3c1>] ixgbevf_poll+0xd1/0x550 [ixgbevf]
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541799] 
[<ffffffff8160e3c2>] net_rx_action+0x152/0x280
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541803] 
[<ffffffff81077025>] __do_softirq+0xf5/0x320
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541805] 
[<ffffffff81077575>] irq_exit+0x115/0x120
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541809] 
[<ffffffff81048895>] smp_call_function_single_interrupt+0x35/0x40
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541811] 
[<ffffffff81718ded>] call_function_single_interrupt+0x6d/0x80
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541812]  <EOI> 
[<ffffffffc03d0047>] ? scsi_host_free_command.isra.10+0x47/0x50 [scsi_mod]
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541824] 
[<ffffffff817173e6>] ? _raw_spin_unlock_irq+0x16/0x50
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541826] 
[<ffffffff81362fa5>] blk_delay_work+0x35/0x40
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541831] 
[<ffffffff8108bd56>] process_one_work+0x146/0x410
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541833] 
[<ffffffff8108c141>] worker_thread+0x121/0x450
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541836] 
[<ffffffff8108c020>] ? process_one_work+0x410/0x410
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541838] 
[<ffffffff810911b9>] kthread+0xc9/0xe0
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541840] 
[<ffffffff810910f0>] ? kthread_create_on_node+0x180/0x180
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541843] 
[<ffffffff81717918>] ret_from_fork+0x58/0x90
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541845] 
[<ffffffff810910f0>] ? kthread_create_on_node+0x180/0x180
Jul 21 22:57:27 vsa-000001cc-vc-1 kernel: [96804.541846] Disabling lock 
debugging due to kernel taint 
