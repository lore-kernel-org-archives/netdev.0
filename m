From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sun, 15 Jan 2012 00:08:39 +0100
Message-ID: <20120114230839.GA12667@nautica>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <20120114122222.GA21233@nautica>
 <CA+55aFxTkKwTy8mq9vRzHLNE7W8SYd5kbg2Ofr8LiG0DznLy6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Arend van Spriel <arend@broadcom.com>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:44763 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2ANXI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jan 2012 18:08:56 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFxTkKwTy8mq9vRzHLNE7W8SYd5kbg2Ofr8LiG0DznLy6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Linus Torvalds wrote on Sat, Jan 14, 2012 :
> The commit that should fix MCE is just a oneliner: commit a3301b751b19
> ("x86/mce: Fix CPU hotplug and suspend regression related to MCE").

Right, I missed it. Suspend works as long as I don't use wireless
before.
I still get a warning:

[   30.256946] ------------[ cut here ]------------
[   30.256956] WARNING: at drivers/base/core.c:194
device_release+0x6a/0x73()
[   30.256960] Hardware name: 1215B
[   30.256963] Device 'machinecheck1' does not have a release()
function, it is broken and must be fixed.
[   30.256966] Modules linked in: tun ipv6 snd_hrtimer uinput fuse ext4
jbd2 crc16 ext2 mbcache loop kvm_amd kvm snd_hda_codec_realtek
snd_hda_codec_hdmi brcmsmac mac80211 brcmutil cfg80211 crc8 cordic
eeepc_wmi asus_wmi sparse_keymap rfkill pci_hotplug uvcvideo videodev
media v4l2_compat_ioctl32 evdev psmouse snd_hda_intel snd_hda_codec
snd_hwdep snd_seq snd_pcm k10temp i2c_piix4 snd_timer snd_seq_device
bcma radeon snd ttm drm_kms_helper soundcore drm snd_page_alloc
i2c_algo_bit i2c_core battery ac power_supply video wmi button processor
xfs exportfs dm_mod sg sd_mod crc_t10dif thermal ohci_hcd xhci_hcd
thermal_sys ahci libahci ehci_hcd libata usbcore scsi_mod usb_common
[last unloaded: scsi_wait_scan]
[   30.257049] Pid: 3468, comm: pm-suspend Tainted: G        W    3.2.0+ #3
[   30.257052] Call Trace:
[   30.257063]  [<ffffffff8102e4b1>] ? warn_slowpath_common+0x78/0x8c
[   30.257069]  [<ffffffff8102e566>] ? warn_slowpath_fmt+0x45/0x4a
[   30.257075]  [<ffffffff811a4be3>] ? add_uevent_var+0xd9/0xd9
[   30.257080]  [<ffffffff81246c6b>] ? device_release+0x6a/0x73
[   30.257086]  [<ffffffff811a4090>] ? kobject_release+0x48/0x5e
[   30.257093]  [<ffffffff8130b17d>] ? mce_cpu_callback+0xdf/0x175
[   30.257101]  [<ffffffff8104bb15>] ? notifier_call_chain+0x2e/0x5b
[   30.257106]  [<ffffffff8102fb59>] ? __cpu_notify+0x1b/0x30
[   30.257110]  [<ffffffff8102fb86>] ? cpu_notify_nofail+0x9/0x14
[   30.257116]  [<ffffffff812ff826>] ? _cpu_down+0x133/0x1f4
[   30.257122]  [<ffffffff8102fd0b>] ? disable_nonboot_cpus+0x58/0xf3
[   30.257127]  [<ffffffff8106ed71>] ? suspend_devices_and_enter+0xd7/0x1c4
[   30.257132]  [<ffffffff8106ef5d>] ? enter_state+0xff/0x10d
[   30.257138]  [<ffffffff8106e1b0>] ? state_store+0xb4/0x108
[   30.257144]  [<ffffffff81144a19>] ? sysfs_write_file+0xd3/0x10f
[   30.257149]  [<ffffffff810f3c96>] ? vfs_write+0xa6/0xf9
[   30.257154]  [<ffffffff810f3e8b>] ? sys_write+0x45/0x6b
[   30.257160]  [<ffffffff813150f9>] ? system_call_fastpath+0x16/0x1b
[   30.257165] ---[ end trace 527780f5547f85b2 ]---

but it does work.


brcmsmac seems to have a problem that looks like it's fixed in
wireless-next, after a suspend if it's been used then all network
operation hang (i.e. 'ip addr', something like resolving an host doesn't
work but doesn't hang either, modprobe -r brcmsmac hangs as well)
Here's the revelent information about this:

[  232.352927] ieee80211 phy0: wl0: wlc_coreinit: ucode did not self-suspend!
[  232.490867] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.490877] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  232.587468] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.587477] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  232.684150] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.684159] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  232.780771] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.780781] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  232.884260] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.884271] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  232.987619] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  232.987630] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  233.090996] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  233.091007] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  233.194345] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  233.194356] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  233.194380] ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
[  233.297619] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  233.297630] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  233.297703] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
[  233.297710] ieee80211 phy0: changing basic rates failed: -22
[  233.297715] ieee80211 phy0: brcms_ops_bss_info_changed: cqm change: threshold 0, hys 0  (implement)
[  233.297720] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 1 (implement)
[  233.297724] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true (implement)
...
[  233.892239] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  233.892256] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000031, psm_brc 0x0000
[  233.988440] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  233.988452] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  234.084714] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  234.084725] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  234.180626] ieee80211 phy0: wl0: wlc_suspend_mac_and_wait: waited 83000 uS and MI_MACSSPNDD is still not on.
[  234.180637] ieee80211 phy0: wl0: psmdebug 0x00ff8f7f, phydebug 0x00000000, psm_brc 0x0000
[  234.180658] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[  234.180668] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: disassociated
[  234.180677] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled false, count 1 (implement)

and when something hangs:

[  361.248353] INFO: task wpa_supplicant:9102 blocked for more than 120 seconds.
[  361.248362] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  361.248367] wpa_supplicant  D ffff880062d68400     0  9102      1 0x00000000
[  361.248375]  ffff880062d68400 0000000000000082 ffff88005f72df38 ffff8800580e27b0
[  361.248383]  0000000000012080 ffff88005f72dfd8 ffff88005f72dfd8 0000000000012080
[  361.248390]  ffff880062d68400 0000000000012080 0000000000012080 0000000000012080
[  361.248397] Call Trace:
[  361.248411]  [<ffffffff81313307>] ? __mutex_lock_common.clone.5+0x114/0x179
[  361.248432]  [<ffffffffa03bef8a>] ? cfg80211_wext_siwscan+0xbd/0x2dc [cfg80211]
[  361.248439]  [<ffffffff81313137>] ? mutex_lock+0x12/0x25
[  361.248458]  [<ffffffffa03f83c1>] ? ieee80211_request_scan+0x20/0x4e [mac80211]
[  361.248469]  [<ffffffffa03bf151>] ? cfg80211_wext_siwscan+0x284/0x2dc [cfg80211]
[  361.248477]  [<ffffffff812f910e>] ? ioctl_standard_iw_point+0x142/0x26f
[  361.248484]  [<ffffffff810e7982>] ? __kmalloc+0xd0/0xe2
[  361.248490]  [<ffffffff812f9199>] ? ioctl_standard_iw_point+0x1cd/0x26f
[  361.248501]  [<ffffffffa03beecd>] ? cfg80211_unlock_rdev+0x21/0x21 [cfg80211]
[  361.248507]  [<ffffffff812f937c>] ? ioctl_standard_call+0x7d/0xa4
[  361.248513]  [<ffffffff812f9c66>] ? iw_handler_get_private+0x4c/0x4c
[  361.248519]  [<ffffffff812f9c66>] ? iw_handler_get_private+0x4c/0x4c
[  361.248525]  [<ffffffff812f9c66>] ? iw_handler_get_private+0x4c/0x4c
[  361.248531]  [<ffffffff812f92ff>] ? call_commit_handler+0x31/0x31
[  361.248536]  [<ffffffff812f8a33>] ? wext_ioctl_dispatch+0x8b/0x194
[  361.248542]  [<ffffffff812f9452>] ? wext_handle_ioctl+0x33/0x69
[  361.248550]  [<ffffffff812887f4>] ? dev_ioctl+0x5db/0x620
[  361.248557]  [<ffffffff810c9c1d>] ? tlb_flush_mmu+0x37/0x50
[  361.248563]  [<ffffffff810f4d71>] ? fget_light+0x2e/0x77
[  361.248568]  [<ffffffff810f4d71>] ? fget_light+0x2e/0x77
[  361.248576]  [<ffffffff81273f67>] ? sock_ioctl+0x41/0x204
[  361.248582]  [<ffffffff811013bf>] ? do_vfs_ioctl+0x416/0x455
[  361.248588]  [<ffffffff81101449>] ? sys_ioctl+0x4b/0x72
[  361.248595]  [<ffffffff813150f9>] ? system_call_fastpath+0x16/0x1b


Since it looks fixed with linux-next and the patches I don't know if it
is really important to fix, but it could be that some of the patches
that were intended for linux-next would help with some minor changes.


Regards,
-- 
Dominique Martinet | Asmadeus
