From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH linux-next] nf_defrag_ipv6: fix oops on module unloading
Date: Tue, 25 Sep 2012 20:07:50 +0400
Message-ID: <20120925160750.30475.77562.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48539 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756837Ab2IYQHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 12:07:54 -0400
Received: by lbon3 with SMTP id n3so357996lbo.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 09:07:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix copy-paste error introduced in linux-next commit
"ipv6: add a new namespace for nf_conntrack_reasm"

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Amerigo Wang <amwang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>

---

[    1.958698] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
[    1.962639] IP: [<ffffffffa1d521e3>] nf_ct_net_exit+0x24/0x79 [nf_defrag_ipv6]
[    1.962639] PGD 0
[    1.962639] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[    1.962639] Modules linked in: dib3000mc dibx000_common rng_core whci umc nop_usb_xceiv eni videocodec orinoco pcmcia pcmcia_core xfrm_algo spi_bitbang ppp_generic videobuf_vmalloc nf_nat s5h1420 scsi_dh cs5535_mfgpt speakup(C) nf_defrag_ipv6(-) pmbus_core ptp pps_core scsi_transport_sas videobuf2_vmalloc videobuf2_memops videobuf2_core scsi_transport_iscsi i8042 sound suni serio phonet usbip_core(C) sir_dev irda dvb_usb dvb_core slhc udc_core atm snd_mpu401_uart snd_ac97_codec ac97_bus snd_rawmidi uio comedi(C) rt2x00pci rt2x00lib crc_itu_t snd_soc_core snd_compress btcx_risc tveeprom videobuf_dma_sg videobuf_core v4l2_common rc_core videodev media regmap_i2c wusbcore uwb ni_tio(C) x_tables industrialio nf_conntrack p54common mac80211 cfg80211 crc_ccitt led_class b1 kernelcapi ppdev lp
  bnep rfcomm
[    1.962639]  bluetooth rfkill uinput fuse nfsd auth_rpcgss nfs_acl nfs lockd sunrpc af_packet ipv6 loop evbug evdev mac_hid snd_hda_codec_realtek snd_hda_intel snd_hda_codec nouveau snd_hwdep snd_pcm powernow_k8 mxm_wmi snd_page_alloc freq_table wmi video kvm_amd ttm snd_seq kvm drm_kms_helper snd_seq_device snd_timer drm agpgart i2c_algo_bit cfbfillrect cfbimgblt snd cfbcopyarea backlight fb edac_core fbdev edac_mce_amd soundcore firmware_class pcspkr k8temp hid_generic parport_pc parport rtc_cmos 8250_pnp i2c_nforce2 processor thermal_sys button hwmon i2c_core ext4 crc16 jbd2 mbcache btrfs crc32c libcrc32c zlib_deflate usbhid hid sd_mod crc_t10dif ide_cd_mod cdrom ohci_hcd ata_generic pata_acpi pata_amd ehci_hcd sata_nv amd74xx forcedeth usbcore libata usb_common scsi_mod ide_pci_gene
 ric ide_core
[    1.962639]  unix [last unloaded: nf_defrag_ipv4]
[    1.962639] CPU 1
[    1.962639] Pid: 12431, comm: rmmod Tainted: P    B   WC   3.6.0-rc6-next-20120921-00009-g0383d9a #563 Gigabyte Technology Co., Ltd. M52S-S3P/M52S-S3P
[    1.962639] RIP: 0010:[<ffffffffa1d521e3>]  [<ffffffffa1d521e3>] nf_ct_net_exit+0x24/0x79 [nf_defrag_ipv6]
[    1.962639] RSP: 0018:ffff8800539ade18  EFLAGS: 00010203
[    1.962639] RAX: ffffffff82529ab0 RBX: ffffffff82529a40 RCX: ffffffffa1d552d0
[    1.962639] RDX: ffff8800539ade68 RSI: ffff8800539ade68 RDI: 0000000000000000
[    1.962639] RBP: ffff8800539ade28 R08: ffff8800539ade68 R09: ffffffff8167c7c0
[    1.962639] R10: ffff88007d010240 R11: ffff88007d010240 R12: ffffffffa1d552d0
[    1.962639] R13: ffff8800539ade68 R14: 00007fad18abf170 R15: 0000000000000800
[    1.962639] FS:  00007fad18887700(0000) GS:ffff88007d000000(0000) knlGS:0000000000000000
[    1.962639] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.962639] CR2: 0000000000000020 CR3: 0000000055278000 CR4: 00000000000007e0
[    1.962639] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.962639] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    1.962639] Process rmmod (pid: 12431, threadinfo ffff8800539ac000, task ffff880056820000)
[    1.962639] Stack:
[    1.962639]  ffffffff82529a40 ffffffffa1d552d0 ffff8800539ade58 ffffffff81554af3
[    1.962639]  ffff8800539ade68 ffffffffa1d552d0 ffffffff8252ab30 ffff8800539ade68
[    1.962639]  ffff8800539ade98 ffffffff81555031 ffffffff82529ab0 ffffffff82529ab0
[    1.962639] Call Trace:
[    1.962639]  [<ffffffff81554af3>] ops_exit_list+0x4e/0x83
[    1.962639]  [<ffffffff81555031>] unregister_pernet_operations+0x84/0xe0
[    1.962639]  [<ffffffff8155512b>] unregister_pernet_subsys+0x32/0x50
[    1.962639]  [<ffffffffa1d5392e>] nf_ct_frag6_cleanup+0x1c/0x3a [nf_defrag_ipv6]
[    1.962639]  [<ffffffffa1d53974>] nf_defrag_fini+0x28/0x31 [nf_defrag_ipv6]
[    1.962639]  [<ffffffff8110ec5a>] sys_delete_module+0x328/0x3d2
[    1.962639]  [<ffffffff8168be58>] tracesys+0xe1/0xe6
[    1.962639] Code: 05 bb 4b 00 00 5d c3 66 66 66 66 90 55 48 ff 05 f4 4e 00 00 48 ff 05 0d 4f 00 00 48 89 e5 41 54 53 48 89 fb 48 8b bf 88 0b 00 00 <4c> 8b 67 20 e8 0d 8f 8e df 48 ff 05 f5 4e 00 00 48 81 fb 40 9a
[    1.962639] RIP  [<ffffffffa1d521e3>] nf_ct_net_exit+0x24/0x79 [nf_defrag_ipv6]
[    1.962639]  RSP <ffff8800539ade18>
[    1.962639] CR2: 0000000000000020
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 1af12fde..18bd9bb 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -106,7 +106,7 @@ static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
 	if (hdr == NULL)
 		goto err_reg;
 
-	net->ipv6.sysctl.frags_hdr = hdr;
+	net->nf_frag.sysctl.frags_hdr = hdr;
 	return 0;
 
 err_reg:
