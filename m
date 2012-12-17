From: Benjamin LaHaise <bcrl@kvack.org>
Subject: 3.6.10 tcp crash - net/ipv4/tcp.c:1667 & tcp.c:1655
Date: Mon, 17 Dec 2012 12:41:45 -0500
Message-ID: <20121217174145.GH22452@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:55797 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753654Ab2LQRlq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 12:41:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I just hit the following crash with Fedora's 3.6.10-2.fc17 kernel.  I don't 
have time to debug this myself at the moment, but can certainly test patches 
or provide more info as needed.  I wasn't doing anything unusual at the time, 
just reading email/web browsing.  I believe the network driver in use was 
ipheth for tethering to an iPhone 4S over USB (the other driver being used 
intermittently on this laptop is iwlwifi).  Any ideas?

		-ben
-- 
"Thought is the essence of where you are now."

Dec 17 12:28:40 lappy kernel: [ 4044.846922] ------------[ cut here ]------------
Dec 17 12:28:40 lappy kernel: [ 4044.846931] WARNING: at net/ipv4/tcp.c:1667 tcp_recvmsg+0xc25/0xd80()
Dec 17 12:28:40 lappy kernel: [ 4044.846933] Hardware name: HP Pavilion dv7 Notebook PC
Dec 17 12:28:40 lappy kernel: [ 4044.846935] recvmsg bug 2: copied DE50E114 seq 90D65A21 rcvnxt DE50E114 fl 0
Dec 17 12:28:40 lappy kernel: [ 4044.846936] Modules linked in: fuse lockd sunrpc rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack btusb bluetooth snd_hda_codec_hdmi arc4 iwldvm ipheth mac80211 iTCO_wdt iTCO_vendor_support hp_wmi sparse_keymap uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev media coretemp microcode i7core_edac edac_core snd_hda_codec_idt i2c_i801 ir_lirc_codec lirc_dev ir_mce_kbd_decoder ir_sanyo_decoder iwlwifi snd_hda_intel ir_sony_decoder snd_hda_codec cfg80211 snd_hwdep jmb38x_ms snd_seq snd_seq_device ir_jvc_decoder lpc_ich memstick mfd_core ir_rc6_decoder snd_pcm r8169 mii rfkill ir_rc5_decoder ir_nec_decoder snd_page_alloc snd_timer snd soundcore vhost_net t
 un macvtap macvlan rc_rc6_mce kvm ene_ir rc_core hp_accel lis3lv02d input_polldev uinput crc32c_intel sdhci_pci firewire_ohci sdhci firewire_core mmc_core crc_itu_t nouveau mxm_wmi wmi video i2c_algo_bit drm_kms_helper ttm drm
Dec 17 12:28:40 lappy kernel: i2c_core
Dec 17 12:28:40 lappy kernel: [ 4044.847025] Pid: 2080, comm: Socket Thread Tainted: G        W    3.6.10-2.fc17.x86_64 #1
Dec 17 12:28:40 lappy kernel: [ 4044.847030] Call Trace:
Dec 17 12:28:40 lappy kernel: [ 4044.847035]  [<ffffffff8105c8ef>] warn_slowpath_common+0x7f/0xc0
Dec 17 12:28:40 lappy kernel: [ 4044.847038]  [<ffffffff8105c9e6>] warn_slowpath_fmt+0x46/0x50
Dec 17 12:28:40 lappy kernel: [ 4044.847040]  [<ffffffff815576c5>] tcp_recvmsg+0xc25/0xd80
Dec 17 12:28:40 lappy kernel: [ 4044.847043]  [<ffffffff8157cb1b>] inet_recvmsg+0x6b/0x80
Dec 17 12:28:40 lappy kernel: [ 4044.847047]  [<ffffffff814fa707>] sock_recvmsg+0xd7/0x110
Dec 17 12:28:40 lappy kernel: [ 4044.847051]  [<ffffffff811a2fd0>] ? __pollwait+0xf0/0xf0
Dec 17 12:28:40 lappy kernel: [ 4044.847053]  [<ffffffff811a2fd0>] ? __pollwait+0xf0/0xf0
Dec 17 12:28:40 lappy kernel: [ 4044.847055]  [<ffffffff814fc11f>] sys_recvfrom+0xef/0x170
Dec 17 12:28:40 lappy kernel: [ 4044.847058]  [<ffffffff811a2fd0>] ? __pollwait+0xf0/0xf0
Dec 17 12:28:40 lappy kernel: [ 4044.847062]  [<ffffffff810d868c>] ? __audit_syscall_entry+0xcc/0x300
Dec 17 12:28:40 lappy kernel: [ 4044.847064]  [<ffffffff810d8cac>] ? __audit_syscall_exit+0x3ec/0x450
Dec 17 12:28:40 lappy kernel: [ 4044.847067]  [<ffffffff816270e9>] system_call_fastpath+0x16/0x1b
Dec 17 12:28:40 lappy kernel: [ 4044.847068] ---[ end trace 28d4acf1e1aa598d ]---
Dec 17 12:28:40 lappy kernel: [ 4044.847069] ------------[ cut here ]------------
Dec 17 12:28:40 lappy kernel: [ 4044.847071] WARNING: at net/ipv4/tcp.c:1655 tcp_recvmsg+0x671/0xd80()
Dec 17 12:28:40 lappy kernel: [ 4044.847072] Hardware name: HP Pavilion dv7 Notebook PC
Dec 17 12:28:40 lappy kernel: [ 4044.847073] recvmsg bug: copied DE50E114 seq 0 rcvnxt DE50E114 fl 0
Dec 17 12:28:40 lappy kernel: [ 4044.847074] Modules linked in: fuse lockd sunrpc rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack btusb bluetooth snd_hda_codec_hdmi arc4 iwldvm ipheth mac80211 iTCO_wdt iTCO_vendor_support hp_wmi sparse_keymap uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev media coretemp microcode i7core_edac edac_core snd_hda_codec_idt i2c_i801 ir_lirc_codec lirc_dev ir_mce_kbd_decDec 17 12:29:32 lappy kernel: imklog 5.8.10, log source = /proc/kmsg started.
