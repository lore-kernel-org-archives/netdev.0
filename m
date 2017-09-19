From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Tue, 19 Sep 2017 18:05:57 +0200
Message-ID: <3995617.ACt316cfgQ@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name> <2149381.XGPd7soC9e@natalenko.name> <CAK6E8=e7SE-M4r2nJ8K_FoDMVcN2xYdtw=MetvD5MvXMm9iA1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:56202 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdISQF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:05:59 -0400
In-Reply-To: <CAK6E8=e7SE-M4r2nJ8K_FoDMVcN2xYdtw=MetvD5MvXMm9iA1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And 2 more events:

=3D=3D=3D
$ dmesg --time-format iso | grep RIP
=E2=80=A6
2017-09-19T16:52:21,623328+0200 RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0xd0
2017-09-19T16:52:40,455296+0200 RIP: 0010:tcp_fastretrans_alert+0x7c8/0x990
2017-09-19T16:52:41,047378+0200 RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0xd0
=E2=80=A6
2017-09-19T16:54:59,930726+0200 RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0xd0
2017-09-19T16:55:07,985767+0200 RIP: 0010:tcp_fastretrans_alert+0x7c8/0x990
2017-09-19T16:55:41,911527+0200 RIP: 0010:tcp_undo_cwnd_reduction+0xbd/0xd0
=E2=80=A6
=3D=3D=3D

On pond=C4=9Bl=C3=AD 18. z=C3=A1=C5=99=C3=AD 2017 23:40:08 CEST Yuchung Che=
ng wrote:
> On Mon, Sep 18, 2017 at 1:46 PM, Oleksandr Natalenko
>=20
> <oleksandr@natalenko.name> wrote:
> > Actually, same warning was just triggered with RACK enabled. But main
> > warning was not triggered in this case.
>=20
> Thanks.
>=20
> I assume this kernel does not have the patch that Neal proposed in his
> first reply?
>=20
> The main warning needs to be triggered by another peculiar SACK that
> kicks the sender into recovery again (after undo). Please let it run
> longer if possible to see if we can get both. But the new data does
> indicate the we can (validly) be in CA_Open with retrans_out > 0.
>=20
> > =3D=3D=3D
> > Sep 18 22:44:32 defiant kernel: ------------[ cut here ]------------
> > Sep 18 22:44:32 defiant kernel: WARNING: CPU: 1 PID: 702 at net/ipv4/
> > tcp_input.c:2392 tcp_undo_cwnd_reduction+0xbd/0xd0
> > Sep 18 22:44:32 defiant kernel: Modules linked in: netconsole ctr ccm
> > cls_bpf sch_htb act_mirred cls_u32 sch_ingress sit tunnel4 ip_tunnel
> > 8021q mrp nf_conntrack_ipv6 nf_defrag_ipv6 nft_ct nft_set_bitmap
> > nft_set_hash nft_set_rbtree nf_tables_inet nf_tables_ipv6 nft_masq_ipv4
> > nf_nat_masquerade_ipv4 nft_masq nft_nat nft_counter nft_meta
> > nft_chain_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
> > nf_conntrack libcrc32c crc32c_generic nf_tables_ipv4 nf_tables tun nct6=
775
> > nfnetlink hwmon_vid nls_iso8859_1 nls_cp437 vfat fat ext4
> > snd_hda_codec_hdmi mbcache jbd2 snd_hda_codec_realtek
> > snd_hda_codec_generic f2fs arc4 fscrypto intel_rapl iTCO_wdt ath9k
> > iTCO_vendor_support intel_powerclamp ath9k_common ath9k_hw coretemp
> > kvm_intel ath mac80211 kvm irqbypass intel_cstate cfg80211 pcspkr
> > snd_hda_intel snd_hda_codec r8169
> > Sep 18 22:44:32 defiant kernel:  joydev evdev mii snd_hda_core mousedev
> > mei_txe input_leds i2c_i801 mac_hid i915 lpc_ich mei shpchp snd_hwdep
> > snd_intel_sst_acpi snd_intel_sst_core snd_soc_rt5670
> > snd_soc_sst_atom_hifi2_platform battery snd_soc_sst_match snd_soc_rl6231
> > drm_kms_helper hci_uart ov5693(C) ov2722(C) lm3554(C) btbcm btqca
> > v4l2_common snd_soc_core btintel snd_compress videodev snd_pcm_dmaengine
> > snd_pcm video bluetooth snd_timer drm media tpm_tis snd i2c_hid soundco=
re
> > tpm_tis_core rfkill_gpio ac97_bus soc_button_array ecdh_generic rfkill
> > crc16 tpm 8250_dw intel_gtt syscopyarea sysfillrect acpi_pad sysimgblt
> > intel_int0002_vgpio fb_sys_fops pinctrl_cherryview i2c_algo_bit button
> > sch_fq_codel tcp_bbr ifb ip_tables x_tables btrfs xor raid6_pq
> > algif_skcipher af_alg hid_logitech_hidpp hid_logitech_dj usbhid hid uas
> > Sep 18 22:44:32 defiant kernel:  usb_storage dm_crypt dm_mod dax raid10
> > md_mod sd_mod crct10dif_pclmul crc32_pclmul crc32c_intel
> > ghash_clmulni_intel pcbc ahci aesni_intel xhci_pci libahci aes_x86_64
> > crypto_simd glue_helper xhci_hcd cryptd libata usbcore scsi_mod
> > usb_common serio sdhci_acpi sdhci led_class mmc_core
> > Sep 18 22:44:32 defiant kernel: CPU: 1 PID: 702 Comm: irq/123-enp3s0
> > Tainted: G        WC      4.13.0-pf4 #1
> > Sep 18 22:44:32 defiant kernel: Hardware name: To Be Filled By O.E.M. To
> > Be
> > Filled By O.E.M./J3710-ITX, BIOS P1.30 03/30/2016
> > Sep 18 22:44:32 defiant kernel: task: ffff88923a738000 task.stack:
> > ffff958001500000
> > Sep 18 22:44:32 defiant kernel: RIP:
> > 0010:tcp_undo_cwnd_reduction+0xbd/0xd0
> > Sep 18 22:44:32 defiant kernel: RSP: 0018:ffff88927fc83a48 EFLAGS:
> > 00010202
> > Sep 18 22:44:32 defiant kernel: RAX: 0000000000000001 RBX:
> > ffff8892412d9800
> > RCX: ffff88927fc83b0c
> > Sep 18 22:44:32 defiant kernel: RDX: 000000007fffffff RSI:
> > 0000000000000001
> > RDI: ffff8892412d9800
> > Sep 18 22:44:32 defiant kernel: RBP: ffff88927fc83a50 R08:
> > 0000000000000000
> > R09: 0000000018dfb063
> > Sep 18 22:44:32 defiant kernel: R10: 0000000018dfd223 R11:
> > 0000000018dfb063
> > R12: 0000000000005320
> > Sep 18 22:44:32 defiant kernel: R13: ffff88927fc83b10 R14:
> > 0000000000000001
> > R15: ffff88927fc83b0c
> > Sep 18 22:44:32 defiant kernel: FS:  0000000000000000(0000)
> > GS:ffff88927fc80000(0000) knlGS:0000000000000000
> > Sep 18 22:44:32 defiant kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> > 0000000080050033
> > Sep 18 22:44:32 defiant kernel: CR2: 00007f1cd1a43620 CR3:
> > 0000000114a09000
> > CR4: 00000000001006e0
> > Sep 18 22:44:32 defiant kernel: Call Trace:
> > Sep 18 22:44:32 defiant kernel:  <IRQ>
> > Sep 18 22:44:32 defiant kernel:  tcp_try_undo_loss+0xb3/0xf0
> > Sep 18 22:44:32 defiant kernel:  tcp_fastretrans_alert+0x746/0x990
> > Sep 18 22:44:32 defiant kernel:  tcp_ack+0x741/0x1110
> > Sep 18 22:44:32 defiant kernel:  tcp_rcv_established+0x325/0x770
> > Sep 18 22:44:32 defiant kernel:  ? sk_filter_trim_cap+0xd4/0x1a0
> > Sep 18 22:44:32 defiant kernel:  tcp_v4_do_rcv+0x90/0x1e0
> > Sep 18 22:44:32 defiant kernel:  tcp_v4_rcv+0x950/0xa10
> > Sep 18 22:44:32 defiant kernel:  ? nf_ct_deliver_cached_events+0xb8/0x1=
10
> > [nf_conntrack]
> > Sep 18 22:44:32 defiant kernel:  ip_local_deliver_finish+0x68/0x210
> > Sep 18 22:44:32 defiant kernel:  ip_local_deliver+0xfa/0x110
> > Sep 18 22:44:32 defiant kernel:  ? ip_rcv_finish+0x410/0x410
> > Sep 18 22:44:32 defiant kernel:  ip_rcv_finish+0x120/0x410
> > Sep 18 22:44:32 defiant kernel:  ip_rcv+0x28e/0x3b0
> > Sep 18 22:44:32 defiant kernel:  ? inet_del_offload+0x40/0x40
> > Sep 18 22:44:32 defiant kernel:  __netif_receive_skb_core+0x39b/0xb00
> > Sep 18 22:44:32 defiant kernel:  ? netif_receive_skb_internal+0xa0/0x480
> > Sep 18 22:44:32 defiant kernel:  ? dev_gro_receive+0x2eb/0x4a0
> > Sep 18 22:44:32 defiant kernel:  __netif_receive_skb+0x18/0x60
> > Sep 18 22:44:32 defiant kernel:  netif_receive_skb_internal+0x98/0x480
> > Sep 18 22:44:32 defiant kernel:  netif_receive_skb+0x1c/0x80
> > Sep 18 22:44:32 defiant kernel:  ifb_ri_tasklet+0x109/0x26a [ifb]
> > Sep 18 22:44:32 defiant kernel:  tasklet_action+0x63/0x120
> > Sep 18 22:44:32 defiant kernel:  __do_softirq+0xdf/0x2e5
> > Sep 18 22:44:32 defiant kernel:  ? irq_finalize_oneshot.part.39+0xe0/0x=
e0
> > Sep 18 22:44:32 defiant kernel:  do_softirq_own_stack+0x1c/0x30
> > Sep 18 22:44:32 defiant kernel:  </IRQ>
> > Sep 18 22:44:32 defiant kernel:  do_softirq.part.17+0x4e/0x60
> > Sep 18 22:44:32 defiant kernel:  __local_bh_enable_ip+0x77/0x80
> > Sep 18 22:44:32 defiant kernel:  irq_forced_thread_fn+0x5c/0x70
> > Sep 18 22:44:32 defiant kernel:  irq_thread+0x131/0x1a0
> > Sep 18 22:44:32 defiant kernel:  ? wake_threads_waitq+0x30/0x30
> > Sep 18 22:44:32 defiant kernel:  kthread+0x126/0x140
> > Sep 18 22:44:32 defiant kernel:  ? irq_thread_check_affinity+0x90/0x90
> > Sep 18 22:44:32 defiant kernel:  ? kthread_create_on_node+0x70/0x70
> > Sep 18 22:44:32 defiant kernel:  ret_from_fork+0x25/0x30
> > Sep 18 22:44:32 defiant kernel: Code: 5d c3 80 60 35 fb 48 8b 00 48 39 =
c2
> > 74 85 48 3b 83 50 01 00 00 75 eb e9 77 ff ff ff 89 83 48 06 00 00 80 a3
> > 1e 06 00 00 fb eb b3 <0f> ff 5b 5d c3 0f 1f 40 00 66 2e 0f 1f 84 00 00 =
00
> > 00 00 0f 1f Sep 18 22:44:32 defiant kernel: ---[ end trace
> > 1aea180efeedb474 ]--- =3D=3D=3D
> >=20
> > On pond=C4=9Bl=C3=AD 18. z=C3=A1=C5=99=C3=AD 2017 20:01:42 CEST Yuchung=
 Cheng wrote:
> >> On Mon, Sep 18, 2017 at 10:59 AM, Oleksandr Natalenko
> >>=20
> >> <oleksandr@natalenko.name> wrote:
> >> > OK. Should I keep FACK disabled?
> >>=20
> >> Yes since it is disabled in the upstream by default. Although you can
> >> experiment FACK enabled additionally.
> >>=20
> >> Do we know the crash you first experienced is tied to this issue?
> >>=20
> >> > On pond=C4=9Bl=C3=AD 18. z=C3=A1=C5=99=C3=AD 2017 19:51:21 CEST Yuch=
ung Cheng wrote:
> >> >> Can you try this patch to verify my theory with tcp_recovery=3D0 an=
d 1?
> >> >> thanks
> >> >>=20
> >> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> >> index 5af2f04f8859..9253d9ee7d0e 100644
> >> >> --- a/net/ipv4/tcp_input.c
> >> >> +++ b/net/ipv4/tcp_input.c
> >> >> @@ -2381,6 +2381,7 @@ static void tcp_undo_cwnd_reduction(struct so=
ck
> >> >> *sk, bool unmark_loss)
> >> >>=20
> >> >>         }
> >> >>         tp->snd_cwnd_stamp =3D tcp_time_stamp;
> >> >>         tp->undo_marker =3D 0;
> >> >>=20
> >> >> +       WARN_ON(tp->retrans_out);
> >> >>=20
> >> >>  }
