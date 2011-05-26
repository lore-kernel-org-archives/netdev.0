From: Parag Warudkar <parag.lkml@gmail.com>
Subject: atl1c suspend issue - remove_proc_entry: removing non-empty directory
 'irq/44', leaking at least 'smp_affinity_list'
Date: Wed, 25 May 2011 21:50:12 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1105252144500.2539@ubuntu-natty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got this on suspend :

[  115.182723] cfg80211:     (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[  115.182732] cfg80211:     (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[  115.182740] cfg80211:     (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[  115.182747] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[  115.182755] cfg80211:     (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[  115.292922] ------------[ cut here ]------------
[  115.292949] WARNING: at fs/proc/generic.c:849 remove_proc_entry+0x26e/0x280()
[  115.292959] Hardware name: 0876                            
[  115.292969] remove_proc_entry: removing non-empty directory 'irq/44', leaking at least 'smp_affinity_list'
[  115.292979] Modules linked in: cryptd aes_x86_64 aes_generic parport_pc ppdev nls_utf8 udf crc_itu_t fuse binfmt_misc joydev snd_hda_codec_hdmi snd_hda_codec_realtek i915 snd_hda_intel snd_hda_codec arc4 drm_kms_helper drm snd_hwdep i2c_algo_bit iwlagn snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq cfbcopyarea cfbimgblt snd_timer cfbfillrect mac80211 snd_seq_device snd uvcvideo usb_storage soundcore cfg80211 videodev ideapad_laptop v4l2_compat_ioctl32 psmouse video snd_page_alloc serio_raw intel_ips sparse_keymap btusb mac_hid lp bluetooth parport ext4 mbcache jbd2 ahci libahci libata atl1c
[  115.293170] Pid: 749, comm: NetworkManager Not tainted 2.6.39+ #11
[  115.293179] Call Trace:
[  115.293204]  [<ffffffff8105875f>] warn_slowpath_common+0x7f/0xc0
[  115.293218]  [<ffffffff81058856>] warn_slowpath_fmt+0x46/0x50
[  115.293232]  [<ffffffff8119f84e>] remove_proc_entry+0x26e/0x280
[  115.293251]  [<ffffffff811f59e0>] ? sprintf+0x40/0x50
[  115.293270]  [<ffffffff810b7db7>] unregister_irq_proc+0xb7/0xe0
[  115.293285]  [<ffffffff810b3a4c>] free_desc+0x2c/0x70
[  115.293297]  [<ffffffff810b3ada>] irq_free_descs+0x4a/0x90
[  115.293314]  [<ffffffff81029c9b>] free_irq_at+0x3b/0x50
[  115.293329]  [<ffffffff8102bc7b>] destroy_irq+0x7b/0x90
[  115.293343]  [<ffffffff8102bf0e>] native_teardown_msi_irq+0xe/0x10
[  115.293359]  [<ffffffff8122282f>] default_teardown_msi_irqs+0x6f/0x90
[  115.293374]  [<ffffffff81222216>] free_msi_irqs+0x96/0x130
[  115.293387]  [<ffffffff81222ec5>] pci_disable_msi+0x45/0x50
[  115.293414]  [<ffffffffa0002ef7>] atl1c_down+0xc7/0x110 [atl1c]
[  115.293434]  [<ffffffffa00034f8>] atl1c_close+0x28/0x50 [atl1c]
[  115.293452]  [<ffffffff8138f666>] __dev_close_many+0x86/0xd0
[  115.293467]  [<ffffffff8138f6e6>] __dev_close+0x36/0x50
[  115.293480]  [<ffffffff81395681>] __dev_change_flags+0xa1/0x180
[  115.293492]  [<ffffffff81395828>] dev_change_flags+0x28/0x70
[  115.293508]  [<ffffffff813a3220>] do_setlink+0x200/0x9f0
[  115.293527]  [<ffffffff81047ef0>] ? update_curr+0x100/0x1a0
[  115.293541]  [<ffffffff81205390>] ? nla_parse+0x30/0xd0
[  115.293555]  [<ffffffff813a3aff>] rtnl_setlink+0xef/0x130
[  115.293572]  [<ffffffff813a16bf>] rtnetlink_rcv_msg+0x20f/0x240
[  115.293587]  [<ffffffff813a14b0>] ? rtnetlink_net_init+0x50/0x50
[  115.293604]  [<ffffffff813bb8e9>] netlink_rcv_skb+0xa9/0xd0
[  115.293620]  [<ffffffff813a2055>] rtnetlink_rcv+0x25/0x40
[  115.293635]  [<ffffffff813bb223>] netlink_unicast+0x2d3/0x2f0
[  115.293648]  [<ffffffff8138998d>] ? memcpy_fromiovec+0x7d/0xa0
[  115.293662]  [<ffffffff813bb462>] netlink_sendmsg+0x222/0x360
[  115.293678]  [<ffffffff8137d0cf>] sock_sendmsg+0xef/0x120
[  115.293695]  [<ffffffff814201dd>] ? unix_dgram_sendmsg+0x5cd/0x650
[  115.293711]  [<ffffffff8137d0cf>] ? sock_sendmsg+0xef/0x120
[  115.293725]  [<ffffffff8137ecc0>] ? move_addr_to_kernel+0x50/0x60
[  115.293738]  [<ffffffff81389a32>] ? verify_iovec+0x82/0xf0
[  115.293751]  [<ffffffff8137e79d>] __sys_sendmsg+0x1dd/0x340
[  115.293765]  [<ffffffff8137b893>] ? sock_destroy_inode+0x33/0x40
[  115.293783]  [<ffffffff8112dfd0>] ? kmem_cache_free+0x20/0xe0
[  115.293798]  [<ffffffff8137f796>] ? sys_sendto+0x156/0x190
[  115.293813]  [<ffffffff8115d65f>] ? mntput+0x1f/0x30
[  115.293827]  [<ffffffff8137fc19>] sys_sendmsg+0x49/0x90
[  115.293847]  [<ffffffff81487c82>] system_call_fastpath+0x16/0x1b
[  115.293858] ---[ end trace e0ec9dc53f93f46e ]---
[  116.649267] EXT4-fs (sda6): re-mounted. Opts: errors=remount-ro,commit=0
[  116.652785] EXT4-fs (sda1): re-mounted. Opts: commit=0
[  117.994536] PM: Syncing filesystems ... done.
[  117.996922] PM: Preparing system for mem sleep
[  118.449261] Freezing user space processes ... (elapsed 0.01 seconds) done.
[  118.462504] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[  118.475800] PM: Entering mem sleep
[  118.475902] Suspending console(s) (use no_console_suspend to debug)
[  118.476562] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[  118.478045] sd 0:0:0:0: [sda] Stopping disk
[  118.608869] ehci_hcd 0000:00:1a.0: PCI INT A disabled
[  118.608903] ehci_hcd 0000:00:1d.0: PCI INT A disabled
