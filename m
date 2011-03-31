From: Dave Jones <davej@redhat.com>
Subject: appletalk oops.
Date: Thu, 31 Mar 2011 16:05:26 -0400
Message-ID: <20110331200525.GA17516@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759336Ab1CaUFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 16:05:37 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p2VK5bbM020521
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 16:05:37 -0400
Received: from gelk.kernelslacker.org (ovpn-113-129.phx2.redhat.com [10.3.113.129])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p2VK5ZsY027797
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 16:05:36 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.4/8.14.4) with ESMTP id p2VK5TkC020358
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 16:05:29 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.4/8.14.4/Submit) id p2VK5QAo020356
	for netdev@vger.kernel.org; Thu, 31 Mar 2011 16:05:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just hit this on current git head while fuzzing syscalls.
I suspect we need to check somewhere for null sock's being passed in from userspace
I'm not sure yet this is appletalk specific, or it belongs somewhere further up
in accept.

	Dave


[ 9264.494982] BUG: unable to handle kernel NULL pointer dereference at 000000000000004c
[ 9264.495660] IP: [<ffffffffa0593351>] sock_hold+0x9/0xf [appletalk]
[ 9264.495660] PGD 37a40067 PUD 860bd067 PMD 0 
[ 9264.495660] Oops: 0002 [#1] SMP 
[ 9264.495660] last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_supply/BAT0/energy_full
[ 9264.495660] CPU 1 
[ 9264.495660] Modules linked in: tcp_lp nfnetlink can_bcm cmtp kernelcapi can_raw bnep hidp rfcomm rose ax25 af_key af_802154 atm pppoe pppox ppp_generic slhc irda crc_ccitt decnet rds can phonet appletalk ipx p8022 psnap llc p8023 sctp libcrc32c tun nfs fscache fuse nfsd lockd nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 uinput arc4 iwlagn snd_hda_codec_hdmi mac80211 snd_hda_codec_idt snd_usb_audio snd_hda_intel snd_hda_codec btusb bluetooth snd_seq uvcvideo snd_pcm snd_hwdep snd_usbmidi_lib dell_wmi zaurus cfg80211 sparse_keymap videodev snd_rawmidi dell_laptop cdc_ether snd_seq_device v4l2_compat_ioctl32 usbnet snd_timer dcdbas mii microcode cdc_acm cdc_wdm snd tg3 iTCO_wdt joydev 
 i2c_i801 pcspkr iTCO_vendor_support rfkill soundcore snd_page_alloc wmi i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[ 9264.495660] 
[ 9264.495660] Pid: 3522, comm: trinity Not tainted 2.6.38-09065-g89078d5-dirty #6 Dell Inc. Adamo 13   /0N70T0
[ 9264.495660] RIP: 0010:[<ffffffffa0593351>]  [<ffffffffa0593351>] sock_hold+0x9/0xf [appletalk]
[ 9264.495660] RSP: 0018:ffff88009e699dc8  EFLAGS: 00010296
[ 9264.523112] RAX: ffffffffa0596140 RBX: 0000000000000000 RCX: 0000000000000001
[ 9264.523112] RDX: ffff8800b6f76010 RSI: ffff8800b6f76000 RDI: 0000000000000000
[ 9264.523112] RBP: ffff88009e699dc8 R08: 0000000000000000 R09: 0000000000000000
[ 9264.523112] R10: ffff8800b6f76010 R11: 0000000000002000 R12: ffff8800a47f9080
[ 9264.523112] R13: ffff8800a47f90b0 R14: ffff8800a47f90b0 R15: ffff8800b8b097e0
[ 9264.523112] FS:  00007f4053fe8720(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
[ 9264.523112] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 9264.523112] CR2: 000000000000004c CR3: 0000000086324000 CR4: 00000000000406e0
[ 9264.523112] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 9264.523112] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 9264.523112] Process trinity (pid: 3522, threadinfo ffff88009e698000, task ffff880109a38000)
[ 9264.523112] Stack:
[ 9264.523112]  ffff88009e699df8 ffffffffa059454b 0000000000000000 ffff8800a47f9080
[ 9264.523112]  ffffffffa0597550 ffff8800a47f90b0 ffff88009e699e18 ffffffff81404a87
[ 9264.523112]  ffff8800b6f76000 0000000000000008 ffff88009e699e28 ffffffff81404b03
[ 9264.523112] Call Trace:
[ 9264.523112]  [<ffffffffa059454b>] atalk_release+0x21/0x15b [appletalk]
[ 9264.523112]  [<ffffffff81404a87>] sock_release+0x1f/0x74
[ 9264.523112]  [<ffffffff81404b03>] sock_close+0x27/0x2b
[ 9264.523112]  [<ffffffff8113f412>] fput+0x128/0x1f7
[ 9264.523112]  [<ffffffff814053de>] sys_accept4+0x19b/0x1cb
[ 9264.523112]  [<ffffffff814cdaf7>] ? schedule+0x6d9/0x70b
[ 9264.523112]  [<ffffffff8108811b>] ? trace_hardirqs_off_caller+0x33/0x90
[ 9264.523112]  [<ffffffff814d0339>] ? retint_swapgs+0x13/0x1b
[ 9264.523112]  [<ffffffff8108bdf5>] ? trace_hardirqs_on_caller+0x10b/0x12f
[ 9264.523112]  [<ffffffff810b09bd>] ? audit_syscall_entry+0x11c/0x148
[ 9264.523112]  [<ffffffff8126744e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 9264.523112]  [<ffffffff814d6bc2>] system_call_fastpath+0x16/0x1b
[ 9264.523112] Code: 75 e1 48 83 c3 08 48 81 fb 80 00 00 00 75 a5 48 c7 c7 10 70 59 a0 e8 bc c5 f3 e0 41 5a 5b c9 c3 90 90 55 48 89 e5 0f 1f 44 00 00 <f0> ff 47 4c c9 c3 55 48 89 e5 0f 1f 44 00 00 48 8b 97 88 02 00 
[ 9264.523112] RIP  [<ffffffffa0593351>] sock_hold+0x9/0xf [appletalk]
[ 9264.523112]  RSP <ffff88009e699dc8>
[ 9264.523112] CR2: 000000000000004c
[ 9264.592577] ---[ end trace f86d1c3c82ba221d ]---

