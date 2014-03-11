From: John Greene <jogreene@redhat.com>
Subject: [PATCH RFT] ath5k: add missing dma_map_error call
Date: Tue, 11 Mar 2014 14:08:34 -0400
Message-ID: <1394561314-27195-1-git-send-email-jogreene@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbaCKSIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 14:08:53 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2BI8g3b005393
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 14:08:43 -0400
Received: from jgpicker.redhat.com (vpn-50-51.rdu2.redhat.com [10.10.50.51])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s2BI8faW002725
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 14:08:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial patch to address this trace. Now calls dma_mapping_error and
return -ENOSPC if a problem found.

WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x960()
Hardware name: Aspire 5515
ath5k 0000:02:00.0: DMA-API: device driver failed to check map
error[device address=0x00000000874fcd42] [size=45 bytes] [mapped as
single]
Modules linked in: bnep bluetooth ebtable_filter ebtables
ip6table_filter ip6_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio
cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm
ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi
scsi_transport_iscsi arc4 snd_hda_codec_realtek snd_hda_intel
snd_hda_codec snd_hwdep snd_seq snd_seq_device ath5k ath snd_pcm
sparse_keymap snd_page_alloc mac80211 snd_timer sp5100_tco snd edac_core
k8temp soundcore edac_mce_amd i2c_piix4 cfg80211 rfkill shpchp vhost_net
tun macvtap macvlan kvm_amd kvm uinput dm_crypt ata_generic pata_acpi
radeon i2c_algo_bit pata_atiixp drm_kms_helper ttm drm r8169 mii
i2c_core wmi video sunrpc
Pid: 820, comm: firewalld Not tainted 3.9.0-0.rc3.git1.4.fc19.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff81068df0>] warn_slowpath_common+0x70/0xa0
 [<ffffffff81068e6c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff8137ebeb>] check_unmap+0x47b/0x960
 [<ffffffff81021cf5>] ? native_sched_clock+0x15/0x80
 [<ffffffff81021d69>] ? sched_clock+0x9/0x10
 [<ffffffff8137f12f>] debug_dma_unmap_page+0x5f/0x70
 [<ffffffffa048fa07>] ath5k_tasklet_tx+0x157/0x3f0 [ath5k]
 [<ffffffff810acc0d>] ? sched_clock_local+0x1d/0x80
 [<ffffffff81072aa6>] ? tasklet_action+0x56/0x210
 [<ffffffff81072ae7>] tasklet_action+0x97/0x210
 [<ffffffff8107343f>] __do_softirq+0xff/0x400
 [<ffffffff81073905>] irq_exit+0xb5/0xc0
 [<ffffffff81728916>] do_IRQ+0x56/0xc0
 [<ffffffff8171dc32>] common_interrupt+0x72/0x72
 <EOI>  [<ffffffff811f1f81>] ? dput+0x111/0x310
 [<ffffffff811f1ea7>] ? dput+0x37/0x310
 [<ffffffff811e75e8>] link_path_walk+0x528/0x910
 [<ffffffff811ea624>] path_openat+0x94/0x530
 [<ffffffff811eb148>] do_filp_open+0x38/0x80
 [<ffffffff811e1dda>] open_exec+0x4a/0x130
 [<ffffffff81238be3>] load_elf_binary+0x7f3/0x18e0
 [<ffffffff81021d69>] ? sched_clock+0x9/0x10
 [<ffffffff810acc0d>] ? sched_clock_local+0x1d/0x80
 [<ffffffff810acd98>] ? sched_clock_cpu+0xa8/0x100
 [<ffffffff810d515d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff810acedf>] ? local_clock+0x5f/0x70
 [<ffffffff810d5dbf>] ? lock_release_holdtime.part.28+0xf/0x190
 [<ffffffff812383f0>] ? elf_core_dump+0x1980/0x1980
 [<ffffffff811e1151>] search_binary_handler+0x1a1/0x4f0
 [<ffffffff811e1017>] ? search_binary_handler+0x67/0x4f0
 [<ffffffff811e28fc>] do_execve_common.isra.26+0x64c/0x710
 [<ffffffff811e23c2>] ? do_execve_common.isra.26+0x112/0x710
 [<ffffffff811e2cc6>] sys_execve+0x36/0x50
 [<ffffffff81727249>] stub_execve+0x69/0xa0

Signed-off-by: John Greene <jogreene@redhat.com>
---
 drivers/net/wireless/ath/ath5k/base.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index ef35da8..4b18434 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -751,6 +751,9 @@ ath5k_txbuf_setup(struct ath5k_hw *ah, struct ath5k_buf *bf,
 	bf->skbaddr = dma_map_single(ah->dev, skb->data, skb->len,
 			DMA_TO_DEVICE);
 
+	if (dma_mapping_error(ah->dev, bf->skbaddr))
+		return -ENOSPC;
+
 	ieee80211_get_tx_rates(info->control.vif, (control) ? control->sta : NULL, skb, bf->rates,
 			       ARRAY_SIZE(bf->rates));
 
-- 
1.8.1.4
