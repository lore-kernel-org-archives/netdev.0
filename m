From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236
Date: Thu, 4 May 2017 09:23:36 -0600
Message-ID: <240bae44-56e4-f342-0d1b-358a573e2eeb@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Running current -git on my laptop, and I see this spew every once
in a while. This is new, haven't seen it in 4.11 or previously. Driver
is iwlwifi:

04:00.0 Network controller: Intel Corporation Wireless 8260 (rev 3a)


[ 3285.862640] IPv6: ADDRCONF(NETDEV_CHANGE): wlp4s0: link becomes ready
[ 3285.978482] ------------[ cut here ]------------
[ 3285.978501] WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236 cfg80211_calculate_bitrate+0x130/0x160 [cfg80211]
[ 3285.978502] Modules linked in: ctr ccm rfcomm fuse bnep arc4 snd_hda_codec_hdmi iwlmvm snd_hda_codec_conexant snd_hda_codec_generic mac80211 snd_hda_intel snd_hda_codec binfmt_misc snd_hwdep snd_hda_core snd_pcm x86_pkg_temp_thermal nls_iso8859_1 intel_powerclamp nls_cp437 kvm_intel vfat snd_seq_midi fat kvm iwlwifi snd_seq_midi_event btusb snd_rawmidi btintel bluetooth snd_seq uvcvideo irqbypass aesni_intel videobuf2_vmalloc videobuf2_memops snd_seq_device aes_x86_64 videobuf2_v4l2 crypto_simd snd_timer videobuf2_core cryptd glue_helper videodev cfg80211 ecdh_generic snd soundcore hid_generic usbhid hid i915 psmouse e1000e ptp pps_core xhci_pci xhci_hcd intel_gtt
[ 3285.978536] CPU: 2 PID: 682 Comm: NetworkManager Tainted: G     U          4.11.0+ #59
[ 3285.978537] Hardware name: LENOVO 20FBCTO1WW/20FBCTO1WW, BIOS N1FET50W (1.24 ) 03/08/2017
[ 3285.978538] task: ffff880421de2880 task.stack: ffff8804234a8000
[ 3285.978551] RIP: 0010:cfg80211_calculate_bitrate+0x130/0x160 [cfg80211]
[ 3285.978552] RSP: 0018:ffff8804234ab638 EFLAGS: 00010293
[ 3285.978553] RAX: 0000000000000000 RBX: ffff88042df2cf00 RCX: 0000000000000002
[ 3285.978554] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8804234ab7d6
[ 3285.978555] RBP: ffff8804234ab638 R08: 0000000000000004 R09: ffff8804252c20d4
[ 3285.978556] R10: 00000000088002aa R11: ffffffffa02a6000 R12: ffff8804234ab7d6
[ 3285.978557] R13: ffff8804252c20d0 R14: ffff8804252c2030 R15: ffff880424bf0000
[ 3285.978559] FS:  00007f4e016a8940(0000) GS:ffff880441500000(0000) knlGS:0000000000000000
[ 3285.978560] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3285.978561] CR2: 00000c5e5d540010 CR3: 000000042b626000 CR4: 00000000001406e0
[ 3285.978561] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3285.978562] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 3285.978563] Call Trace:
[ 3285.978577]  nl80211_put_sta_rate+0x4e/0x1f0 [cfg80211]
[ 3285.978591]  nl80211_send_station.isra.66+0x344/0xcc0 [cfg80211]
[ 3285.978595]  ? __kmalloc_track_caller+0x31/0x1a0
[ 3285.978608]  nl80211_get_station+0x1d9/0x250 [cfg80211]
[ 3285.978620]  genl_family_rcv_msg+0x1bf/0x380
[ 3285.978622]  genl_rcv_msg+0x4c/0x90
[ 3285.978623]  ? genl_family_rcv_msg+0x380/0x380
[ 3285.978629]  netlink_rcv_skb+0x7f/0x110
[ 3285.978630]  genl_rcv+0x28/0x40
[ 3285.978633]  netlink_unicast+0x183/0x220
[ 3285.978635]  netlink_sendmsg+0x293/0x390
[ 3285.978637]  sock_sendmsg+0x38/0x50
[ 3285.978638]  ___sys_sendmsg+0x256/0x2b0
[ 3285.978641]  ? __slab_free+0x1d1/0x2c0
[ 3285.978643]  ? destroy_inode+0x3b/0x60
[ 3285.978645]  ? do_wp_page+0x103/0x440
[ 3285.978646]  ? __handle_mm_fault+0x34e/0xa10
[ 3285.978648]  ? __fget+0x6e/0x90
[ 3285.978650]  __sys_sendmsg+0x45/0x80
[ 3285.978652]  ? __sys_sendmsg+0x45/0x80
[ 3285.978654]  SyS_sendmsg+0x12/0x20
[ 3285.978656]  entry_SYSCALL_64_fastpath+0x13/0x94
[ 3285.978657] RIP: 0033:0x7f4dff521a6d
[ 3285.978658] RSP: 002b:00007ffc7507aec0 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
[ 3285.978660] RAX: ffffffffffffffda RBX: 0000000002044b60 RCX: 00007f4dff521a6d
[ 3285.978661] RDX: 0000000000000000 RSI: 00007ffc7507af50 RDI: 0000000000000010
[ 3285.978661] RBP: 00007f4dff50bb20 R08: 0000000000000000 R09: 0000000000000000
[ 3285.978662] R10: 0000000001fd8df0 R11: 0000000000000293 R12: 0000000000001010
[ 3285.978663] R13: 00007f4dff50bb78 R14: 00000000000026fc R15: 0000000001ffc570
[ 3285.978664] Code: d0 f7 e1 d1 ea 8d 14 92 01 d2 81 c2 50 c3 00 00 b9 c5 5a 7c 0a 5d c1 ea 05 89 d0 f7 e1 89 d0 c1 e8 07 c3 31 c0 40 80 fe 02 74 b6 <0f> ff 31 c0 eb b0 8d 14 52 01 d2 e9 41 ff ff ff 0f ff 31 c0 5d 
[ 3285.978693] ---[ end trace ae08dfa326cc120a ]---

-- 
Jens Axboe
