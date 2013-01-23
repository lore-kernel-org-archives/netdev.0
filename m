From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Wed, 23 Jan 2013 18:12:38 +0200
Message-ID: <20130123161238.GE8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:59939 "EHLO
	vulpes-int.media.sonera.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756245Ab3AWRCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 12:02:32 -0500
Received: from smtp.tele.fi (smtp.tele.fi [192.89.123.25])
	by vulpes-int.media.sonera.net (Postfix) with ESMTP id EBE9A3B76
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 18:13:11 +0200 (EET)
Received: from ydin.reaktio.net (reaktio.net [194.89.68.22])
	by smtp.tele.fi (Postfix) with ESMTP id D3F2715FC
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 18:12:39 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My laptop running Fedora 17 randomly crashes when using wfica (Citrix Receiver / ICA Client) 
proprietary closed source client for accessing remote desktop server. 
wfica is running as a normal user, so it shouldn't be able to cause a kernel crash. 

Crashes seem to happen most often when I use either wlan- or 3G mobile data Internet connection. 
These kernel crashes happen ramdomly, often 1-2 times a week. 
What usually happens is that I notice the Internet connection has died, 
and when I check the kernel dmesg I'm seeing the traceback. 
At this point I'm still able to use the gnome desktop for maybe 1-5 minutes, 
but applications start to fail one by one, and finally everything just halts 
and I need to power cycle the laptop. 

Without wfica the system is perfectly stable. I've been running memtest86+ for 2 days without errors. 
I've seen these crashes happening with multiple (all?) Fedora 17 Linux 3.6.x kernel versions.
Currently I'm running Linux 3.6.11-5.fc17.x86_64. Laptop is Lenovo T430.

I reported this crash also to Fedora 17 bugzilla: 
https://bugzilla.redhat.com/show_bug.cgi?id=903273

Kernel crash traceback:

[11056.124003] BUG: soft lockup - CPU#2 stuck for 22s! [wfica:2232]
[11056.124008] Modules linked in: xts gf128mul dm_crypt fuse lockd sunrpc rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_state nf_conntrack ip6_tables btusb bluetooth arc4 snd_hda_codec_realtek iwldvm uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev cdc_acm snd_hda_intel snd_hda_codec snd_hwdep mac80211 media snd_seq snd_seq_device snd_pcm thinkpad_acpi snd_page_alloc coretemp snd_timer kvm_intel kvm e1000e iwlwifi cdc_wdm cdc_ncm usbnet mii iTCO_wdt iTCO_vendor_support mei lpc_ich snd mfd_core cfg80211 i2c_i801 soundcore rfkill microcode uinput crc32c_intel ghash_clmulni_intel sdhci_pci sdhci mmc_core wmi i915 video i2c_algo_bit drm_kms_helper drm i2c_core
[11056.124078] CPU 2 
[11056.124083] Pid: 2232, comm: wfica Not tainted 3.6.11-1.fc17.x86_64 #1 LENOVO 2349H2G/2349H2G
[11056.124086] RIP: 0010:[<ffffffff8156d3a0>]  [<ffffffff8156d3a0>] tcp_slow_start+0x70/0xa0
[11056.124097] RSP: 0018:ffff8802c384ba18  EFLAGS: 00200246
[11056.124099] RAX: 0000000000000000 RBX: ffffffff8106c05b RCX: 000000003db56a41
[11056.124102] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8802c394c600
[11056.124104] RBP: ffff8802c384ba18 R08: 000000000000050e R09: 0000000000000000
[11056.124106] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88030cd98000
[11056.124108] R13: ffff8802c394c978 R14: ffff88030cd98000 R15: 0000000000013cc0
[11056.124111] FS:  0000000000000000(0000) GS:ffff88031e280000(0063) knlGS:00000000f6314b40
[11056.124113] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[11056.124115] CR2: 00007fbf0e912000 CR3: 00000002c3b5b000 CR4: 00000000001407e0
[11056.124117] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[11056.124120] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[11056.124122] Process wfica (pid: 2232, threadinfo ffff8802c384a000, task ffff8802c9d85c40)
[11056.124124] Stack:
[11056.124126]  ffff8802c384ba48 ffffffff8159624b ffff8802c384ba48 0000000000000006
[11056.124131]  0000000000000004 0000000000000003 ffff8802c384bb08 ffffffff8155f5e2
[11056.124135]  ffff88031e293cc0 ffff88020000050e 00000000e4434980 0000000000000000
[11056.124139] Call Trace:
[11056.124148]  [<ffffffff8159624b>] bictcp_cong_avoid+0x5b/0x3c0
[11056.124153]  [<ffffffff8155f5e2>] tcp_ack+0x572/0x1210
[11056.124158]  [<ffffffff815604fe>] tcp_rcv_established+0x27e/0x8f0
[11056.124163]  [<ffffffff8156a584>] tcp_v4_do_rcv+0x1b4/0x4c0
[11056.124170]  [<ffffffff81552bc7>] tcp_prequeue_process+0x67/0xb0
[11056.124174]  [<ffffffff815576d7>] tcp_recvmsg+0x9d7/0xd80
[11056.124179]  [<ffffffff8157cd7b>] inet_recvmsg+0x6b/0x80
[11056.124186]  [<ffffffff814f9ed2>] sock_aio_read.part.10+0x142/0x170
[11056.124193]  [<ffffffff8108f05c>] ? ttwu_do_wakeup+0x2c/0xf0
[11056.124197]  [<ffffffff814f9f25>] sock_aio_read+0x25/0x40
[11056.124204]  [<ffffffff8118fa77>] do_sync_read+0xa7/0xe0
[11056.124210]  [<ffffffff8119044d>] vfs_read+0x15d/0x180
[11056.124214]  [<ffffffff811904ba>] sys_read+0x4a/0x90
[11056.124220]  [<ffffffff816286e6>] sysenter_dispatch+0x7/0x21
[11056.124222] Code: 01 f6 39 b7 f0 05 00 00 0f 43 c1 03 87 b8 05 00 00 31 c9 c7 87 f0 05 00 00 00 00 00 00 39 d0 89 87 b8 05 00 00 72 13 0f 1f 40 00 <29> d0 83 c1 01 39 d0 73 f7 89 87 b8 05 00 00 8b 87 bc 05 00 00


Any ideas? 

Thanks,

-- Pasi
