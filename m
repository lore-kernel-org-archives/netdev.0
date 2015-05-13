From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: BUG: rwlock bad magic on CPU#1, NetworkManager/
Date: Wed, 13 May 2015 14:49:39 -0700
Message-ID: <20150513214939.GA4755@hudson.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33596 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137AbbEMVtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:49:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

all,

Running the latest linux-next (20150513) on an Acer C720 causes the
machine to lockup as the window manager is started.  The following BUG
messages and trace are found in the logs from the failed boot (full log
is attached).

May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-adsl.so
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wwan.so
May 13 14:25:25 newt NetworkManager[1182]: <info> WiFi enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> WWAN enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> WiMAX enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> Networking is enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): link connected
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): carrier is ON
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): new Generic device (driver: 'unknown' ifindex: 1)
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): exported as /org/freedesktop/NetworkManager/Devices/0
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): using nl80211 for WiFi device control
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): driver supports Access Point (AP) mode
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): new 802.11 WiFi device (driver: 'ath9k' ifindex: 2)
May 13 14:25:25 newt kernel: random: nonblocking pool is initialized
May 13 14:25:25 newt kernel: BUG: rwlock bad magic on CPU#1, NetworkManager/1182, ffff880074862918
May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862930 ffffffff815628c6 ffff880074862918
May 13 14:25:25 newt kernel:  ffffffff810b6594 ffff880074862900 ffffffffa05a941b 0000000000000001
May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862900 ffff880074862900 ffff880071e50740
May 13 14:25:25 newt kernel: Call Trace:
May 13 14:25:25 newt kernel:  [<ffffffff815628c6>] ? dump_stack+0x40/0x50
May 13 14:25:25 newt kernel:  [<ffffffff810b6594>] ? do_raw_read_lock+0x34/0x50
May 13 14:25:25 newt kernel:  [<ffffffffa05a941b>] ? tpt_trig_timer+0xdb/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
May 13 14:25:25 newt kernel: BUG: unable to handle kernel paging request at ffffffffffffff48
May 13 14:25:25 newt kernel: IP: [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
May 13 14:25:25 newt kernel: PGD 1810067 PUD 1812067 PMD 0 
May 13 14:25:25 newt kernel: Oops: 0000 [#1] SMP 
May 13 14:25:25 newt kernel: Modules linked in: binfmt_misc snd_hda_codec_hdmi uvcvideo hid_generic videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common usbhid videodev hid media cyapatp crc_itu_t tpm_infineon iTCO_wdt iTCO_vendor_support arc4 ath9k ath9k_common ath9k_hw x86_pkg_temp_thermal intel_powerclamp intel_rapl iosf_mbi coretemp kvm_intel kvm ath mac80211 crct10dif_pclmul crc32_pclmul chromeos_laptop crc32c_intel ghash_clmulni_intel cryptd evdev cfg80211 serio_raw pcspkr i915 i2c_i801 tpm_tis ac tpm battery snd_hda_codec_realtek snd_hda_codec_generic ath3k snd_hda_intel btusb snd_hda_codec btintel i2c_algo_bit drm_kms_helper video bluetooth snd_hwdep snd_hda_core drm snd_pcm button processor rfkill snd_timer lpc_ich shpchp snd mfd_core i2c_designware_pci i2c_designware_cor
 e i2c_core soundcore fuse
May 13 14:25:25 newt kernel:  autofs4 ext4 crc16 mbcache jbd2 sg sd_mod fan ahci libahci thermal sdhci_acpi sdhci mmc_core thermal_sys xhci_pci xhci_hcd usbcore libata scsi_mod usb_common
May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
May 13 14:25:25 newt kernel: task: ffff88003529a250 ti: ffff880035590000 task.ti: ffff880035590000
May 13 14:25:25 newt kernel: RIP: 0010:[<ffffffff810d3075>]  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
May 13 14:25:25 newt kernel: RSP: 0018:ffff8800355936e8  EFLAGS: 00010296
May 13 14:25:25 newt kernel: RAX: 0000000000000000 RBX: ffffffffffffff30 RCX: 0000000000000006
May 13 14:25:25 newt kernel: RDX: ffff880035593780 RSI: ffff880035593720 RDI: ffffffffffffff48
May 13 14:25:25 newt kernel: RBP: ffff880035593778 R08: 000000000000000a R09: 00000000fffffffe
May 13 14:25:25 newt kernel: R10: 0000000000000296 R11: 0000000000000002 R12: ffffffffffffff48
May 13 14:25:25 newt kernel: R13: ffff880035593720 R14: 0000000000000001 R15: ffff880074b90a60
May 13 14:25:25 newt kernel: FS:  00007f00b64ea8c0(0000) GS:ffff880100300000(0000) knlGS:0000000000000000
May 13 14:25:25 newt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
May 13 14:25:25 newt kernel: CR2: ffffffffffffff48 CR3: 00000000715b5000 CR4: 00000000000407e0
May 13 14:25:25 newt kernel: Stack:
May 13 14:25:25 newt kernel:  0000000000000000 ffffffffffffff30 ffff880035593778 ffff880035593780
May 13 14:25:25 newt kernel:  0000000000000000 ffffffff810d429c 0000000000000000 0000000000000001
May 13 14:25:25 newt kernel:  ffff880074b90a60 ffffffffffffff30 ffff880035593778 ffffffff810d432a
May 13 14:25:25 newt kernel: Call Trace:
May 13 14:25:25 newt kernel:  [<ffffffff810d429c>] ? try_to_del_timer_sync+0x1c/0x60
May 13 14:25:25 newt kernel:  [<ffffffff810d432a>] ? del_timer_sync+0x4a/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8143e61b>] ? led_blink_set+0x1b/0x40
May 13 14:25:25 newt kernel:  [<ffffffffa05a9440>] ? tpt_trig_timer+0x100/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
May 13 14:25:25 newt kernel: Code: 1a 83 e2 3f e8 9d fc ff ff e9 e3 fd ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 41 55 41 54 49 89 f5 55 53 49 89 fc 48 83 ec 08 <49> 8b 1c 24 48 89 dd 48 83 e5 fc 74 31 48 89 ef e8 86 61 49 00 
May 13 14:25:25 newt kernel: RIP  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60

If I disable NetworkManager

  systemctl disable NetworkManager.service

and reboot, everything works, except networking is down.

So somehow NetworkManager is triggering a fault although I am not sure
how.  Any suggestions for what to try next are welcome.

-- 
- Jeremiah Mahler

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="dmesg-20150513.log"
Content-Transfer-Encoding: 8bit

-- Logs begin at Wed 2015-05-13 00:03:45 PDT, end at Wed 2015-05-13 14:28:21 PDT. --
May 13 14:25:23 newt systemd-journal[158]: Runtime journal is using 4.6M (max allowed 37.5M, trying to leave 56.3M free of 371.0M available → current limit 37.5M).
May 13 14:25:23 newt systemd-journal[158]: Runtime journal is using 4.6M (max allowed 37.5M, trying to leave 56.3M free of 371.0M available → current limit 37.5M).
May 13 14:25:23 newt kernel: Initializing cgroup subsys cpuset
May 13 14:25:23 newt kernel: Initializing cgroup subsys cpu
May 13 14:25:23 newt kernel: Initializing cgroup subsys cpuacct
May 13 14:25:23 newt kernel: Linux version 4.1.0-rc3-next-20150513+ (jeri@newt) (gcc version 4.9.2 (Debian 4.9.2-10) ) #192 SMP Wed May 13 14:21:52 PDT 2015
May 13 14:25:23 newt kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-4.1.0-rc3-next-20150513+ root=UUID=e5fd0a8b-e57d-428c-831e-3aff30526800 ro quiet
May 13 14:25:23 newt kernel: e820: BIOS-provided physical RAM map:
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000002ffff] usable
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000000030000-0x000000000003ffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000000040000-0x000000000009e3ff] usable
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x000000000009e400-0x000000000009ffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000000100000-0x0000000000efffff] usable
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000000f00000-0x0000000000ffffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000001000000-0x000000007bf79fff] usable
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x000000007bf7a000-0x000000007e9fffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x00000000f0000000-0x00000000f3ffffff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x00000000fed10000-0x00000000fed19fff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x00000000fed84000-0x00000000fed84fff] reserved
May 13 14:25:23 newt kernel: BIOS-e820: [mem 0x0000000100000000-0x00000001005fffff] usable
May 13 14:25:23 newt kernel: NX (Execute Disable) protection: active
May 13 14:25:23 newt kernel: SMBIOS 2.7 present.
May 13 14:25:23 newt kernel: DMI: Acer Peppy, BIOS          04/30/2014
May 13 14:25:23 newt kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
May 13 14:25:23 newt kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
May 13 14:25:23 newt kernel: e820: last_pfn = 0x100600 max_arch_pfn = 0x400000000
May 13 14:25:23 newt kernel: MTRR default type: uncachable
May 13 14:25:23 newt kernel: MTRR fixed ranges enabled:
May 13 14:25:23 newt kernel:   00000-9FFFF write-back
May 13 14:25:23 newt kernel:   A0000-BFFFF uncachable
May 13 14:25:23 newt kernel:   C0000-FFFFF write-back
May 13 14:25:23 newt kernel: MTRR variable ranges enabled:
May 13 14:25:23 newt kernel:   0 base 0000000000 mask 7F80000000 write-back
May 13 14:25:23 newt kernel:   1 base 007C800000 mask 7FFF800000 uncachable
May 13 14:25:23 newt kernel:   2 base 007D000000 mask 7FFF000000 uncachable
May 13 14:25:23 newt kernel:   3 base 007E000000 mask 7FFE000000 uncachable
May 13 14:25:23 newt kernel:   4 base 00D0000000 mask 7FF0000000 write-combining
May 13 14:25:23 newt kernel:   5 base 00FF800000 mask 7FFF800000 uncachable
May 13 14:25:23 newt kernel:   6 base 0100000000 mask 7F00000000 write-back
May 13 14:25:23 newt kernel:   7 disabled
May 13 14:25:23 newt kernel:   8 disabled
May 13 14:25:23 newt kernel:   9 disabled
May 13 14:25:23 newt kernel: PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
May 13 14:25:23 newt kernel: e820: last_pfn = 0x7bf7a max_arch_pfn = 0x400000000
May 13 14:25:23 newt kernel: Base memory trampoline at [ffff880000098000] 98000 size 24576
May 13 14:25:23 newt kernel: Using GB pages for direct mapping
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x00000000-0x000fffff]
May 13 14:25:23 newt kernel:  [mem 0x00000000-0x000fffff] page 4k
May 13 14:25:23 newt kernel: BRK [0x01b24000, 0x01b24fff] PGTABLE
May 13 14:25:23 newt kernel: BRK [0x01b25000, 0x01b25fff] PGTABLE
May 13 14:25:23 newt kernel: BRK [0x01b26000, 0x01b26fff] PGTABLE
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x100400000-0x1005fffff]
May 13 14:25:23 newt kernel:  [mem 0x100400000-0x1005fffff] page 2M
May 13 14:25:23 newt kernel: BRK [0x01b27000, 0x01b27fff] PGTABLE
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x100000000-0x1003fffff]
May 13 14:25:23 newt kernel:  [mem 0x100000000-0x1003fffff] page 2M
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x60000000-0x7bf79fff]
May 13 14:25:23 newt kernel:  [mem 0x60000000-0x7bdfffff] page 2M
May 13 14:25:23 newt kernel:  [mem 0x7be00000-0x7bf79fff] page 4k
May 13 14:25:23 newt kernel: BRK [0x01b28000, 0x01b28fff] PGTABLE
May 13 14:25:23 newt kernel: BRK [0x01b29000, 0x01b29fff] PGTABLE
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x40000000-0x5fffffff]
May 13 14:25:23 newt kernel:  [mem 0x40000000-0x5fffffff] page 2M
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x00100000-0x00efffff]
May 13 14:25:23 newt kernel:  [mem 0x00100000-0x001fffff] page 4k
May 13 14:25:23 newt kernel:  [mem 0x00200000-0x00dfffff] page 2M
May 13 14:25:23 newt kernel:  [mem 0x00e00000-0x00efffff] page 4k
May 13 14:25:23 newt kernel: init_memory_mapping: [mem 0x01000000-0x3fffffff]
May 13 14:25:23 newt kernel:  [mem 0x01000000-0x3fffffff] page 2M
May 13 14:25:23 newt kernel: RAMDISK: [mem 0x35264000-0x36929fff]
May 13 14:25:23 newt kernel: ACPI: Early table checksum verification disabled
May 13 14:25:23 newt kernel: ACPI: RSDP 0x00000000000FDBB0 000024 (v02 CORE  )
May 13 14:25:23 newt kernel: ACPI: XSDT 0x000000007BF840E0 000054 (v01 CORE   COREBOOT 00000000 CORE 00000000)
May 13 14:25:23 newt kernel: ACPI: FACP 0x000000007BF88690 0000F4 (v03 CORE   COREBOOT 00000000 CORE 00000001)
May 13 14:25:23 newt kernel: ACPI: DSDT 0x000000007BF84250 004431 (v02 COREv4 COREBOOT 20110725 INTL 20090123)
May 13 14:25:23 newt kernel: ACPI: FACS 0x000000007BF84210 000040
May 13 14:25:23 newt kernel: ACPI: HPET 0x000000007BF88790 000038 (v01 CORE   COREBOOT 00000000 CORE 00000000)
May 13 14:25:23 newt kernel: ACPI: APIC 0x000000007BF887D0 00005C (v01 CORE   COREBOOT 00000000 CORE 00000000)
May 13 14:25:23 newt kernel: ACPI: MCFG 0x000000007BF88830 00003C (v01 CORE   COREBOOT 00000000 CORE 00000000)
May 13 14:25:23 newt kernel: ACPI: SSDT 0x000000007BF89730 0008A0 (v02 CORE   COREBOOT 0000002A CORE 0000002A)
May 13 14:25:23 newt kernel: ACPI: SSDT 0x000000007BF89FD0 00005C (v02 CORE   COREBOOT 0000002A CORE 0000002A)
May 13 14:25:23 newt kernel: ACPI: Local APIC address 0xfee00000
May 13 14:25:23 newt kernel: No NUMA configuration found
May 13 14:25:23 newt kernel: Faking a node at [mem 0x0000000000000000-0x00000001005fffff]
May 13 14:25:23 newt kernel: NODE_DATA(0) allocated [mem 0x1005fa000-0x1005fefff]
May 13 14:25:23 newt kernel:  [ffffea0000000000-ffffea00041fffff] PMD -> [ffff880079800000-ffff88007b9fffff] on node 0
May 13 14:25:23 newt kernel: Zone ranges:
May 13 14:25:23 newt kernel:   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
May 13 14:25:23 newt kernel:   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
May 13 14:25:23 newt kernel:   Normal   [mem 0x0000000100000000-0x00000001005fffff]
May 13 14:25:23 newt kernel: Movable zone start for each node
May 13 14:25:23 newt kernel: Early memory node ranges
May 13 14:25:23 newt kernel:   node   0: [mem 0x0000000000001000-0x000000000002ffff]
May 13 14:25:23 newt kernel:   node   0: [mem 0x0000000000040000-0x000000000009dfff]
May 13 14:25:23 newt kernel:   node   0: [mem 0x0000000000100000-0x0000000000efffff]
May 13 14:25:23 newt kernel:   node   0: [mem 0x0000000001000000-0x000000007bf79fff]
May 13 14:25:23 newt kernel:   node   0: [mem 0x0000000100000000-0x00000001005fffff]
May 13 14:25:23 newt kernel: Initmem setup node 0 [mem 0x0000000000001000-0x00000001005fffff]
May 13 14:25:23 newt kernel: On node 0 totalpages: 508935
May 13 14:25:23 newt kernel:   DMA zone: 59 pages used for memmap
May 13 14:25:23 newt kernel:   DMA zone: 21 pages reserved
May 13 14:25:23 newt kernel:   DMA zone: 3725 pages, LIFO batch:0
May 13 14:25:23 newt kernel:   DMA32 zone: 7870 pages used for memmap
May 13 14:25:23 newt kernel:   DMA32 zone: 503674 pages, LIFO batch:31
May 13 14:25:23 newt kernel:   Normal zone: 24 pages used for memmap
May 13 14:25:23 newt kernel:   Normal zone: 1536 pages, LIFO batch:0
May 13 14:25:23 newt kernel: Reserving Intel graphics stolen memory at 0x7ca00000-0x7e9fffff
May 13 14:25:23 newt kernel: ACPI: PM-Timer IO Port: 0x1008
May 13 14:25:23 newt kernel: ACPI: Local APIC address 0xfee00000
May 13 14:25:23 newt kernel: IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-39
May 13 14:25:23 newt kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
May 13 14:25:23 newt kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
May 13 14:25:23 newt kernel: ACPI: IRQ0 used by override.
May 13 14:25:23 newt kernel: ACPI: IRQ9 used by override.
May 13 14:25:23 newt kernel: Using ACPI (MADT) for SMP configuration information
May 13 14:25:23 newt kernel: ACPI: HPET id: 0x8086a201 base: 0xfed00000
May 13 14:25:23 newt kernel: smpboot: Allowing 2 CPUs, 0 hotplug CPUs
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x00030000-0x0003ffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x00f00000-0x00ffffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x7bf7a000-0x7e9fffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0x7ea00000-0xefffffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xf0000000-0xf3ffffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xf4000000-0xfed0ffff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xfed10000-0xfed19fff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xfed1a000-0xfed83fff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xfed84000-0xfed84fff]
May 13 14:25:23 newt kernel: PM: Registered nosave memory: [mem 0xfed85000-0xffffffff]
May 13 14:25:23 newt kernel: e820: [mem 0x7ea00000-0xefffffff] available for PCI devices
May 13 14:25:23 newt kernel: Booting paravirtualized kernel on bare hardware
May 13 14:25:23 newt kernel: clocksource refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
May 13 14:25:23 newt kernel: setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 nr_node_ids:1
May 13 14:25:23 newt kernel: PERCPU: Embedded 33 pages/cpu @ffff880100200000 s96808 r8192 d30168 u1048576
May 13 14:25:23 newt kernel: pcpu-alloc: s96808 r8192 d30168 u1048576 alloc=1*2097152
May 13 14:25:23 newt kernel: pcpu-alloc: [0] 0 1 
May 13 14:25:23 newt kernel: Built 1 zonelists in Node order, mobility grouping on.  Total pages: 500961
May 13 14:25:23 newt kernel: Policy zone: Normal
May 13 14:25:23 newt kernel: Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.1.0-rc3-next-20150513+ root=UUID=e5fd0a8b-e57d-428c-831e-3aff30526800 ro quiet
May 13 14:25:23 newt kernel: PID hash table entries: 4096 (order: 3, 32768 bytes)
May 13 14:25:23 newt kernel: xsave: enabled xstate_bv 0x3, cntxt size 0x240 using standard form
May 13 14:25:23 newt kernel: Calgary: detecting Calgary via BIOS EBDA area
May 13 14:25:23 newt kernel: Calgary: Unable to locate Rio Grande table in EBDA - bailing!
May 13 14:25:23 newt kernel: Memory: 1899300K/2035740K available (5560K kernel code, 1077K rwdata, 1824K rodata, 1232K init, 872K bss, 136440K reserved, 0K cma-reserved)
May 13 14:25:23 newt kernel: Hierarchical RCU implementation.
May 13 14:25:23 newt kernel:         Build-time adjustment of leaf fanout to 64.
May 13 14:25:23 newt kernel:         RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=2.
May 13 14:25:23 newt kernel: RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=2
May 13 14:25:23 newt kernel: NR_IRQS:33024 nr_irqs:512 16
May 13 14:25:23 newt kernel: Console: colour VGA+ 80x25
May 13 14:25:23 newt kernel: console [tty0] enabled
May 13 14:25:23 newt kernel: clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
May 13 14:25:23 newt kernel: hpet clockevent registered
May 13 14:25:23 newt kernel: tsc: Fast TSC calibration using PIT
May 13 14:25:23 newt kernel: tsc: Detected 1396.754 MHz processor
May 13 14:25:23 newt kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 2793.50 BogoMIPS (lpj=5587016)
May 13 14:25:23 newt kernel: pid_max: default: 32768 minimum: 301
May 13 14:25:23 newt kernel: ACPI: Core revision 20150410
May 13 14:25:23 newt kernel: ACPI: All ACPI Tables successfully acquired
May 13 14:25:23 newt kernel: Security Framework initialized
May 13 14:25:23 newt kernel: AppArmor: AppArmor disabled by boot time parameter
May 13 14:25:23 newt kernel: Yama: becoming mindful.
May 13 14:25:23 newt kernel: Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
May 13 14:25:23 newt kernel: Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
May 13 14:25:23 newt kernel: Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
May 13 14:25:23 newt kernel: Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
May 13 14:25:23 newt kernel: Initializing cgroup subsys blkio
May 13 14:25:23 newt kernel: Initializing cgroup subsys memory
May 13 14:25:23 newt kernel: Initializing cgroup subsys devices
May 13 14:25:23 newt kernel: Initializing cgroup subsys freezer
May 13 14:25:23 newt kernel: Initializing cgroup subsys net_cls
May 13 14:25:23 newt kernel: Initializing cgroup subsys perf_event
May 13 14:25:23 newt kernel: Initializing cgroup subsys net_prio
May 13 14:25:23 newt kernel: CPU: Physical Processor ID: 0
May 13 14:25:23 newt kernel: CPU: Processor Core ID: 0
May 13 14:25:23 newt kernel: mce: CPU supports 7 MCE banks
May 13 14:25:23 newt kernel: CPU0: Thermal monitoring enabled (TM1)
May 13 14:25:23 newt kernel: process: using mwait in idle threads
May 13 14:25:23 newt kernel: Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
May 13 14:25:23 newt kernel: Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
May 13 14:25:23 newt kernel: Freeing SMP alternatives memory: 20K (ffffffff81a43000 - ffffffff81a48000)
May 13 14:25:23 newt kernel: ftrace: allocating 22218 entries in 87 pages
May 13 14:25:23 newt kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
May 13 14:25:23 newt kernel: TSC deadline timer enabled
May 13 14:25:23 newt kernel: smpboot: CPU0: Intel(R) Celeron(R) 2955U @ 1.40GHz (fam: 06, model: 45, stepping: 01)
May 13 14:25:23 newt kernel: Performance Events: PEBS fmt2+, 16-deep LBR, Haswell events, full-width counters, Intel PMU driver.
May 13 14:25:23 newt kernel: ... version:                3
May 13 14:25:23 newt kernel: ... bit width:              48
May 13 14:25:23 newt kernel: ... generic registers:      8
May 13 14:25:23 newt kernel: ... value mask:             0000ffffffffffff
May 13 14:25:23 newt kernel: ... max period:             0000ffffffffffff
May 13 14:25:23 newt kernel: ... fixed-purpose events:   3
May 13 14:25:23 newt kernel: ... event mask:             00000007000000ff
May 13 14:25:23 newt kernel: x86: Booting SMP configuration:
May 13 14:25:23 newt kernel: .... node  #0, CPUs:      #1
May 13 14:25:23 newt kernel: x86: Booted up 1 node, 2 CPUs
May 13 14:25:23 newt kernel: smpboot: Total of 2 processors activated (5587.01 BogoMIPS)
May 13 14:25:23 newt kernel: NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
May 13 14:25:23 newt kernel: devtmpfs: initialized
May 13 14:25:23 newt kernel: clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
May 13 14:25:23 newt kernel: pinctrl core: initialized pinctrl subsystem
May 13 14:25:23 newt kernel: NET: Registered protocol family 16
May 13 14:25:23 newt kernel: cpuidle: using governor ladder
May 13 14:25:23 newt kernel: cpuidle: using governor menu
May 13 14:25:23 newt kernel: ACPI: bus type PCI registered
May 13 14:25:23 newt kernel: acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
May 13 14:25:23 newt kernel: PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf0000000-0xf3ffffff] (base 0xf0000000)
May 13 14:25:23 newt kernel: PCI: MMCONFIG at [mem 0xf0000000-0xf3ffffff] reserved in E820
May 13 14:25:23 newt kernel: PCI: Using configuration type 1 for base access
May 13 14:25:23 newt kernel: NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
May 13 14:25:23 newt kernel: perf_event_intel: PMU erratum BJ122, BV98, HSD29 workaround disabled, HT off
May 13 14:25:23 newt kernel: ACPI: Added _OSI(Module Device)
May 13 14:25:23 newt kernel: ACPI: Added _OSI(Processor Device)
May 13 14:25:23 newt kernel: ACPI: Added _OSI(3.0 _SCP Extensions)
May 13 14:25:23 newt kernel: ACPI: Added _OSI(Processor Aggregator Device)
May 13 14:25:23 newt kernel: ACPI : EC: EC started
May 13 14:25:23 newt kernel: ACPI: Interpreter enabled
May 13 14:25:23 newt kernel: ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150410/hwxface-580)
May 13 14:25:23 newt kernel: ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150410/hwxface-580)
May 13 14:25:23 newt kernel: ACPI: (supports S0 S3 S4 S5)
May 13 14:25:23 newt kernel: ACPI: Using IOAPIC for interrupt routing
May 13 14:25:23 newt kernel: PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
May 13 14:25:23 newt kernel: ACPI: Power Resource [TNP0] (off)
May 13 14:25:23 newt kernel: ACPI: Power Resource [TNP1] (on)
May 13 14:25:23 newt kernel: ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
May 13 14:25:23 newt kernel: acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
May 13 14:25:23 newt kernel: acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
May 13 14:25:23 newt kernel: acpi PNP0A08:00: ignoring host bridge window [mem 0x000cc000-0x000cffff window] (conflicts with Video ROM [mem 0x000c0000-0x000cebff])
May 13 14:25:23 newt kernel: acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
May 13 14:25:23 newt kernel: PCI host bridge to bus 0000:00
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [bus 00-ff]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000cbfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000ebfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000effff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x000f0000-0x000fffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0x7ea00001-0xfebfffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff window]
May 13 14:25:23 newt kernel: pci 0000:00:00.0: [8086:0a04] type 00 class 0x060000
May 13 14:25:23 newt kernel: pci 0000:00:02.0: [8086:0a06] type 00 class 0x030000
May 13 14:25:23 newt kernel: pci 0000:00:02.0: reg 0x10: [mem 0xe0000000-0xe03fffff 64bit]
May 13 14:25:23 newt kernel: pci 0000:00:02.0: reg 0x18: [mem 0xd0000000-0xdfffffff 64bit pref]
May 13 14:25:23 newt kernel: pci 0000:00:02.0: reg 0x20: [io  0x1800-0x183f]
May 13 14:25:23 newt kernel: pci 0000:00:03.0: [8086:0a0c] type 00 class 0x040300
May 13 14:25:23 newt kernel: pci 0000:00:03.0: reg 0x10: [mem 0xe0510000-0xe0513fff 64bit]
May 13 14:25:23 newt kernel: pci 0000:00:14.0: [8086:9c31] type 00 class 0x0c0330
May 13 14:25:23 newt kernel: pci 0000:00:14.0: reg 0x10: [mem 0xe0500000-0xe050ffff 64bit]
May 13 14:25:23 newt kernel: pci 0000:00:14.0: PME# supported from D3hot D3cold
May 13 14:25:23 newt kernel: pci 0000:00:14.0: System wakeup disabled by ACPI
May 13 14:25:23 newt kernel: pci 0000:00:15.0: [8086:9c60] type 00 class 0x080102
May 13 14:25:23 newt kernel: pci 0000:00:15.0: reg 0x10: [mem 0xe0518000-0xe0518fff]
May 13 14:25:23 newt kernel: pci 0000:00:15.0: reg 0x14: [mem 0xe0519000-0xe0519fff]
May 13 14:25:23 newt kernel: pci 0000:00:15.1: [8086:9c61] type 00 class 0x0c8000
May 13 14:25:23 newt kernel: pci 0000:00:15.1: reg 0x10: [mem 0xe051a000-0xe051afff]
May 13 14:25:23 newt kernel: pci 0000:00:15.1: reg 0x14: [mem 0xe051b000-0xe051bfff]
May 13 14:25:23 newt kernel: pci 0000:00:15.2: [8086:9c62] type 00 class 0x0c8000
May 13 14:25:23 newt kernel: pci 0000:00:15.2: reg 0x10: [mem 0xe051c000-0xe051cfff]
May 13 14:25:23 newt kernel: pci 0000:00:15.2: reg 0x14: [mem 0xe051d000-0xe051dfff]
May 13 14:25:23 newt kernel: pci 0000:00:1b.0: [8086:9c20] type 00 class 0x040300
May 13 14:25:23 newt kernel: pci 0000:00:1b.0: reg 0x10: [mem 0xe0514000-0xe0517fff 64bit]
May 13 14:25:23 newt kernel: pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
May 13 14:25:23 newt kernel: pci 0000:00:1b.0: System wakeup disabled by ACPI
May 13 14:25:23 newt kernel: pci 0000:00:1c.0: [8086:9c10] type 01 class 0x060400
May 13 14:25:23 newt kernel: pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
May 13 14:25:23 newt kernel: pci 0000:00:1d.0: [8086:9c26] type 00 class 0x0c0320
May 13 14:25:23 newt kernel: pci 0000:00:1d.0: reg 0x10: [mem 0xe051f800-0xe051fbff]
May 13 14:25:23 newt kernel: pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
May 13 14:25:23 newt kernel: pci 0000:00:1d.0: System wakeup disabled by ACPI
May 13 14:25:23 newt kernel: pci 0000:00:1f.0: [8086:9c45] type 00 class 0x060100
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: [8086:9c03] type 00 class 0x010601
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x10: [io  0x1860-0x1867]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x14: [io  0x1870-0x1873]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x18: [io  0x1868-0x186f]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x1c: [io  0x1874-0x1877]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x20: [io  0x1840-0x185f]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: reg 0x24: [mem 0xe051f000-0xe051f7ff]
May 13 14:25:23 newt kernel: pci 0000:00:1f.2: PME# supported from D3hot
May 13 14:25:23 newt kernel: pci 0000:00:1f.3: [8086:9c22] type 00 class 0x0c0500
May 13 14:25:23 newt kernel: pci 0000:00:1f.3: reg 0x10: [mem 0xe051fc00-0xe051fcff 64bit]
May 13 14:25:23 newt kernel: pci 0000:00:1f.3: reg 0x20: [io  0x0400-0x041f]
May 13 14:25:23 newt kernel: pci 0000:00:1f.6: [8086:9c24] type 00 class 0x118000
May 13 14:25:23 newt kernel: pci 0000:00:1f.6: reg 0x10: [mem 0xe051e000-0xe051efff 64bit]
May 13 14:25:23 newt kernel: pci 0000:01:00.0: [168c:0034] type 00 class 0x028000
May 13 14:25:23 newt kernel: pci 0000:01:00.0: reg 0x10: [mem 0xe0400000-0xe047ffff 64bit]
May 13 14:25:23 newt kernel: pci 0000:01:00.0: reg 0x30: [mem 0xe0480000-0xe048ffff pref]
May 13 14:25:23 newt kernel: pci 0000:01:00.0: supports D1 D2
May 13 14:25:23 newt kernel: pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
May 13 14:25:23 newt kernel: pci 0000:00:1c.0: PCI bridge to [bus 01]
May 13 14:25:23 newt kernel: pci 0000:00:1c.0:   bridge window [mem 0xe0400000-0xe04fffff]
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 11 12 14 15) *10, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 12 14 15) *11, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *11 12 14 15), disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 7 10 12 14 15) *0, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 10 12 14 15) *0, disabled.
May 13 14:25:23 newt kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
May 13 14:25:23 newt kernel: ACPI : EC: GPE = 0x24, I/O: command/status = 0x66, data = 0x62
May 13 14:25:23 newt kernel: vgaarb: setting as boot device: PCI:0000:00:02.0
May 13 14:25:23 newt kernel: vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
May 13 14:25:23 newt kernel: vgaarb: loaded
May 13 14:25:23 newt kernel: vgaarb: bridge control possible 0000:00:02.0
May 13 14:25:23 newt kernel: PCI: Using ACPI for IRQ routing
May 13 14:25:23 newt kernel: PCI: pci_cache_line_size set to 64 bytes
May 13 14:25:23 newt kernel: e820: reserve RAM buffer [mem 0x0009e400-0x0009ffff]
May 13 14:25:23 newt kernel: e820: reserve RAM buffer [mem 0x7bf7a000-0x7bffffff]
May 13 14:25:23 newt kernel: e820: reserve RAM buffer [mem 0x100600000-0x103ffffff]
May 13 14:25:23 newt kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
May 13 14:25:23 newt kernel: hpet0: 8 comparators, 64-bit 14.318180 MHz counter
May 13 14:25:23 newt kernel: Switched to clocksource hpet
May 13 14:25:23 newt kernel: pnp: PnP ACPI init
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed1c000-0xfed1ffff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed10000-0xfed13fff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed18000-0xfed18fff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed19000-0xfed19fff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xf0000000-0xf3ffffff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed20000-0xfed3ffff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0xfed45000-0xfed8ffff] could not be reserved
May 13 14:25:23 newt kernel: system 00:00: [mem 0x00f00000-0x00ffffff] has been reserved
May 13 14:25:23 newt kernel: system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
May 13 14:25:23 newt kernel: system 00:01: [mem 0xfed00000-0xfed003ff] has been reserved
May 13 14:25:23 newt kernel: system 00:01: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active)
May 13 14:25:23 newt kernel: system 00:02: [io  0x1000-0x10fe] could not be reserved
May 13 14:25:23 newt kernel: system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
May 13 14:25:23 newt kernel: pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
May 13 14:25:23 newt kernel: system 00:04: [io  0x0900-0x09fe] has been reserved
May 13 14:25:23 newt kernel: system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
May 13 14:25:23 newt kernel: system 00:05: [io  0x0200] has been reserved
May 13 14:25:23 newt kernel: system 00:05: [io  0x0204] has been reserved
May 13 14:25:23 newt kernel: system 00:05: [io  0x0800-0x087f] has been reserved
May 13 14:25:23 newt kernel: system 00:05: [io  0x0880-0x08ff] has been reserved
May 13 14:25:23 newt kernel: system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
May 13 14:25:23 newt kernel: pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
May 13 14:25:23 newt kernel: pnp 00:07: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
May 13 14:25:23 newt kernel: pnp 00:08: Plug and Play ACPI device, IDs IFX0102 PNP0c31 (active)
May 13 14:25:23 newt kernel: system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
May 13 14:25:23 newt kernel: pnp: PnP ACPI: found 10 devices
May 13 14:25:23 newt kernel: clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
May 13 14:25:23 newt kernel: pci 0000:00:1c.0: PCI bridge to [bus 01]
May 13 14:25:23 newt kernel: pci 0000:00:1c.0:   bridge window [mem 0xe0400000-0xe04fffff]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000c3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 8 [mem 0x000c4000-0x000c7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000cbfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 10 [mem 0x000d0000-0x000d3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 11 [mem 0x000d4000-0x000d7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 12 [mem 0x000d8000-0x000dbfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 13 [mem 0x000dc000-0x000dffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 14 [mem 0x000e0000-0x000e3fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 15 [mem 0x000e4000-0x000e7fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 16 [mem 0x000e8000-0x000ebfff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 17 [mem 0x000ec000-0x000effff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 18 [mem 0x000f0000-0x000fffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 19 [mem 0x7ea00001-0xfebfffff window]
May 13 14:25:23 newt kernel: pci_bus 0000:00: resource 20 [mem 0xfed40000-0xfed44fff window]
May 13 14:25:23 newt kernel: pci_bus 0000:01: resource 1 [mem 0xe0400000-0xe04fffff]
May 13 14:25:23 newt kernel: NET: Registered protocol family 2
May 13 14:25:23 newt kernel: TCP established hash table entries: 16384 (order: 5, 131072 bytes)
May 13 14:25:23 newt kernel: TCP bind hash table entries: 16384 (order: 7, 524288 bytes)
May 13 14:25:23 newt kernel: TCP: Hash tables configured (established 16384 bind 16384)
May 13 14:25:23 newt kernel: UDP hash table entries: 1024 (order: 4, 98304 bytes)
May 13 14:25:23 newt kernel: UDP-Lite hash table entries: 1024 (order: 4, 98304 bytes)
May 13 14:25:23 newt kernel: NET: Registered protocol family 1
May 13 14:25:23 newt kernel: pci 0000:00:02.0: Video device with shadowed ROM
May 13 14:25:23 newt kernel: PCI: CLS 64 bytes, default 64
May 13 14:25:23 newt kernel: Unpacking initramfs...
May 13 14:25:23 newt kernel: Freeing initrd memory: 23320K (ffff880035264000 - ffff88003692a000)
May 13 14:25:23 newt kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
May 13 14:25:23 newt kernel: software IO TLB [mem 0x75800000-0x79800000] (64MB) mapped at [ffff880075800000-ffff8800797fffff]
May 13 14:25:23 newt kernel: RAPL PMU detected, API unit is 2^-32 Joules, 4 fixed counters 655360 ms ovfl timer
May 13 14:25:23 newt kernel: hw unit of domain pp0-core 2^-14 Joules
May 13 14:25:23 newt kernel: hw unit of domain package 2^-14 Joules
May 13 14:25:23 newt kernel: hw unit of domain dram 2^-14 Joules
May 13 14:25:23 newt kernel: hw unit of domain pp1-gpu 2^-14 Joules
May 13 14:25:23 newt kernel: microcode: CPU0 sig=0x40651, pf=0x40, revision=0x15
May 13 14:25:23 newt kernel: microcode: CPU1 sig=0x40651, pf=0x40, revision=0x15
May 13 14:25:23 newt kernel: microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
May 13 14:25:23 newt kernel: futex hash table entries: 512 (order: 3, 32768 bytes)
May 13 14:25:23 newt kernel: audit: initializing netlink subsys (disabled)
May 13 14:25:23 newt kernel: audit: type=2000 audit(1431552321.772:1): initialized
May 13 14:25:23 newt kernel: HugeTLB registered 2 MB page size, pre-allocated 0 pages
May 13 14:25:23 newt kernel: zpool: loaded
May 13 14:25:23 newt kernel: zbud: loaded
May 13 14:25:23 newt kernel: VFS: Disk quotas dquot_6.6.0
May 13 14:25:23 newt kernel: VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
May 13 14:25:23 newt kernel: alg: No test for stdrng (krng)
May 13 14:25:23 newt kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
May 13 14:25:23 newt kernel: io scheduler noop registered
May 13 14:25:23 newt kernel: io scheduler deadline registered
May 13 14:25:23 newt kernel: io scheduler cfq registered (default)
May 13 14:25:23 newt kernel: aer 0000:00:1c.0:pcie02: service driver aer loaded
May 13 14:25:23 newt kernel: pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
May 13 14:25:23 newt kernel: pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
May 13 14:25:23 newt kernel: pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
May 13 14:25:23 newt kernel: pci_hotplug: PCI Hot Plug PCI Core version: 0.5
May 13 14:25:23 newt kernel: pciehp: PCI Express Hot Plug Controller Driver version: 0.4
May 13 14:25:23 newt kernel: intel_idle: MWAIT substates: 0x11142120
May 13 14:25:23 newt kernel: intel_idle: v0.4 model 0x45
May 13 14:25:23 newt kernel: intel_idle: lapic_timer_reliable_states 0xffffffff
May 13 14:25:23 newt kernel: GHES: HEST is not enabled!
May 13 14:25:23 newt kernel: Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
May 13 14:25:23 newt kernel: Linux agpgart interface v0.103
May 13 14:25:23 newt kernel: AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
May 13 14:25:23 newt kernel: AMD IOMMUv2 functionality not available on this system
May 13 14:25:23 newt kernel: i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
May 13 14:25:23 newt kernel: i8042: PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
May 13 14:25:23 newt kernel: i8042: Warning: Keylock active
May 13 14:25:23 newt kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
May 13 14:25:23 newt kernel: mousedev: PS/2 mouse device common for all mice
May 13 14:25:23 newt kernel: rtc_cmos 00:03: RTC can wake from S4
May 13 14:25:23 newt kernel: rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
May 13 14:25:23 newt kernel: rtc_cmos 00:03: alarms up to one month, 242 bytes nvram, hpet irqs
May 13 14:25:23 newt kernel: Intel P-state driver initializing.
May 13 14:25:23 newt kernel: ledtrig-cpu: registered to indicate activity on CPUs
May 13 14:25:23 newt kernel: NET: Registered protocol family 10
May 13 14:25:23 newt kernel: mip6: Mobile IPv6
May 13 14:25:23 newt kernel: NET: Registered protocol family 17
May 13 14:25:23 newt kernel: registered taskstats version 1
May 13 14:25:23 newt kernel: rtc_cmos 00:03: setting system clock to 2015-05-13 21:25:22 UTC (1431552322)
May 13 14:25:23 newt kernel: Freeing unused kernel memory: 1232K (ffffffff8190f000 - ffffffff81a43000)
May 13 14:25:23 newt kernel: Write protecting the kernel read-only data: 8192k
May 13 14:25:23 newt kernel: Freeing unused kernel memory: 572K (ffff880001571000 - ffff880001600000)
May 13 14:25:23 newt kernel: Freeing unused kernel memory: 224K (ffff8800017c8000 - ffff880001800000)
May 13 14:25:23 newt kernel: input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
May 13 14:25:23 newt systemd-udevd[62]: starting version 215
May 13 14:25:23 newt kernel: random: systemd-udevd urandom read with 2 bits of entropy available
May 13 14:25:23 newt kernel: SCSI subsystem initialized
May 13 14:25:23 newt kernel: ACPI: bus type USB registered
May 13 14:25:23 newt kernel: usbcore: registered new interface driver usbfs
May 13 14:25:23 newt kernel: usbcore: registered new interface driver hub
May 13 14:25:23 newt kernel: usbcore: registered new device driver usb
May 13 14:25:23 newt kernel: sdhci: Secure Digital Host Controller Interface driver
May 13 14:25:23 newt kernel: sdhci: Copyright(c) Pierre Ossman
May 13 14:25:23 newt kernel: libata version 3.00 loaded.
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 1
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x0000b810
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
May 13 14:25:23 newt kernel: usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
May 13 14:25:23 newt kernel: usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
May 13 14:25:23 newt kernel: usb usb1: Product: xHCI Host Controller
May 13 14:25:23 newt kernel: usb usb1: Manufacturer: Linux 4.1.0-rc3-next-20150513+ xhci-hcd
May 13 14:25:23 newt kernel: usb usb1: SerialNumber: 0000:00:14.0
May 13 14:25:23 newt kernel: hub 1-0:1.0: USB hub found
May 13 14:25:23 newt kernel: hub 1-0:1.0: 8 ports detected
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: xHCI Host Controller
May 13 14:25:23 newt kernel: xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
May 13 14:25:23 newt kernel: usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
May 13 14:25:23 newt kernel: usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
May 13 14:25:23 newt kernel: usb usb2: Product: xHCI Host Controller
May 13 14:25:23 newt kernel: usb usb2: Manufacturer: Linux 4.1.0-rc3-next-20150513+ xhci-hcd
May 13 14:25:23 newt kernel: usb usb2: SerialNumber: 0000:00:14.0
May 13 14:25:23 newt kernel: hub 2-0:1.0: USB hub found
May 13 14:25:23 newt kernel: hub 2-0:1.0: 4 ports detected
May 13 14:25:23 newt kernel: thermal LNXTHERM:00: registered as thermal_zone0
May 13 14:25:23 newt kernel: ACPI: Thermal Zone [THRM] (47 C)
May 13 14:25:23 newt kernel: ahci 0000:00:1f.2: version 3.0
May 13 14:25:23 newt kernel: ahci 0000:00:1f.2: SSS flag set, parallel bus scan disabled
May 13 14:25:23 newt kernel: ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 2 ports 6 Gbps 0x1 impl SATA mode
May 13 14:25:23 newt kernel: ahci 0000:00:1f.2: flags: 64bit ncq ilck stag pm led clo only pio slum part deso sadm sds apst 
May 13 14:25:23 newt kernel: scsi host0: ahci
May 13 14:25:23 newt kernel: scsi host1: ahci
May 13 14:25:23 newt kernel: ata1: SATA max UDMA/133 abar m2048@0xe051f000 port 0xe051f100 irq 42
May 13 14:25:23 newt kernel: ata2: DUMMY
May 13 14:25:23 newt kernel: usb 1-3: new high-speed USB device number 2 using xhci_hcd
May 13 14:25:23 newt kernel: ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
May 13 14:25:23 newt kernel: ata1.00: ATA-10: SC2 M2 SSD, S9FM01.7, max UDMA/100
May 13 14:25:23 newt kernel: ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
May 13 14:25:23 newt kernel: ata1.00: configured for UDMA/100
May 13 14:25:23 newt kernel: scsi 0:0:0:0: Direct-Access     ATA      SC2 M2 SSD       01.7 PQ: 0 ANSI: 5
May 13 14:25:23 newt kernel: sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
May 13 14:25:23 newt kernel: sd 0:0:0:0: [sda] Write Protect is off
May 13 14:25:23 newt kernel: sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
May 13 14:25:23 newt kernel: sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 13 14:25:23 newt kernel:  sda: sda1 sda2 < sda5 >
May 13 14:25:23 newt kernel: sd 0:0:0:0: [sda] Attached SCSI disk
May 13 14:25:23 newt kernel: sd 0:0:0:0: Attached scsi generic sg0 type 0
May 13 14:25:23 newt kernel: PM: Starting manual resume from disk
May 13 14:25:23 newt kernel: usb 1-3: New USB device found, idVendor=1bcf, idProduct=2c67
May 13 14:25:23 newt kernel: usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
May 13 14:25:23 newt kernel: usb 1-3: Product: HD WebCam
May 13 14:25:23 newt kernel: usb 1-3: Manufacturer: NC.21411.024409008DCLM0001
May 13 14:25:23 newt kernel: EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
May 13 14:25:23 newt kernel: usb 1-4: new full-speed USB device number 3 using xhci_hcd
May 13 14:25:23 newt kernel: usb 1-4: string descriptor 0 read error: -22
May 13 14:25:23 newt kernel: usb 1-4: New USB device found, idVendor=0489, idProduct=e056
May 13 14:25:23 newt kernel: usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
May 13 14:25:23 newt kernel: fuse init (API version 7.23)
May 13 14:25:23 newt kernel: tsc: Refined TSC clocksource calibration: 1396.766 MHz
May 13 14:25:23 newt kernel: clocksource tsc: mask: 0xffffffffffffffff max_cycles: 0x1422315cd49, max_idle_ns: 440795270477 ns
May 13 14:25:23 newt systemd[1]: systemd-modules-load.service: main process exited, code=exited, status=1/FAILURE
May 13 14:25:23 newt systemd[1]: Failed to start Load Kernel Modules.
May 13 14:25:23 newt systemd[1]: Unit systemd-modules-load.service entered failed state.
May 13 14:25:23 newt systemd-udevd[163]: starting version 215
May 13 14:25:23 newt systemd-journal[158]: Journal started
May 13 14:25:23 newt systemd-modules-load[138]: Failed to find module 'lp'
May 13 14:25:23 newt systemd-modules-load[138]: Failed to find module 'ppdev'
May 13 14:25:23 newt systemd-modules-load[138]: Failed to find module 'parport_pc'
May 13 14:25:23 newt systemd-modules-load[138]: Inserted module 'fuse'
May 13 14:25:23 newt systemd-fsck[132]: /dev/sda1: clean, 356531/7077888 files, 11969634/28287232 blocks
May 13 14:25:23 newt hdparm[166]: Setting parameters of disc: (none).
May 13 14:25:23 newt systemd-udevd[203]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[214]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[213]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[215]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[216]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[217]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[218]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[221]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[222]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[220]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[219]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[223]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[228]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[230]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[229]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[225]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[224]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[236]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[235]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[227]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[226]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[234]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[231]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[232]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[233]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[245]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[242]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[243]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[244]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[246]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[241]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[247]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[248]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[240]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[239]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[238]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: usb 1-5: new low-speed USB device number 4 using xhci_hcd
May 13 14:25:23 newt systemd-udevd[249]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[237]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[260]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[253]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[254]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[255]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[262]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[263]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[256]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[257]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[258]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[252]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[259]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[261]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[251]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[250]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[275]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[268]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[270]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[271]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[272]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[273]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt keyboard-setup[165]: Setting preliminary keymap...done.
May 13 14:25:23 newt systemd-udevd[274]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[269]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[267]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[266]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[265]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[277]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[278]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[285]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[287]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
May 13 14:25:23 newt systemd-udevd[264]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[282]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[283]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[291]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[290]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[289]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[286]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[297]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[298]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[299]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[288]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-journal[158]: Permanent journal is using 48.0M (max allowed 4.0G, trying to leave 4.0G free of 56.8G available → current limit 4.0G).
May 13 14:25:23 newt systemd-journal[158]: Time spent on flushing to /var is 32.867ms for 600 entries.
May 13 14:25:23 newt systemd-udevd[284]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[312]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[309]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[316]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[315]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[314]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[310]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[311]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[320]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[319]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[301]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[321]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kbd[296]: Setting console screen modes.
May 13 14:25:23 newt kbd[296]: setterm: $TERM is not defined.
May 13 14:25:23 newt systemd-udevd[308]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[326]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[300]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[332]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[333]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[334]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[329]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[328]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[325]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[324]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[327]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[417]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: usb 1-5: New USB device found, idVendor=046d, idProduct=c062
May 13 14:25:23 newt kernel: usb 1-5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
May 13 14:25:23 newt kernel: usb 1-5: Product: USB Laser Mouse
May 13 14:25:23 newt kernel: usb 1-5: Manufacturer: Logitech
May 13 14:25:23 newt kernel: usb 1-5: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
May 13 14:25:23 newt systemd-udevd[433]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[438]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[441]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[449]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[437]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[442]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[436]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[443]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[435]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[434]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[461]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[468]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[464]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[447]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt networking[317]: Configuring network interfaces...done.
May 13 14:25:23 newt systemd-udevd[481]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[477]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[487]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt ntpdate[470]: Can't find host 0.debian.pool.ntp.org: Name or service not known (-2)
May 13 14:25:23 newt ntpdate[470]: Can't find host 1.debian.pool.ntp.org: Name or service not known (-2)
May 13 14:25:23 newt ntpdate[470]: Can't find host 2.debian.pool.ntp.org: Name or service not known (-2)
May 13 14:25:23 newt ntpdate[470]: Can't find host 3.debian.pool.ntp.org: Name or service not known (-2)
May 13 14:25:23 newt ntpdate[470]: no servers can be used, exiting
May 13 14:25:23 newt kernel: shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
May 13 14:25:23 newt systemd-udevd[504]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[507]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[508]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[509]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input1
May 13 14:25:23 newt kernel: ACPI: Lid Switch [LID0]
May 13 14:25:23 newt kernel: input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input2
May 13 14:25:23 newt kernel: ACPI: Power Button [PWRB]
May 13 14:25:23 newt kernel: input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input3
May 13 14:25:23 newt kernel: ACPI: Sleep Button [TPAD]
May 13 14:25:23 newt kernel: input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:01/input/input4
May 13 14:25:23 newt kernel: ACPI: Sleep Button [TSCR]
May 13 14:25:23 newt kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input5
May 13 14:25:23 newt kernel: ACPI: Power Button [PWRF]
May 13 14:25:23 newt systemd-udevd[500]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[510]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[505]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[506]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[511]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[516]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[514]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[517]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[515]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[512]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[513]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[523]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[524]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[521]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[522]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[520]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[519]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[518]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: [drm] Initialized drm 1.1.0 20060810
May 13 14:25:23 newt systemd-udevd[530]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[528]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[529]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
May 13 14:25:23 newt kernel: input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input6
May 13 14:25:23 newt kernel: Bluetooth: Core ver 2.20
May 13 14:25:23 newt kernel: NET: Registered protocol family 31
May 13 14:25:23 newt kernel: Bluetooth: HCI device and connection manager initialized
May 13 14:25:23 newt kernel: Bluetooth: HCI socket layer initialized
May 13 14:25:23 newt kernel: Bluetooth: L2CAP socket layer initialized
May 13 14:25:23 newt kernel: Bluetooth: SCO socket layer initialized
May 13 14:25:23 newt systemd-udevd[531]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[527]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[526]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[525]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt console-setup[380]: Setting up console font and keymap...done.
May 13 14:25:23 newt systemd-udevd[532]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[536]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[538]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[537]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[543]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[539]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt kernel: usbcore: registered new interface driver btusb
May 13 14:25:23 newt systemd-udevd[541]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:23 newt systemd-udevd[535]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[544]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[545]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[553]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[554]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[555]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt rpcbind[482]: Starting rpcbind daemon....
May 13 14:25:24 newt systemd-udevd[557]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[556]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[558]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[559]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[560]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[563]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC283: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x21/0x0/0x0/0x0/0x0)
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:    inputs:
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:      Internal Mic=0x1a
May 13 14:25:24 newt kernel: snd_hda_codec_realtek hdaudioC1D0:      Mic=0x19
May 13 14:25:24 newt systemd-udevd[562]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[561]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[564]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[566]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[565]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[568]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[573]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[572]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[571]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[570]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[567]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[569]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[574]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[575]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[580]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[576]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[581]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[579]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[577]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[583]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[584]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[582]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[578]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[587]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: usb 1-4: USB disconnect, device number 3
May 13 14:25:24 newt kernel: usbcore: registered new interface driver ath3k
May 13 14:25:24 newt systemd-udevd[588]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[585]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: ACPI: Battery Slot [BAT0] (battery present)
May 13 14:25:24 newt systemd-udevd[586]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[589]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[594]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[590]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[591]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[595]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[596]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[598]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/sound/card1/input7
May 13 14:25:24 newt kernel: input: HDA Intel PCH Mic as /devices/pci0000:00/0000:00:1b.0/sound/card1/input8
May 13 14:25:24 newt kernel: input: HDA Intel PCH Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card1/input9
May 13 14:25:24 newt kernel: ACPI: AC Adapter [AC] (on-line)
May 13 14:25:24 newt systemd-udevd[599]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[593]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[592]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[600]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[602]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[603]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[601]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[605]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[608]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[606]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[607]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[609]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[604]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[610]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[611]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[614]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[613]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[617]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[615]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[616]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[622]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[618]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[620]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[612]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[621]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[623]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[619]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[625]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[626]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[624]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[627]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[628]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[630]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[632]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[629]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[631]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[634]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[635]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[636]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
May 13 14:25:24 newt systemd-udevd[637]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[633]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[639]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[640]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[638]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[642]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[644]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[646]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[647]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[650]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[652]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[641]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[651]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[648]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[645]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: input: PC Speaker as /devices/platform/pcspkr/input/input10
May 13 14:25:24 newt systemd-udevd[658]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: [drm] Memory usable by graphics device = 2048M
May 13 14:25:24 newt kernel: [drm] Replacing VGA console driver
May 13 14:25:24 newt kernel: Console: switching to colour dummy device 80x25
May 13 14:25:24 newt kernel: [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
May 13 14:25:24 newt kernel: [drm] Driver supports precise vblank timestamp query.
May 13 14:25:24 newt kernel: [drm] applying backlight present quirk
May 13 14:25:24 newt kernel: vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
May 13 14:25:24 newt systemd-udevd[653]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[661]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[659]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[656]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[655]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[657]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[660]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[663]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[670]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: tpm_tis tpm_tis: 1.2 TPM (device-id 0xB, rev-id 16)
May 13 14:25:24 newt systemd-udevd[665]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[666]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[667]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[671]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: cfg80211: Calling CRDA to update world regulatory domain
May 13 14:25:24 newt systemd-udevd[676]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[677]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[664]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[679]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[681]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[682]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[683]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[684]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[680]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[688]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[686]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[687]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[689]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt kernel: snd_hda_intel 0000:00:03.0: bound 0000:00:02.0 (ops i915_audio_component_bind_ops [i915])
May 13 14:25:24 newt kernel: [drm] Initialized i915 1.6.0 20150508 for 0000:00:02.0 on minor 0
May 13 14:25:24 newt systemd-udevd[685]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[691]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[696]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[692]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[693]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[690]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[694]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[704]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[703]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[698]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[706]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[701]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[702]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[707]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[708]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[715]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[716]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[720]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[721]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[724]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[722]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[714]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[713]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[712]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[725]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[730]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[729]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[728]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[727]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[726]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[732]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[735]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[736]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[738]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[733]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[737]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[739]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[740]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[742]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[743]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[741]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[747]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[748]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[751]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[750]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[752]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[753]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[754]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[757]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[764]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[763]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[761]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[771]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[772]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[773]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[776]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[775]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[774]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[782]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[783]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[781]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[778]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[785]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[787]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[786]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[790]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[792]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[791]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[794]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[795]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[798]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[799]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[800]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[804]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[806]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[807]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[812]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[811]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[813]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[815]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[805]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[814]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[816]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[817]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[819]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[820]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[824]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[825]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[809]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[818]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[834]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[835]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[831]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[833]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[832]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[836]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[821]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[822]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[837]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[842]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[838]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[839]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[841]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[840]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[843]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[846]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[848]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[849]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[845]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[847]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[854]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[851]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[850]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[853]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[855]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[856]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[864]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[865]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[860]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[861]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[858]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[857]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[867]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[859]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[876]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[871]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[866]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[868]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[870]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[872]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[873]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[874]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[877]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[882]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[886]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[878]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[880]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[881]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[884]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[879]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[888]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[894]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[890]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[891]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[887]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[889]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[896]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[900]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[901]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[899]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[898]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[897]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[895]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[904]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[905]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[906]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[902]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[903]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[909]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[913]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[907]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[908]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[912]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[911]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[910]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[915]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[917]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[914]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[916]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[918]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[920]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[921]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[922]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[929]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[926]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[927]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[930]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[924]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[923]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[928]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[925]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[933]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[931]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[919]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[934]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[937]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[936]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[932]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[938]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[939]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[935]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[942]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[945]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[941]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[940]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[946]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[944]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[943]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[948]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[947]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[952]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[951]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[950]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[955]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[957]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[958]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[954]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[949]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[956]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[960]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[961]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[959]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[962]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[963]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[964]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[965]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[953]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[966]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[968]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[969]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[970]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[971]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[973]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[974]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[967]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[975]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[972]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[977]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[978]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[976]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[980]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[986]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[985]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[983]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[989]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[990]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[988]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[982]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[981]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[984]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[987]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[991]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[979]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[992]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[993]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[994]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[995]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[996]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[997]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[998]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[999]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1001]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1004]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1006]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1008]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1002]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1009]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1005]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1007]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1015]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1011]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1012]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1016]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1017]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1022]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1024]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1023]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1003]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1019]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1020]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1028]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1026]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1027]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1030]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1031]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1025]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1034]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1033]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1035]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1032]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1040]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1036]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1029]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1037]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1038]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1042]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1044]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1045]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1046]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1043]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1047]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1049]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1051]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1050]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1052]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1048]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1054]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1053]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1055]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1058]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt mtp-probe[1041]: checking bus 1, device 4: "/sys/devices/pci0000:00/0000:00:14.0/usb1/1-5"
May 13 14:25:24 newt systemd-udevd[1060]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1062]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt mtp-probe[1039]: checking bus 1, device 2: "/sys/devices/pci0000:00/0000:00:14.0/usb1/1-3"
May 13 14:25:24 newt systemd-udevd[1063]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1059]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1056]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1057]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt mtp-probe[1039]: bus: 1, device: 2 was not an MTP device
May 13 14:25:24 newt systemd-udevd[1061]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1065]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1070]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt mtp-probe[1041]: bus: 1, device: 4 was not an MTP device
May 13 14:25:24 newt systemd-udevd[1068]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1067]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1069]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1074]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1072]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1077]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1075]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1073]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1076]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1079]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1081]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1082]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1083]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1080]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1085]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1086]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1084]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1087]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1090]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1096]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1095]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1092]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1093]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1098]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1099]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1100]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1101]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1094]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1097]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1102]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1106]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1107]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1104]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1109]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1103]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1105]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1111]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1108]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1112]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1115]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1116]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1114]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1113]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1118]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1117]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1119]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1120]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1121]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1123]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1124]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1122]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1125]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1126]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1127]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1128]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1129]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1130]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1132]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1133]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1134]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1135]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1137]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1138]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1139]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1140]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:24 newt systemd-udevd[1141]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1142]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt kernel: fbcon: inteldrmfb (fb0) is primary device
May 13 14:25:25 newt kernel: __add_probed_i2c_device failed to register device 1-4a
May 13 14:25:25 newt kernel: __add_probed_i2c_device failed to register device 1-4a
May 13 14:25:25 newt kernel: intel_rapl: Found RAPL domain package
May 13 14:25:25 newt kernel: intel_rapl: Found RAPL domain core
May 13 14:25:25 newt kernel: intel_rapl: Found RAPL domain uncore
May 13 14:25:25 newt kernel: intel_rapl: Found RAPL domain dram
May 13 14:25:25 newt kernel: usb 1-4: new full-speed USB device number 5 using xhci_hcd
May 13 14:25:25 newt kernel: ath: phy0: ASPM enabled: 0x43
May 13 14:25:25 newt kernel: ath: EEPROM regdomain: 0x6c
May 13 14:25:25 newt kernel: ath: EEPROM indicates we should expect a direct regpair map
May 13 14:25:25 newt kernel: ath: Country alpha2 being used: 00
May 13 14:25:25 newt kernel: ath: Regpair used: 0x6c
May 13 14:25:25 newt kernel: ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
May 13 14:25:25 newt kernel: ieee80211 phy0: Atheros AR9462 Rev:2 mem=0xffffc90000600000, irq=16
May 13 14:25:25 newt kernel: __add_probed_i2c_device failed to register device 1-4a
May 13 14:25:25 newt kernel: iTCO_vendor_support: vendor-support=0
May 13 14:25:25 newt kernel: iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
May 13 14:25:25 newt kernel: iTCO_wdt: Found a Lynx Point_LP TCO device (Version=2, TCOBASE=0x1060)
May 13 14:25:25 newt kernel: iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
May 13 14:25:25 newt kernel: __add_probed_i2c_device failed to register device 1-4a
May 13 14:25:25 newt kernel: tpm_inf_pnp 00:08: Found TPM with ID IFX0102
May 13 14:25:25 newt kernel: usb 1-4: string descriptor 0 read error: -22
May 13 14:25:25 newt kernel: usb 1-4: New USB device found, idVendor=0489, idProduct=e056
May 13 14:25:25 newt kernel: usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
May 13 14:25:25 newt kernel: __add_probed_i2c_device failed to register device 1-4a
May 13 14:25:25 newt kernel: chromeos_laptop_probe: Ran out of tries for device.
May 13 14:25:25 newt kernel: cfg80211: World regulatory domain updated:
May 13 14:25:25 newt kernel: cfg80211:  DFS Master region: unset
May 13 14:25:25 newt kernel: cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
May 13 14:25:25 newt kernel: cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
May 13 14:25:25 newt kernel: cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
May 13 14:25:25 newt kernel: cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
May 13 14:25:25 newt kernel: cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
May 13 14:25:25 newt kernel: cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
May 13 14:25:25 newt kernel: cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
May 13 14:25:25 newt kernel: cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
May 13 14:25:25 newt kernel: cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
May 13 14:25:25 newt kernel: Switched to clocksource tsc
May 13 14:25:25 newt kernel: media: Linux media interface: v0.10
May 13 14:25:25 newt kernel: hidraw: raw HID events driver (C) Jiri Kosina
May 13 14:25:25 newt kernel: Linux video capture interface: v2.00
May 13 14:25:25 newt kernel: usbcore: registered new interface driver usbhid
May 13 14:25:25 newt kernel: usbhid: USB HID core driver
May 13 14:25:25 newt kernel: input: Logitech USB Laser Mouse as /devices/pci0000:00/0000:00:14.0/usb1/1-5/1-5:1.0/0003:046D:C062.0001/input/input11
May 13 14:25:25 newt kernel: hid-generic 0003:046D:C062.0001: input,hidraw0: USB HID v1.10 Mouse [Logitech USB Laser Mouse] on usb-0000:00:14.0-5/input0
May 13 14:25:25 newt kernel: uvcvideo: Found UVC 1.00 device HD WebCam (1bcf:2c67)
May 13 14:25:25 newt kernel: input: HD WebCam as /devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3:1.0/input/input12
May 13 14:25:25 newt kernel: usbcore: registered new interface driver uvcvideo
May 13 14:25:25 newt kernel: USB Video Class driver (1.1.1)
May 13 14:25:25 newt kernel: input: Cypress APA Trackpad (cyapa) as /devices/pci0000:00/0000:00:15.1/i2c-0/0-0067/input/input13
May 13 14:25:25 newt kernel: Console: switching to colour frame buffer device 170x48
May 13 14:25:25 newt kernel: i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
May 13 14:25:25 newt kernel: i915 0000:00:02.0: registered panic notifier
May 13 14:25:25 newt systemd-udevd[1149]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt kernel: Adding 4069372k swap on /dev/sda5.  Priority:-1 extents:1 across:4069372k SSFS
May 13 14:25:25 newt systemd-udevd[1156]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1159]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1165]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1163]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt kernel: input: HDA Intel HDMI HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:03.0/sound/card0/input14
May 13 14:25:25 newt kernel: input: HDA Intel HDMI HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:03.0/sound/card0/input15
May 13 14:25:25 newt kernel: input: HDA Intel HDMI HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:03.0/sound/card0/input16
May 13 14:25:25 newt cron[1164]: (CRON) INFO (pidfile fd = 3)
May 13 14:25:25 newt cron[1164]: (CRON) INFO (Running @reboot jobs)
May 13 14:25:25 newt systemd-udevd[1167]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1168]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1172]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1173]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1169]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1174]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1175]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1176]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1170]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1171]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1179]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1180]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt anacron[1181]: Anacron 2.3 started on 2015-05-13
May 13 14:25:25 newt anacron[1181]: Normal exit (0 jobs run)
May 13 14:25:25 newt acpi-support[1190]: Enabling power management...done.
May 13 14:25:25 newt sshd[1178]: Server listening on 0.0.0.0 port 22.
May 13 14:25:25 newt sshd[1178]: Server listening on :: port 22.
May 13 14:25:25 newt irqbalance[1193]: Starting SMP IRQ Balancer: irqbalance.
May 13 14:25:25 newt avahi-daemon[1196]: Found user 'avahi' (UID 117) and group 'avahi' (GID 127).
May 13 14:25:25 newt avahi-daemon[1196]: Successfully dropped root privileges.
May 13 14:25:25 newt avahi-daemon[1196]: avahi-daemon 0.6.31 starting up.
May 13 14:25:25 newt ModemManager[1183]: <info>  ModemManager (version 1.4.0) starting in system bus...
May 13 14:25:25 newt avahi-daemon[1196]: Successfully called chroot().
May 13 14:25:25 newt avahi-daemon[1196]: Successfully dropped remaining capabilities.
May 13 14:25:25 newt avahi-daemon[1196]: No service file found in /etc/avahi/services.
May 13 14:25:25 newt avahi-daemon[1196]: Network interface enumeration completed.
May 13 14:25:25 newt avahi-daemon[1196]: Registering HINFO record with values 'X86_64'/'LINUX'.
May 13 14:25:25 newt avahi-daemon[1196]: Server startup complete. Host name is newt.local. Local service cookie is 1365278672.
May 13 14:25:25 newt saned[1209]: saned disabled; edit /etc/default/saned.
May 13 14:25:25 newt dbus[1199]: [system] Activating via systemd: service name='org.freedesktop.PolicyKit1' unit='polkitd.service'
May 13 14:25:25 newt NetworkManager[1182]: <info> NetworkManager (version 0.9.10.0) is starting...
May 13 14:25:25 newt NetworkManager[1182]: <info> Read config: /etc/NetworkManager/NetworkManager.conf
May 13 14:25:25 newt NetworkManager[1182]: <info> WEXT support is enabled
May 13 14:25:25 newt dbus[1199]: [system] Activating via systemd: service name='org.freedesktop.ColorManager' unit='colord.service'
May 13 14:25:25 newt systemd-logind[1185]: New seat seat0.
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event5 (Power Button)
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event6 (Video Bus)
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event2 (Power Button)
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event1 (Lid Switch)
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event3 (Sleep Button)
May 13 14:25:25 newt systemd-logind[1185]: Watching system buttons on /dev/input/event4 (Sleep Button)
May 13 14:25:25 newt systemd-udevd[1234]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt colord[1225]: Using mapping database file /var/lib/colord/mapping.db
May 13 14:25:25 newt colord[1225]: Using device database file /var/lib/colord/storage.db
May 13 14:25:25 newt colord[1225]: Using profile database file /var/lib/colord/storage.db
May 13 14:25:25 newt colord[1225]: loaded plugin libcd_plugin_sane.so
May 13 14:25:25 newt colord[1225]: loaded plugin libcd_plugin_scanner.so
May 13 14:25:25 newt polkitd[1226]: started daemon version 0.105 using authority implementation `local' version `0.105'
May 13 14:25:25 newt dbus[1199]: [system] Successfully activated service 'org.freedesktop.PolicyKit1'
May 13 14:25:25 newt colord[1225]: loaded plugin libcd_plugin_camera.so
May 13 14:25:25 newt colord[1225]: Daemon ready for requests
May 13 14:25:25 newt dbus[1199]: [system] Successfully activated service 'org.freedesktop.ColorManager'
May 13 14:25:25 newt NetworkManager[1182]: <info> init!
May 13 14:25:25 newt NetworkManager[1182]: <info> update_system_hostname
May 13 14:25:25 newt NetworkManager[1182]: <info>       interface-parser: parsing file /etc/network/interfaces
May 13 14:25:25 newt NetworkManager[1182]: <info>       interface-parser: finished parsing file /etc/network/interfaces
May 13 14:25:25 newt NetworkManager[1182]: <info> management mode: unmanaged
May 13 14:25:25 newt NetworkManager[1182]: <info> devices added (path: /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/net/wlan0, iface: wlan0)
May 13 14:25:25 newt NetworkManager[1182]: <info> device added (path: /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/net/wlan0, iface: wlan0): no ifupdown configuration found.
May 13 14:25:25 newt NetworkManager[1182]: <info> devices added (path: /sys/devices/virtual/net/lo, iface: lo)
May 13 14:25:25 newt NetworkManager[1182]: <info> device added (path: /sys/devices/virtual/net/lo, iface: lo): no ifupdown configuration found.
May 13 14:25:25 newt NetworkManager[1182]: <info> end _init.
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded plugin ifupdown: (C) 2008 Canonical Ltd.  To report bugs please use the NetworkManager mailing list.
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded plugin keyfile: (c) 2007 - 2013 Red Hat, Inc.  To report bugs please use the NetworkManager mailing list.
May 13 14:25:25 newt NetworkManager[1182]: <info> (8982688) ... get_connections.
May 13 14:25:25 newt NetworkManager[1182]: <info> (8982688) ... get_connections (managed=false): return empty list.
May 13 14:25:25 newt lightdm[1239]: ** (lightdm:1239): WARNING **: Error getting user list from org.freedesktop.Accounts: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.Accounts was not provided by any .service files
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/AndroidAP
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/Milt's Stop & Eat
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/92QBF
May 13 14:25:25 newt systemd-udevd[1252]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1253]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/linksys
May 13 14:25:25 newt systemd-udevd[1254]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt systemd-udevd[1255]: failed to execute '/lib/udev/socket:@/org/freedesktop/hal/udev_event' 'socket:@/org/freedesktop/hal/udev_event': No such file or directory
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/Moab Information Center
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/GrandCountyLibrary
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/Dave's Corner Market
May 13 14:25:25 newt NetworkManager[1182]: <info> new connection /etc/NetworkManager/system-connections/Courthouse Wash and Clean
May 13 14:25:25 newt acpid[1216]: starting up with netlink and the input layer
May 13 14:25:25 newt NetworkManager[1182]: <info> get unmanaged devices count: 0
May 13 14:25:25 newt acpid[1216]: 27 rules loaded
May 13 14:25:25 newt acpid[1216]: waiting for events: event logging is off
May 13 14:25:25 newt NetworkManager[1182]: <info> monitoring kernel firmware directory '/lib/firmware'.
May 13 14:25:25 newt NetworkManager[1182]: <info> monitoring ifupdown state file '/run/network/ifstate'.
May 13 14:25:25 newt NetworkManager[1182]: <info> rfkill0: found WiFi radio killswitch (at /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/ieee80211/phy0/rfkill0) (driver ath9k)
May 13 14:25:25 newt NetworkManager[1182]: <info> WiFi hardware radio set enabled
May 13 14:25:25 newt NetworkManager[1182]: <info> WWAN hardware radio set enabled
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-bluetooth.so
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wifi.so
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-adsl.so
May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wwan.so
May 13 14:25:25 newt NetworkManager[1182]: <info> WiFi enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> WWAN enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> WiMAX enabled by radio killswitch; enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> Networking is enabled by state file
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): link connected
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): carrier is ON
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): new Generic device (driver: 'unknown' ifindex: 1)
May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): exported as /org/freedesktop/NetworkManager/Devices/0
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): using nl80211 for WiFi device control
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): driver supports Access Point (AP) mode
May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): new 802.11 WiFi device (driver: 'ath9k' ifindex: 2)
May 13 14:25:25 newt kernel: random: nonblocking pool is initialized
May 13 14:25:25 newt kernel: BUG: rwlock bad magic on CPU#1, NetworkManager/1182, ffff880074862918
May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862930 ffffffff815628c6 ffff880074862918
May 13 14:25:25 newt kernel:  ffffffff810b6594 ffff880074862900 ffffffffa05a941b 0000000000000001
May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862900 ffff880074862900 ffff880071e50740
May 13 14:25:25 newt kernel: Call Trace:
May 13 14:25:25 newt kernel:  [<ffffffff815628c6>] ? dump_stack+0x40/0x50
May 13 14:25:25 newt kernel:  [<ffffffff810b6594>] ? do_raw_read_lock+0x34/0x50
May 13 14:25:25 newt kernel:  [<ffffffffa05a941b>] ? tpt_trig_timer+0xdb/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
May 13 14:25:25 newt kernel: BUG: unable to handle kernel paging request at ffffffffffffff48
May 13 14:25:25 newt kernel: IP: [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
May 13 14:25:25 newt kernel: PGD 1810067 PUD 1812067 PMD 0 
May 13 14:25:25 newt kernel: Oops: 0000 [#1] SMP 
May 13 14:25:25 newt kernel: Modules linked in: binfmt_misc snd_hda_codec_hdmi uvcvideo hid_generic videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common usbhid videodev hid media cyapatp crc_itu_t tpm_infineon iTCO_wdt iTCO_vendor_support arc4 ath9k ath9k_common ath9k_hw x86_pkg_temp_thermal intel_powerclamp intel_rapl iosf_mbi coretemp kvm_intel kvm ath mac80211 crct10dif_pclmul crc32_pclmul chromeos_laptop crc32c_intel ghash_clmulni_intel cryptd evdev cfg80211 serio_raw pcspkr i915 i2c_i801 tpm_tis ac tpm battery snd_hda_codec_realtek snd_hda_codec_generic ath3k snd_hda_intel btusb snd_hda_codec btintel i2c_algo_bit drm_kms_helper video bluetooth snd_hwdep snd_hda_core drm snd_pcm button processor rfkill snd_timer lpc_ich shpchp snd mfd_core i2c_designware_pci i2c_designware_cor
 e i2c_core soundcore fuse
May 13 14:25:25 newt kernel:  autofs4 ext4 crc16 mbcache jbd2 sg sd_mod fan ahci libahci thermal sdhci_acpi sdhci mmc_core thermal_sys xhci_pci xhci_hcd usbcore libata scsi_mod usb_common
May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
May 13 14:25:25 newt kernel: task: ffff88003529a250 ti: ffff880035590000 task.ti: ffff880035590000
May 13 14:25:25 newt kernel: RIP: 0010:[<ffffffff810d3075>]  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
May 13 14:25:25 newt kernel: RSP: 0018:ffff8800355936e8  EFLAGS: 00010296
May 13 14:25:25 newt kernel: RAX: 0000000000000000 RBX: ffffffffffffff30 RCX: 0000000000000006
May 13 14:25:25 newt kernel: RDX: ffff880035593780 RSI: ffff880035593720 RDI: ffffffffffffff48
May 13 14:25:25 newt kernel: RBP: ffff880035593778 R08: 000000000000000a R09: 00000000fffffffe
May 13 14:25:25 newt kernel: R10: 0000000000000296 R11: 0000000000000002 R12: ffffffffffffff48
May 13 14:25:25 newt kernel: R13: ffff880035593720 R14: 0000000000000001 R15: ffff880074b90a60
May 13 14:25:25 newt kernel: FS:  00007f00b64ea8c0(0000) GS:ffff880100300000(0000) knlGS:0000000000000000
May 13 14:25:25 newt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
May 13 14:25:25 newt kernel: CR2: ffffffffffffff48 CR3: 00000000715b5000 CR4: 00000000000407e0
May 13 14:25:25 newt kernel: Stack:
May 13 14:25:25 newt kernel:  0000000000000000 ffffffffffffff30 ffff880035593778 ffff880035593780
May 13 14:25:25 newt kernel:  0000000000000000 ffffffff810d429c 0000000000000000 0000000000000001
May 13 14:25:25 newt kernel:  ffff880074b90a60 ffffffffffffff30 ffff880035593778 ffffffff810d432a
May 13 14:25:25 newt kernel: Call Trace:
May 13 14:25:25 newt kernel:  [<ffffffff810d429c>] ? try_to_del_timer_sync+0x1c/0x60
May 13 14:25:25 newt kernel:  [<ffffffff810d432a>] ? del_timer_sync+0x4a/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8143e61b>] ? led_blink_set+0x1b/0x40
May 13 14:25:25 newt kernel:  [<ffffffffa05a9440>] ? tpt_trig_timer+0x100/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
May 13 14:25:25 newt kernel: Code: 1a 83 e2 3f e8 9d fc ff ff e9 e3 fd ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 41 55 41 54 49 89 f5 55 53 49 89 fc 48 83 ec 08 <49> 8b 1c 24 48 89 dd 48 83 e5 fc 74 31 48 89 ef e8 86 61 49 00 
May 13 14:25:25 newt kernel: RIP  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60

--OgqxwSJOaUobr8KG--
