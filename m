From: Andi Kleen <andi@firstfloor.org>
Subject: ip_rt_bug route.c:1677 in 3.0
Date: Tue, 6 Sep 2011 13:45:45 -0700
Message-ID: <20110906204545.GA29628@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31654 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150Ab1IFUpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 16:45:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FYI,

My 3.0 workstation just spew:

I wonder if a application could have caused this?

ip_rt_bug: 10.7.201.108 -> 255.255.255.255, ?
------------[ cut here ]------------
WARNING: at /home/ak/lsrc/git/linux-2.6/net/ipv4/route.c:1677 ip_rt_bug+0x5f/0x70()
Hardware name: ...
Modules linked in: vfat fat nls_utf8 udf ses enclosure nfs lockd fscache auth_rpcgss nfs_acl fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 kvm_intel kvm uinput snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm iTCO_wdt microcode e1000 snd_timer snd soundcore broadcom iTCO_vendor_support tg3 i7core_edac edac_core snd_page_alloc i2c_i801 dcdbas serio_raw joydev pcspkr firewire_ohci firewire_core crc_itu_t usb_storage radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Pid: 28530, comm: xsane Not tainted 3.0.0+ #15
Call Trace:
 [<ffffffff810510ef>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8105114a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff814946cf>] ip_rt_bug+0x5f/0x70
 [<ffffffff8149f149>] ip_local_out+0x29/0x30
 [<ffffffff814a047b>] ip_send_skb+0x1b/0x70
 [<ffffffff814c25fa>] udp_send_skb+0x11a/0x3b0
 [<ffffffff8149d3d0>] ? ip_setup_cork+0x170/0x170
 [<ffffffff814c475c>] udp_sendmsg+0x37c/0x9b0
 [<ffffffff814c31b9>] ? udp_lib_get_port+0x2a9/0x3e0
 [<ffffffff81528d25>] ? _raw_spin_unlock_bh+0x15/0x20
 [<ffffffff81448ca3>] ? release_sock+0xe3/0x110
 [<ffffffff814ce214>] inet_sendmsg+0x64/0xb0
 [<ffffffff81443e19>] sock_sendmsg+0xe9/0x120
 [<ffffffff8111bb74>] ? handle_pte_fault+0x84/0x980
 [<ffffffff8112be91>] ? free_pages_and_swap_cache+0xb1/0xe0
 [<ffffffff812750cd>] ? cpumask_any_but+0x2d/0x40
 [<ffffffff814464d1>] ? move_addr_to_kernel+0x71/0x80
 [<ffffffff81446f39>] sys_sendto+0x139/0x190
 [<ffffffff8144b20e>] ? sock_setsockopt+0x1ae/0x790
 [<ffffffff811511ed>] ? fd_install+0x3d/0x70
 [<ffffffff814471f3>] ? sys_setsockopt+0xb3/0xc0
 [<ffffffff8153092b>] system_call_fastpath+0x16/0x1b
---[ end trace ada1d01fefb0d73c ]---
ip_rt_bug: 10.7.201.108 -> 255.255.255.255, ?
------------[ cut here ]------------
WARNING: at /home/ak/lsrc/git/linux-2.6/net/ipv4/route.c:1677 ip_rt_bug+0x5f/0x70()
Hardware name: ...
Modules linked in: vfat fat nls_utf8 udf ses enclosure nfs lockd fscache auth_rpcgss nfs_acl fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 kvm_intel kvm uinput snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm iTCO_wdt microcode e1000 snd_timer snd soundcore broadcom iTCO_vendor_support tg3 i7core_edac edac_core snd_page_alloc i2c_i801 dcdbas serio_raw joydev pcspkr firewire_ohci firewire_core crc_itu_t usb_storage radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Pid: 28530, comm: xsane Tainted: G        W   3.0.0+ #15
Call Trace:
 [<ffffffff810510ef>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8105114a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff814946cf>] ip_rt_bug+0x5f/0x70
 [<ffffffff8149f149>] ip_local_out+0x29/0x30
 [<ffffffff814a047b>] ip_send_skb+0x1b/0x70
 [<ffffffff814c25fa>] udp_send_skb+0x11a/0x3b0
 [<ffffffff8149d3d0>] ? ip_setup_cork+0x170/0x170
 [<ffffffff814c475c>] udp_sendmsg+0x37c/0x9b0
 [<ffffffff814c31b9>] ? udp_lib_get_port+0x2a9/0x3e0
 [<ffffffff81528d25>] ? _raw_spin_unlock_bh+0x15/0x20
 [<ffffffff81448ca3>] ? release_sock+0xe3/0x110
 [<ffffffff814ce214>] inet_sendmsg+0x64/0xb0
 [<ffffffff81443e19>] sock_sendmsg+0xe9/0x120
...


-- 
ak@linux.intel.com -- Speaking for myself only
