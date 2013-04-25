From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: WARNING: at net/ipv4/tcp_input.c:2776 tcp_fastretrans_alert+0xc14/0xc60()
Date: Thu, 25 Apr 2013 02:37:09 +0200
Message-ID: <CA+icZUXsr5KicsdimNgjCMgt93Zi4UXi_pvrxn+P6eZYpPc7cA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Intel Linux Wireless <ilw@linux.intel.com>
To: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36906 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758069Ab3DYAhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 20:37:11 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1638672wey.33
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 17:37:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I pulled into next-20130424

net-next up to commit "Merge branch 'bnx2x'"

...and...

mac80211-next uo to commit "mac80211_hwsim: correctly register the
platform driver"

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=01f27fc085574b301248d4da241e9d5ebd61e5c9
http://git.kernel.org/cgit/linux/kernel/git/jberg/mac80211-next.git/commit/?id=2fd488508d6276cc7f5435283957ba62e6fbc43e

...and see this WARNING:

[  147.123618] ------------[ cut here ]------------
[  147.123630] WARNING: at net/ipv4/tcp_input.c:2776
tcp_fastretrans_alert+0xc14/0xc60()
[  147.123632] Modules linked in: snd_hda_codec_hdmi
snd_hda_codec_realtek coretemp kvm_intel snd_hda_intel kvm
snd_hda_codec arc4 iwldvm snd_hwdep ghash_clmulni_intel snd_pcm
aesni_intel i915 mac80211 rfcomm aes_x86_64 parport_pc snd_page_alloc
glue_helper bnep ppdev joydev snd_seq_midi lrw snd_seq_midi_event
uvcvideo gf128mul snd_rawmidi ablk_helper i2c_algo_bit snd_seq cryptd
iwlwifi videobuf2_vmalloc drm_kms_helper snd_timer btusb
videobuf2_memops drm snd_seq_device videobuf2_core bluetooth videodev
microcode psmouse snd cfg80211 soundcore samsung_laptop wmi lp
serio_raw video mac_hid lpc_ich parport hid_generic usbhid hid r8169
[  147.123675] CPU: 0 PID: 955 Comm: irq/48-iwlwifi Not tainted
3.9.0-rc8-next20130424-5-iniza-small #1
[  147.123678] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
[  147.123680]  ffffffff81a9ccd0 ffff88008f2fd4d8 ffffffff816ca97a
ffff88008f2fd518
[  147.123684]  ffffffff81059680 ffff88008f2fd500 ffff88008f1d0040
0000000000000000
[  147.123687]  0000000000000001 0000000000004320 0000000000000001
ffff88008f2fd528
[  147.123690] Call Trace:
[  147.123696]  [<ffffffff816ca97a>] dump_stack+0x19/0x1b
[  147.123700]  [<ffffffff81059680>] warn_slowpath_common+0x70/0xa0
[  147.123703]  [<ffffffff810596ca>] warn_slowpath_null+0x1a/0x20
[  147.123706]  [<ffffffff81628414>] tcp_fastretrans_alert+0xc14/0xc60
[  147.123710]  [<ffffffff81628eb0>] tcp_ack+0x990/0xd70
[  147.123713]  [<ffffffff8162982a>] tcp_rcv_established+0x1ca/0x860
[  147.123717]  [<ffffffff812d08f6>] ? security_sock_rcv_skb+0x16/0x20
[  147.123721]  [<ffffffff8168e4ed>] tcp_v6_do_rcv+0x35d/0x630
[  147.123726]  [<ffffffff8135d89c>] ? do_raw_spin_lock+0x4c/0x120
[  147.123729]  [<ffffffff8168ecda>] tcp_v6_rcv+0x51a/0x650
[  147.123732]  [<ffffffff816749b0>] ? ip6_pol_route.isra.47+0x440/0x440
[  147.123736]  [<ffffffff816691aa>] ip6_input_finish+0xda/0x310
[  147.123740]  [<ffffffff816697f2>] ip6_input+0x22/0x60
[  147.123743]  [<ffffffff816690c8>] ip6_rcv_finish+0x88/0x90
[  147.123746]  [<ffffffff81669655>] ipv6_rcv+0x275/0x3f0
[  147.123751]  [<ffffffff815de6ef>] __netif_receive_skb_core+0x54f/0x700
[  147.123754]  [<ffffffff815de8c1>] __netif_receive_skb+0x21/0x70
[  147.123757]  [<ffffffff815deb03>] netif_receive_skb+0x23/0x90
[  147.123772]  [<ffffffffa03115b1>]
ieee80211_deliver_skb.isra.32+0xa1/0x200 [mac80211]
[  147.123784]  [<ffffffffa03128f5>]
ieee80211_rx_handlers+0xc05/0x2530 [mac80211]
[  147.123789]  [<ffffffff8117b480>] ? poison_obj+0x30/0x40
[  147.123799]  [<ffffffffa03143af>]
ieee80211_prepare_and_rx_handle+0x18f/0xb00 [mac80211]
[  147.123802]  [<ffffffff8117ecac>] ? __kmalloc_node_track_caller+0x3c/0x50
[  147.123813]  [<ffffffffa0315026>] ieee80211_rx+0x306/0x8d0 [mac80211]
[  147.123821]  [<ffffffffa04920a7>] iwlagn_rx_reply_rx+0x437/0x740 [iwldvm]
[  147.123827]  [<ffffffffa0493625>] iwl_rx_dispatch+0xc5/0x120 [iwldvm]
[  147.123835]  [<ffffffffa02155a9>] iwl_pcie_irq_handler+0xb29/0x1240 [iwlwifi]
[  147.123839]  [<ffffffff810897fc>] ? finish_task_switch+0x5c/0x100
[  147.123844]  [<ffffffff810eaf90>] ? irq_thread_dtor+0xc0/0xc0
[  147.123847]  [<ffffffff810eafb5>] irq_thread_fn+0x25/0x50
[  147.123850]  [<ffffffff810eaf90>] ? irq_thread_dtor+0xc0/0xc0
[  147.123853]  [<ffffffff810eacbf>] irq_thread+0x12f/0x160
[  147.123857]  [<ffffffff810eaed0>] ? irq_finalize_oneshot.part.33+0xf0/0xf0
[  147.123860]  [<ffffffff810eab90>] ? irq_thread_check_affinity+0xb0/0xb0
[  147.123864]  [<ffffffff8107f9e8>] kthread+0xd8/0xe0
[  147.123867]  [<ffffffff8107f910>] ? flush_kthread_worker+0xe0/0xe0
[  147.123870]  [<ffffffff816da0ac>] ret_from_fork+0x7c/0xb0
[  147.123873]  [<ffffffff8107f910>] ? flush_kthread_worker+0xe0/0xe0
[  147.123875] ---[ end trace c85ed14f5e6c99b1 ]---

Thanks for feedback!

- Sedat -
