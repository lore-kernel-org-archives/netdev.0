From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH] igb: add more checks for disconnected adapter
Date: Mon, 21 Sep 2015 13:11:28 -0400
Message-ID: <1442855488-27453-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some pci changes upcoming in 4.3 seem to cause additional disconnects,
which can happen at unfortuitous times for igb, leading to issues such as
this, where the disconnect happened just before igb_configure_tx_ring():

[  414.440115] igb 0000:15:00.0: enabling device (0000 -> 0002)
[  414.474934] pps pps0: new PPS source ptp1
[  414.474937] igb 0000:15:00.0: added PHC on eth0
[  414.474938] igb 0000:15:00.0: Intel(R) Gigabit Ethernet Network Connection
[  414.474940] igb 0000:15:00.0: eth0: (PCIe:2.5Gb/s:Width x1) e8:ea:6a:00:1b:2a
[  414.475072] igb 0000:15:00.0: eth0: PBA No: 000200-000
[  414.475073] igb 0000:15:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
[  414.478453] igb 0000:15:00.0 enp21s0: renamed from eth0
[  414.497747] IPv6: ADDRCONF(NETDEV_UP): enp21s0: link is not ready
[  414.536745] igb 0000:15:00.0 enp21s0: PCIe link lost, device now detached
[  414.854808] BUG: unable to handle kernel paging request at 0000000000003818
[  414.854827] IP: [<ffffffffa0b95a9c>] igb_configure_tx_ring+0x14c/0x250 [igb]
[  414.854846] PGD 0
[  414.854849] Oops: 0002 [#1] SMP
[  414.854856] Modules linked in: firewire_ohci firewire_core crc_itu_t igb dca ctr ccm arc4 iwlmvm mac80211 fuse xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter bnep dm_mirror dm_region_hash dm_log dm_mod snd_hda_codec_hdmi coretemp x86_pkg_temp_thermal intel_powerclamp kvm_intel iTCO_wdt ppdev kvm iTCO_vendor_support hp_wmi sparse_keymap crct10dif_pclmul crc32_pclmul ghash_cl
 mulni_intel
[  414.855073]  drbg ansi_cprng snd_hda_codec_realtek snd_hda_codec_generic aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd snd_hda_intel snd_hda_codec microcode snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm iwlwifi uvcvideo btusb cfg80211 videobuf2_vmalloc videobuf2_memops btrtl btbcm videobuf2_core btintel bluetooth v4l2_common snd_timer videodev snd parport_pc rtsx_pci_ms joydev pcspkr input_leds i2c_i801 media sg memstick rfkill soundcore lpc_ich 8250_fintek parport mei_me hp_accel ie31200_edac shpchp lis3lv02d mei edac_core input_polldev hp_wireless tpm_infineon sch_fq_codel nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sr_mod sd_mod cdrom rtsx_pci_sdmmc mmc_core crc32c_intel serio_raw rtsx_pci nouveau mxm_wmi ahci hwmon libahci e1000e 
 drm_kms_helper
[  414.855309]  ptp xhci_pci pps_core ttm xhci_hcd wmi video ipv6 autofs4
[  414.855331] CPU: 2 PID: 875 Comm: NetworkManager Not tainted 4.2.0-5.el7_UNSUPPORTED.x86_64 #1
[  414.855348] Hardware name: Hewlett-Packard HP ZBook 15 G2/2253, BIOS M70 Ver. 01.07 02/26/2015
[  414.855365] task: ffff880484698c00 ti: ffff88005859c000 task.ti: ffff88005859c000
[  414.855380] RIP: 0010:[<ffffffffa0b95a9c>]  [<ffffffffa0b95a9c>] igb_configure_tx_ring+0x14c/0x250 [igb]
[  414.855401] RSP: 0018:ffff88005859f608  EFLAGS: 00010246
[  414.855410] RAX: 0000000000003818 RBX: 0000000000000000 RCX: 0000000000003818
[  414.855424] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00000000002a9fe6
[  414.855437] RBP: ffff88005859f638 R08: 0000000003030300 R09: 00000000ffffffe7
[  414.855451] R10: ffffffff81fa91b4 R11: 00000000000007e3 R12: 0000000000000000
[  414.855464] R13: ffff880471c98840 R14: ffff8804670a1180 R15: 0000000483cce000
[  414.855478] FS:  00007f389c6fb8c0(0000) GS:ffff88049dc80000(0000) knlGS:0000000000000000
[  414.855493] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  414.855504] CR2: 0000000000003818 CR3: 00000004875da000 CR4: 00000000001406e0
[  414.855518] Stack:
[  414.855520]  ffff88005859f638 ffff880471c98840 ffff880471c98df8 0000000000000001
[  414.855538]  ffff880471c98848 0000000000000001 ffff88005859f698 ffffffffa0b99cb0
[  414.855555]  ffff88005859f678 59ab02179a7fe4d0 f3ce6b27ad46225f f5454218094e72d1
[  414.855572] Call Trace:
[  414.855577]  [<ffffffffa0b99cb0>] igb_configure+0x240/0x400 [igb]
[  414.855590]  [<ffffffffa0b99f32>] __igb_open+0xc2/0x560 [igb]
[  414.855602]  [<ffffffff8108f43d>] ? notifier_call_chain+0x4d/0x80
[  414.855614]  [<ffffffffa0b9a540>] igb_open+0x10/0x20 [igb]
[  414.855625]  [<ffffffff81581b81>] __dev_open+0xb1/0x130
[  414.855636]  [<ffffffff81581e91>] __dev_change_flags+0xa1/0x160
[  414.855647]  [<ffffffff81581f79>] dev_change_flags+0x29/0x60
[  414.855658]  [<ffffffff8158efc3>] do_setlink+0x5d3/0xaa0
[  414.855679]  [<ffffffff81308073>] ? nla_parse+0xa3/0x100
[  414.855689]  [<ffffffff815905f0>] rtnl_newlink+0x4f0/0x880
[  414.855700]  [<ffffffff815901f3>] ? rtnl_newlink+0xf3/0x880
[  414.855721]  [<ffffffff815ae23e>] ? netlink_unicast+0x1ae/0x220
[  414.855734]  [<ffffffff81266648>] ? security_capable+0x48/0x60
[  414.855746]  [<ffffffff810796bd>] ? ns_capable+0x2d/0x60
[  414.855756]  [<ffffffff8158db35>] rtnetlink_rcv_msg+0x95/0x240
[  414.855768]  [<ffffffff8126adc0>] ? sock_has_perm+0x70/0x90
[  414.855779]  [<ffffffff8158daa0>] ? rtnetlink_rcv+0x40/0x40
[  414.855789]  [<ffffffff815ae7ff>] netlink_rcv_skb+0xaf/0xc0
[  414.855800]  [<ffffffff8158da8c>] rtnetlink_rcv+0x2c/0x40
[  414.855810]  [<ffffffff815ae1de>] netlink_unicast+0x14e/0x220
[  414.855821]  [<ffffffff815ae5ca>] netlink_sendmsg+0x31a/0x390
[  414.855833]  [<ffffffff81563208>] sock_sendmsg+0x38/0x50
[  414.855843]  [<ffffffff81563b4e>] ___sys_sendmsg+0x27e/0x2a0
[  414.855855]  [<ffffffff8123d82f>] ? sysctl_head_finish+0x3f/0x50
[  414.855866]  [<ffffffff81077c10>] ? proc_put_long+0xb0/0xb0
[  414.855877]  [<ffffffff8123d9d9>] ? proc_sys_call_handler+0x79/0xc0
[  414.855890]  [<ffffffff812ec2fc>] ? lockref_put_or_lock+0x4c/0x80
[  414.855902]  [<ffffffff81564432>] __sys_sendmsg+0x42/0x80
[  414.855913]  [<ffffffff81564482>] SyS_sendmsg+0x12/0x20
[  414.855924]  [<ffffffff8165042e>] entry_SYSCALL_64_fastpath+0x12/0x71
[  414.855935] Code: c1 49 89 4e 30 49 8b 85 c0 05 00 00 48 85 c0 0f 84 0e 01 00 00 81 c2 10 38 00 00 48 63 d2 48 01 d0 31 d2 89 10 49 8b 46 30 31 d2 <89> 10 41 8b 95 44 06 00 00 b8 14 01 10 02 83
fa 05 74 0b 83 fa
[  414.856037] RIP  [<ffffffffa0b95a9c>] igb_configure_tx_ring+0x14c/0x250 [igb]
[  414.856052]  RSP <ffff88005859f608>
[  414.856057] CR2: 0000000000003818
[  414.872327] ---[ end trace e97522c0c584ea70 ]---

This can at least be reduced to a harmless initialization failure with some
additional checking of device presence, similar to ixgbe. With this patch
in place, instead we get:

[ 8010.562550] igb 0000:15:00.0: enabling device (0000 -> 0002)
[ 8010.597402] pps pps0: new PPS source ptp1
[ 8010.597406] igb 0000:15:00.0: added PHC on eth0
[ 8010.597407] igb 0000:15:00.0: Intel(R) Gigabit Ethernet Network Connection
[ 8010.597409] igb 0000:15:00.0: eth0: (PCIe:2.5Gb/s:Width x1) e8:ea:6a:00:1b:2a
[ 8010.597543] igb 0000:15:00.0: eth0: PBA No: 000200-000
[ 8010.597545] igb 0000:15:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
[ 8010.600468] igb 0000:15:00.0 enp21s0: renamed from eth0
[ 8010.619354] IPv6: ADDRCONF(NETDEV_UP): enp21s0: link is not ready
[ 8010.663999] igb 0000:15:00.0 enp21s0: PCIe link lost, device now detached
[ 8011.012427] igb 0000:15:00.0: Unable to allocate memory for vectors

CC: Mark Rustad <mark.d.rustad@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
Note: this is a follow-up patch in addition to the previously submitted
      "igb: don't unmap NULL hw_addr"

 drivers/net/ethernet/intel/igb/igb_main.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6369f9e..7060edf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -952,6 +952,11 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	if (err)
 		goto err_out;
 
+	if (E1000_REMOVED(hw->hw_addr)) {
+		err = -EIO;
+		goto err_free;
+	}
+
 	for (i = 0; i < adapter->num_q_vectors; i++) {
 		struct igb_q_vector *q_vector = adapter->q_vector[i];
 
@@ -1199,6 +1204,9 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	if (txr_count > 1 || rxr_count > 1)
 		return -ENOMEM;
 
+	if (E1000_REMOVED(adapter->hw.hw_addr))
+		return -EIO;
+
 	ring_count = txr_count + rxr_count;
 	size = sizeof(struct igb_q_vector) +
 	       (sizeof(struct igb_ring) * ring_count);
@@ -3248,6 +3256,9 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	u64 tdba = ring->dma;
 	int reg_idx = ring->reg_idx;
 
+	if (E1000_REMOVED(adapter->io_addr))
+		return;
+
 	/* disable the queue */
 	wr32(E1000_TXDCTL(reg_idx), 0);
 	wrfl();
@@ -3259,7 +3270,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	     tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
 	writel(0, ring->tail);
 
@@ -3615,7 +3626,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	     ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
+	ring->tail = adapter->io_addr + E1000_RDT(reg_idx);
 	wr32(E1000_RDH(reg_idx), 0);
 	writel(0, ring->tail);
 
-- 
1.8.3.1
