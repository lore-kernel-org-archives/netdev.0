From: Honggang LI <honli@redhat.com>
Subject: [PATCH] IB/IPoIB: Check the headroom size
Date: Tue, 25 Apr 2017 17:55:55 +0800
Message-ID: <1493114155-12101-1-git-send-email-honli@redhat.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Honggang Li <honli@redhat.com>
To: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, pabeni@redhat.com,
        linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Honggang Li <honli@redhat.com>

Minimal hard_header_len set by bond_compute_features is ETH_HLEN, which
is smaller than IPOIB_HARD_LEN. ipoib_hard_header should check the
size of headroom to avoid skb_under_panic.

[  122.871493] ipoib_hard_header: skb->head= ffff8808179d9400, skb->data= ffff8808179d9420, skb_headroom= 0x20
[  123.055400] bond0: Releasing backup interface mthca_ib1
[  123.560529] bond_compute_features:1112 bond0 bond_dev->hard_header_len = 14
[  123.568822] CPU: 0 PID: 12336 Comm: ifdown-ib Not tainted 4.9.0-debug #1
[  123.576668] Hardware name: Dell Inc. PowerEdge R415/0GXH08, BIOS 2.0.2 10/22/2012
[  123.585284]  ffffc90009027be8 ffffffff81362d6c ffff8808198b7000 0000000000010000
[  123.593845]  ffffc90009027c50 ffffffffa06cf833 ffff8808198b7000 ffff8808198b78c0
[  123.602392]  ffffc90009027c30 ffffffff815ed725 ffff8808158a9c00 00000000a67486bf
[  123.610926] Call Trace:
[  123.614454]  [<ffffffff81362d6c>] dump_stack+0x63/0x87
[  123.620661]  [<ffffffffa06cf833>] bond_compute_features.isra.42+0x243/0x260 [bonding]
[  123.629546]  [<ffffffff815ed725>] ? call_netdevice_notifiers_info+0x35/0x60
[  123.637557]  [<ffffffffa06d3a7b>] __bond_release_one+0x2db/0x530 [bonding]
[  123.645483]  [<ffffffffa06d3ce0>] bond_release+0x10/0x20 [bonding]
[  123.652711]  [<ffffffffa06de038>] bond_option_slaves_set+0xe8/0x130 [bonding]
[  123.660874]  [<ffffffffa06df336>] __bond_opt_set+0xd6/0x320 [bonding]
[  123.668357]  [<ffffffffa06df5d6>] bond_opt_tryset_rtnl+0x56/0xa0 [bonding]
[  123.676284]  [<ffffffffa06dbba5>] bonding_sysfs_store_option+0x35/0x60 [bonding]
[  123.684748]  [<ffffffff814b0bd8>] dev_attr_store+0x18/0x30
[  123.691311]  [<ffffffff812b6c5a>] sysfs_kf_write+0x3a/0x50
[  123.697879]  [<ffffffff812b678b>] kernfs_fop_write+0x10b/0x190
[  123.704801]  [<ffffffff81231647>] __vfs_write+0x37/0x160
[  123.711213]  [<ffffffff812f0235>] ? selinux_file_permission+0xe5/0x120
[  123.718856]  [<ffffffff812e5a8b>] ? security_file_permission+0x3b/0xc0
[  123.726506]  [<ffffffff81231d72>] vfs_write+0xb2/0x1b0
[  123.732776]  [<ffffffff81003510>] ? syscall_trace_enter+0x1d0/0x2b0
[  123.740148]  [<ffffffff812331c5>] SyS_write+0x55/0xc0
[  123.746288]  [<ffffffff81003a47>] do_syscall_64+0x67/0x180
[  123.752846]  [<ffffffff8170f7ab>] entry_SYSCALL64_slow_path+0x25/0x25
[  123.760421] bond0: last VLAN challenged slave mthca_ib1 left bond bond0 - VLAN blocking is removed
[  124.023489] dump_LL_RESERVED_SPACE, bond0, dev->hard_header_len = 0xe, dev->needed_headroom= 0x0, HH_DATA_MOD= 0x10
[  124.023490] dump_LL_RESERVED_SPACE, bond0, LL_RESERVED_SPACE(dev) = 0x10
[  124.023491] dump_LL_RESERVED_SPACE, bond0, dev->hard_header_len = 0xe, dev->needed_headroom= 0x0, HH_DATA_MOD= 0x10
[  124.023492] dump_LL_RESERVED_SPACE, bond0, LL_RESERVED_SPACE(dev) = 0x10
[  124.023494] arp_create:547 skb->head= ffff8808179dac00, skb->data= ffff8808179dac00, skb_headroom= 0x0, <NULL>
[  124.023495] arp_create:549 skb->head= ffff8808179dac00, skb->data= ffff8808179dac10, skb_headroom= 0x10, <NULL>
[  124.023496] arp_create:551 skb->head= ffff8808179dac00, skb->data= ffff8808179dac10, skb_headroom= 0x10, <NULL>
[  124.023497] arp_create:553 skb->head= ffff8808179dac00, skb->data= ffff8808179dac10, skb_headroom= 0x10, <NULL>
[  124.023498] arp_create:564 skb->head= ffff8808179dac00, skb->data= ffff8808179dac10, skb_headroom= 0x10, bond0
[  124.023500] ipoib_hard_header: skb->head= ffff8808179dac00, skb->data= ffff8808179dac10, skb_headroom= 0x10
[  124.023502] skbuff: skb_under_panic: text:ffffffffa040f6a9 len:80 put:20 head:ffff8808179dac00 data:ffff8808179dabf8 tail:0x48 end:0xc0 dev:bond0
[  124.023536] ------------[ cut here ]------------
[  124.023537] kernel BUG at net/core/skbuff.c:105!
[  124.023539] invalid opcode: 0000 [#1] SMP
[  124.023563] Modules linked in: bonding amd64_edac_mod edac_mce_amd edac_core kvm_amd kvm ib_mthca ipmi_ssif ipmi_devintf irqbypass ipmi_si dcdbas acpi_power_meter sp5100_tco ipmi_msghandler sg pcspkr i2c_piix4 k10temp shpchp acpi_cpufreq rpcrdma ib_isert iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi ib_srpt target_core_mod ib_srp scsi_transport_srp ib_ipoib nfsd rdma_ucm auth_rpcgss ib_ucm nfs_acl ib_uverbs lockd grace ib_umad rdma_cm sunrpc ib_cm iw_cm ib_core ip_tables xfs libcrc32c sd_mod ata_generic pata_acpi mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm ahci drm libahci pata_atiixp serio_raw libata i2c_core bnx2 fjes dm_mirror dm_region_hash dm_log dm_mod
[  124.023567] CPU: 2 PID: 12265 Comm: ping Not tainted 4.9.0-debug #1
[  124.023567] Hardware name: Dell Inc. PowerEdge R415/0GXH08, BIOS 2.0.2 10/22/2012
[  124.023569] task: ffff880818214080 task.stack: ffffc900085e0000
[  124.023577] RIP: 0010:[<ffffffff817005c4>]  [<ffffffff817005c4>] skb_panic+0x66/0x68
[  124.023578] RSP: 0018:ffffc900085e38e0  EFLAGS: 00010246
[  124.023578] RAX: 0000000000000085 RBX: ffff880816a72500 RCX: 0000000000000000
[  124.023579] RDX: 0000000000000000 RSI: 0000000000000296 RDI: 0000000000000296
[  124.023580] RBP: ffffc900085e3900 R08: 0000000000000085 R09: ffffffff82012ce5
[  124.023581] R10: 00000000000003ed R11: 0000000000000000 R12: ffff8808198b7368
[  124.023581] R13: 0000000000000608 R14: 000000000701de0a R15: ffff8808198b7000
[  124.023583] FS:  00002b3922409b00(0000) GS:ffff88083fc80000(0000) knlGS:0000000000000000
[  124.023584] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  124.023584] CR2: 00002ac965af0072 CR3: 0000000814472000 CR4: 00000000000006e0
[  124.023585] Stack:
[  124.023588]  ffff8808179dabf8 0000000000000048 00000000000000c0 ffff8808198b7000
[  124.023590]  ffffc900085e3910 ffffffff815dcb5d ffffc900085e3938 ffffffffa040f6a9
[  124.023592]  ffff8808179dac10 ffff8808198b7368 000000000601de0a ffffc900085e3990
[  124.023592] Call Trace:
[  124.023598]  [<ffffffff815dcb5d>] skb_push+0x3d/0x40
[  124.023607]  [<ffffffffa040f6a9>] ipoib_hard_header+0x69/0x90 [ib_ipoib]
[  124.023611]  [<ffffffff8166c7ee>] arp_create+0x2ae/0x3e0
[  124.023613]  [<ffffffff8166cd28>] arp_send_dst.part.19+0x28/0x50
[  124.023615]  [<ffffffff8166ce65>] arp_solicit+0x115/0x290
[  124.023618]  [<ffffffff815e050c>] ? skb_clone+0x4c/0xa0
[  124.023619]  [<ffffffff815dd92e>] ? __skb_clone+0x2e/0x140
[  124.023622]  [<ffffffff815ff235>] neigh_probe+0x45/0x60
[  124.023624]  [<ffffffff81600117>] __neigh_event_send+0xa7/0x230
[  124.023625]  [<ffffffff8160081e>] neigh_resolve_output+0x12e/0x1c0
[  124.023628]  [<ffffffff8163bc2b>] ip_finish_output2+0x14b/0x370
[  124.023630]  [<ffffffff8163d2e6>] ip_finish_output+0x136/0x1e0
[  124.023632]  [<ffffffff8163dd7e>] ip_output+0x6e/0xf0
[  124.023633]  [<ffffffff8163d402>] ? __ip_local_out+0x72/0x120
[  124.023635]  [<ffffffff8163d1b0>] ? ip_fragment.constprop.49+0x80/0x80
[  124.023636]  [<ffffffff8163d4e5>] ip_local_out+0x35/0x40
[  124.023638]  [<ffffffff8163e819>] ip_send_skb+0x19/0x40
[  124.023640]  [<ffffffff8163e873>] ip_push_pending_frames+0x33/0x40
[  124.023641]  [<ffffffff81665dfa>] raw_sendmsg+0x77a/0xb00
[  124.023644]  [<ffffffff815e6131>] ? skb_recv_datagram+0x41/0x60
[  124.023645]  [<ffffffff81665044>] ? raw_recvmsg+0x94/0x1d0
[  124.023650]  [<ffffffff812e9280>] ? sock_has_perm+0x70/0x90
[  124.023653]  [<ffffffff815d6502>] ? ___sys_recvmsg+0xf2/0x1f0
[  124.023655]  [<ffffffff816753b7>] inet_sendmsg+0x67/0xa0
[  124.023657]  [<ffffffff815d5aa8>] sock_sendmsg+0x38/0x50
[  124.023659]  [<ffffffff815d5f62>] SYSC_sendto+0x102/0x190
[  124.023662]  [<ffffffff8113ed6f>] ? __audit_syscall_entry+0xaf/0x100
[  124.023665]  [<ffffffff81003510>] ? syscall_trace_enter+0x1d0/0x2b0
[  124.023667]  [<ffffffff8113ef9b>] ? __audit_syscall_exit+0x1db/0x260
[  124.023669]  [<ffffffff815d6b0e>] SyS_sendto+0xe/0x10
[  124.023670]  [<ffffffff81003a47>] do_syscall_64+0x67/0x180
[  124.023673]  [<ffffffff8170f7ab>] entry_SYSCALL64_slow_path+0x25/0x25
[  124.023688] Code: 00 00 48 89 44 24 10 8b 87 c8 00 00 00 48 89 44 24 08 48 8b 87 d8 00 00 00 48 c7 c7 50 83 ab 81 48 89 04 24 31 c0 e8 5f e6 a9 ff <0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 0f 1f 44 00 00 55 48
[  124.023690] RIP  [<ffffffff817005c4>] skb_panic+0x66/0x68
[  124.023691]  RSP <ffffc900085e38e0>
[  124.023696] ---[ end trace 95c238901cb322be ]---
[  124.026071] Kernel panic - not syncing: Fatal exception in interrupt
[  124.026368] Kernel Offset: disabled
[  124.644414] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

Fixes: fc791b633515 ('IB/ipoib: move back IB LL address into the hard header')
Reported-by: Norbert P <noe@physik.uzh.ch>
Signed-off-by: Honggang Li <honli@redhat.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index d1d3fb7..3668e1e 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1161,6 +1161,9 @@ static int ipoib_hard_header(struct sk_buff *skb,
 {
 	struct ipoib_header *header;
 
+	if (unlikely(skb_headroom(skb) < IPOIB_HARD_LEN))
+		return -EINVAL;
+
 	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
 
 	header->proto = htons(type);
-- 
1.8.3.1
