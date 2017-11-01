From: Dave Taht <dave.taht@gmail.com>
Subject: Oops with HTB on net-next
Date: Tue, 31 Oct 2017 23:42:14 -0700
Message-ID: <CAA93jw6y3-uO2uXJqiWeu0YeKZCuMyXCO9zvoWXBs=Z04-=KbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:44955 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdKAGmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 02:42:16 -0400
Received: by mail-qt0-f175.google.com with SMTP id 8so1585730qtv.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 23:42:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using a fairly complex htb + three tiers of fq_codel and a couple
tc filters (it's the sqm-scripts "simple.qos" model). I rebased on
net-next head an hour ago, and....

[    8.357963] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becomes ready
[    9.759942] u32 classifier
[    9.759944]     Actions configured
[    9.762152] Mirror/redirect action on
[    9.859138] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000018
[    9.859149] IP: tcf_block_put+0xf/0x50
[    9.859151] PGD 144e8e067 P4D 144e8e067 PUD 144ea3067 PMD 0
[    9.859155] Oops: 0000 [#1] PREEMPT SMP
[    9.859157] Modules linked in: act_mirred cls_u32 sch_ingress
sch_fq_codel sch_htb ifb bnep binfmt_misc nls_iso8859_1 arc4
intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp
snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic
kvm_intel ath9k snd_hda_intel kvm ath9k_common ath9k_hw irqbypass
snd_hda_codec crct10dif_pclmul ath snd_hda_core crc32_pclmul
ghash_clmulni_intel snd_hwdep mac80211 uvcvideo pcbc videobuf2_vmalloc
videobuf2_memops snd_pcm videobuf2_v4l2 videobuf2_core aesni_intel
snd_seq_midi ath3k snd_seq_midi_event aes_x86_64 crypto_simd
glue_helper cfg80211 snd_rawmidi cryptd videodev btusb serio_raw btrtl
snd_seq btbcm btintel snd_seq_device media bluetooth input_leds
snd_timer lpc_ich ecdh_generic snd mei_me soundcore mei shpchp
topstar_laptop sparse_keymap acpi_als acpi_pad
[    9.859194]  mac_hid kfifo_buf industrialio sch_fq cuse parport_pc
ppdev lp sunrpc parport autofs4 hid_generic usbhid hid i915
i2c_algo_bit drm_kms_helper syscopyarea r8169 sysfillrect sysimgblt
fb_sys_fops ahci drm libahci mii video
[    9.859209] CPU: 3 PID: 1644 Comm: tc Not tainted 4.14.0-rc7-netem-3 #1
[    9.859210] Hardware name: Intel Corporation SharkBay
Platform/WhiteTip Mountain1 Fab2, BIOS 5.6.5 06/18/2015
[    9.859212] task: ffff8eb5c3ea1e80 task.stack: ffffac13c160c000
[    9.859214] RIP: 0010:tcf_block_put+0xf/0x50
[    9.859215] RSP: 0018:ffffac13c160f9b8 EFLAGS: 00010286
[    9.859217] RAX: ffff8eb5c4febc01 RBX: ffff8eb5c6668000 RCX: 0000000000f=
98e03
[    9.859218] RDX: 0000000000f98c03 RSI: 0000000000000000 RDI: 00000000000=
00000
[    9.859220] RBP: ffffac13c160f9c8 R08: 000000000001f820 R09: ffffffffb37=
f0048
[    9.859221] R10: ffffcf324513fa80 R11: 0000000000000001 R12: ffff8eb5c66=
67000
[    9.859222] R13: 0000000000000001 R14: ffff8eb5c4febe00 R15: 00000000000=
00001
[    9.859223] FS:  00007f322bc3e700(0000) GS:ffff8eb5ced80000(0000)
knlGS:0000000000000000
[    9.859225] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    9.859226] CR2: 0000000000000018 CR3: 0000000144f82002 CR4: 00000000003=
606e0
[    9.859227] Call Trace:
[    9.859232]  htb_destroy_class.isra.18+0x3a/0x50 [sch_htb]
[    9.859235]  htb_destroy+0xbe/0x160 [sch_htb]
[    9.859237]  qdisc_destroy+0x5d/0xd0
[    9.859240]  notify_and_destroy+0x2c/0x30
[    9.859242]  qdisc_graft+0x2bd/0x370
[    9.859244]  tc_get_qdisc+0x18f/0x230
[    9.859250]  rtnetlink_rcv_msg+0x15c/0x270
[    9.859252]  ? proto_seq_start+0x30/0x30
[    9.859254]  ? __kmalloc_node_track_caller+0x35/0x2d0
[    9.859256]  ? rtnl_calcit.isra.29+0x110/0x110
[    9.859258]  netlink_rcv_skb+0xe7/0x120
[    9.859260]  rtnetlink_rcv+0x15/0x20
[    9.859262]  netlink_unicast+0x196/0x240
[    9.859264]  netlink_sendmsg+0x2c5/0x3a0
[    9.859267]  sock_sendmsg+0x38/0x50
[    9.859269]  ___sys_sendmsg+0x2b6/0x2d0
[    9.859272]  ? pagevec_lru_move_fn+0xc8/0xe0
[    9.859274]  ? __activate_page+0x2c0/0x2c0
[    9.859276]  ? __lru_cache_add+0x5f/0x80
[    9.859278]  ? lru_cache_add_active_or_unevictable+0x36/0xb0
[    9.859282]  __sys_sendmsg+0x54/0x90
[    9.859284]  ? __sys_sendmsg+0x54/0x90
[    9.859287]  SyS_sendmsg+0x12/0x20
[    9.859290]  entry_SYSCALL_64_fastpath+0x1e/0xa9
[    9.859292] RIP: 0033:0x7f322b274450
[    9.859293] RSP: 002b:00007ffcb4925018 EFLAGS: 00000246 ORIG_RAX:
000000000000002e
[    9.859295] RAX: ffffffffffffffda RBX: 00007ffcb4925000 RCX: 00007f322b2=
74450
[    9.859296] RDX: 0000000000000000 RSI: 00007ffcb4925060 RDI: 00000000000=
00003
[    9.859297] RBP: 0000000059f95db7 R08: 0000000000000014 R09: 00000000000=
00000
[    9.859298] R10: 00000000000005e7 R11: 0000000000000246 R12: 00007ffcb49=
25060
[    9.859299] R13: 00007ffcb493d2b0 R14: 0000000000655aa0 R15: 00000000000=
00000
[    9.859301] Code: 48 8d 53 30 bf 00 02 00 00 e8 ee 71 8a ff 5b 5d
f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 31 f6 48 89 e5
48 83 ec 10 <48> 8b 57 18 48 8d 4d f4 c7 45 f4 00 00 00 00 65 48 8b 04
25 28
[    9.859329] RIP: tcf_block_put+0xf/0x50 RSP: ffffac13c160f9b8
[    9.859330] CR2: 0000000000000018
[    9.859332] ---[ end trace 92295ce23d2d8592 ]---

Things have gone wrong somewhere between

commit aa2bc739ef4a181a7589eb009be96a870cc1788f
Author: Jakub Kicinski <jakub.kicinski@netronome.com>
Date:   Mon Oct 30 13:46:47 2017 -0700

and:

commit ca82214144d925155977abe7c0af7c2c252b837f
Merge: f5333f80 75c119a
Author: David S. Miller <davem@davemloft.net>
Date:   Sat Oct 7 00:28:54 2017 +0100

    Merge branch 'tcp-rbtree-retransmit-queue'



--=20

Dave T=C3=A4ht
CEO, TekLibre, LLC
http://www.teklibre.com
Tel: 1-669-226-2619
