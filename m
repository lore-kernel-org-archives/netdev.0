From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Sun, 10 Sep 2017 22:53:44 +0200
Message-ID: <10035198.1vE6NFrMDO@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:10032 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbdIJU7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 16:59:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Since, IIRC, v4.11, there is some regression in TCP stack resulting in the 
warning shown below. Most of the time it is harmless, but rarely it just 
causes either freeze or (I believe, this is related too) panic in 
tcp_sacktag_walk() (because sk_buff passed to this function is NULL). 
Unfortunately, I still do not have proper stacktrace from panic, but will try 
to capture it if possible.

Also, I have custom settings regarding TCP stack, shown below as well. ifb is 
used to shape traffic with tc.

Please note this regression was already reported as BZ [1] and as a letter to 
ML [2], but got neither attention nor resolution. It is reproducible for (not 
only) me on my home router since v4.11 till v4.13.1 incl.

Please advise on how to deal with it. I'll provide any additional info if 
necessary, also ready to test patches if any.

Thanks.

[1] https://bugzilla.kernel.org/show_bug.cgi?id=195835
[2] https://www.spinics.net/lists/netdev/msg436158.html

=== warning
[14407.060066] ------------[ cut here ]------------
[14407.060353] WARNING: CPU: 0 PID: 719 at net/ipv4/tcp_input.c:2826 
tcp_fastretrans_alert+0x7c8/0x990
[14407.060747] Modules linked in: netconsole ctr ccm cls_bpf sch_htb 
act_mirred cls_u32 sch_ingress sit tunnel4 ip_tunnel 8021q mrp nf
_conntrack_ipv6 nf_defrag_ipv6 nft_ct nft_set_bitmap nft_set_hash 
nft_set_rbtree nf_tables_inet nf_tables_ipv6 nft_masq_ipv4 nf_nat_ma
squerade_ipv4 nft_masq nft_nat nft_counter nft_meta nft_chain_nat_ipv4 
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrac
k libcrc32c crc32c_generic nf_tables_ipv4 tun nf_tables nfnetlink nct6775 
hwmon_vid nls_iso8859_1 nls_cp437 vfat fat ext4 mbcache jbd2
 arc4 f2fs snd_hda_codec_hdmi fscrypto snd_hda_codec_realtek 
snd_hda_codec_generic intel_rapl intel_powerclamp coretemp iTCO_wdt iTCO_
vendor_support ath9k ath9k_common kvm_intel ath9k_hw kvm ath irqbypass 
intel_cstate mac80211 pcspkr snd_intel_sst_acpi i2c_i801 i915 s
nd_hda_intel
[14407.063800]  snd_intel_sst_core r8169 cfg80211 evdev mii snd_hda_codec 
joydev mousedev input_leds snd_soc_rt5670 mei_txe snd_soc_ss
t_atom_hifi2_platform snd_hda_core snd_soc_rl6231 snd_soc_sst_match mac_hid 
mei lpc_ich shpchp drm_kms_helper snd_hwdep snd_soc_core s
nd_compress battery snd_pcm_dmaengine drm hci_uart ov2722(C) snd_pcm lm3554(C) 
ov5693(C) snd_timer v4l2_common btbcm snd intel_gtt btq
ca btintel videodev syscopyarea bluetooth video soundcore sysfillrect media 
sysimgblt ac97_bus ecdh_generic rfkill_gpio i2c_hid rfkill
 tpm_tis crc16 fb_sys_fops i2c_algo_bit 8250_dw tpm_tis_core tpm 
soc_button_array pinctrl_cherryview intel_int0002_vgpio acpi_pad butt
on sch_fq_codel tcp_bbr ifb ip_tables x_tables btrfs xor raid6_pq 
algif_skcipher af_alg hid_logitech_hidpp hid_logitech_dj usbhid hid
uas usb_storage
[14407.066873]  dm_crypt dm_mod dax raid10 md_mod sd_mod crct10dif_pclmul 
crc32_pclmul crc32c_intel ghash_clmulni_intel pcbc aesni_int
el aes_x86_64 crypto_simd glue_helper cryptd ahci xhci_pci libahci xhci_hcd 
libata usbcore scsi_mod usb_common serio sdhci_acpi sdhci
led_class mmc_core
[14407.068034] CPU: 0 PID: 719 Comm: irq/123-enp3s0 Tainted: G         C      
4.13.0-pf2 #1
[14407.068403] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./
J3710-ITX, BIOS P1.30 03/30/2016
[14407.068827] task: ffff98b1c0a05400 task.stack: ffffbb59c15c0000
[14407.069111] RIP: 0010:tcp_fastretrans_alert+0x7c8/0x990
[14407.069358] RSP: 0018:ffff98b1ffc03a78 EFLAGS: 00010202
[14407.069607] RAX: 0000000000000000 RBX: ffff98b135ae0000 RCX: 
ffff98b1ffc03b0c
[14407.069928] RDX: 0000000000000001 RSI: 0000000000000001 RDI: 
ffff98b135ae0000
[14407.070248] RBP: ffff98b1ffc03ab8 R08: 0000000000000000 R09: 
ffff98b1ffc03b60
[14407.070565] R10: 0000000000000000 R11: 0000000000000000 R12: 
0000000000005120
[14407.070884] R13: ffff98b1ffc03b10 R14: 0000000000000001 R15: 
ffff98b1ffc03b0c
[14407.071205] FS:  0000000000000000(0000) GS:ffff98b1ffc00000(0000) knlGS:
0000000000000000
[14407.071564] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[14407.071827] CR2: 00007ffc580b2f0f CR3: 0000000010a09000 CR4: 
00000000001006f0
[14407.072146] Call Trace:
[14407.072279]  <IRQ>
[14407.072412]  ? sk_reset_timer+0x18/0x30
[14407.072610]  tcp_ack+0x741/0x1110
[14407.072810]  tcp_rcv_established+0x325/0x770
[14407.073033]  ? sk_filter_trim_cap+0xd4/0x1a0
[14407.073249]  tcp_v4_do_rcv+0x90/0x1e0
[14407.073449]  tcp_v4_rcv+0x950/0xa10
[14407.073647]  ? nf_ct_deliver_cached_events+0xb8/0x110 [nf_conntrack]
[14407.073955]  ip_local_deliver_finish+0x68/0x210
[14407.074183]  ip_local_deliver+0xfa/0x110
[14407.074385]  ? ip_rcv_finish+0x410/0x410
[14407.074589]  ip_rcv_finish+0x120/0x410
[14407.074782]  ip_rcv+0x28e/0x3b0
[14407.074952]  ? inet_del_offload+0x40/0x40
[14407.075154]  __netif_receive_skb_core+0x39b/0xb00
[14407.075389]  ? netif_receive_skb_internal+0xa0/0x480
[14407.075635]  ? skb_release_all+0x24/0x30
[14407.075832]  ? consume_skb+0x38/0xa0
[14407.076025]  __netif_receive_skb+0x18/0x60
[14407.076230]  netif_receive_skb_internal+0x98/0x480
[14407.076470]  netif_receive_skb+0x1c/0x80
[14407.087463]  ifb_ri_tasklet+0x109/0x26a [ifb]
[14407.090528]  tasklet_action+0x63/0x120
[14407.093258]  __do_softirq+0xdf/0x2e5
[14407.095974]  ? irq_finalize_oneshot.part.39+0xe0/0xe0
[14407.098708]  do_softirq_own_stack+0x1c/0x30
[14407.101437]  </IRQ>
[14407.104139]  do_softirq.part.17+0x4e/0x60
[14407.106854]  __local_bh_enable_ip+0x77/0x80
[14407.109671]  irq_forced_thread_fn+0x5c/0x70
[14407.112407]  irq_thread+0x131/0x1a0
[14407.115120]  ? wake_threads_waitq+0x30/0x30
[14407.117836]  kthread+0x126/0x140
[14407.120541]  ? irq_thread_check_affinity+0x90/0x90
[14407.123244]  ? kthread_create_on_node+0x70/0x70
[14407.125913]  ret_from_fork+0x25/0x30
[14407.128548] Code: 05 00 00 3b 83 30 05 00 00 0f 88 ca 01 00 00 0f b6 83 3c 
06 00 00 80 a3 cd 05 00 00 7f c0 e8 04 0f 85 3b fb ff ff
 e9 2c fb ff ff <0f> ff e9 46 f9 ff ff 31 d2 48 89 df e8 47 aa ff ff e9 f9 f9 
ff
[14407.133867] ---[ end trace 4bb223d8deb9f077 ]---
===

=== code
2823     /* D. Check state exit conditions. State can be terminated
2824      *    when high_seq is ACKed. */
2825     if (icsk->icsk_ca_state == TCP_CA_Open) {
2826         WARN_ON(tp->retrans_out != 0); // here
2827         tp->retrans_stamp = 0;
===

=== sysctl custom settings
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_local_port_range = 1026 59999
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.route.max_size = 16384
net.ipv4.ip_dynaddr = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fack = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_rmem = 4096 262143 4194304
net.ipv4.tcp_wmem = 4096 262143 4194304
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_retries2 = 5
net.core.rmem_max = 4194304
net.core.rmem_default = 262143
net.core.wmem_max = 4194304
net.core.wmem_default = 262143
net.core.bpf_jit_enable = 1
net.ipv4.tcp_ecn = 1
===

=== kernel cmdline
BOOT_IMAGE=/vmlinuz-linux-pf root=/dev/mapper/system-root rw cryptdevice=/dev/
md0:system:allow-discards resume=/dev/mapper/system-swap quiet zswap.enabled=1 
threadirqs
===
